# JAC Core Syntax Rules - MANDATORY REFERENCE

## CRITICAL SYNTAX REQUIREMENTS

### Type Annotations (MANDATORY)
```jac
# CORRECT - All variables MUST have explicit type annotations
name: str = "Alice";
age: int = 25;
score: float = 95.5;
is_active: bool = True;
items: list[str] = ["apple", "banana"];
mapping: dict[str, int] = {"a": 1, "b": 2};

# INCORRECT - No type inference allowed
name = "Alice";  # ❌ WRONG
age = 25;        # ❌ WRONG
```

### Function Definitions (MANDATORY)
```jac
# CORRECT - Functions MUST have return type annotations
def greet(name: str) -> str {
    return f"Hello, {name}!";
}

def calculate(a: int, b: int) -> int {
    result: int = a + b;
    return result;
}

# Functions with no parameters (omit parentheses)
def get_version -> str {
    return "1.0.0";
}

# INCORRECT - Missing type annotations
def greet(name) {          # ❌ WRONG - missing parameter type
    return f"Hello, {name}!";
}

def calculate(a: int, b: int) {  # ❌ WRONG - missing return type
    return a + b;
}
```

### Semicolons (MANDATORY)
```jac
# CORRECT - End statements with semicolons
name: str = "Alice";
age: int = 25;
print("Hello World");

# INCORRECT - Missing semicolons
name: str = "Alice"   # ❌ WRONG
age: int = 25         # ❌ WRONG
```

### Curly Braces for Blocks
```jac
# CORRECT - Use curly braces for function/object/control blocks
def my_function() -> str {
    result: str = "Hello";
    return result;
}

if condition {
    print("True");
} else {
    print("False");
}

# INCORRECT - No indentation-based blocks like Python
def my_function() -> str:     # ❌ WRONG
    result = "Hello"          # ❌ WRONG
    return result             # ❌ WRONG
```

### Entry Points
```jac
# CORRECT - Use 'with entry' block for main execution
with entry {
    print("Program starts here");
    main();
}

# INCORRECT - Not Python's if __name__ == "__main__"
if __name__ == "__main__":    # ❌ WRONG - This is Python
    print("Wrong syntax")     # ❌ WRONG
```

### Object-Spatial Programming Constructs

#### Node Definitions
```jac
# CORRECT - Node with type annotations
node Person {
    has name: str;
    has age: int;
    has email: str = "";  # Default value
    
    def get_info() -> str {
        return f"Name: {self.name}, Age: {self.age}";
    }
}

# Node creation
with entry {
    person: Person = root ++> Person(name="Alice", age=25);
}
```

#### Walker Definitions
```jac
# CORRECT - Walker with proper syntax
walker DataCollector {
    has collected_data: list[str] = [];
    
    can visit_node with Person entry {
        self.collected_data.append(here.name);
        print(f"Visited: {here.name}");
    }
}

# Walker spawning
with entry {
    collector: DataCollector = DataCollector() spawn root;
}
```

#### Edge Definitions and Connections
```jac
# CORRECT - Edge definition and usage
edge FriendsWith;

with entry {
    alice: Person = root ++> Person(name="Alice", age=25);
    bob: Person = root ++> Person(name="Bob", age=30);
    
    # Bidirectional connection
    alice <+:FriendsWith:+> bob;
    
    # Unidirectional connection
    alice +[:FriendsWith:]-> bob;
}
```

### AI Integration
```jac
# CORRECT - AI-powered functions
import from mtllm { Model }

glob llm = Model(model_name="gpt-4o-mini");

def analyze_sentiment(text: str) -> str by llm();

enum Category {
    POSITIVE = "positive",
    NEGATIVE = "negative", 
    NEUTRAL = "neutral"
}

def categorize_feedback(text: str) -> Category by llm();
```

### Import Statements
```jac
# CORRECT - Import syntax
import os;
import sys;
import from mtllm { Model }
import from langchain_community.document_loaders { PyPDFLoader }

# INCORRECT - Not Python imports
from mtllm import Model     # ❌ WRONG - This is Python syntax
import mtllm.Model          # ❌ WRONG
```

### Global Variables
```jac
# CORRECT - Global variable declaration and access
glob app_name: str = "MyApp";
glob version: int = 1;

def get_app_info() -> str {
    :g: app_name, version;  # Access globals with :g:
    return f"{app_name} v{version}";
}

# INCORRECT - No global keyword like Python
global app_name = "MyApp"   # ❌ WRONG - This is Python
```

### Control Structures
```jac
# CORRECT - Control flow with curly braces
with entry {
    numbers: list[int] = [1, 2, 3, 4, 5];
    
    for num in numbers {
        if num % 2 == 0 {
            print(f"{num} is even");
        } else {
            print(f"{num} is odd");
        }
    }
    
    count: int = 0;
    while count < 5 {
        print(f"Count: {count}");
        count += 1;
    }
}
```

### Collections and Comprehensions
```jac
# CORRECT - List/dict comprehensions with type annotations
with entry {
    numbers: list[int] = [1, 2, 3, 4, 5];
    squares: list[int] = [x * x for x in numbers];
    evens: list[int] = [x for x in numbers if x % 2 == 0];
    
    mapping: dict[str, int] = {"a": 1, "b": 2, "c": 3};
    values: list[int] = [v for v in mapping.values()];
}
```

## COMMON MISTAKES TO AVOID

1. **Don't mix Python syntax with JAC syntax**
2. **Always use type annotations - no type inference**
3. **Always end statements with semicolons**
4. **Use curly braces, not indentation for blocks**
5. **Use 'with entry' not 'if __name__ == "__main__"'**
6. **Use proper JAC import syntax**
7. **Use :g: to access global variables**
8. **Use ++> for node creation and connections**

## QUICK REFERENCE TEMPLATE

```jac
import from mtllm { Model }

glob llm = Model(model_name="gpt-4o-mini");

node MyNode {
    has data: str;
    has value: int = 0;
    
    def process() -> str {
        return f"Processing: {self.data}";
    }
}

walker MyWalker {
    has results: list[str] = [];
    
    can visit_node with MyNode entry {
        result: str = here.process();
        self.results.append(result);
    }
}

def ai_function(input: str) -> str by llm();

with entry {
    node: MyNode = root ++> MyNode(data="test", value=42);
    walker: MyWalker = MyWalker() spawn root;
    
    response: str = ai_function("Hello JAC!");
    print(response);
}
```
