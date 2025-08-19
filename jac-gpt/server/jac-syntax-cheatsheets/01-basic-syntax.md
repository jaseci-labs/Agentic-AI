# Jac Basic Syntax Cheat Sheet

## Entry Points
```jac
# Program execution starts here (equivalent to Python's if __name__ == "__main__":)
with entry {
    print("Hello, Jac World!");
}

# Multiple entry blocks execute in order
with entry {
    print("First block");
}

with entry {
    print("Second block");
}
```

## Variables and Types
```jac
# Type annotations are mandatory
name: str = "Alice";
age: int = 25;
gpa: float = 3.8;
is_student: bool = True;

# No automatic type inference - explicit typing required
grades: list[int] = [85, 92, 78];
student_info: dict[str, str] = {"name": "Bob", "major": "CS"};
courses: set[str] = {"Math", "Physics", "CS"};
```

## Functions
```jac
# Basic function with mandatory type annotations
def add_numbers(a: int, b: int) -> int {
    result: int = a + b;
    return result;
}

# Function with no parameters (omit parentheses)
def greet -> str {
    return "Hello!";
}

# Function with default parameters
def calculate_grade(score: int, bonus: int = 0) -> str {
    total: int = score + bonus;
    return "Pass" if total >= 60 else "Fail";
}
```

## Objects
```jac
# Basic object definition
obj Student {
    has name: str;
    has age: int;
    has gpa: float = 0.0;  # Default value

    def get_info() -> str {
        return f"Name: {self.name}, Age: {self.age}, GPA: {self.gpa}";
    }
}

# Object instantiation
with entry {
    student: Student = Student("Alice", 20, 3.8);
    print(student.get_info());
}
```

## Global Variables
```jac
# Global variables with :g: access
glob app_name: str = "My Jac App";
glob version: int = 1;

def get_app_info() -> str {
    :g: app_name, version;  # Access global variables
    return f"{app_name} v{version}";
}
```

## Collections and Comprehensions
```jac
with entry {
    # List operations
    numbers: list[int] = [1, 2, 3, 4, 5];
    squares: list[int] = [x * x for x in numbers];
    evens: list[int] = [x for x in numbers if x % 2 == 0];
    
    # Dictionary operations
    grades: dict[str, int] = {"Alice": 85, "Bob": 92};
    
    # Set operations
    subjects: set[str] = {"Math", "Physics", "Chemistry"};
}
```

## Control Flow
```jac
# If-else statements
with entry {
    score: int = 85;
    
    if score >= 90 {
        print("A grade");
    } elif score >= 80 {
        print("B grade");
    } else {
        print("Need improvement");
    }
}

# For loops
with entry {
    numbers: list[int] = [1, 2, 3, 4, 5];
    
    for num in numbers {
        print(f"Number: {num}");
    }
    
    # Range-based loops
    for i in range(5) {
        print(f"Index: {i}");
    }
}

# While loops
with entry {
    count: int = 0;
    while count < 5 {
        print(f"Count: {count}");
        count += 1;
    }
}
```

## Error Handling
```jac
with entry {
    try {
        result: float = 10.0 / 0.0;
    } except ZeroDivisionError as e {
        print(f"Error: {e}");
    } finally {
        print("Cleanup code here");
    }
}
```

## Enumerations
```jac
enum Status {
    PENDING = "pending",
    ACTIVE = "active",
    INACTIVE = "inactive"
}

with entry {
    current_status: Status = Status.ACTIVE;
    print(f"Status: {current_status.value}");
}
```

## Comments and Documentation
```jac
# Single line comment

"""
Multi-line comment
or documentation string
"""

def documented_function(x: int) -> int {
    """This function doubles the input value."""
    return x * 2;
}
```

## String Formatting
```jac
with entry {
    name: str = "Alice";
    age: int = 25;
    
    # F-string formatting (preferred)
    message: str = f"Hello {name}, you are {age} years old";
    
    # String concatenation
    greeting: str = "Hello " + name;
    
    print(message);
}
```

## Type Checking
```jac
with entry {
    # Type checking at runtime
    value: int = 42;
    
    if isinstance(value, int) {
        print("It's an integer");
    }
}
```
