# Jac Syntax Cheat Sheets

A comprehensive collection of cheat sheets for the Jac programming language, covering all essential syntax and patterns for Object-Spatial Programming.

## Cheat Sheet Index

### 📚 [01. Basic Syntax](./01-basic-syntax.md)
- Entry points and program structure
- Variables and mandatory type annotations
- Functions and objects
- Control flow and collections
- String formatting and comments

### 🌐 [02. Object-Spatial Programming](./02-object-spatial.md)
- Nodes: data containers with abilities
- Edges: typed relationships
- Walkers: mobile computation
- Graph navigation patterns
- Node and walker inheritance

### 🤖 [03. AI Integration (MTLLM)](./03-ai-integration.md)
- MTLLM setup and configuration
- AI-integrated functions with `by` keyword
- Semantic strings and LLM-powered processing
- AI-enhanced nodes and walkers
- Multi-agent AI systems

### ⚡ [04. Advanced Features](./04-advanced-features.md)
- Implementation blocks (`impl`)
- Complex node abilities and state management
- Advanced walker patterns
- Inline Python integration
- Testing framework and debugging

### ☁️ [05. Cloud & Deployment](./05-cloud-deployment.md)
- Scale-agnostic design patterns
- HTTP API development
- Database integration
- Authentication and middleware
- WebSocket support and monitoring

### 🚀 [06. Quick Reference & Best Practices](./06-quick-reference.md)
- Essential syntax summary
- Common patterns and idioms
- Best practices and anti-patterns
- Testing strategies
- Performance optimization

## About Jac

Jac is a revolutionary programming language that introduces **Object-Spatial Programming (OSP)**, where computation moves to data rather than data moving to computation. This enables naturally distributed and scale-agnostic applications.

### Key Features:
- **Nodes**: Stateful entities that hold data
- **Edges**: Typed relationships between nodes
- **Walkers**: Mobile computation that traverses graphs
- **Scale-Agnostic**: Same code runs locally and in cloud
- **AI-Native**: Built-in LLM integration via MTLLM
- **Type-Safe**: Mandatory type annotations

### Quick Start
```bash
# Install Jac
pip install jaclang

# Run a Jac program
jac run myprogram.jac

# Serve as web API
jac serve myprogram.jac
```

### Hello World
```jac
with entry {
    print("Hello, Jac World!");
}
```

### Object-Spatial Example
```jac
node Person {
    has name: str;
    has age: int;
}

walker Greeter {
    can greet with Person entry {
        print(f"Hello, {here.name}!");
        visit [-->];
    }
}

with entry {
    alice = root ++> Person(name="Alice", age=30);
    bob = alice ++> Person(name="Bob", age=25);
    
    Greeter() spawn root;
}
```

## Usage Instructions

These cheat sheets are designed for:
1. **LLM Reference**: Provide these to language models for accurate Jac code generation
2. **Developer Reference**: Quick syntax lookup during development
3. **Learning Resource**: Structured introduction to Jac concepts

Each cheat sheet includes:
- ✅ Complete, runnable code examples
- 📝 Clear explanations of syntax
- 🔧 Practical patterns and use cases
- ⚠️ Common pitfalls and best practices

## Examples Organization

Examples progress from basic to advanced:
- **Basic Syntax**: Fundamental language features
- **Object-Spatial**: Core Jac paradigm concepts  
- **AI Integration**: Modern LLM-powered development
- **Advanced Features**: Power-user capabilities
- **Cloud Deployment**: Production-ready patterns
- **Quick Reference**: Instant lookup guide

Start with the basic syntax if you're new to Jac, or jump to specific topics based on your needs.
