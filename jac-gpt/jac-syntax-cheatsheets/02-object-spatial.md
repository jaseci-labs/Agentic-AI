# Jac Object-Spatial Programming Cheat Sheet

## Nodes - Data with Location

### Basic Node Definition
```jac
# Simple node
node Person {
    has name: str;
    has age: int;
    has email: str = "";  # Default value
}

# Node with methods
node User {
    has username: str;
    has score: int = 0;
    
    def get_display_name() -> str {
        return f"@{self.username}";
    }
}
```

### Node Creation and Connection
```jac
with entry {
    # Create nodes
    user1 = root ++> Person(name="Alice", age=25);
    user2 = root ++> Person(name="Bob", age=30);
    
    # Direct connection between nodes
    user1 ++> user2;  # Unidirectional edge
    user1 <++> user2; # Bidirectional edge
}
```

### Node Abilities (Event-Driven Methods)
```jac
node EventNode {
    has data: str = "default";
    
    # Triggered when ANY walker enters
    can log_entry with entry {
        print(f"Walker entered: {self}");
    }
    
    # Triggered when specific walker type enters
    can handle_agent with Agent entry {
        print(f"Agent {here} entered node {self}");
        here.collected_data.append(self.data);
    }
    
    # Triggered when walker exits
    can log_exit with exit {
        print(f"Walker exited: {self}");
    }
    
    # Regular callable method
    def process_data() -> str {
        return f"Processed: {self.data}";
    }
}
```

### Node Inheritance
```jac
# Base node
node Service {
    has service_type: str;
}

# Inherited nodes
node Weather(Service) {
    has temperature: int;
    has humidity: float;
    
    can provide_data with Agent entry {
        here.state["weather"] = {
            "temp": self.temperature,
            "humidity": self.humidity
        };
    }
}

node Time(Service) {
    has current_hour: int;
    
    can provide_data with Agent entry {
        here.state["time"] = f"{self.current_hour}:00";
    }
}
```

## Edges - Typed Relationships

### Generic Edges
```jac
with entry {
    node1 = root ++> Person(name="Alice", age=25);
    node2 = root ++> Person(name="Bob", age=30);
    
    # Generic edges
    node1 ++> node2;     # Unidirectional
    node1 <++> node2;    # Bidirectional
    node1 <--> node2;    # Alternative bidirectional syntax
}
```

### Custom Edges with Properties
```jac
# Define custom edge type
edge FriendsWith {
    has since: str;
    has strength: int = 1;
}

edge WorksWith {
    has department: str;
    has role: str;
}

with entry {
    alice = root ++> Person(name="Alice", age=25);
    bob = root ++> Person(name="Bob", age=30);
    
    # Create typed edges with properties
    alice +:FriendsWith:since="2020", strength=5:+> bob;
    alice <+:WorksWith:department="Engineering", role="teammate":+> bob;
}
```

### Edge Operations
```jac
with entry {
    node1 = root ++> Person(name="Alice", age=25);
    node2 = root ++> Person(name="Bob", age=30);
    
    # Create edge
    node1 +:FriendsWith:since="2023":+> node2;
    
    # Delete edge
    node1 del --> node2;
    
    # Delete specific edge type
    node1 del :FriendsWith: node2;
}
```

## Walkers - Mobile Computation

### Basic Walker Definition
```jac
walker DataCollector {
    has collected_data: list[str] = [];
    has visit_count: int = 0;
    
    # Entry ability - runs when walker is spawned
    can start with entry {
        print("Walker started collecting data");
        visit [-->];  # Visit all connected nodes
    }
    
    # Runs when visiting specific node types
    can collect_from_person with Person entry {
        self.collected_data.append(here.name);
        self.visit_count += 1;
    }
    
    # Exit ability - runs when walker finishes
    can finish with exit {
        print(f"Collected {len(self.collected_data)} items");
    }
}
```

### Walker Navigation Patterns
```jac
walker Explorer {
    can navigate with entry {
        # Visit all successor nodes
        visit [-->];
        
        # Visit all predecessor nodes  
        visit [<--];
        
        # Visit specific node types
        visit [-->(`?Person)];
        
        # Visit nodes with specific edge types
        visit [:FriendsWith:-->];
        
        # Visit nodes through specific edge with conditions
        visit [:FriendsWith:strength > 3:-->];
        
        # Conditional navigation
        if len([-->]) > 0 {
            visit [-->];
        }
    }
}
```

### Walker Spawning and Control
```jac
with entry {
    # Create graph
    alice = root ++> Person(name="Alice", age=25);
    bob = alice ++> Person(name="Bob", age=30);
    charlie = bob ++> Person(name="Charlie", age=35);
    
    # Spawn walker at specific node
    collector = DataCollector() spawn root;
    
    # Access walker results after execution
    print(f"Walker collected: {collector.collected_data}");
}

walker ControlledWalker {
    has max_visits: int = 3;
    has current_visits: int = 0;
    
    can limited_traverse with entry {
        if self.current_visits < self.max_visits {
            self.current_visits += 1;
            visit [-->];
        } else {
            disengage;  # Stop walker execution
        }
    }
}
```

### Walker Inheritance
```jac
# Base walker
walker BaseAgent {
    has state: dict = {};
    
    can initialize with entry {
        print("Base agent initialized");
    }
}

# Specialized walker
walker IntelligentAgent(BaseAgent) {
    has memory: list[str] = [];
    
    can enhanced_behavior with entry {
        # Inherit base behavior, add new functionality
        super.initialize();
        self.memory.append("Agent started");
        visit [-->(`?Service)];  # Only visit service nodes
    }
}
```

## Graph Queries and Filtering

### Node Filtering by Type
```jac
with entry {
    # Visit only specific node types
    visit [-->(`?Person)];           # Visit Person nodes
    visit [-->(`?Service)];          # Visit Service nodes
    visit [-->(`?Weather | `?Time)]; # Visit Weather OR Time nodes
}
```

### Edge-Based Navigation
```jac
walker RelationshipExplorer {
    can explore_relationships with entry {
        # Navigate via specific edge types
        visit [:FriendsWith:-->];
        visit [:WorksWith:-->];
        
        # Navigate with edge property conditions
        visit [:FriendsWith:strength >= 3:-->];
        visit [:WorksWith:department == "Engineering":-->];
    }
}
```

### Complex Graph Patterns
```jac
walker PatternMatcher {
    can find_patterns with entry {
        # Find friends of friends
        friends = [-->:FriendsWith:];
        for friend in friends {
            friends_of_friends = [friend-->:FriendsWith:];
            for fof in friends_of_friends {
                print(f"Friend of friend: {fof.name}");
            }
        }
        
        # Find nodes at specific distances
        level_2_nodes = [-->-->];  # Nodes 2 steps away
        level_3_nodes = [-->-->-->]; # Nodes 3 steps away
    }
}
```

## Advanced Object-Spatial Patterns

### Multi-Walker Coordination
```jac
walker Leader {
    can coordinate with entry {
        # Spawn multiple workers
        for i in range(3) {
            worker = Worker(worker_id=i) spawn here;
        }
    }
}

walker Worker {
    has worker_id: int;
    
    can work with entry {
        print(f"Worker {self.worker_id} processing node {here}");
    }
}
```

### State Synchronization
```jac
node SharedState {
    has global_counter: int = 0;
    
    can increment with Counter entry {
        self.global_counter += 1;
        here.local_count = self.global_counter;
    }
}

walker Counter {
    has local_count: int = 0;
    
    can count with SharedState entry {
        # Node ability will update this walker's state
    }
}
```
