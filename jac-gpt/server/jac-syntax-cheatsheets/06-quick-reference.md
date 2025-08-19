# Jac Quick Reference & Best Practices

## Essential Jac Syntax at a Glance

### Core Language Elements
```jac
# Entry point
with entry { ... }

# Variables (type annotations mandatory)
name: str = "value";
count: int = 42;
items: list[str] = [];

# Functions
def func_name(param: type) -> return_type { ... }

# Objects
obj ClassName {
    has attribute: type;
    def method() -> type { ... }
}

# Global variables
glob var_name: type = value;
:g: var_name;  # Access global
```

### Object-Spatial Programming
```jac
# Nodes (data containers)
node NodeName {
    has data: type;
    can ability with WalkerType entry { ... }
}

# Edges (relationships)
edge EdgeName { has property: type; }
node1 +:EdgeName:property=value:+> node2;

# Walkers (mobile computation)
walker WalkerName {
    has state: type;
    can ability with entry { visit [-->]; }
}

# Spawn walker
walker_instance = WalkerName() spawn root;
```

### Navigation Patterns
```jac
visit [-->];              # Visit successors
visit [<--];              # Visit predecessors
visit [-->(`?NodeType)];  # Visit specific node type
visit [:EdgeType:-->];    # Navigate via edge type
disengage;                # Stop walker
```

## Common Patterns and Idioms

### Data Processing Pipeline
```jac
walker DataPipeline {
    has data: list = [];
    has processed: list = [];
    
    can process with entry {
        for item in self.data {
            result = self.transform(item);
            if self.validate(result) {
                self.processed.append(result);
            }
        }
        visit [-->];
    }
    
    def transform(item) -> dict { return {"processed": item}; }
    def validate(item) -> bool { return item is not None; }
}
```

### Service-Oriented Architecture
```jac
node Service {
    has name: str;
    can handle_request with RequestWalker entry {
        response = self.process_request(here.data);
        here.response = response;
    }
    def process_request(data: dict) -> dict { return data; }
}

walker RequestWalker {
    has data: dict;
    has response: dict = {};
    can make_request with entry { visit [-->(`?Service)]; }
}
```

### Event-Driven Architecture
```jac
node EventHub {
    has subscribers: list = [];
    can publish_event with EventWalker entry {
        for subscriber in self.subscribers {
            NotificationWalker(event=here.event) spawn subscriber;
        }
    }
}

walker EventWalker {
    has event: dict;
    can publish with entry { visit [-->(`?EventHub)]; }
}
```

## Best Practices

### Code Organization
```jac
# 1. Group related functionality
node UserService {
    # All user-related operations in one place
    def create_user(data: dict) -> dict { ... }
    def update_user(id: str, data: dict) -> dict { ... }
    def delete_user(id: str) -> bool { ... }
}

# 2. Use inheritance for shared behavior
node BaseService {
    has created_at: str;
    def log_operation(op: str) { ... }
}

node UserService(BaseService) { ... }
node OrderService(BaseService) { ... }

# 3. Separate interface from implementation
node Calculator {
    def add(a: float, b: float) -> float;
    def multiply(a: float, b: float) -> float;
}

impl Calculator {
    def add(a: float, b: float) -> float { return a + b; }
    def multiply(a: float, b: float) -> float { return a * b; }
}
```

### Error Handling
```jac
walker RobustWalker {
    has errors: list[str] = [];
    
    can safe_operation with entry {
        try {
            self.risky_operation();
        } except SpecificError as e {
            self.errors.append(f"Known error: {e}");
            # Handle gracefully
        } except Exception as e {
            self.errors.append(f"Unexpected error: {e}");
            # Log and continue or disengage
        }
    }
    
    def risky_operation() { ... }
}
```

### Type Safety
```jac
# Always use explicit types
def process_data(data: list[dict[str, str]]) -> dict[str, int] {
    # Clear input/output contracts
    result: dict[str, int] = {};
    for item in data {
        result[item["key"]] = len(item["value"]);
    }
    return result;
}
```

### Performance Considerations
```jac
walker EfficientWalker {
    can optimize_traversal with entry {
        # Avoid unnecessary visits
        if not self.should_process(here) {
            return;
        }
        
        # Batch operations when possible
        batch_data = self.collect_batch();
        if len(batch_data) >= 10 {
            self.process_batch(batch_data);
        }
        
        # Use specific navigation
        visit [-->(`?TargetType)];  # Don't visit all nodes
    }
    
    def should_process(node) -> bool { ... }
    def collect_batch() -> list { ... }
    def process_batch(data: list) { ... }
}
```

## Common Anti-Patterns to Avoid

### ❌ Don't: Global State Abuse
```jac
# Avoid excessive global variables
glob user_data: dict = {};  # Bad: global mutable state
glob current_user: str = "";  # Bad: unclear ownership
```

### ✅ Do: Localized State
```jac
# Keep state in appropriate contexts
walker UserSession {
    has user_data: dict;
    has session_id: str;
    # State travels with the walker
}
```

### ❌ Don't: Deep Inheritance Hierarchies
```jac
# Avoid complex inheritance chains
node A { ... }
node B(A) { ... }
node C(B) { ... }  # Getting complex
node D(C) { ... }  # Too deep
```

### ✅ Do: Composition Over Inheritance
```jac
# Use composition and abilities
node DataProcessor {
    can process with DataWalker entry { ... }
}

node ValidationService {
    can validate with DataWalker entry { ... }
}
```

### ❌ Don't: Monolithic Walkers
```jac
walker DoEverything {
    # Avoid walkers that do too many things
    can process_data with entry { ... }
    can send_emails with entry { ... }
    can update_database with entry { ... }
    can generate_reports with entry { ... }  # Too much responsibility
}
```

### ✅ Do: Single Responsibility Walkers
```jac
walker DataProcessor {
    can process with entry { ... }  # Only processes data
}

walker EmailService {
    can send with entry { ... }  # Only sends emails
}
```

## Testing Strategies

### Unit Testing
```jac
test test_node_behavior {
    node TestNode {
        has value: int;
        def double() -> int { return self.value * 2; }
    }
    
    node = TestNode(value=5);
    assert node.double() == 10;
}

test test_walker_traversal {
    walker TestWalker {
        has count: int = 0;
        can count_nodes with entry {
            self.count += 1;
            visit [-->];
        }
    }
    
    # Set up test graph
    root ++> TestNode(value=1);
    root ++> TestNode(value=2);
    
    walker = TestWalker() spawn root;
    assert walker.count == 3;  # root + 2 nodes
}
```

### Integration Testing
```jac
test test_service_integration {
    # Test complete workflows
    service = UserService() spawn root;
    request = RequestWalker(data={"name": "test"}) spawn root;
    
    assert request.response["status"] == "success";
}
```

## Debugging Tips

### Add Logging
```jac
walker DebuggableWalker {
    has debug: bool = True;
    
    can debug_traverse with entry {
        if self.debug {
            print(f"Visiting: {here} at {self.get_timestamp()}");
        }
        visit [-->];
    }
    
    def get_timestamp() -> str {
        import {datetime} with "://" py "from datetime import datetime";
        return datetime.now().isoformat();
    }
}
```

### State Inspection
```jac
walker StateInspector {
    can inspect with entry {
        print(f"Walker state: {self.__dict__}");
        print(f"Node state: {here.__dict__ if hasattr(here, '__dict__') else 'No state'}");
        print(f"Connections: {len([-->])} out, {len([<--])} in");
    }
}
```

### Conditional Debugging
```jac
walker ConditionalDebugger {
    has debug_condition: str = "node_type";
    
    can conditional_debug with entry {
        if self.should_debug(here) {
            self.detailed_inspection(here);
        }
        visit [-->];
    }
    
    def should_debug(node) -> bool {
        return isinstance(node, DebugTarget);
    }
    
    def detailed_inspection(node) {
        print(f"Debug: {node}");
        # Add breakpoint logic here
    }
}
```

## Performance Optimization

### Efficient Graph Traversal
```jac
walker OptimizedTraversal {
    has visited: set = set();
    
    can avoid_cycles with entry {
        node_id = id(here);
        if node_id in self.visited {
            return;  # Skip already visited nodes
        }
        self.visited.add(node_id);
        
        # Process and continue
        visit [-->];
    }
}
```

### Batch Processing
```jac
walker BatchProcessor {
    has batch_size: int = 100;
    has current_batch: list = [];
    
    can batch_process with entry {
        self.current_batch.append(here);
        
        if len(self.current_batch) >= self.batch_size {
            self.process_batch(self.current_batch);
            self.current_batch = [];
        }
        
        visit [-->];
    }
    
    def process_batch(batch: list) {
        # Efficient batch processing
        pass;
    }
}
```
