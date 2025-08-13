import json;
import os;
import subprocess;
import time;
import re;
import from pathlib { Path }
import from typing { Any, Dict, List, Optional, Tuple }
import from aider.web_search { web_search, create_web_searcher }
import from mcp_client { list_mcp_tools, call_mcp_tool }
import from mtllm {Model}

with entry {
    try {
        WEB_SEARCH_AVAILABLE = True;
    } except ImportError {
        WEB_SEARCH_AVAILABLE = False;
        create_web_searcher = None;
    }
}

obj Plan {
    has name: str;
    has type: str;
    has details: str;
    has priority: int = 1;
    has dependencies: List[str] = [];
    has estimated_effort: str = "medium";
    has file: Optional[str] = None;
    has retry_count: int = 0;
}

sem Plan = "A specific, actionable development task with clear implementation requirements";
sem Plan.name = "Clear, descriptive name for the task (e.g., 'Create calculator backend', 'Add input validation')";
sem Plan.type = "Task category: feature_implementation, fix_tests, fix_lint, fix_security, improvement, refactor, or documentation";
sem Plan.priority = "Task priority: 1=highest (main task), 2-3=supporting tasks, 4-5=maintenance/optional";
sem Plan.details = "Specific implementation instructions: what files to create, functions to implement, libraries to use";
sem Plan.dependencies = "List of task names that must be completed before this task (use actual task names from the same plan)";
sem Plan.estimated_effort = "Development effort estimate: small, medium, or large";
sem Plan.file = "Specific file path if the task is focused on a particular file (optional)";

obj SecurityScanResult {
    has file_path: str;
    has issues: List[str] = [];
    has analysis: Dict[str, str] = {};
    has risk_level: str = "low";
    has recommendations: List[str] = [];
}

sem SecurityScanResult = "Security analysis result for a specific file";
sem SecurityScanResult.file_path = "Path to the file that was analyzed";
sem SecurityScanResult.issues = "List of specific security issues found (empty if none)";
sem SecurityScanResult.analysis = "Detailed security analysis breakdown by category";
sem SecurityScanResult.risk_level = "Overall risk assessment: low, medium, high, critical";
sem SecurityScanResult.recommendations = "List of security improvement recommendations";

node IntelligentDecisionNode {
    has decision_model: Optional[Model] = None;
    has current_task_context: dict = {};
    has repo_context: dict = {};
    
    """Analyze a file operation request and decide whether to approve it based on context, safety, and task relevance."""
    def should_approve_file_operation(
        operation_type: str, 
        file_path: str, 
        task_context: str, 
        repo_context: str,
        operation_details: str = ""
    ) -> bool by self.decision_model(method="Reason");
    
    """Make an intelligent decision about file operations"""
    def make_intelligent_decision(
        operation_type: str,
        file_path: str,
        operation_details: str = "",
        task_context: Optional[Dict] = None,
        repo_context: Optional[Dict] = None
    ) -> bool {
        if not self.decision_model {
            # Fallback to safe default if no decision model
            return operation_type in ['create', 'edit', 'read'];
        }
        
        try {
            # Prepare context for the decision
            task_str = str(task_context) if task_context else "No task context";
            repo_str = str(repo_context) if repo_context else "No repository context";
            
            decision = self.should_approve_file_operation(
                operation_type,
                file_path,
                task_str,
                repo_str,
                operation_details
            );
            
            print(f"Intelligent Decision: {operation_type} {file_path} -> {'APPROVED' if decision else 'DENIED'}");
            return decision;
        } except Exception as e {
            print(f"Decision making failed: {str(e)}, defaulting to safe approval");
            # Default to approval for common operations if decision fails
            return operation_type in ['create', 'edit', 'read'];
        }
    }
}

obj IntelligentIO {
    """Custom IO wrapper that makes intelligent decisions about file operations"""
    has original_io: Any;
    has decision_node: IntelligentDecisionNode;
    has current_task: Optional[Dict] = None;
    has repo_context: Optional[Dict] = None;
    
    def __init__(original_io: Any, decision_model: Any) {
        self.original_io = original_io;
        self.decision_node = IntelligentDecisionNode(decision_model=decision_model);
    }
    
    def set_context(task: Optional[Dict], repo_context: Optional[Dict]) {
        self.current_task = task;
        self.repo_context = repo_context;
        self.decision_node.current_task_context = task or {};
        self.decision_node.repo_context = repo_context or {};
    }
    
    def confirm_ask(
        question: str,
        default: str = "y",
        subject: Optional[str] = None,
        explicit_yes_required: bool = False,
        group: Any = None,
        allow_never: bool = False
    ) -> bool {
        # Analyze the question to determine operation type
        operation_type = "unknown";
        file_path = subject or "unknown";
        
        if "Create new file" in question or "create" in question.lower() {
            operation_type = "create";
        } elif "edit" in question.lower() or "modify" in question.lower() {
            operation_type = "edit";
        } elif "delete" in question.lower() or "remove" in question.lower() {
            operation_type = "delete";
        } elif "add" in question.lower() and "to the chat" in question.lower() {
            operation_type = "add_to_chat";
        } elif "commit" in question.lower() {
            operation_type = "commit";
        }
        
        # Make intelligent decision
        decision = self.decision_node.make_intelligent_decision(
            operation_type=operation_type,
            file_path=file_path,
            operation_details=question,
            task_context=self.current_task,
            repo_context=self.repo_context
        );
        
        if decision {
            self.original_io.tool_output(f"AI Decision: APPROVED - {operation_type} {file_path}");
            return True;
        } else {
            self.original_io.tool_output(f"AI Decision: DENIED - {operation_type} {file_path}");
            self.original_io.tool_output(f"Reason: Operation deemed unsafe or unnecessary for current task");
            return False;
        }
    }
    
    # Delegate all other methods to original IO
    def __getattr__(name: str) -> Any {
        return getattr(self.original_io, name);
    }
}


node PlanningNode {
    has task: str = "";
    has status: str = "pending";
    has result: Optional[Any] = None;
    has error: Optional[str] = None;
    has task_graph: list = [];
    has repo_context: dict = {};
    has issues: list = [];
    has planning_model: Optional[Model] = None;
    
    """Enhanced logging for agent actions with structured data"""
    def log_agent_action(phase: str, action: str, reasoning: str, details: Optional[Dict] = None) {
        print(f"Genius Agent - Phase: {phase} | Action: {action} | Reasoning: {reasoning}");
        print("");
    }
    
    """Gather comprehensive repository context"""
    def gather_repository_context(coder: Any) -> Dict[str, Any] {
        context = {
            'files_in_chat': list(coder.abs_fnames),
            'readonly_files': list(coder.abs_read_only_fnames),
            'repo_map': None,
            'terminal_output': None,
            'git_status': None,
            'missing_files': []
        };
        
        if coder.repo_map {
            repo_map = coder.get_repo_map();
            if repo_map {
                context['repo_map'] = repo_map;
                
                # Find mentioned files that might be missing
                file_mentions = re.findall(r'(\w+\.\w+)', repo_map);
                missing_files = [];
                for file_path in file_mentions {
                    if not Path(file_path).exists() {
                        missing_files.append(file_path);
                    }
                }
                if missing_files {
                    context['missing_files'] = missing_files[:10];  # Limit to first 10
                }
            }
        }
        
        if coder.repo {
            try {
                git_status = coder.repo.get_dirty_files();
                context['git_status'] = git_status;
            } except Exception as e {
                print(f"Git status failed: {str(e)}");
            }
        }
        
        # print(f"Gathered repository context: {context}");
        return context;
    }
    
    """Analyze current issues in the codebase"""
    def analyze_current_issues(coder: Any) -> List[Dict] {
        issues = [];
        
        # Check for lint issues
        if coder.auto_lint and coder.abs_fnames {
            try {
                for fname in list(coder.abs_fnames) {
                    lint_output = coder.commands.cmd_lint(fname);
                    if lint_output and lint_output.strip() {
                        issues.append({
                            'type': 'lint',
                            'file': fname,
                            'details': lint_output,
                            'priority': 'medium'
                        });
                    }
                }
            } except Exception as e {
                print(f"Lint analysis failed: {str(e)}");
            }
        }
        
        # Check for test failures
        if coder.test_cmd {
            try {
                test_result = coder.commands.cmd_test(coder.test_cmd);
                if test_result and "FAILED" in test_result {
                    issues.append({
                        'type': 'test',
                        'details': test_result,
                        'priority': 'high'
                    });
                }
            } except Exception as e {
                print(f"Test analysis failed: {str(e)}");
            }
        }
        
        print(f"Identified issues in codebase: {issues}");
        return issues;
    }

    # """Perform background research to gather additional context"""
    # def background_research(task_description:str) -> str by self.planning_model(method="ReAct", tools=[web_search]);

    """Generate specific implementation instructions for the user's task, focusing on exact code structure and technologies to use."""
    def generate_plan(task_description: str, repo_context: str, issues_context: str) -> List[Plan] by self.planning_model(method="Reason"); 

    """Use LLM to analyze the task and repository context to create an intelligent task plan."""
    def llm_based_task_planning(task: str, repo_context: Dict, issues: List[Dict], planning_model: Any, coder: Any) -> List[Dict] {
        print(f"Consulting planning model for intelligent task breakdown");
        
        try {
            # web_scraped_info = self.background_research(task);
            # print(f"Background research results: {web_scraped_info}");
            plan_objects = self.generate_plan(task, str(repo_context), str(issues)); # , web_scraped_info
            print(f"Planning response: {plan_objects}");
            
            if plan_objects {
                tasks = [];
                for plan in plan_objects {
                    task_dict = {
                        'name': plan.name,
                        'type': plan.type,
                        'priority': plan.priority,
                        'details': plan.details,
                        'dependencies': plan.dependencies,
                        'estimated_effort': plan.estimated_effort
                    };
                    if plan.file {
                        task_dict['file'] = plan.file;
                    }
                    tasks.append(task_dict);
                }
                
                print(f"Generated {len(tasks)} structured tasks");
                
                # Sort by priority
                def get_priority(task: dict) -> int {
                    return task['priority'];
                }
                sorted_tasks = sorted(tasks, key=get_priority);
                print(f"Sorted tasks by priority: {[task['name'] for task in sorted_tasks]}");
                return sorted_tasks;
            }
        } except Exception as e {
            print(f"LLM planning failed: {str(e)}");
        }
    }
}




node EditorNode {
    has file_path: str = "";
    has content: str = "";
    has changes: list = [];
    has status: str = "pending";
    has current_task: dict = {};
    has web_context: Optional[str] = None;
    has editor_model: Optional[Model] = None;
    
    """Prepare a context-aware message for the current task"""
    def prepare_task_message(task: Dict, last_error_context: Optional[str] = None) -> str {
        # Check if this is a retry with specific details
        if task.get('retry_details') {
            base_message = task['retry_details'];
        } else {
            base_message = f"Task: {task['name']}\n\n";
        }
        
        if not task.get('retry_details') {
            if task['type'] == 'fix_lint' {
                if task.get('file') {
                    base_message += f"Please fix the following linting issues in {task['file']}:\n";
                } else {
                    base_message += "Please fix the following linting issues:\n";
                }
                base_message += f"```\n{task['details']}\n```\n";
                base_message += "Focus on fixing the specific issues without changing unrelated code.";
            } elif task['type'] == 'fix_tests' {
                base_message += "Please fix the failing tests:\n";
                base_message += f"```\n{task['details']}\n```\n";
                base_message += "Analyze the test failures and fix the underlying issues.";
            } elif task['type'] == 'feature_implementation' {
                base_message += f"Please implement the following feature or improvement:\n{task['details']}\n\n";
                details_lower = task['details'].lower();
                if 'create' in details_lower or 'new file' in details_lower {
                    base_message += "IMPORTANT: You must create the necessary files. The AI assistant will intelligently approve necessary file operations.\n";
                }
                # Add intelligent operation directive
                base_message += "INTELLIGENT MODE: An AI assistant will review and approve file operations based on task relevance and safety. Proceed with necessary file operations.\n";
                if 'calculator' in details_lower {
                    base_message += "Create a functional calculator with basic arithmetic operations (addition, subtraction, multiplication, division).\n";
                    base_message += "Include proper error handling for division by zero and invalid inputs.\n";
                    base_message += "Make it user-friendly with clear prompts and output formatting.\n";
                }
                base_message += "Consider the existing codebase structure and maintain consistency.\n";
                base_message += "Create all necessary files and implement the complete functionality.";
            } elif task['type'] == 'improvement' {
                base_message += "Please review the code and make improvements:\n";
                base_message += "- Add documentation where missing\n";
                base_message += "- Improve code readability and structure\n";
                base_message += "- Add type hints where appropriate\n";
                base_message += "- Ensure consistent coding style\n";
            } elif task['type'] == 'fix_security' {
                base_message += "Please fix the following security issues:\n";
                base_message += f"```\n{task['details']}\n```\n";
                base_message += "Address the security vulnerabilities while maintaining functionality.";
            } elif task['type'] == 'refactor' {
                base_message += f"Please refactor the code as described:\n{task['details']}\n";
                base_message += "Maintain existing functionality while improving code structure.";
            } elif task['type'] == 'documentation' {
                base_message += f"Please add or improve documentation:\n{task['details']}\n";
                base_message += "Focus on clear, helpful documentation that explains the code's purpose and usage.";
            } else {
                base_message += f"Please complete the following task:\n{task['details']}\n";
            }
        }
        
        if last_error_context and not task.get('retry_details') {
            base_message += f"\n\nNote: Previous attempt failed with: {last_error_context}\n";
            base_message += "Please address this issue in your implementation.";
        }
        
        # Add intelligent operation directive for all tasks
        base_message += f"\n\nINTELLIGENT MODE: This agent has an AI assistant that will intelligently review and approve file operations based on task relevance, safety, and necessity. Proceed with the implementation knowing that file operations will be evaluated appropriately.";
        
        return base_message;
    }

    """Determine if web search is required for this task. if you dont have the latest syntaxes of a language, you should search the web for it."""
    def need_web_search(task: Dict, web_searcher: Any, last_error_context: Optional[str] = None) -> bool by self.editor_model(method="Reason");

    def generate_web_search_queries(task: Dict, last_error_context: Optional[str] = None) -> List[str] by self.editor_model(method="Reason");

    """Perform web search for additional context using Serper API"""
    def perform_web_search(task: Dict, web_searcher: Any, last_error_context: Optional[str] = None) -> Optional[str] {
        search_queries = self.generate_web_search_queries(task, last_error_context);
        if not search_queries {
            return None;
        }
        
        try {
            search_results = "";
            for query in search_queries[:2] { 
                search_results += f"Searching for: {query}\n";
                result = call_mcp_tool("search_web", {'query': query});
                # result = web_searcher.search(query);
                print(f"Search result for '{query}': {result}");
                if result and not result.startswith('No') and len(result.strip()) > 50 {
                    if len(result) > 1000 {
                        result = result[:1000] + "... (truncated)";
                    }
                    search_results += f"\n--- Search: {query} ---\n{result}\n";
                }
            }
            
            if search_results and len(search_results.strip()) > 100 {
                print(f"Found useful search context ({len(search_results)} chars)");
                return search_results;
            } else {
                print("No useful search results found");
                return None;
            }
        } except Exception as e {
            print(f"Search exception: {e}");
            return None;
        }
    }
}

node ValidatorNode {
    has file_path: str = "";
    has issues: list = [];
    has status: str = "pending";
    has validation_results: dict = {};
    has validation_model: Optional[Model] = None;
    
    """Perform intelligent security analysis on the edited/generated code, as a cybersecurity expert."""
    def intelligent_security_scan(code_content: str, file_path: str, coder_context: str) -> SecurityScanResult by self.validation_model(method="ReAct");
    
    """Comprehensive validation phase with testing, linting, and security scanning."""
    def code_execution_validation(coder: Any, enable_security_scan: bool = True) -> Tuple[bool, Dict] {
        validation_results = {
            'lint_passed': True,
            'tests_passed': True,
            'security_passed': True,
            'lint_output': None,
            'test_output': None,
            'security_output': None
        };
        
        # Run linting on files that are in the chat (recently edited files)
        if coder.auto_lint and coder.abs_fnames {
            print("Running linting validation");
            try {
                lint_output = "";
                # Get files to lint - use the files currently in chat
                files_to_lint = list(coder.abs_fnames);
                print(f"Linting files: {files_to_lint}");
                
                for fname in files_to_lint {
                    # Use the coder's linter directly for fatal errors
                    if hasattr(coder, 'linter') and coder.linter {
                        file_lint = coder.linter.lint(fname);
                        if file_lint and file_lint.strip() {
                            lint_output += f"\n=== Fatal/Syntax Errors in {fname} ===\n{file_lint}\n";
                        }
                    }
                    
                    # Also run a comprehensive style check if requested
                    style_lint = self.run_comprehensive_lint(fname);
                    if style_lint and style_lint.strip() {
                        lint_output += f"\n=== Style Issues in {fname} ===\n{style_lint}\n";
                    }
                }
                
                print(f"Lint output: {lint_output}");
                validation_results['lint_output'] = lint_output;
                validation_results['lint_passed'] = not lint_output.strip();
            } except Exception as e {
                print(f"Lint validation failed: {str(e)}");
                validation_results['lint_passed'] = False;
                validation_results['lint_output'] = str(e);
            }
        } else {
            print(f"Skipping lint validation: auto_lint={getattr(coder, 'auto_lint', None)}, abs_fnames={getattr(coder, 'abs_fnames', None)}");
        }
        
        # Run tests
        if coder.auto_test and coder.test_cmd {
            print("Running test validation");
            try {
                print(f"Running test command: {coder.test_cmd}");
                test_output = coder.commands.cmd_test(coder.test_cmd);
                print(f"Test output: {test_output}");
                validation_results['test_output'] = test_output;
                validation_results['tests_passed'] = test_output and "FAILED" not in test_output;
            } except Exception as e {
                print(f"Test validation failed: {str(e)}");
                validation_results['tests_passed'] = False;
                validation_results['test_output'] = str(e);
            }
        } else {
            print(f"Skipping test validation: auto_test={getattr(coder, 'auto_test', None)}, test_cmd={getattr(coder, 'test_cmd', None)}");
        }
        
        # Run security scan
        if enable_security_scan {
            security_result = self.run_security_scan(coder);
            validation_results['security_passed'] = security_result['passed'];
            validation_results['security_output'] = security_result['output'];
        }
        
        overall_success = (validation_results['lint_passed'] and 
                          validation_results['tests_passed'] and 
                          validation_results['security_passed']);
        
        status = "PASSED" if overall_success else "FAILED";
        print(f"Validation complete: {status}");
        
        lint_status = "✅" if validation_results['lint_passed'] else "❌";
        test_status = "✅" if validation_results['tests_passed'] else "❌";
        security_status = "✅" if validation_results['security_passed'] else "❌";
        
        print(f"Lint: {lint_status}, Tests: {test_status}, Security: {security_status}");
        
        return (overall_success, validation_results);
    }
    
    """Run comprehensive linting that includes style checks"""
    def run_comprehensive_lint(fname: str) -> Optional[str] {
        if not fname.endswith('.py') {
            return None;
        }
        
        try {
            import subprocess;
            
            # Try flake8 first for comprehensive Python linting
            try {
                result = subprocess.run(
                    ['flake8', '--max-line-length=88', '--extend-ignore=E203,W503', fname],
                    capture_output=True,
                    text=True,
                    timeout=30
                );
                if result.returncode != 0 and result.stdout.strip() {
                    return result.stdout.strip();
                }
            } except (FileNotFoundError, subprocess.TimeoutExpired) {
                # Flake8 not available or timed out
                print("Flake8 not available or timed out");
            }
            
            # Try pycodestyle as fallback
            try {
                result = subprocess.run(
                    ['pycodestyle', '--max-line-length=88', fname],
                    capture_output=True,
                    text=True,
                    timeout=30
                );
                if result.returncode != 0 and result.stdout.strip() {
                    return result.stdout.strip();
                }
            } except (FileNotFoundError, subprocess.TimeoutExpired) {
                # Pycodestyle not available or timed out
                print("Pycodestyle not available or timed out");
            }
            
            return None;
        } except Exception as e {
            print(f"Error in comprehensive lint: {str(e)}");
            return None;
        }
    }
    
    """Run AI-powered security scanning on the codebase"""
    def run_security_scan(coder: Any) -> Dict[str, Any] {
        print("Checking for security issues");
        security_issues = [];
        
        for fname in coder.abs_fnames {
            try {
                with open(fname, 'r', encoding='utf-8') as f {
                    content = f.read();
                }
                if self.validation_model and len(content.strip()) > 0 {
                    try {
                        # Create context about the coder's recent work
                        coder_context = f"Files being worked on: {list(coder.abs_fnames)[:5]}";
                        print(f"Recent files in chat: {coder_context}");
                        if hasattr(coder, 'cur_messages') and coder.cur_messages {
                            recent_messages = coder.cur_messages[-3:];  # Last 3 messages
                            coder_context += f"\nRecent conversation: {str(recent_messages)[:500]}...";
                        }
                        
                        ai_scan_result = self.intelligent_security_scan(content, fname, coder_context);
                        
                        print(f"AI security scan result for {fname}: {ai_scan_result}");
                        
                        if ai_scan_result {
                            # Add specific issues if found
                            if hasattr(ai_scan_result, 'issues') and ai_scan_result.issues {
                                for issue in ai_scan_result.issues {
                                    security_issues.append(f"{fname}: {issue}");
                                }
                            }
                            # Add recommendations as issues if risk level is medium or higher
                            if hasattr(ai_scan_result, 'risk_level') and ai_scan_result.risk_level in ['medium', 'high', 'critical'] {
                                if hasattr(ai_scan_result, 'recommendations') and ai_scan_result.recommendations {
                                    for rec in ai_scan_result.recommendations {
                                        security_issues.append(f"{fname}: Recommendation - {rec}");
                                    }
                                }
                            }
                        }
                    } except Exception as e {
                        print(f"AI security scan failed for {fname}: {str(e)}");
                    }
                }
                
            } except (UnicodeDecodeError, FileNotFoundError) as e {
                print(f"Could not read file {fname}: {str(e)}");
            } except Exception as e {
                print(f"Security scan failed for {fname}: {str(e)}");
            }
        }
        
        return {
            'passed': len(security_issues) == 0,
            'output': "\n".join(security_issues) if security_issues else "No security issues detected"
        };
    }
    
}

# User input node for task continuation
node UserInputNode {
    has status: str = "waiting";
    has user_input: str = "";
    has should_continue: bool = True;
    
    """Wait for user input and determine next action"""
    def get_user_input(coder: Any) -> Tuple[str, bool] {
        try {
            coder.io.tool_output("\n" + "="*50);
            coder.io.tool_output("Genius Agent - Task Completed!");
            coder.io.tool_output("What would you like me to do next?");
            coder.io.tool_output("Options:");
            coder.io.tool_output("  - Describe a new task");
            coder.io.tool_output("  - Type 'exit' or 'quit' to stop");
            coder.io.tool_output("  - Type 'status' to see current repository state");
            coder.io.tool_output("="*50);
            
            user_input = input("\nNext task > ").strip();
            
            if user_input.lower() in ['exit', 'quit', 'stop'] {
                return ("", False);
            } elif user_input.lower() == 'status' {
                return ("status", True);
            } elif user_input == '' {
                return ("empty", True);  # Handle empty input separately
            } else {
                return (user_input, True);
            }
        } except (KeyboardInterrupt, EOFError) {
            coder.io.tool_output("\nExiting Genius Agent...");
            return ("", False);
        } except Exception as e {
            coder.io.tool_output(f"Error getting user input: {str(e)}");
            return ("", False);
        }
    }
    
    """Show current repository status"""
    def show_status(coder: Any) {
        coder.io.tool_output("\nCurrent Repository Status:");
        coder.io.tool_output("-" * 30);
        
        if coder.abs_fnames {
            coder.io.tool_output("Files in current session:");
            for fname in coder.abs_fnames {
                coder.io.tool_output(f"  - {fname}");
            }
        } else {
            coder.io.tool_output("No files in current session");
        }
        
        if coder.repo {
            try {
                dirty_files = coder.repo.get_dirty_files();
                if dirty_files {
                    coder.io.tool_output("\nModified files:");
                    for file in dirty_files {
                        coder.io.tool_output(f"  - {file}");
                    }
                } else {
                    coder.io.tool_output("\nNo uncommitted changes");
                }
            } except Exception as e {
                coder.io.tool_output(f"Could not get git status: {e}");
            }
        }
    }
}

# Terminal node for end of graph traversal
node EndNode {}
glob END = EndNode();

"""Genius Agent for advanced AI coding tasks using Object-Spatial Programming"""
walker GeniusAgent {
    has coder: Any;
    has task: str = "Analyze and improve the codebase";
    has task_explicitly_provided: bool = False;
    has max_iterations: int = 10;
    has enable_web_search: bool = True;
    has enable_security_scan: bool = True;
    has planning_model: Any = None;
    has editor_model: Any = None;
    has web_searcher: Any = None;
    has current_iteration: int = 0;
    has completed_tasks: list = [];
    has failed_tasks: list = [];
    has context_memory: dict = {};
    has last_error_context: Optional[str] = None;
    has validation_results: dict = {};
    has planning_complete: bool = False;

    # Initialize the agent and start at root
    can start with `root entry {
        # Set up planning and editor models first
        self.planning_model = Model(model_name="gpt-4.1-mini");
        self.editor_model = Model(model_name="gpt-4.1-mini");
        
        # Replace the coder's IO with intelligent decision-making IO
        original_io = self.coder.io;
        self.coder.io = IntelligentIO(original_io, self.editor_model);
        self.coder.io.tool_output("Genius Agent - Intelligent Decision Mode Enabled: AI will make smart decisions about file operations");
        
        # Initialize web searcher if available
        if WEB_SEARCH_AVAILABLE and create_web_searcher {
            self.web_searcher = create_web_searcher(print_error=self.coder.io.tool_error);
        } else {
            self.web_searcher = None;
        }
        
        # Create the workflow graph
        planning_node = PlanningNode(task=self.task, status="pending", planning_model=self.planning_model);
        editor_node = EditorNode(file_path="", content="", changes=[], status="pending", editor_model=self.editor_model);
        validator_node = ValidatorNode(file_path="", issues=[], status="pending", validation_model=self.editor_model);
        user_input_node = UserInputNode(status="waiting");
        
        # Connect the workflow with user input loop
        root ++> planning_node;
        planning_node ++> editor_node;
        editor_node ++> validator_node;
        validator_node ++> user_input_node;  # Go to user input instead of END
        
        self.coder.io.tool_output(f"Genius Agent - Phase: Initialization | Action: Starting Genius Agent | Reasoning: Beginning autonomous development cycle for: {self.task}");
        
        # Start traversal
        visit [-->];
    }

    # Handle planning phase
    can plan_tasks with PlanningNode entry {
        here.log_agent_action("Planning", "Starting planning phase", "Analyzing repository and creating task graph");
        
        # Get task from user if not provided
        if not self.task_explicitly_provided {
            try {
                self.coder.io.tool_output("Genius Agent: A specific task is required to proceed.");
                self.coder.io.tool_output("Please describe what you'd like me to work on:");
                self.coder.io.tool_output("(Ctrl+C to cancel)");
                user_input = input("\n> ").strip();
                if user_input {
                    self.task = user_input;
                    self.task_explicitly_provided = True;
                    here.task = self.task;
                    here.log_agent_action("Planning", "User task received", f"Updated task to: {self.task}");
                } else {
                    self.coder.io.tool_output("No task provided. Cannot proceed without a specific task.");
                    here.status = "failed";
                    here.error = "No task provided";
                    return;
                }
            } except (KeyboardInterrupt, EOFError) {
                self.coder.io.tool_output("\nTask input cancelled by user.");
                here.status = "failed";
                return;
            } except Exception as e {
                self.coder.io.tool_output(f"Error getting user input: {str(e)}");
                here.status = "failed";
                return;
            }
        }

        # Refresh repository map if available
        if self.coder.repo_map {
            here.log_agent_action("Planning", "Refreshing repository map", "Ensuring up-to-date view of current files and structure before analysis");
            self.coder.get_repo_map(force_refresh=True);
        }

        # Gather comprehensive repository context
        here.log_agent_action("Planning", "Analyzing repository structure and dependencies", "Building comprehensive understanding of codebase before making changes");
        repo_context = here.gather_repository_context(self.coder);
        issues = here.analyze_current_issues(self.coder);
        
        # Store context in memory
        self.context_memory['repo_analysis'] = repo_context;
        self.context_memory['identified_issues'] = issues;
        
        # Use LLM-based planning
        task_graph = here.llm_based_task_planning(self.task, repo_context, issues, self.planning_model, self.coder);
        
        # Store results in the node
        here.task_graph = task_graph;
        here.repo_context = repo_context;
        here.issues = issues;
        here.status = "completed";
        
        self.planning_complete = True;
        here.log_agent_action("Planning", "LLM-generated task graph created", f"Generated {len(task_graph)} prioritized tasks using intelligent planning", {'tasks': [task['name'] for task in task_graph]});
        
        # Move to next phase
        visit [-->];
    }

    # Handle editing/code generation phase
    can edit_code with EditorNode entry {
        if not self.planning_complete {
            self.coder.io.tool_output("Genius Agent - Phase: Editing | Action: Planning not complete | Reasoning: Cannot proceed without completed planning");
            return;
        }
        
        # Get planning results from previous node
        planning_node = [<--][0];
        task_graph = planning_node.task_graph;
        
        # Main execution loop
        for iteration in range(self.max_iterations) {
            self.current_iteration = iteration + 1;
            self.coder.io.tool_output(f"Genius Agent - Phase: Iteration | Action: Starting iteration {self.current_iteration} | Reasoning: Working through task graph");
            
            # Get next task
            current_task = None;
            for task in task_graph {
                if task not in self.completed_tasks and task not in self.failed_tasks {
                    current_task = task;
                    break;
                }
            }
            
            if not current_task {
                self.coder.io.tool_output("Genius Agent - Phase: Completion | Action: All tasks completed | Reasoning: No more tasks in the queue");
                break;
            }
            
            # Store current task in node
            here.current_task = current_task;
            here.status = "processing";
            
            # Update the intelligent IO with current task context
            self.coder.io.set_context(current_task, planning_node.repo_context);
            
            # Enhanced editing with web search if needed
            self.coder.io.tool_output(f"Genius Agent - Phase: Editing/Code Generation | Action: Working on {current_task['name']} | Reasoning: Implementing {current_task['type']} with targeted approach");
            
            # Prepare the task message
            message = here.prepare_task_message(current_task, self.last_error_context);
            
            # Perform web search if beneficial
            if self.enable_web_search and here.need_web_search(current_task, self.web_searcher, self.last_error_context) {
                print(f"Performing web search for task: {current_task}");
                web_context = here.perform_web_search(current_task, self.web_searcher, self.last_error_context);
                print(f"Web search context: {web_context}");
                if web_context {
                    message += f"\n\nAdditional context from web search:\n{web_context}";
                    here.web_context = web_context;
                }
            }
            
            try {
                # Store the state before running the coder
                files_before = set(self.coder.abs_fnames) if self.coder.abs_fnames else set();
                repo_dirty_before = self.coder.repo.is_dirty() if self.coder.repo else False;
                
                # Temporarily disable auto-commits to prevent automatic committing
                original_auto_commits = self.coder.auto_commits;
                self.coder.auto_commits = False;
                
                self.coder.run(with_message=message);
                
                # Restore original auto-commit setting
                self.coder.auto_commits = original_auto_commits;
                
                edit_success = True;
                
                # Check if actual changes were made
                files_after = set(self.coder.abs_fnames) if self.coder.abs_fnames else set();
                repo_dirty_after = self.coder.repo.is_dirty() if self.coder.repo else False;
                
                # Validate that work was actually done
                files_added = files_after - files_before;
                changes_made = repo_dirty_after and not repo_dirty_before;
                
                if not files_added and not changes_made {
                    self.coder.io.tool_output("Warning: No files were created or modified. Task may not be complete.");
                    # Still consider it a success but flag for retry if it's a creation task
                    if 'create' in current_task.get('details', '').lower() {
                        edit_success = False;
                        self.last_error_context = "No files were created despite being a creation task";
                    }
                } else {
                    if files_added {
                        self.coder.io.tool_output(f"Files added: {', '.join(files_added)}");
                    }
                    if changes_made {
                        self.coder.io.tool_output("Changes detected in repository");
                    }
                }
            } except Exception as e {
                # Restore original auto-commit setting in case of error
                if 'original_auto_commits' in locals() {
                    self.coder.auto_commits = original_auto_commits;
                }
                self.coder.io.tool_output(f"Genius Agent - Phase: Editing | Action: Code generation failed | Reasoning: {str(e)}");
                edit_success = False;
                self.last_error_context = str(e);
            }
            
            if not edit_success {
                # Handle retry logic
                retry_count = current_task.get('retry_count', 0);
                if retry_count < 2 {
                    current_task['retry_count'] = retry_count + 1;
                    self.coder.io.tool_output(f"Genius Agent - Phase: Retry | Action: Retrying task {current_task['name']} | Reasoning: Attempt {retry_count + 2}/3 with error context");
                    # Add more specific instruction for retry
                    if 'create' in current_task.get('details', '').lower() and 'No files were created' in str(self.last_error_context) {
                        current_task['retry_details'] = f"RETRY: {current_task['details']}\n\nIMPORTANT: The previous attempt failed to create any files. You MUST create the actual implementation files. Do not just provide explanations or ask for confirmation.";
                    }
                    continue;
                } else {
                    self.failed_tasks.append(current_task);
                    self.coder.io.tool_output(f"Genius Agent - Phase: Failure | Action: Task failed after retries | Reasoning: {current_task['name']} failed 3 times, moving to next task");
                    continue;
                }
            }
            
            # Simple validation for now - can be enhanced
            validation_success = True;
            
            if validation_success {
                self.completed_tasks.append(current_task);
                self.last_error_context = None;
                
                # Auto-commit if enabled
                # if (self.coder.auto_commits and 
                #     self.coder.repo and 
                #     self.coder.repo.is_dirty()) {
                #     commit_msg = f"Genius Agent: {current_task['name']}";
                #     self.coder.commands.cmd_commit(commit_msg);
                #     self.coder.io.tool_output(f"Genius Agent - Phase: Git | Action: Changes committed | Reasoning: {commit_msg}");
                # }
            }
        }
        
        here.status = "completed";
        
        # Generate comprehensive report
        self.generate_comprehensive_report();
        
        # Move to validation node for final validation
        visit [-->];
    }

    # Handle validation phase - comprehensive validation
    can validate_code with ValidatorNode entry {
        print("Running comprehensive validation suite");
        print("Ensuring code quality, functionality, and security");
        
        (validation_success, validation_details) = here.code_execution_validation(self.coder, self.enable_security_scan);
        
        # Store validation results
        here.validation_results = validation_details;
        self.validation_results = validation_details;
        
        if validation_success {
            here.status = "passed";
            print("Final validation passed - All validation checks completed successfully");
        } else {
            here.status = "failed";
            print("Validation issues found - Some validation checks failed but execution continues");
            
            # Log specific validation failures
            if not validation_details['lint_passed'] {
                self.coder.io.tool_output("Lint issues found:");
                self.coder.io.tool_output(validation_details['lint_output']);
            }
            if not validation_details['tests_passed'] {
                self.coder.io.tool_output("Test failures found:");
                self.coder.io.tool_output(validation_details['test_output']);
            }
            if not validation_details['security_passed'] {
                self.coder.io.tool_output("Security issues found:");
                self.coder.io.tool_output(validation_details['security_output']);
            }
        }
        
        # Generate report before moving to user input
        self.generate_comprehensive_report();
        
        visit [-->];
    }

    # Handle user input and decide next action
    can handle_user_input with UserInputNode entry {
        here.status = "waiting";
        
        while True {
            (user_input, should_continue) = here.get_user_input(self.coder);
            
            if not should_continue {
                self.coder.io.tool_output("Genius Agent - Phase: Shutdown | Action: User requested exit | Reasoning: Gracefully shutting down");
                # End the walker execution
                return;
            }
            
            if user_input == "status" {
                here.show_status(self.coder);
                continue;
            }
            
            if user_input == "empty" {
                self.coder.io.tool_output("Please provide a task description or type 'exit' to quit.");
                continue;
            }
            
            if user_input {
                # Reset for new task
                self.task = user_input;
                self.task_explicitly_provided = True;
                self.planning_complete = False;
                self.last_error_context = None;
                self.current_iteration = 0;
                
                self.coder.io.tool_output(f"Genius Agent - Phase: New Task | Action: Starting new task | Reasoning: User provided new task: {user_input}");
                
                # Reset the intelligent IO context for the new task
                self.coder.io.set_context(None, None);
                
                # Create new nodes for the next cycle
                planning_node = PlanningNode(task=self.task, status="pending", planning_model=self.planning_model);
                editor_node = EditorNode(file_path="", content="", changes=[], status="pending", editor_model=self.editor_model);
                validator_node = ValidatorNode(file_path="", issues=[], status="pending", validation_model=self.editor_model);
                new_user_input_node = UserInputNode(status="waiting");
                
                # Connect the new workflow
                here ++> planning_node;
                planning_node ++> editor_node;
                editor_node ++> validator_node;
                validator_node ++> new_user_input_node;
                
                # Start the new cycle
                visit [-->];
                return;
            } else {
                here.show_status(self.coder);
                self.coder.io.tool_output("Please provide a valid task or type 'exit' to quit.");
            }
        }
    }

    # Handle reaching the end
    can finish with EndNode entry {
        success = len(self.completed_tasks) > 0;
        
        self.coder.io.tool_output(f"Genius Agent - Phase: Completion | Action: Genius Agent finished | Reasoning: Success: {success}, Completed: {len(self.completed_tasks)}, Failed: {len(self.failed_tasks)}");
        
        return success;
    }
    
    """Generate a comprehensive report of the agent's work"""
    def generate_comprehensive_report() {
        now = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime());
        report_md = [
            "# Genius Agent Task Report\n",
            "**Date/Time:** " + str(now) + "\n",
            "**Task Description:** " + str(self.task) + "\n",
            "**Iterations Completed:** " + str(self.current_iteration) + "/" + str(self.max_iterations) + "\n",
            "**Tasks Completed:** " + str(len(self.completed_tasks)) + "\n",
            "**Tasks Failed:** " + str(len(self.failed_tasks)) + "\n",
            "\n---\n"
        ];

        if self.completed_tasks {
            report_md.append("## Completed Tasks\n");
            for task in self.completed_tasks {
                report_md.append("- ✅ **" + str(task["name"]) + "**\n  - Type: " + str(task.get("type", "")) + "\n  - Details: " + str(task.get("details", "")) + "\n  - Files Changed: " + str(task.get("file", "N/A")) + "\n");
            }
            report_md.append("\n");
        }

        if self.failed_tasks {
            report_md.append("## Failed Tasks\n");
            for task in self.failed_tasks {
                report_md.append("- ❌ **" + str(task["name"]) + "**\n  - Type: " + str(task.get("type", "")) + "\n  - Details: " + str(task.get("details", "")) + "\n  - Files Changed: " + str(task.get("file", "N/A")) + "\n");
            }
            report_md.append("\n");
        }

        if self.validation_results {
            report_md.append("## Validation Results\n");
            report_md.append("- Lint: " + ("✅ PASSED" if self.validation_results["lint_passed"] else "❌ FAILED") + "\n");
            report_md.append("- Tests: " + ("✅ PASSED" if self.validation_results["tests_passed"] else "❌ FAILED") + "\n");
            report_md.append("- Security: " + ("✅ PASSED" if self.validation_results["security_passed"] else "❌ FAILED") + "\n");
            report_md.append("\n");
        }

        # Save report to reports/ folder
        safe_now = str(now).replace(" ", "_").replace(":", "-");
        report_dir = "aider-genius/reports";
        
        if not os.path.exists(report_dir) {
            os.makedirs(report_dir);
        }
        report_path = report_dir + "/report_" + safe_now + ".md";
        file = open(report_path, "w");
        file.write("\n".join(report_md));
        file.close();

        # Also output to tool_output for visibility
        for line in report_md {
            self.coder.io.tool_output(line);
        }
    }
}



# Legacy wrapper for backwards compatibility
obj GeniusMode {
    has coder: Any;
    has task: str;
    has max_iterations: int;
    has enable_web_search: bool = True;
    has enable_security_scan: bool = True;

    def __init__(coder: Any, task: Any = None, max_iterations: Any = 5, enable_web_search: bool = True, enable_security_scan: bool = True) {
        self.coder = coder;
        self.task = task or "Analyze and improve the codebase";
        self.max_iterations = max_iterations;
        self.enable_web_search = enable_web_search;
        self.enable_security_scan = enable_security_scan;
    }

    def run() -> bool {
        agent = GeniusAgent(
            coder=self.coder,
            task=self.task,
            max_iterations=self.max_iterations,
            enable_web_search=self.enable_web_search,
            enable_security_scan=self.enable_security_scan,
            planning_model=None
        ) spawn root;
        
        return True;  # The walker handles the actual execution
    }
}