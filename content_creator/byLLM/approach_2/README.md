# Content Creator - Approach 2

A streamlined multi-agent workflow system for automated content creation using Jac language, featuring intelligent routing, iterative refinement, and quality assurance through specialized agents.

## Architecture

The system is built on **Jaseci Stack** where **agents are walkers** that navigate through **nodes representing specialized roles**.

### Core Concept

- **Walkers (Agents)**: Mobile entities that execute specific tasks (planning, writing, reviewing)
- **Nodes (Agent Roles)**: Specialized agent nodes with domain-specific capabilities
- **Supervisor Pattern**: Centralized routing logic that determines workflow progression
- **State Management**: Session-based state tracking with execution history

### Agent Workflow

| Agent | Role | Capabilities |
|-------|------|-------------|
| `Supervisor` | Workflow Controller | Routes to appropriate agent based on current state and stage |
| `PlannerAgent` | Content Strategy | Creates detailed content plans with objectives and structure |
| `WriterAgent` | Content Creation | Writes/revises content based on plan and review feedback |
| `ReviewAgent` | Quality Assurance | Evaluates content quality, word count, and approval status |

### Workflow Stages

The system progresses through distinct stages:

1. **PLANNING**: Initial content strategy creation
2. **WRITING**: Content generation based on plan
3. **REVIEWING**: Quality evaluation and feedback
4. **REVISING**: Content improvement iteration (if rejected)
5. **COMPLETED**: Final approval and workflow termination

## Features

- **Stage-Based Workflow**: Clear progression through planning, writing, and review stages
- **Iterative Refinement**: Automatic revision cycles with feedback integration
- **Loop Prevention**: Smart detection of infinite loops and circular patterns
- **Quality Control**: Word count limits and content approval criteria
- **Session Persistence**: State management across agent interactions
- **Execution Tracking**: JSONL logging of all agent outputs
- **Max Revision Safety**: Automatic completion after 5 revision attempts

## Installation

1. **Clone and navigate to the directory**:
   ```bash
   cd content_creator/byLLM/approach_2
   ```

2. **Install dependencies**:
   ```bash
   pip install byllm python-dotenv
   ```

3. **Set up environment variables**:

4. **Required API Keys**:
   - `OPENAI_API_KEY`: For GPT models (required for LLM reasoning)

## Usage

Run the content creator:
```bash
jac run main.jac
```

### Configuration

Edit the `utterance` variable in `main.jac` to customize your content request:

```python
with entry {
    utterance = "Generate a readme post regarding Agentic AI.";
    agent_executor(utterance=utterance) spawn root;
}
```


## Output Files

- `output.jsonl`: Agent interaction logs with timestamps
- Console output displays final content upon workflow completion

## Execution Flow

1. **Planning Phase**: 
   - `PlannerAgent` creates content structure and strategy
   - Sets stage to `WRITING`

2. **Writing Phase**: 
   - `WriterAgent` generates content based on plan
   - Sets stage to `REVIEWING`

3. **Review Phase**: 
   - `ReviewAgent` evaluates content quality and word count
   - Provides approval decision and detailed feedback
   - If approved: Sets stage to `COMPLETED`
   - If rejected: Sets stage to `REVISING`, increments revision count

4. **Revision Phase** (if needed):
   - `WriterAgent` receives feedback and revises content
   - Returns to `REVIEWING` stage
   - Max 5 revision attempts before forced completion

5. **Completion**: 

   - Supervisor routes to `END`
   - Final content displayed
   - Workflow terminates


### Supervisor Pattern
The `Supervisor` node acts as a central controller that:
- Analyzes current workflow state
- Determines next agent based on stage
- Routes walker to appropriate agent node
- Handles workflow termination

### State Management
`Session` object maintains:
- **current_state**: Workflow stage, content, plan, feedback, approval status
- **agent_execution_sequence**: Tracks agent call order
- **execution_count**: Total number of agent invocations
- **history**: Conversation and action history

### Loop Prevention
Built-in safety mechanisms:
- Maximum 10 iterations per workflow
- Detection of consecutive same-agent calls
- Ping-pong pattern detection (A→B→A→B)
- Automatic workflow termination on loop detection

### Quality Assurance
`ReviewAgent` uses LLM reasoning to:
- Evaluate content against plan objectives
- Check word count compliance
- Provide detailed improvement feedback
- Make approval decisions

## Key Differences from Approach 1

- **No External Tools**: Focuses on pure LLM-driven workflow without web search or media generation
- **Simplified Architecture**: Direct agent-to-agent flow with supervisor routing
- **Stage-Based Logic**: Explicit workflow stages guide agent selection
- **Built-in Loop Prevention**: Advanced detection of circular patterns
- **Revision Limits**: Automatic completion after max revision attempts
- **Reasoning-Based Review**: Uses LLM reasoning method for structured review output
