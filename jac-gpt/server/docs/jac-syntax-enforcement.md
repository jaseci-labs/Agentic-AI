# JAC Syntax Enforcement - CRITICAL RULES

## 🚨 ABSOLUTE SYNTAX REQUIREMENTS (NEVER VIOLATE)

### Comments Syntax
```jac
# ✅ CORRECT - JAC uses hash/pound symbol for comments
# This is a proper JAC comment
# Multi-line comments use this format too

#*
✅ CORRECT - Multi-line comment block
This is how you write
multi-line comments in JAC
*#

// ❌ WRONG - This is C/Java/JavaScript syntax, NOT JAC!
// This will cause syntax errors in JAC
/* ❌ WRONG - This is also NOT JAC syntax */
```

### Object-Oriented vs Object-Spatial Programming
```jac
# ✅ CORRECT - JAC uses nodes for data entities
node Calculator {
    has history: list[str] = [];
    
    def add(a: float, b: float) -> float {
        result: float = a + b;
        self.history.append(f"Added {a} + {b} = {result}");
        return result;
    }
}

# ✅ CORRECT - JAC also supports traditional objects
obj Calculator {
    has history: list[str] = [];
    
    def add(a: float, b: float) -> float {
        result: float = a + b;
        self.history.append(f"Added {a} + {b} = {result}");
        return result;
    }
}

# ❌ WRONG - 'class' is Python/Java syntax, NOT JAC!
class Calculator {  # This will cause syntax errors!
    history: list[str] = [];
}
```

### Object Instantiation
```jac
# ✅ CORRECT - JAC instantiation (no 'new' keyword)
with entry {
    calc: Calculator = Calculator();
    node_calc: Calculator = root ++> Calculator();  # For nodes
}

# ❌ WRONG - 'new' keyword is NOT JAC syntax!
with entry {
    calc: Calculator = new Calculator();  # Syntax error!
}
```

### Variable and Function Type Annotations
```jac
# ✅ CORRECT - All variables MUST have type annotations
name: str = "Alice";
age: int = 25;
scores: list[float] = [95.5, 87.2, 92.1];

# ✅ CORRECT - All functions MUST have parameter and return types
def calculate_average(scores: list[float]) -> float {
    total: float = sum(scores);
    return total / len(scores);
}

# ❌ WRONG - Missing type annotations
name = "Alice";  # Syntax error - no type!
age = 25;        # Syntax error - no type!

def calculate_average(scores) {  # Syntax error - no types!
    return sum(scores) / len(scores);
}
```

### Semicolons are MANDATORY
```jac
# ✅ CORRECT - All statements end with semicolons
name: str = "Alice";
age: int = 25;
print(f"Hello, {name}!");

# ❌ WRONG - Missing semicolons will cause syntax errors
name: str = "Alice"    # Syntax error!
age: int = 25          # Syntax error!
print(f"Hello, {name}!")  # Syntax error!
```

### Entry Points
```jac
# ✅ CORRECT - JAC uses 'with entry' blocks
with entry {
    print("Program starts here");
    main_function();
}

# ❌ WRONG - Python's if __name__ is NOT JAC syntax!
if __name__ == "__main__":  # This is Python, not JAC!
    print("Wrong syntax")
```

### Self Reference in Objects/Nodes
```jac
node Calculator {
    has history: list[str] = [];
    
    def add_to_history(entry: str) -> None {
        # ✅ CORRECT - Use self to access object attributes
        self.history.append(entry);
    }
    
    def wrong_method(entry: str) -> None {
        # ❌ WRONG - Missing self reference
        history.append(entry);  # This will cause errors!
    }
}
```

## 🎯 JAC-SPECIFIC CONSTRUCTS TO USE

### Nodes and Spatial Programming
```jac
# Define a node for data entities
node Student {
    has name: str;
    has grade: float;
    has courses: list[str] = [];
}

# Define edges for relationships
edge EnrolledIn;

with entry {
    # Create nodes using ++> operator
    alice: Student = root ++> Student(name="Alice", grade=95.5);
    math_course: Course = root ++> Course(name="Mathematics");
    
    # Connect nodes with edges
    alice +[:EnrolledIn:]-> math_course;
}
```

### Walkers for Data Processing
```jac
walker GradeCalculator {
    has total_grade: float = 0.0;
    has student_count: int = 0;
    
    can calculate with Student entry {
        self.total_grade += here.grade;
        self.student_count += 1;
        print(f"Processed student: {here.name}");
    }
}

with entry {
    calculator: GradeCalculator = GradeCalculator() spawn root;
    average: float = calculator.total_grade / calculator.student_count;
    print(f"Average grade: {average}");
}
```

### AI Integration
```jac
import from mtllm { Model }

glob llm = Model(model_name="gpt-4o-mini");

# AI-powered function
def analyze_student_performance(grades: list[float]) -> str by llm();

# AI-enhanced node
node SmartTutor {
    has subject: str;
    has expertise_level: int;
    
    def provide_feedback(student_work: str) -> str by llm(incl_info=(self.subject, self.expertise_level));
}
```

## ❌ COMMON SYNTAX ERRORS TO AVOID

| Wrong Syntax | Correct JAC Syntax | Note |
|--------------|-------------------|------|
| `// Comment` | `# Comment` | JAC uses # for comments |
| `class MyClass` | `node MyClass` or `obj MyClass` | JAC uses node/obj, not class |
| `new MyClass()` | `MyClass()` | No 'new' keyword in JAC |
| `variable = value` | `variable: type = value;` | Type annotations mandatory |
| `def func(param)` | `def func(param: type) -> return_type` | All types required |
| `statement` | `statement;` | Semicolons mandatory |
| `if __name__ == "__main__"` | `with entry { ... }` | JAC entry point syntax |

## 🔧 CORRECT JAC TEMPLATE

```jac
# JAC file template with proper syntax
import from mtllm { Model }

glob llm = Model(model_name="gpt-4o-mini");

node Calculator {
    has history: list[str] = [];
    
    def add(a: float, b: float) -> float {
        result: float = a + b;
        self.history.append(f"Added {a} + {b} = {result}");
        return result;
    }
    
    def subtract(a: float, b: float) -> float {
        result: float = a - b;
        self.history.append(f"Subtracted {b} from {a} = {result}");
        return result;
    }
    
    def show_history() -> None {
        print("Calculation History:");
        for entry in self.history {
            print(f"  {entry}");
        }
    }
}

walker MathProcessor {
    has calculations: list[float] = [];
    
    can process with Calculator entry {
        result1: float = here.add(10.0, 5.0);
        result2: float = here.subtract(20.0, 8.0);
        self.calculations.append(result1);
        self.calculations.append(result2);
    }
}

with entry {
    # Create calculator node
    calc: Calculator = root ++> Calculator();
    
    # Process with walker
    processor: MathProcessor = MathProcessor() spawn root;
    
    # Show results
    calc.show_history();
    print(f"Processed calculations: {processor.calculations}");
}
```

---
🔥 **REMEMBER**: JAC has strict syntax rules. Always use # for comments, node/obj instead of class, mandatory type annotations, and semicolons!
