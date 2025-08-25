# JAC Syntax Essentials - Code Generation Reference

## ⚡ CRITICAL SYNTAX RULES (MANDATORY)

### 🎯 Type Annotations (REQUIRED)
```jac
# ✅ CORRECT - All variables MUST have explicit type annotations
name: str = "Alice";
age: int = 25;
score: float = 95.5;
is_active: bool = True;
items: list[str] = ["apple", "banana"];
mapping: dict[str, int] = {"a": 1, "b": 2};

# ❌ WRONG - No type inference allowed
name = "Alice";  # ERROR: Missing type annotation
age = 25;        # ERROR: Missing type annotation
```

### 🔧 Function Definitions (REQUIRED)
```jac
# ✅ CORRECT - Functions MUST have return type annotations
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

# ❌ WRONG - Missing type annotations
def greet(name) {          # ERROR: Missing parameter type
    return f"Hello, {name}!";
}
```

### 📍 Semicolons (MANDATORY)
```jac
# ✅ CORRECT - End statements with semicolons
name: str = "Alice";
age: int = 25;
print("Hello World");

# ❌ WRONG - Missing semicolons
name: str = "Alice"   # ERROR: Missing semicolon
age: int = 25         # ERROR: Missing semicolon
```

### 📦 Entry Points (REQUIRED)
```jac
# ✅ CORRECT - Use 'with entry' block for main execution
with entry {
    print("Program starts here");
    main();
}

# ❌ WRONG - Not Python's if __name__ == "__main__"
if __name__ == "__main__":    # ERROR: This is Python syntax
    print("Wrong syntax")     # ERROR: Wrong syntax
```

### 🧮 Import Statements
```jac
# ✅ CORRECT - JAC import syntax
import os;
import sys;
import from mtllm { Model }
import from langchain_community.document_loaders { PyPDFLoader }

# ❌ WRONG - Not Python imports
from mtllm import Model     # ERROR: This is Python syntax
import mtllm.Model          # ERROR: Wrong syntax
```

## 🌐 Object-Spatial Programming (OSP)

### 🏗️ Node Definitions
```jac
# ✅ CORRECT - Node with type annotations
node Person {
    has name: str;
    has age: int;
    has email: str = "";  # Default value
    
    def get_info() -> str {
        return f"Name: {self.name}, Age: {self.age}";
    }
}

# Node creation and connections
with entry {
    # Create nodes using ++> operator
    alice: Person = root ++> Person(name="Alice", age=25);
    bob: Person = root ++> Person(name="Bob", age=30);
    
    # Connect nodes
    alice ++> bob;     # Unidirectional connection
    alice <++> bob;    # Bidirectional connection
}
```

### 🚶 Walker Definitions
```jac
# ✅ CORRECT - Walker with proper syntax
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

### 🔗 Edge Definitions
```jac
# ✅ CORRECT - Edge definition and usage
edge FriendsWith;

with entry {
    alice: Person = root ++> Person(name="Alice", age=25);
    bob: Person = root ++> Person(name="Bob", age=30);
    
    # Bidirectional connection with typed edge
    alice <+:FriendsWith:+> bob;
    
    # Unidirectional connection with typed edge
    alice +[:FriendsWith:]-> bob;
}
```

## 🤖 AI Integration (MTLLM)

### 🧠 AI-Powered Functions
```jac
# ✅ CORRECT - AI-powered functions
import from mtllm { Model }

glob llm = Model(model_name="gpt-4o-mini");

# Simple AI function
def analyze_sentiment(text: str) -> str by llm();

# AI function with enum return type
enum Category {
    POSITIVE = "positive",
    NEGATIVE = "negative", 
    NEUTRAL = "neutral"
}

def categorize_feedback(text: str) -> Category by llm();

# AI function with context
def generate_response(query: str, context: dict) -> str by llm(incl_info=(context));
```

### 🎯 AI-Enhanced Objects
```jac
# ✅ CORRECT - Object with AI methods
obj SmartAssistant {
    has name: str;
    has expertise: list[str];
    
    def answer_question(question: str) -> str by llm(incl_info=(self.expertise));
    
    def provide_advice(topic: str) -> str by llm();
}
```

## 🌍 Global Variables
```jac
# ✅ CORRECT - Global variable declaration and access
glob app_name: str = "MyApp";
glob version: int = 1;

def get_app_info() -> str {
    :g: app_name, version;  # Access globals with :g:
    return f"{app_name} v{version}";
}
```

## 📊 Collections and Control Flow
```jac
# ✅ CORRECT - Collections with type annotations
with entry {
    numbers: list[int] = [1, 2, 3, 4, 5];
    squares: list[int] = [x * x for x in numbers];
    evens: list[int] = [x for x in numbers if x % 2 == 0];
    
    mapping: dict[str, int] = {"a": 1, "b": 2, "c": 3};
    
    # Control structures with curly braces
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

## 🚫 COMMON MISTAKES TO AVOID

1. **❌ Missing type annotations** - JAC requires explicit types for ALL variables
2. **❌ Missing semicolons** - Every statement must end with `;`
3. **❌ Using Python syntax** - JAC has its own syntax rules
4. **❌ Wrong entry points** - Use `with entry {}` not Python's `if __name__`
5. **❌ Incorrect imports** - Use JAC import syntax, not Python's
6. **❌ Wrong node creation** - Use `++>` operator for node creation
7. **❌ Missing curly braces** - Use `{}` for all code blocks, not indentation

## 📝 QUICK TEMPLATE

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
    # Create node
    node: MyNode = root ++> MyNode(data="test", value=42);
    
    # Spawn walker
    walker: MyWalker = MyWalker() spawn root;
    
    # Use AI function
    response: str = ai_function("Hello JAC!");
    print(response);
}
```

---
🔥 **Remember**: JAC is a superset of Python with strict typing and unique OSP features. Always use proper JAC syntax!
