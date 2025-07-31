<p align="center">
    <img src="https://aider.chat/assets/logo.svg" alt="Aider Logo" width="300">
</p>

<h1 align="center">
Aider-Genius: Agentic AI Pair Programming
</h1>

<p align="center">
An enhanced version of Aider featuring Genius mode - an intelligent agentic workflow for planning, coding, and validating software projects.
</p>

---

## Overview

Aider-Genius is an advanced enhancement of the popular [Aider](https://github.com/Aider-AI/aider) AI pair programming tool. It introduces **Genius mode**, a sophisticated agentic workflow that elevates AI-assisted development by incorporating intelligent planning, systematic coding, and comprehensive validation phases.

## Key Features

### 🧠 **Genius Mode - Agentic Workflow**
- **Intelligent Planning**: AI analyzes requirements and creates comprehensive development plans
- **Systematic Coding**: Structured approach to implementing features with iterative refinement
- **Comprehensive Validation**: Automated testing, code review, and quality assurance
- **Adaptive Learning**: Learns from project patterns and improves suggestions over time

### 🤖 **Enhanced AI Capabilities**
- **Multi-phase development**: Planning → Coding → Validation → Iteration
- **Context-aware decisions**: Deep understanding of project architecture and goals
- **Quality assurance**: Built-in code review and optimization suggestions
- **Error prevention**: Proactive identification of potential issues before implementation

### 🛠️ **Advanced Development Tools**
- **Project architecture analysis**: Understands and respects existing code patterns
- **Intelligent refactoring**: Suggests and implements code improvements
- **Dependency management**: Handles complex project dependencies intelligently
- **Documentation generation**: Creates comprehensive documentation alongside code

### 🎯 **Productivity Enhancements**
- **Goal-oriented development**: Maintains focus on project objectives
- **Iterative improvement**: Continuous refinement of code quality
- **Knowledge retention**: Builds project-specific knowledge over time
- **Best practices enforcement**: Ensures code follows industry standards

## Quick Start

### Installation

```bash
# Clone the Aider-Genius repository
git clone https://github.com/udithishanka/jac-coder.git
cd jac-coder

# Set up the environment
python -m pip install -e .

# Configure your AI model API keys
export ANTHROPIC_API_KEY=your_key_here
export OPENAI_API_KEY=your_key_here
export DEEPSEEK_API_KEY=your_key_here
```

### Basic Usage

```bash
# Start Aider-Genius in your project directory
cd /path/to/your/project
python -m aider.main --genius

# Describe your project goals
aider> "I want to build a REST API for user authentication with proper security"

# Let Genius mode plan, code, and validate
# The AI will:
# 1. Analyze requirements and create a development plan
# 2. Implement features systematically
# 3. Validate code quality and functionality
# 4. Iterate based on feedback and testing
```

## Genius Mode Workflow

### Phase 1: Planning 🧭
- **Requirement Analysis**: Deep understanding of project goals and constraints
- **Architecture Design**: Creates optimal code structure and component relationships
- **Task Breakdown**: Divides complex features into manageable implementation steps
- **Risk Assessment**: Identifies potential challenges and mitigation strategies

### Phase 2: Coding 💻
- **Systematic Implementation**: Follows the planned approach with intelligent adaptations
- **Code Quality Focus**: Maintains high standards for readability and maintainability
- **Pattern Recognition**: Leverages established patterns and best practices
- **Progressive Enhancement**: Builds features incrementally with validation at each step

### Phase 3: Validation ✅
- **Code Review**: Automated analysis for bugs, security issues, and improvements
- **Testing Integration**: Generates and runs appropriate tests for new functionality
- **Performance Analysis**: Identifies optimization opportunities
- **Documentation Check**: Ensures code is properly documented and explained

### Phase 4: Iteration 🔄
- **Feedback Integration**: Incorporates user feedback and test results
- **Continuous Improvement**: Refines implementation based on validation outcomes
- **Knowledge Update**: Updates project understanding for future tasks
- **Quality Assurance**: Final review and cleanup before completion

## Architecture

Aider-Genius extends the original Aider architecture with intelligent agentic components.

## Features in Detail

### Intelligent Planning Agent
- **Project Analysis**: Deep understanding of existing codebase and requirements
- **Strategic Planning**: Creates comprehensive development roadmaps
- **Resource Optimization**: Efficient allocation of development effort
- **Risk Mitigation**: Identifies and addresses potential challenges early

### Enhanced Coding Agent
- **Context-Aware Development**: Maintains awareness of project goals throughout coding
- **Pattern-Based Implementation**: Leverages proven design patterns and best practices
- **Incremental Development**: Builds features step-by-step with validation
- **Adaptive Coding**: Adjusts approach based on project feedback and constraints

### Comprehensive Validation Agent
- **Multi-Layer Testing**: Unit, integration, and system-level test generation
- **Security Analysis**: Identifies and addresses security vulnerabilities
- **Performance Optimization**: Analyzes and improves code performance
- **Code Quality Metrics**: Maintains high standards for maintainability and readability

### Workflow Coordination
- **Phase Management**: Seamless transitions between planning, coding, and validation
- **Progress Tracking**: Monitors development progress against project goals
- **Knowledge Persistence**: Retains project insights across development sessions
- **Adaptive Learning**: Improves recommendations based on project history

### Development Workflow
Genius mode integrates seamlessly with modern development practices:
- **Git Integration**: Intelligent commit messages and branch management
- **CI/CD Compatibility**: Works with existing continuous integration pipelines
- **Code Review Integration**: Automated pre-review analysis and suggestions
- **Documentation Sync**: Keeps documentation updated with code changes

## Configuration

### API Keys
Set up your preferred AI model:

```bash
# Environment variables
export ANTHROPIC_API_KEY=your_key_here
export OPENAI_API_KEY=your_key_here
export DEEPSEEK_API_KEY=your_key_here
```

## Examples

### Building a Complete Feature
```bash
aider> /genius on
aider> "Build a user authentication system with JWT tokens, password hashing, and role-based access control"

# Genius mode will:
# 1. Plan the authentication architecture
# 2. Design database schemas and API endpoints
# 3. Implement security best practices
# 4. Create comprehensive tests
# 5. Generate documentation
# 6. Validate security and performance
```

### Code Refactoring with Analysis
```bash
aider> "Refactor this legacy module to improve maintainability and performance"

# Genius mode will:
# 1. Analyze current code structure and issues
# 2. Plan refactoring strategy with minimal breaking changes
# 3. Implement improvements incrementally
# 4. Validate functionality preservation
# 5. Update tests and documentation
```

### Complex System Design
```bash
aider> "Design and implement a microservices architecture for an e-commerce platform"

# Genius mode will:
# 1. Plan service boundaries and communication patterns
# 2. Design data models and API contracts
# 3. Implement services with proper error handling
# 4. Create monitoring and logging systems
# 5. Validate system integration and performance
```

## Contributing

Aider-Genius builds on the excellent foundation of [Aider](https://github.com/Aider-AI/aider) by adding sophisticated agentic capabilities for enhanced AI-assisted development.

### Development Setup

```bash
# Clone the repository
git https://github.com/udithishanka/jac-coder
cd jac-coder

# Set up development environment
python3 -m venv venv
source venv/bin/activate
pip install -e .
pip install -r requirements-dev.txt
```

### Contributing to Genius Mode

We welcome contributions to enhance the agentic workflow:

1. **Planning Agents**: Improve requirement analysis and project planning
2. **Coding Agents**: Enhance pattern recognition and code generation
3. **Validation Agents**: Add new testing and quality assurance capabilities
4. **Workflow Coordination**: Optimize agent communication and task management


## Documentation

- [Original Aider Documentation](https://aider.chat/docs/) - Base functionality and features
- [Genius Mode Guide](docs/genius-mode.md) - Detailed guide to agentic workflow
- [Agent Development](docs/agent-development.md) - Creating custom agents
- [Workflow Customization](docs/workflow-customization.md) - Configuring the agentic workflow
- [API Reference](docs/api-reference.md) - Programming interface documentation

## Related Projects

- **[Aider](https://github.com/Aider-AI/aider)**: The original AI pair programming tool
- **[Jaseci](https://github.com/Jaseci-Labs/jaseci)**: The Jaseci AI development platform
- **[AutoGPT](https://github.com/Significant-Gravitas/AutoGPT)**: Autonomous AI agent framework

## License

This project maintains the same license as the original Aider project. See the [LICENSE](LICENSE) file for details.

## Community

- [GitHub Discussions](https://github.com/jaseci-labs/Agentic-AI/discussions) - Project discussions and Q&A
- [Original Aider Discord](https://discord.gg/Y7X7bhMQFV) - General Aider community
- [Issues](https://github.com/jaseci-labs/Agentic-AI/issues) - Bug reports and feature requests

---

*Revolutionizing AI pair programming with intelligent agentic workflows for the future of software development.*
