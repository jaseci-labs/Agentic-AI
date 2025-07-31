# Genius Agent - AI-Powered Autonomous Development

The Genius Agent is an enhanced version of aider's Genius Mode that implements a sophisticated AI agent architecture for autonomous software development. The agent operates through multiple phases, creating a feedback loop that continuously improves code quality and functionality.

## Architecture Overview

The Genius Agent follows the proposed architecture with these key phases:

```
┌─────────────────┐    Fed back to the agent
│   Genius Agent │◄─────────────────────────────┐
└─────────┬───────┘                              │
          │                                      │
          ▼                                      │
┌─────────────────┐   ┌─────────────────────┐   │   ┌─────────────────┐
│ Planning phase  │──►│ Editing/Code        │──►│──►│ Code Execution/ │
│                 │   │ generation phase    │   │   │ Validation phase│
└─────────────────┘   └─────────────────────┘   │   └─────────────────┘
          │                       │               │             │
          ▼                       ▼               │             ▼
┌─────────────────┐   ┌─────────────────────┐   │   ┌─────────────────┐
│• Reads issue,   │   │• Web Search for     │   │   │• Run tests      │
│  repo map, and  │   │  Updates            │   │   │• Lint check     │
│  terminal output│   │• Generate / Edit    │   │   │• Safety/Security│
│• Plans task     │   │  Code               │   │   │  scan           │
│  graph          │   │                     │   │   │                 │
│  dynamically    │   │                     │   │   │                 │
└─────────────────┘   └─────────────────────┘   │   └─────────────────┘
                                                  │
                                                  │
                      ┌─────────────────────────────┘
                      │
                      ▼
              ┌─────────────────┐
              │ Generate        │
              │ report (.md)    │
              └─────────────────┘
```

## Key Features

### 1. Multi-Phase Architecture

- **Planning Phase**: Analyzes repository structure, creates dynamic task graphs
- **Editing/Code Generation**: Implements features with context-aware code generation
- **Code Execution/Validation**: Comprehensive testing, linting, and security scanning
- **Web Search Integration**: Searches for additional context when needed
- **Feedback Loop**: Uses validation results to improve subsequent iterations

### 2. Intelligent Task Management

- **Dynamic Task Graph**: Creates prioritized tasks based on analysis
- **Context Memory**: Maintains context across iterations
- **Error Handling**: Intelligent retry mechanisms with error context
- **Progress Tracking**: Detailed logging and reporting

### 3. Comprehensive Validation

- **Linting**: Code style and syntax checking
- **Testing**: Automated test execution
- **Security Scanning**: Basic security vulnerability detection
- **Quality Metrics**: Code quality assessment

## Usage Examples

### Basic Usage

```python
from aider.genius_mode import GeniusAgent
from aider.coders import Coder

# Create a coder instance
coder = Coder.create(model, edit_format, io)

# Create and run the Genius Agent
agent = GeniusAgent(
    coder=coder,
    task="Add comprehensive error handling to the user authentication system",
    max_iterations=5
)

success = agent.run()
```

### Advanced Configuration

```python
# Advanced agent with all features enabled
agent = GeniusAgent(
    coder=coder,
    task="Implement new API endpoints with full testing and documentation",
    max_iterations=10,
    enable_web_search=True,      # Enable web search for additional context
    enable_security_scan=True,   # Enable security vulnerability scanning
    planning_model=planning_model # Use a different model for planning
)

# Run the agent
success = agent.run()

# Get detailed report
report = agent.generate_report()
print(report)
```

### Integration with Existing Workflows

```python
# Use with existing aider setup
from aider.main import main
from aider.genius_mode import GeniusAgent

# Run in genius mode from command line arguments
if args.genius:
    genius = GeniusAgent(coder, task=args.message)
    success = genius.run()
else:
    # Regular aider operation
    coder.run()
```

## Command Line Usage

The Genius Agent can be activated through aider's command line interface:

```bash
# Basic genius mode
aider --genius "Implement user authentication with JWT tokens"

# Advanced genius mode with web search
aider --genius "Add real-time notifications" --enable-web-search

# Genius mode with custom iterations
aider --genius "Refactor database layer" --genius-iterations 8
```

## Configuration Options

### Agent Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `task` | str | None | The main task description for the agent |
| `max_iterations` | int | 10 | Maximum number of iterations to perform |
| `enable_web_search` | bool | True | Enable web search for additional context |
| `enable_security_scan` | bool | True | Enable security vulnerability scanning |
| `planning_model` | Model | None | Optional separate model for planning phase |

### Environment Variables

```bash
# Configure agent behavior
export AIDER_GENIUS_MAX_ITERATIONS=15
export AIDER_GENIUS_WEB_SEARCH=true
export AIDER_GENIUS_SECURITY_SCAN=true
```

## Phase Details

### Planning Phase

The planning phase performs comprehensive analysis:

1. **Repository Analysis**
   - Scans current file structure
   - Analyzes git status and history
   - Generates repository map

2. **Issue Detection**
   - Identifies linting issues
   - Detects test failures
   - Analyzes error patterns

3. **Task Graph Creation**
   - Creates prioritized task list
   - Considers dependencies
   - Balances urgency vs. importance

### Editing/Code Generation Phase

The editing phase implements intelligent code generation:

1. **Context Preparation**
   - Analyzes current task requirements
   - Prepares context-aware prompts
   - Includes error context from previous attempts

2. **Web Search Integration**
   - Searches for relevant documentation
   - Finds implementation examples
   - Gathers best practices

3. **Code Generation**
   - Generates targeted code changes
   - Maintains consistency with existing codebase
   - Implements error handling and edge cases

### Validation Phase

The validation phase ensures quality:

1. **Linting**
   - Runs configured linters
   - Checks code style compliance
   - Validates syntax correctness

2. **Testing**
   - Executes test suites
   - Validates functionality
   - Checks for regressions

3. **Security Scanning**
   - Detects common vulnerabilities
   - Checks for insecure patterns
   - Validates security best practices

## Error Handling and Recovery

The Genius Agent implements sophisticated error handling:

### Retry Mechanisms

- **Automatic Retries**: Up to 2 retries per task
- **Error Context**: Includes previous error information in retries
- **Progressive Learning**: Improves with each iteration

### Failure Recovery

- **Graceful Degradation**: Continues with other tasks if one fails
- **Context Preservation**: Maintains successful changes
- **Detailed Reporting**: Provides comprehensive failure analysis

### Validation Feedback

- **Smart Retries**: Analyzes validation failures
- **Targeted Fixes**: Focuses on specific failure types
- **Learning Loop**: Uses failure patterns to improve

## Integration Points

### Existing Aider Features

The Genius Agent integrates seamlessly with existing aider features:

- **Auto-commit**: Commits successful changes automatically
- **Linting**: Uses existing linter configuration
- **Testing**: Leverages configured test commands
- **Git Integration**: Works with existing git workflows

### Extension Points

The architecture supports easy extension:

```python
class CustomGeniusAgent(GeniusAgent):
    def custom_validation_phase(self):
        """Add custom validation logic"""
        # Your custom validation
        pass
    
    def custom_web_search(self, query):
        """Add custom search providers"""
        # Your custom search logic
        pass
```

## Performance Considerations

### Resource Usage

- **Model Calls**: Optimized to minimize API calls
- **Parallel Operations**: Runs validation checks in parallel where possible
- **Caching**: Caches repository analysis and search results

### Scalability

- **Large Codebases**: Efficiently handles large repositories
- **Long Tasks**: Supports long-running development tasks
- **Resource Management**: Monitors and manages resource usage

## Security Considerations

### Security Scanning

The agent includes basic security scanning:

- **Common Vulnerabilities**: Detects eval(), exec(), shell=True
- **Insecure Patterns**: Identifies pickle.loads() and similar
- **Custom Rules**: Supports additional security rules

### Safe Operations

- **Sandboxed Execution**: All operations run in controlled environment
- **No Arbitrary Execution**: No arbitrary code execution from web searches
- **Validation Gates**: Multiple validation stages prevent harmful changes

## Monitoring and Observability

### Logging

Comprehensive logging throughout all phases:

```python
# Example log output
🤖 Genius Agent - Phase: Planning
   Action: Analyzing repository structure
   Reasoning: Building comprehensive understanding of codebase
   files_analyzed: 15
   issues_found: 3

🤖 Genius Agent - Phase: Validation
   Action: Validation complete: ✅ PASSED
   Reasoning: All validation checks completed
   Lint: ✅
   Tests: ✅
   Security: ✅
```

### Metrics

- **Success Rate**: Track task completion rates
- **Iteration Efficiency**: Monitor iterations per successful task
- **Validation Pass Rate**: Track validation success rates
- **Time to Completion**: Monitor performance metrics

### Reporting

Detailed reports include:

- **Task Summary**: Completed and failed tasks
- **Validation Results**: Detailed test and lint results
- **Performance Metrics**: Time and iteration counts
- **Recommendations**: Suggestions for improvement

## Backwards Compatibility

The enhanced Genius Agent maintains full backwards compatibility:

```python
# Old interface still works
from aider.genius_mode import GeniusMode

genius = GeniusMode(coder, task="my task", max_iterations=5)
success = genius.run()

# But now with enhanced capabilities under the hood
```

## Future Enhancements

Planned improvements include:

1. **Machine Learning**: Learn from successful patterns
2. **Advanced Planning**: More sophisticated task dependency analysis
3. **Custom Validation**: Pluggable validation frameworks
4. **Team Integration**: Multi-developer collaboration features
5. **Advanced Security**: Integration with professional security tools

## Troubleshooting

### Common Issues

1. **Web Search Failures**
   - Check internet connectivity
   - Verify search provider configuration
   - Disable web search if needed: `enable_web_search=False`

2. **Validation Failures**
   - Check linter and test configuration
   - Verify test commands are correct
   - Review security scan settings

3. **Performance Issues**
   - Reduce max_iterations for faster execution
   - Disable features not needed
   - Use lighter models for planning

### Debug Mode

Enable debug mode for detailed information:

```python
agent = GeniusAgent(coder, task="debug task")
agent.coder.verbose = True  # Enable verbose logging
success = agent.run()
```

## Contributing

To contribute to the Genius Agent:

1. **Fork the Repository**
2. **Create Feature Branch**
3. **Add Tests**: Include comprehensive tests
4. **Update Documentation**: Update this documentation
5. **Submit Pull Request**

### Development Setup

```bash
# Clone the repository
git clone https://github.com/Aider-AI/aider.git
cd aider

# Install development dependencies
pip install -e ".[dev]"

# Run tests
python -m pytest tests/ -v

# Run the genius agent demo
python demo_genius_agent.py
```

---

The Genius Agent represents a significant advancement in AI-powered development tools, providing autonomous, intelligent, and safe code generation and improvement capabilities.
