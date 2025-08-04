import json
import subprocess
import time
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

try:
    from aider.web_search import create_web_searcher
    WEB_SEARCH_AVAILABLE = True
except ImportError:
    WEB_SEARCH_AVAILABLE = False
    create_web_searcher = None

class GeniusAgent:
    """
    AI Agent that autonomously plans, codes, validates, and iterates on development tasks.
    
    This implements a sophisticated agent architecture where the AI acts with multiple phases:
    - Planning: Analyzes the codebase and creates a task graph
    - Editing/Code Generation: Generates and edits code based on planning
    - Code Execution/Validation: Runs tests, lints, and security scans
    - Web Search for Updates: Searches for additional context when needed
    - Feedback Loop: Uses validation results to improve next iteration
    """

    def __init__(self, coder, task=None, max_iterations=10, enable_web_search=True, 
                 enable_security_scan=True, planning_model=None):
        self.coder = coder
        self.task = task or "Analyze and improve the codebase"
        self.task_explicitly_provided = task is not None
        self.max_iterations = max_iterations
        self.enable_web_search = enable_web_search
        self.enable_security_scan = enable_security_scan
        self.planning_model = planning_model or coder.main_model
        
        # Initialize web searcher
        if WEB_SEARCH_AVAILABLE and create_web_searcher:
            self.web_searcher = create_web_searcher(print_error=coder.io.tool_error)
        else:
            self.web_searcher = None
        
        # Agent state
        self.current_iteration = 0
        self.task_graph = []
        self.completed_tasks = []
        self.failed_tasks = []
        self.context_memory = {}
        self.validation_results = {}
        
        # Phase trackers
        self.planning_complete = False
        self.needs_web_search = False
        self.last_error_context = None

    def log_agent_action(self, phase: str, action: str, reasoning: str, details: Optional[Dict] = None):
        """Enhanced logging for agent actions with structured data"""
        self.coder.io.tool_output(f"Genius Agent - Phase: {phase}")
        self.coder.io.tool_output(f"   Action: {action}")
        self.coder.io.tool_output(f"   Reasoning: {reasoning}")
        if details:
            for key, value in details.items():
                self.coder.io.tool_output(f"   {key}: {value}")
        self.coder.io.tool_output("")  # Add spacing

    def planning_phase(self) -> bool:
        """
        Advanced planning phase that uses LLM to analyze the repository and creates a dynamic task graph.
        """
        # Only prompt for user task if no task was explicitly provided
        if not self.task_explicitly_provided:
            user_task = self._get_task_from_user()
            if user_task:
                self.task = user_task
                self.task_explicitly_provided = True
                self.log_agent_action(
                    "Planning",
                    "User task received",
                    f"Updated task to: {self.task}"
                )
            else:
                # No task provided, cannot proceed
                self.log_agent_action(
                    "Planning",
                    "No task provided by user",
                    "Cannot proceed without a specific task"
                )
                return False
        
        # Force refresh the repository map FIRST to get current state
        if self.coder.repo_map:
            self.log_agent_action(
                "Planning",
                "Refreshing repository map",
                "Ensuring up-to-date view of current files and structure before analysis"
            )
            self.coder.get_repo_map(force_refresh=True)
        
        self.log_agent_action(
            "Planning", 
            "Analyzing repository structure and dependencies",
            "Building comprehensive understanding of codebase before making changes"
        )
        
        # Gather repository context (will use the refreshed repo map)
        repo_context = self._gather_repository_context()

        # Analyze current issues and opportunities
        issues = self._analyze_current_issues()
        
        # Use LLM-based planning to create intelligent task graph
        self.task_graph = self._llm_based_task_planning(repo_context, issues)

        # Store context for future reference
        self.context_memory['repo_analysis'] = repo_context
        self.context_memory['identified_issues'] = issues
        
        self.log_agent_action(
            "Planning",
            "LLM-generated task graph created",
            f"Generated {len(self.task_graph)} prioritized tasks using intelligent planning",
            {"tasks": [task["name"] for task in self.task_graph]}
        )
        
        self.planning_complete = True
        return len(self.task_graph) > 0

    def _get_task_from_user(self) -> Optional[str]:
        """Get a task description from the user via input prompt"""
        try:
            self.coder.io.tool_output("Genius Agent: A specific task is required to proceed.")
            self.coder.io.tool_output("Please describe what you'd like me to work on:")
            self.coder.io.tool_output("(Ctrl+C to cancel)")
            
            # Use the coder's IO to get user input
            user_input = input("\n> ").strip()
            
            if user_input:
                return user_input
            else:
                self.coder.io.tool_output("No task provided. Cannot proceed without a specific task.")
                return None
                
        except (KeyboardInterrupt, EOFError):
            self.coder.io.tool_output("\nTask input cancelled by user.")
            return None
        except Exception as e:
            self.log_agent_action(
                "Planning",
                "Failed to get user input",
                f"Error: {str(e)} - Cannot proceed without task"
            )
            return None

    def _gather_repository_context(self) -> Dict[str, Any]:
        """Gather comprehensive repository context"""
        context = {
            "files_in_chat": list(self.coder.abs_fnames),
            "readonly_files": list(self.coder.abs_read_only_fnames),
            "repo_map": None,
            "terminal_output": None,
            "git_status": None,
            "missing_files": []
        }
        
        # Get repository map and check for missing files
        if self.coder.repo_map:
            repo_map = self.coder.get_repo_map()  # Don't force refresh here since we already did it
            if repo_map:
                context["repo_map"] = repo_map
                
                # Check for files mentioned in repo map that don't actually exist
                import re
                # Extract file paths from repo map
                file_mentions = re.findall(r'(\S+\.(?:py|jac|js|ts|md|txt|json|yaml|yml))', str(repo_map))
                missing_files = []
                for file_path in file_mentions:
                    # Resolve relative paths
                    if not file_path.startswith('/'):
                        full_path = Path(self.coder.root) / file_path
                    else:
                        full_path = Path(file_path)
                    
                    if not full_path.exists():
                        missing_files.append(str(file_path))
                
                if missing_files:
                    context["missing_files"] = missing_files
                    self.log_agent_action(
                        "Planning", 
                        "Detected missing files from repo map", 
                        f"Found {len(missing_files)} files referenced but not present: {missing_files[:3]}..."
                    )
                
        # Get git status if available
        if self.coder.repo:
            try:
                git_status = self.coder.repo.get_dirty_files()
                context["git_status"] = git_status
            except Exception as e:
                self.log_agent_action("Planning", "Git status failed", str(e))
        
        return context

    def _analyze_current_issues(self) -> List[Dict[str, Any]]:
        """Analyze current issues in the codebase"""
        issues = []
        
        # Check for linting issues
        if self.coder.auto_lint and self.coder.abs_fnames:
            try:
                for fname in list(self.coder.abs_fnames):
                    lint_result = self.coder.linter.lint(fname)
                    if lint_result:
                        issues.append({
                            "type": "lint",
                            "file": fname,
                            "description": "Linting issues found",
                            "details": lint_result,
                            "priority": "medium"
                        })
            except Exception as e:
                self.log_agent_action("Planning", "Lint analysis failed", str(e))
        
        # Check for test failures
        if self.coder.test_cmd:
            try:
                test_result = self.coder.commands.cmd_test(self.coder.test_cmd)
                if test_result:  # cmd_test returns output on failure
                    issues.append({
                        "type": "test",
                        "description": "Test failures detected",
                        "details": test_result,
                        "priority": "high"
                    })
            except Exception as e:
                self.log_agent_action("Planning", "Test analysis failed", str(e))
        
        return issues

    def _create_task_graph(self, repo_context: Dict, issues: List[Dict]) -> List[Dict[str, Any]]:
        """Create a dynamic task graph based on analysis"""
        tasks = []
        
        # ALWAYS prioritize the main task first if it's not the default
        if self.task and self.task != "Analyze and improve the codebase":
            tasks.append({
                "name": self.task,
                "type": "feature_implementation",
                "priority": 1,
                "details": self.task
            })
        
        # Only add tasks for issues that might block the main task
        critical_issues = []
        for issue in issues:
            # Only include issues that are likely to affect new development
            if issue["type"] == "test" and issue.get("priority") == "high":
                critical_issues.append(issue)
            # Skip lint issues for the main task unless they're in files we need to work with
        
        for issue in critical_issues:
            if issue["type"] == "test":
                tasks.append({
                    "name": "Fix critical failing tests",
                    "type": "fix_tests", 
                    "priority": 2,  # Still secondary to main task
                    "details": issue["details"]
                })
        
        # Add code quality improvement tasks only if we don't have a specific main task
        if self.task == "Analyze and improve the codebase" and repo_context["files_in_chat"]:
            tasks.append({
                "name": "Improve code quality and documentation",
                "type": "improvement",
                "priority": 1,  # Only priority 1 when it IS the main task
                "details": "Review and improve code quality, add documentation where needed"
            })
        
        # Sort by priority (lower number = higher priority)
        tasks.sort(key=lambda x: x["priority"])
        
        return tasks

    def _llm_based_task_planning(self, repo_context: Dict, issues: List[Dict]) -> List[Dict[str, Any]]:
        """
        Use LLM to analyze the task and repository context to create an intelligent task plan.
        """
        self.log_agent_action(
            "LLM Planning",
            "Consulting planning model for intelligent task breakdown",
            f"Using {self.planning_model.name} to analyze task and create execution plan"
        )
        
        # Prepare context for the LLM
        planning_prompt = self._create_planning_prompt(repo_context, issues)
        
        # Debug: Show the planning prompt (truncated for readability)
        prompt_preview = planning_prompt[:500] + "..." if len(planning_prompt) > 500 else planning_prompt
        self.coder.io.tool_output(
            f"DEBUG: Planning prompt preview: {prompt_preview}"
        )
        
        try:
            # Get the planning response from the LLM using the model's send_completion method
            messages = [
                {"role": "system", "content": self._get_planning_system_prompt()},
                {"role": "user", "content": planning_prompt}
            ]
            
            # Use the model's simple_send_with_retries method for a straightforward completion
            planning_response = self.planning_model.simple_send_with_retries(messages)
            
            if planning_response:
                # Debug: Show the LLM response (truncated for readability)
                response_preview = (
                    planning_response[:500] + "..."
                    if len(planning_response) > 500
                    else planning_response
                )
                self.coder.io.tool_output(
                    f"DEBUG: LLM planning response preview: {response_preview}"
                )
                
                # Parse the LLM response to extract tasks
                tasks = self._parse_llm_planning_response(planning_response)
                
                self.log_agent_action(
                    "LLM Planning",
                    "Planning completed successfully",
                    f"LLM generated {len(tasks)} strategic tasks",
                    {"planning_response_length": len(planning_response)}
                )
                
                return tasks
            else:
                self.log_agent_action(
                    "LLM Planning",
                    "No response from planning model",
                    "Falling back to rule-based planning"
                )
                
        except Exception as e:
            self.log_agent_action(
                "LLM Planning",
                "Planning model failed",
                f"Error: {str(e)} - Falling back to rule-based planning"
            )
        
        # Fallback to original method if LLM planning fails
        return self._create_task_graph(repo_context, issues)

    def _get_planning_system_prompt(self) -> str:
        """Get the system prompt for the planning LLM"""
        return """You are an expert software development planning agent. Your job is to analyze a development task and codebase context to create an optimal execution plan.

            CRITICAL PRIORITY RULE: The user's main task should ALWAYS be the highest priority. All other tasks (fixing lint errors, missing files, etc.) are secondary unless they directly block the main task.

            You should:
            1. ALWAYS prioritize the user's main task as priority 1
            2. Break down the main task into smaller, manageable subtasks with priority 1-2
            3. Only include fixing existing issues (lint, tests) if they directly impact the main task
            4. Consider dependencies between tasks and order them logically
            5. Ensure tasks are specific and actionable
            6. For missing files that are not related to the main task, assign low priority (4-5) or exclude them
            7. When creating new files for the main task, focus on "feature_implementation" task types

            Respond with a JSON array of task objects. Each task should have:
            - "name": Clear, descriptive task name
            - "type": One of ["fix_tests", "fix_lint", "fix_security", "feature_implementation", "improvement", "refactor", "documentation"]
            - "priority": Integer (1=highest priority for main task, 2-3=supporting tasks, 4-5=maintenance/optional)
            - "details": Specific description of what needs to be done
            - "dependencies": Array of task names that must complete first (empty array if none)
            - "estimated_effort": "small", "medium", or "large"
            - "file": (optional) Specific file path if the task is file-specific

            IMPORTANT: 
            - The user's main task gets priority 1
            - Supporting tasks for the main task get priority 2-3
            - Existing code fixes only get priority 1-2 if they block the main task
            - Missing files unrelated to main task get priority 4-5 or are excluded

            Example response for "create a calculator":
            [
            {
                "name": "Create calculator.jac file with basic structure",
                "type": "feature_implementation", 
                "priority": 1,
                "details": "Create a new calculator.jac file implementing basic calculator functionality in Jac language",
                "dependencies": [],
                "estimated_effort": "medium"
            },
            {
                "name": "Implement arithmetic operations in calculator",
                "type": "feature_implementation",
                "priority": 2,
                "details": "Add basic arithmetic operations (add, subtract, multiply, divide) to the calculator",
                "dependencies": ["Create calculator.jac file with basic structure"],
                "estimated_effort": "medium"
            }
            ]"""

    def _create_planning_prompt(self, repo_context: Dict, issues: List[Dict]) -> str:
        """Create a comprehensive prompt for the planning LLM"""
        prompt_parts = [
            f"MAIN TASK (HIGHEST PRIORITY): {self.task}",
            "",
            "FOCUS: Create a plan that prioritizes completing the main task above all else.",
            "",
            "REPOSITORY CONTEXT:",
        ]
        
        # Add files in chat
        if repo_context.get("files_in_chat"):
            prompt_parts.append("Files currently being worked on:")
            for file in repo_context["files_in_chat"]:
                prompt_parts.append(f"  - {file}")
            prompt_parts.append("")
        
        # Add missing files information but emphasize they are low priority
        if repo_context.get("missing_files"):
            prompt_parts.append("Missing files (low priority unless needed for main task):")
            for file in repo_context["missing_files"][:3]:  # Limit to first 3 to reduce emphasis
                prompt_parts.append(f"  - {file}")
            if len(repo_context["missing_files"]) > 3:
                prompt_parts.append(f"  - ... and {len(repo_context['missing_files']) - 3} more")
            prompt_parts.append("")
        
        # Add repository map if available
        if repo_context.get("repo_map"):
            prompt_parts.append("Repository structure:")
            # Truncate repo map if too long
            repo_map = str(repo_context["repo_map"])
            if len(repo_map) > 2000:
                repo_map = repo_map[:2000] + "... [truncated]"
            prompt_parts.append(repo_map)
            prompt_parts.append("")
        
        # Add git status
        if repo_context.get("git_status"):
            prompt_parts.append("Git status (dirty files):")
            for file in repo_context["git_status"]:
                prompt_parts.append(f"  - {file}")
            prompt_parts.append("")
        
        # Add identified issues but note they are secondary
        if issues:
            prompt_parts.append("EXISTING ISSUES (only address if they block the main task):")
            for issue in issues:
                prompt_parts.append(f"- {issue['type'].upper()}: {issue['description']}")
                if issue.get('details'):
                    # Truncate details if too long
                    details = str(issue['details'])
                    if len(details) > 500:
                        details = details[:500] + "... [truncated]"
                    prompt_parts.append(f"  Details: {details}")
            prompt_parts.append("")
        
        prompt_parts.extend([
            "REQUIREMENTS:",
            "1. PRIORITY 1: Create tasks to complete the main task - this is most important",
            "2. Break down the main task into logical, implementable steps",
            "3. Only include existing issue fixes if they directly block the main task",
            "4. Consider dependencies and proper ordering for the main task",
            "5. Missing files unrelated to the main task should be low priority or excluded",
            "6. Be specific about what each task should accomplish for the main goal",
            "",
            "Please analyze the above context and create an optimal task execution plan as a JSON array, focusing primarily on the main task:"
        ])
        
        return "\n".join(prompt_parts)

    def _parse_llm_planning_response(self, response: str) -> List[Dict[str, Any]]:
        """Parse the LLM's planning response and convert to task objects"""
        try:
            # Try to extract JSON from the response
            import re
            
            # Look for JSON array in the response
            json_match = re.search(r'\[.*\]', response, re.DOTALL)
            if json_match:
                json_str = json_match.group(0)
                tasks_data = json.loads(json_str)
                
                # Validate and convert to our task format
                tasks = []
                for i, task_data in enumerate(tasks_data):
                    # Ensure required fields exist
                    task = {
                        "name": task_data.get("name", f"Task {i+1}"),
                        "type": task_data.get("type", "improvement"),
                        "priority": task_data.get("priority", 3),
                        "details": task_data.get("details", ""),
                        "dependencies": task_data.get("dependencies", []),
                        "estimated_effort": task_data.get("estimated_effort", "medium")
                    }
                    
                    # Add any file-specific data for lint/test tasks
                    if "file" in task_data:
                        task["file"] = task_data["file"]
                    elif task["type"] == "fix_lint":
                        # For lint tasks without specific file, try to infer from context
                        # Use the first file in chat as a reasonable default
                        if hasattr(self, 'context_memory') and self.context_memory.get('repo_analysis', {}).get('files_in_chat'):
                            task["file"] = self.context_memory['repo_analysis']['files_in_chat'][0]
                    
                    tasks.append(task)
                
                # Sort tasks by priority and dependencies
                tasks = self._resolve_task_dependencies(tasks)
                
                return tasks
            
        except (json.JSONDecodeError, Exception) as e:
            self.log_agent_action(
                "LLM Planning",
                "Failed to parse LLM response",
                f"JSON parsing error: {str(e)}"
            )
        
        # If parsing fails, create a simple fallback task
        return [{
            "name": self.task if self.task != "Analyze and improve the codebase" else "Improve codebase",
            "type": "feature_implementation" if self.task != "Analyze and improve the codebase" else "improvement",
            "priority": 1,
            "details": self.task,
            "dependencies": [],
            "estimated_effort": "medium"
        }]

    def _resolve_task_dependencies(self, tasks: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Sort tasks by dependencies and priority"""
        # Create a mapping of task names to tasks
        task_map = {task["name"]: task for task in tasks}
        
        # Simple topological sort based on dependencies
        resolved = []
        remaining = tasks.copy()
        
        while remaining:
            # Find tasks with no unresolved dependencies
            ready_tasks = []
            for task in remaining:
                deps_resolved = all(
                    dep_name in [t["name"] for t in resolved] 
                    for dep_name in task.get("dependencies", [])
                )
                if deps_resolved:
                    ready_tasks.append(task)
            
            if not ready_tasks:
                # If no tasks are ready, break dependency cycle by taking highest priority
                ready_tasks = [min(remaining, key=lambda x: x["priority"])]
            
            # Sort ready tasks by priority
            ready_tasks.sort(key=lambda x: x["priority"])
            
            # Add to resolved and remove from remaining
            for task in ready_tasks:
                resolved.append(task)
                remaining.remove(task)
        
        return resolved

    def editing_code_generation_phase(self, task: Dict[str, Any]) -> bool:
        """
        Enhanced editing phase that generates/edits code based on current task.
        """
        self.log_agent_action(
            "Editing/Code Generation",
            f"Working on: {task['name']}",
            f"Implementing {task['type']} with targeted approach",
            {"task_details": task.get("details", "No additional details")}
        )
        
        # Prepare context-aware message for the task
        message = self._prepare_task_message(task)
        
        # Check if we need additional context via web search
        if self.enable_web_search and self._should_search_web(task):
            web_context = self._perform_web_search(task)
            if web_context:
                message += f"\n\nAdditional context from web search:\n{web_context}"
        
        try:
            # Execute the coding task
            self.coder.run(with_message=message)
            return True
        except Exception as e:
            self.log_agent_action("Editing", "Code generation failed", str(e))
            self.last_error_context = str(e)
            return False

    def _prepare_task_message(self, task: Dict[str, Any]) -> str:
        """Prepare a context-aware message for the current task"""
        base_message = f"Task: {task['name']}\n\n"
        
        if task["type"] == "fix_lint":
            # Handle both LLM-generated tasks (may not have file) and rule-based tasks (have file)
            if task.get('file'):
                base_message += f"Please fix the following linting issues in {task['file']}:\n"
            else:
                base_message += "Please fix the following linting issues:\n"
            base_message += f"```\n{task['details']}\n```\n"
            base_message += "Focus on fixing the specific issues without changing unrelated code."
            
        elif task["type"] == "fix_tests":
            base_message += "Please fix the failing tests:\n"
            base_message += f"```\n{task['details']}\n```\n"
            base_message += "Analyze the test failures and fix the underlying issues."
            
        elif task["type"] == "feature_implementation":
            base_message += f"Please implement the following feature or improvement:\n{task['details']}\n"
            
            # Check if this is about creating a new file
            details_lower = task['details'].lower()
            if 'create' in details_lower or 'new file' in details_lower:
                base_message += "\nThis appears to be creating a new file. Please create the file with appropriate content and structure.\n"
            
            base_message += "Consider the existing codebase structure and maintain consistency."
            
        elif task["type"] == "improvement":
            base_message += "Please review the code and make improvements:\n"
            base_message += "- Add documentation where missing\n"
            base_message += "- Improve code readability and structure\n"
            base_message += "- Add type hints where appropriate\n"
            base_message += "- Ensure consistent coding style\n"
        
        elif task["type"] == "fix_security":
            base_message += "Please fix the following security issues:\n"
            base_message += f"```\n{task['details']}\n```\n"
            base_message += "Address the security vulnerabilities while maintaining functionality."
        
        elif task["type"] == "refactor":
            base_message += f"Please refactor the code as described:\n{task['details']}\n"
            base_message += "Maintain existing functionality while improving code structure."
        
        elif task["type"] == "documentation":
            base_message += f"Please add or improve documentation:\n{task['details']}\n"
            base_message += "Focus on clear, helpful documentation that explains the code's purpose and usage."
        
        else:
            # Generic fallback for any other task types
            base_message += f"Please complete the following task:\n{task['details']}\n"
        
        # Add context from previous failures if any
        if self.last_error_context:
            base_message += f"\n\nNote: Previous attempt failed with: {self.last_error_context}\n"
            base_message += "Please address this issue in your implementation."
        
        return base_message

    def _should_search_web(self, task: Dict[str, Any]) -> bool:
        """Determine if web search would be helpful for this task"""
        # Only search if web searcher is available and configured
        if not self.web_searcher or not self.web_searcher.is_available():
            return False
            
        # Search for feature implementation, improvement tasks, or when dealing with errors
        return (
            task["type"] in ["feature_implementation", "improvement"] or
            self.last_error_context is not None or
            "jac" in task.get("details", "").lower() or
            "documentation" in task.get("details", "").lower() or
            "jac language" in task.get("details", "").lower() or
            "create" in task.get("details", "").lower()
        )

    def _perform_web_search(self, task: Dict[str, Any]) -> Optional[str]:
        """Perform web search for additional context using Serper API"""
        search_queries = self._generate_search_queries(task)
        
        if not search_queries:
            return None
            
        self.log_agent_action(
            "Web Search",
            f"🔍 STARTING WEB SEARCH - {len(search_queries)} queries",
            "Gathering additional information to improve implementation quality"
        )
        
        # DEBUG: Print search details
        self.coder.io.tool_output(f"DEBUG: Web searcher available: {self.web_searcher is not None}")
        if self.web_searcher:
            self.coder.io.tool_output(f"DEBUG: API configured: {self.web_searcher.is_available()}")
            self.coder.io.tool_output(f"DEBUG: Search queries: {search_queries}")
        
        try:
            # Use the web searcher to search multiple queries
            search_results = self.web_searcher.search_multiple_queries(
                search_queries[:2],  # Limit to 2 queries to avoid being too slow
                max_results_per_query=2
            )
            
            # DEBUG: Print results
            self.coder.io.tool_output(f"DEBUG: Search results length: {len(search_results) if search_results else 0}")
            if search_results:
                self.coder.io.tool_output(f"DEBUG: Results preview: {search_results[:200]}...")
            
            if search_results and not search_results.startswith("No"):
                self.log_agent_action(
                    "Web Search",
                    "SEARCH COMPLETED - Found relevant information",
                    f"Successfully retrieved web search results for task implementation"
                )
                return search_results
            else:
                self.log_agent_action(
                    "Web Search",
                    "SEARCH EMPTY - No useful results found",
                    "Proceeding without additional web context"
                )
                return None
                
        except Exception as e:
            self.coder.io.tool_output(f"DEBUG: Search exception: {e}")
            self.log_agent_action("Web Search", "SEARCH FAILED", str(e))
            return None

    def _generate_search_queries(self, task: Dict[str, Any]) -> List[str]:
        """Generate relevant search queries for the task"""
        queries = []
        details = task.get("details", "").lower()
        
        if task["type"] == "feature_implementation":
            # Extract key terms from the task
            task_details = task.get("details", "")
            
            # Special handling for Jac language
            if "jac language" in details or "jac" in details:
                queries.extend([
                    "Jac programming language syntax examples",
                    "Jac language documentation tutorial",
                    f"Jac language {task_details.replace('jac language', '').strip()}"
                ])
            else:
                queries.extend([
                    f"how to implement {task_details} python",
                    f"{task_details} best practices examples"
                ])
                
            # Add specific context based on content
            if "calculation" in details:
                queries.append("programming calculation script examples")
            if "api" in details:
                queries.append("API development best practices")
            if "test" in details:
                queries.append("unit testing examples")
                
        elif task["type"] == "fix_tests":
            queries.extend([
                "python test debugging common issues",
                "unit test failure troubleshooting"
            ])
            
        elif task["type"] == "fix_lint":
            queries.extend([
                "python linting errors solutions",
                "code style fixing best practices"
            ])
            
        elif self.last_error_context:
            # Search for error solutions
            error_key_terms = self.last_error_context[:100]  # First 100 chars
            queries.append(f"python error solution {error_key_terms}")
        
        # Remove duplicates while preserving order
        unique_queries = []
        seen = set()
        for query in queries:
            if query.lower() not in seen:
                unique_queries.append(query)
                seen.add(query.lower())
                
        return unique_queries

    def code_execution_validation_phase(self) -> Tuple[bool, Dict[str, Any]]:
        """
        Comprehensive validation phase with testing, linting, and security scanning.
        """
        self.log_agent_action(
            "Code Execution/Validation",
            "Running comprehensive validation suite",
            "Ensuring code quality, functionality, and security"
        )
        
        validation_results = {
            "lint_passed": True,
            "tests_passed": True,
            "security_passed": True,
            "lint_output": None,
            "test_output": None,
            "security_output": None
        }
        
        # Run linting
        if self.coder.auto_lint and self.coder.abs_fnames:
            self.log_agent_action("Validation", "Running linter", "Checking code style and syntax")
            try:
                self.coder.commands.cmd_lint(fnames=list(self.coder.abs_fnames))
                lint_passed = self.coder.lint_outcome is not False
                validation_results["lint_passed"] = lint_passed
                
                if not lint_passed:
                    validation_results["lint_output"] = "Linting issues detected"
                    
            except Exception as e:
                validation_results["lint_passed"] = False
                validation_results["lint_output"] = str(e)
        
        # Run tests
        if self.coder.auto_test and self.coder.test_cmd:
            self.log_agent_action("Validation", "Running tests", "Verifying functionality")
            try:
                test_output = self.coder.commands.cmd_test(self.coder.test_cmd)
                test_passed = test_output is None  # cmd_test returns None on success
                validation_results["tests_passed"] = test_passed
                validation_results["test_output"] = test_output
                
            except Exception as e:
                validation_results["tests_passed"] = False
                validation_results["test_output"] = str(e)
        
        # Security scan (if enabled)
        if self.enable_security_scan:
            security_result = self._run_security_scan()
            validation_results["security_passed"] = security_result["passed"]
            validation_results["security_output"] = security_result["output"]
        
        # Overall success
        overall_success = (
            validation_results["lint_passed"] and
            validation_results["tests_passed"] and
            validation_results["security_passed"]
        )
        
        self.validation_results = validation_results
        
        # Log results
        status = "PASSED" if overall_success else "FAILED"
        self.log_agent_action(
            "Validation",
            f"Validation complete: {status}",
            "All validation checks completed",
            {
                "Lint": "✅" if validation_results["lint_passed"] else "❌",
                "Tests": "✅" if validation_results["tests_passed"] else "❌",
                "Security": "✅" if validation_results["security_passed"] else "❌"
            }
        )
        
        return overall_success, validation_results

    def _run_security_scan(self) -> Dict[str, Any]:
        """Run basic security scanning on the codebase"""
        self.log_agent_action("Security Scan", "Checking for security issues", "Ensuring code security")
        
        security_issues = []
        
        # Basic security checks for Python files
        for fname in self.coder.abs_fnames:
            if fname.endswith('.py'):
                try:
                    # Check if file exists before reading
                    if not Path(fname).exists():
                        continue
                        
                    with open(fname, 'r', encoding='utf-8') as f:
                        content = f.read()
                        
                    # Check for common security issues
                    if 'eval(' in content:
                        security_issues.append(f"{fname}: Use of eval() detected - potential security risk")
                    if 'exec(' in content:
                        security_issues.append(f"{fname}: Use of exec() detected - potential security risk")
                    if 'shell=True' in content:
                        security_issues.append(f"{fname}: shell=True in subprocess - potential security risk")
                    if 'pickle.loads' in content:
                        security_issues.append(f"{fname}: pickle.loads() detected - potential security risk")
                        
                except Exception as e:
                    # Don't fail the entire scan for individual file issues
                    self.log_agent_action("Security Scan", f"Could not scan {fname}", str(e))
                    continue
        
        return {
            "passed": len(security_issues) == 0,
            "output": "\n".join(security_issues) if security_issues else "No security issues detected"
        }

    def generate_report(self) -> str:
        """Generate a comprehensive report of the agent's work"""
        report = [
            "Genius Agent Execution Report",
            "=" * 40,
            f"Task: {self.task}",
            f"Iterations completed: {self.current_iteration}/{self.max_iterations}",
            f"Tasks completed: {len(self.completed_tasks)}",
            f"Tasks failed: {len(self.failed_tasks)}",
            "",
            "Completed Tasks:",
        ]
        
        for task in self.completed_tasks:
            report.append(f"  {task['name']}")
            
        if self.failed_tasks:
            report.append("\nFailed Tasks:")
            for task in self.failed_tasks:
                report.append(f"  {task['name']}")
        
        if self.validation_results:
            report.extend([
                "\nFinal Validation Results:",
                f"  Lint: {'✅' if self.validation_results['lint_passed'] else '❌'}",
                f"  Tests: {'✅' if self.validation_results['tests_passed'] else '❌'}",
                f"  Security: {'✅' if self.validation_results['security_passed'] else '❌'}",
            ])
        
        return "\n".join(report)

    def run(self) -> bool:
        """
        Main execution loop for the Genius Agent.
        Implements the complete agent architecture with feedback loops.
        """
        self.log_agent_action(
            "Initialization",
            "Starting Genius Agent",
            f"Beginning autonomous development cycle for: {self.task}",
            {"max_iterations": self.max_iterations, "web_search": self.enable_web_search}
        )
        
        # Initial planning phase
        if not self.planning_phase():
            self.log_agent_action("Error", "Planning failed", "Could not create task graph")
            return False
        
        # Main execution loop
        for iteration in range(self.max_iterations):
            self.current_iteration = iteration + 1
            
            self.log_agent_action(
                "Iteration",
                f"Starting iteration {self.current_iteration}",
                f"Working through task graph: "
                f"{len(self.task_graph) - len(self.completed_tasks)} tasks remaining"
            )
            
            # Get next task from graph
            current_task = self._get_next_task()
            if not current_task:
                self.log_agent_action("Completion", "All tasks completed", "No more tasks in the queue")
                break
            
            # Execute the editing/code generation phase
            edit_success = self.editing_code_generation_phase(current_task)
            if not edit_success:
                self.failed_tasks.append(current_task)
                continue
            
            # Validate the changes
            validation_success, validation_details = self.code_execution_validation_phase()
            
            if validation_success:
                self.completed_tasks.append(current_task)
                self.last_error_context = None  # Clear error context on success
                
                # Check if we should commit changes
                if self.coder.auto_commits and self.coder.repo and self.coder.repo.is_dirty():
                    commit_msg = f"Genius Agent: {current_task['name']}"
                    self.coder.commands.cmd_commit(commit_msg)
                    self.log_agent_action("Git", "Changes committed", commit_msg)
                
            else:
                # Handle validation failure with feedback
                self._handle_validation_failure(current_task, validation_details)
        
        # Generate final report
        report = self.generate_report()
        self.coder.io.tool_output(report)
        
        # Return success if we completed at least one task and have no critical failures
        success = len(self.completed_tasks) > 0 and (
            not self.validation_results or 
            (self.validation_results["tests_passed"] and self.validation_results["security_passed"])
        )
        
        return success

    def _get_next_task(self) -> Optional[Dict[str, Any]]:
        """Get the next task from the task graph"""
        for task in self.task_graph:
            if task not in self.completed_tasks and task not in self.failed_tasks:
                return task
        return None

    def _handle_validation_failure(self, task: Dict[str, Any], validation_details: Dict[str, Any]):
        """Handle validation failure with intelligent feedback"""
        self.log_agent_action(
            "Feedback Loop",
            "Processing validation failure",
            "Analyzing failure and preparing retry strategy"
        )
        
        # Store error context for next iteration
        error_messages = []
        if validation_details["lint_output"]:
            error_messages.append(f"Lint errors: {validation_details['lint_output']}")
        if validation_details["test_output"]:
            error_messages.append(f"Test failures: {validation_details['test_output']}")
        if validation_details["security_output"]:
            error_messages.append(f"Security issues: {validation_details['security_output']}")
        
        self.last_error_context = " | ".join(error_messages)
        
        # Decide whether to retry or mark as failed
        retry_count = getattr(task, 'retry_count', 0)
        if retry_count < 2:  # Allow up to 2 retries
            task['retry_count'] = retry_count + 1
            self.log_agent_action(
                "Feedback",
                f"Scheduling retry {retry_count + 1}/2",
                "Will retry with error context"
            )
        else:
            self.failed_tasks.append(task)
            self.log_agent_action(
                "Feedback",
                "Task marked as failed",
                "Maximum retries exceeded"
            )


# Backwards compatibility
class GeniusMode(GeniusAgent):
    """Legacy wrapper for backwards compatibility"""
    
    def __init__(self, coder, task=None, max_iterations=5):
        super().__init__(coder, task, max_iterations)