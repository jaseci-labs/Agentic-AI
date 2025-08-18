# Jac Advanced Features Cheat Sheet

## Implementation Blocks (impl)

### Separating Interface from Implementation
```jac
# Define interface in node/object
node Calculator {
    has current_value: float = 0.0;
    
    # Declare method signatures
    def add(value: float) -> float;
    def multiply(value: float) -> float;
    def get_result() -> float;
}

# Implement methods separately
impl Calculator {
    def add(value: float) -> float {
        self.current_value += value;
        return self.current_value;
    }
    
    def multiply(value: float) -> float {
        self.current_value *= value;
        return self.current_value;
    }
    
    def get_result() -> float {
        return self.current_value;
    }
}
```

### Walker Implementation
```jac
walker DataProcessor {
    has processed_items: list[str] = [];
    
    # Declare abilities
    can process_data with entry;
    can finalize with exit;
}

impl DataProcessor {
    can process_data with entry {
        if isinstance(here, DataNode) {
            self.processed_items.append(here.data);
        }
        visit [-->];
    }
    
    can finalize with exit {
        print(f"Processed {len(self.processed_items)} items");
    }
}
```

## Advanced Node Features

### Node with Complex Abilities
```jac
node SmartNode {
    has data: dict = {};
    has visitors: list[str] = [];
    has state: str = "idle";
    
    # Multiple entry conditions
    can handle_analyzer with AnalyzerWalker entry {
        self.state = "analyzing";
        here.analysis_result = self.perform_analysis(here.query);
    }
    
    can handle_modifier with ModifierWalker entry {
        self.state = "modifying";
        self.apply_modifications(here.modifications);
    }
    
    # Exit handlers
    can cleanup_analyzer with AnalyzerWalker exit {
        self.state = "idle";
        self.visitors.append(f"analyzer_{here.id}");
    }
    
    def perform_analysis(query: str) -> dict {
        # Complex analysis logic
        return {"status": "complete", "query": query};
    }
    
    def apply_modifications(mods: dict) {
        self.data.update(mods);
    }
}
```

### Node State Management
```jac
node StatefulNode {
    has current_state: str = "initialized";
    has state_history: list[str] = [];
    has lock: bool = False;
    
    can transition_state with StateWalker entry {
        if not self.lock {
            old_state = self.current_state;
            self.current_state = here.target_state;
            self.state_history.append(f"{old_state} -> {self.current_state}");
        }
    }
    
    def lock_state() {
        self.lock = True;
    }
    
    def unlock_state() {
        self.lock = False;
    }
}
```

## Advanced Walker Patterns

### Multi-Phase Walker
```jac
walker MultiPhaseProcessor {
    has phase: str = "discovery";
    has discovered_nodes: list = [];
    has processed_data: dict = {};
    
    can phase_discovery with entry {
        if self.phase == "discovery" {
            if isinstance(here, DataNode) {
                self.discovered_nodes.append(here);
            }
            visit [-->];
            
            # Switch to processing phase
            if len([-->]) == 0 {  # No more nodes to visit
                self.phase = "processing";
                self.process_discovered_nodes();
            }
        }
    }
    
    can phase_processing with entry {
        if self.phase == "processing" {
            # Process each discovered node
            for node in self.discovered_nodes {
                self.processed_data[node.id] = node.process();
            }
            self.phase = "complete";
        }
    }
    
    def process_discovered_nodes() {
        print(f"Processing {len(self.discovered_nodes)} discovered nodes");
    }
}
```

### Conditional Walker Navigation
```jac
walker ConditionalExplorer {
    has max_depth: int = 3;
    has current_depth: int = 0;
    has criteria: dict;
    
    can explore_conditionally with entry {
        self.current_depth += 1;
        
        # Different navigation based on node type and depth
        if isinstance(here, CriticalNode) {
            visit [-->];  # Always explore from critical nodes
        } elif self.current_depth < self.max_depth {
            if self.meets_criteria(here) {
                visit [-->(`?TargetNode)];  # Only visit target nodes
            }
        } else {
            disengage;  # Stop at max depth
        }
    }
    
    def meets_criteria(node) -> bool {
        # Custom criteria evaluation
        return hasattr(node, 'priority') and node.priority > 5;
    }
}
```

## Advanced Edge Features

### Complex Edge Relationships
```jac
edge ComplexRelation {
    has relationship_type: str;
    has strength: float;
    has metadata: dict = {};
    has created_at: str;
    has is_active: bool = True;
}

edge TemporalEdge {
    has start_time: str;
    has end_time: str;
    has duration: int;
}

with entry {
    node1 = root ++> Person(name="Alice", age=25);
    node2 = node1 ++> Person(name="Bob", age=30);
    
    # Complex edge with metadata
    node1 +>:ComplexRelation:
        relationship_type="colleague",
        strength=0.8,
        metadata={"department": "engineering", "project": "jac-dev"},
        created_at="2024-01-01",
        is_active=True
    :+> node2;
}
```

### Dynamic Edge Creation
```jac
walker RelationshipBuilder {
    has relationship_rules: dict;
    
    can build_relationships with entry {
        nearby_nodes = [-->];
        for node in nearby_nodes {
            relation_type = self.determine_relationship(here, node);
            if relation_type {
                self.create_dynamic_edge(here, node, relation_type);
            }
        }
    }
    
    def determine_relationship(node1, node2) -> str {
        # Logic to determine relationship type
        if hasattr(node1, 'department') and hasattr(node2, 'department') {
            if node1.department == node2.department {
                return "colleague";
            }
        }
        return None;
    }
    
    def create_dynamic_edge(node1, node2, rel_type: str) {
        # Dynamically create edge based on relationship type
        if rel_type == "colleague" {
            node1 +>:WorkRelation:type=rel_type:+> node2;
        }
    }
}
```

## Inline Python Integration

### Using Python Libraries
```jac
# Inline Python for complex operations
import {*} with "://" py """
import numpy as np
import pandas as pd
from datetime import datetime

def complex_calculation(data):
    arr = np.array(data)
    return np.mean(arr) * np.std(arr)

def process_dataframe(data_dict):
    df = pd.DataFrame(data_dict)
    return df.describe().to_dict()
""";

with entry {
    data = [1, 2, 3, 4, 5];
    result = complex_calculation(data);
    print(f"Result: {result}");
    
    data_dict = {"values": [1, 2, 3], "labels": ["a", "b", "c"]};
    stats = process_dataframe(data_dict);
    print(f"Statistics: {stats}");
}
```

### Python Integration in Walkers
```jac
walker DataScientist {
    has analysis_tools: str = "";
    
    can analyze_with_python with DataNode entry {
        # Inline Python for data analysis
        result = """
        import pandas as pd
        import numpy as np
        
        # Process the node data
        data = here.dataset
        df = pd.DataFrame(data)
        
        # Perform analysis
        analysis = {
            'mean': df.mean().to_dict(),
            'std': df.std().to_dict(),
            'correlations': df.corr().to_dict()
        }
        
        return analysis
        """ py ;
        
        here.analysis_result = result;
    }
}
```

## Testing Framework

### Unit Tests
```jac
test test_node_creation {
    node TestNode {
        has value: int;
    }
    
    test_node = TestNode(value=42);
    assert test_node.value == 42;
}

test test_walker_behavior {
    walker TestWalker {
        has visited_count: int = 0;
        
        can count_visits with entry {
            self.visited_count += 1;
            visit [-->];
        }
    }
    
    # Create test graph
    node1 = root ++> TestNode(value=1);
    node2 = node1 ++> TestNode(value=2);
    
    # Test walker
    walker = TestWalker() spawn root;
    assert walker.visited_count == 3;  # root + 2 nodes
}
```

### Integration Tests
```jac
test test_ai_integration {
    import from mtllm { Model }
    
    glob test_model = Model(model_name="gpt-3.5-turbo");
    
    def test_ai_function(input: str) -> str by test_model();
    
    result = test_ai_function("Hello AI");
    assert isinstance(result, str);
    assert len(result) > 0;
}

test test_complex_graph_traversal {
    # Create complex graph
    users = [root ++> User(name=f"User{i}") for i in range(5)];
    
    # Create interconnections
    for i in range(len(users) - 1) {
        users[i] +:FriendsWith:+> users[i + 1];
    }
    
    # Test traversal
    walker PathFinder {
        has path_length: int = 0;
        
        can traverse with entry {
            self.path_length += 1;
            visit [-->];
        }
    }
    
    finder = PathFinder() spawn root;
    assert finder.path_length == 6;  # root + 5 users
}
```

## Error Handling and Debugging

### Advanced Error Handling
```jac
walker RobustWalker {
    has errors: list[str] = [];
    has fallback_strategy: str = "continue";
    
    can handle_errors with entry {
        try {
            risky_operation = self.process_node(here);
        } except ProcessingError as e {
            self.errors.append(f"Processing failed at {here}: {e}");
            if self.fallback_strategy == "stop" {
                disengage;
            } elif self.fallback_strategy == "skip" {
                return;  # Skip this node
            }
            # "continue" strategy falls through
        } except Exception as e {
            self.errors.append(f"Unexpected error at {here}: {e}");
            # Log and continue
        }
        
        visit [-->];
    }
    
    def process_node(node) -> str {
        if not hasattr(node, 'data') {
            raise ProcessingError(f"Node {node} missing required data");
        }
        return f"Processed {node.data}";
    }
}
```

### Debugging Utilities
```jac
walker Debugger {
    has debug_mode: bool = True;
    has trace: list[str] = [];
    
    can debug_traverse with entry {
        if self.debug_mode {
            self.trace.append(f"Visiting: {here} at {self.get_timestamp()}");
            self.log_node_state(here);
        }
        
        visit [-->];
    }
    
    def log_node_state(node) {
        if hasattr(node, '__dict__') {
            state = {k: v for k, v in node.__dict__.items() if not k.startswith('_')};
            print(f"Node state: {state}");
        }
    }
    
    def get_timestamp() -> str {
        import {datetime} with "://" py "from datetime import datetime";
        return datetime.now().isoformat();
    }
}
```
