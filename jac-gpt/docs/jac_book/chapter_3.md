# 3. Functions, Control Flow, and Collections in Jac
---
In this chapter, we will explore Jac's enhanced syntax and type system, focusing on functions, control flow, and collections. We will build upon the foundation laid in the previous chapters, introducing more complex data structures and control mechanisms.

## Functions and Type Annotations
---
**Functions** are reusable blocks of code that perform a specific task. In Jac, functions are defined using the `def` keyword, followed by the function name and its parameters. Type annotations are mandatory for all function parameters and return types.

The following example demonstrates a simple function called `add_numbers`  that takes two integers as *arguments* and adds them together, returning the result as an integer. The function is defined with type annotations for both parameters and the return type, ensuring type safety and clarity.

```jac
def add_numbers(a: int, b: int) -> int {
    result: int = a + b;
    return result;
}
```

### Basic Calculator Program
---
Let's build a simple calculator to demonstrate Jac's function in action. The calculator consists of 4 functions that represent basic arithmetic operations: addition, subtraction, multiplication, and division. Each function takes two float arguments and returns the result.

```jac
# calculator.jac
def add(a: float, b: float) -> float {
    return a + b;
}

def subtract(a: float, b: float) -> float {
    return a - b;
}

def multiply(a: float, b: float) -> float {
    return a * b;
}

def divide(a: float, b: float) -> float {
    return a / b;
}

with entry {
    print("=== Simple Calculator ===");

    # Test calculations
    num1: float = 10.0;
    num2: float = 3.0;

    print(f"{num1} + {num2} = {add(num1, num2)}");
    print(f"{num1} - {num2} = {subtract(num1, num2)}");
    print(f"{num1} * {num2} = {multiply(num1, num2)}");
    print(f"{num1} / {num2} = {divide(num1, num2)}");
}
```
<br />

More observant readers may notice that the `divide` function lacks error handling for division by zero—a common beginner mistake. We'll cover proper error handling techniques later in this chapter. In the meantime, use the `divide` function with care, especially when the second argument might be zero. After all, triggering a division-by-zero error might not actually launch a nuclear warhead... but let's not take any chances, shall we?
<br />

## Basic Object Oriented Programming
---
Jac is primarily an Object Spatial Language, but it also supports Object Oriented Programming (OOP) concepts. An object is a self-contained unit that combines data and behavior. In Jac, we can define objects using the `obj` keyword. Objects can also have methods which are defined using the `def` keyword and these represent the behavior of the object. Objects can also have attributes, which are defined using the `has` keyword. These attributes represent the data associated with the object.

### Defining an Object
```jac
obj Student {
    has name: str;
    has age: int;
    has gpa: float;

    def get_info() -> str {
        return f"Name: {self.name}, Age: {self.age}, GPA: {self.gpa}";
    }
}

with entry {
    student: Student = Student("Alice", 20, 3.8);  # Create a new Student object
    print(student.get_info());
}
```
<br />

Hey, where is the constructor? Good question! Jac does not have a constructor in the traditional sense. Instead, the object is initialized with the `has` keyword, and the attributes are set directly. This is a design choice in Jac to keep things simple and straightforward.

!!! note
    Jac's objects operates similar to data classes in Python, where the attributes are defined at the class level and can be set directly when creating an instance of the object. This allows for a more concise syntax while still providing the benefits of encapsulation and data organization.


### Enhanced Calculator with Object-Oriented Design
In a later chapter, we will explore more of Jac's object-oriented features. For now, let's enhance our calculator by encapsulating its functionality in a `obj` called `Calculator`. This allows us to maintain a history of calculations and provides a cleaner interface for users.

<div class="code-block">
```jac
# oop_calculator.jac
obj Calculator {
    has history: list[str] = [];

    def add(a: float, b: float) -> float {
        result: float = a + b;
        self.history.append(f"{a} + {b} = {result}");
        return result;
    }

    def subtract(a: float, b: float) -> float {
        result: float = a - b;
        self.history.append(f"{a} - {b} = {result}");
        return result;
    }

    def get_history() -> list[str] {
        return self.history;
    }

    def clear_history() {
        self.history = [];
    }
}

with entry {
    calc = Calculator();

    # Perform calculations
    result1: float = calc.add(5.0, 3.0);
    result2: float = calc.subtract(10.0, 4.0);

    print(f"Results: {result1}, {result2}");

    # Show history
    print("Calculation History:");
    for entry in calc.get_history() {
        print(f"  {entry}");
    }
}
```
</div>
<br />
While Jac styles itself as a Object Spatial Language, it is important to note that it is not opposed to Object Oriented Programming. In fact, Jac supports both paradigms, allowing you to choose the best approach for your project. Think of Object Spatial as Object Oriented with rocket pack boosters. You can still use all of your OOP goodness, but with the added benefits of Jac's spatial features.




## Variable Scope and Global Variables
---
Jac supports both local and global variables. Local variables are defined within a block and are not accessible outside it, while global variables can be accessed anywhere in the code.
### Local Variables
```jac
def add_numbers(a: int, b: int) -> int {
    result: int = a + b;  # Local variable
    return result;
}
with entry {
    sum = add_numbers(5, 10);
    print(f"Sum: {sum}");
}
```
<br />

### Global Variables
Global variables in Jac are declared using the `glob` keyword and are accessible from anywhere in the program. They are typically used for defining constants or sharing data across multiple contexts. However, their use should be limited, as excessive reliance on global state can lead to unintended side effects. This aligns with Jac’s core philosophy of *moving computation to the data*—favoring localized logic and context-aware execution over broad, global manipulation.



```jac
glob school_name: str = "Jac High School";
glob passing_grade: int = 60;
glob honor_threshold: float = 3.5;

def get_school_info() -> str {
    :g: school_name; # Accessing global variable
    return f"Welcome to {school_name}";
}

with entry {
    print(get_school_info());
    print(f"Honor threshold is {honor_threshold}");
}
```
<br />





## Collections and Data Structures
---
Since Jac is a super-set of Python, it supports the same collection types: lists, dictionaries, sets, and tuples. However, Jac enforces type annotations for all collections, ensuring type safety and clarity.

### Lists
Lists are ordered collections of items that can be of mixed types. In Jac, lists are declared with the `list` type.

```jac
with entry {
    # Create an empty list for storing integer grades
    alice_grades: list[int] = [];

    # Append grades to the list
    alice_grades.append(88); # [88]
    alice_grades.append(92); # [88, 92]
    alice_grades.append(85); # [88, 92, 85]

    # Access grades by index
    first_grade: int = alice_grades[0];  # 88
    print(f"Alice's first grade: {first_grade}");

    # print the entire list of grades
    print(f"Alice's grades: {alice_grades}");
}
```
<br />

```text
$ jac run example.jac
Alice's first grade: 88
Alice's grades: [88, 92, 85]
```


### Dictionaries
Dictionaries are key-value pairs that allow for fast lookups. In Jac, dictionaries are declared with the `dict` type.

```jac
with entry {
    # Class gradebook
    math_grades: dict[str, int] = {
        "Alice": 92,
        "Bob": 85,
        "Charlie": 78
    };

    # Access grades by student name
    print(f"Alice's Math grade: {math_grades['Alice']}");
    print(f"Bob's Math grade: {math_grades['Bob']}");
    print(f"Charlie's Math grade: {math_grades['Charlie']}");
}
```
<br />

```text
$ jac run example.jac
Alice's Math grade: 92
Bob's Math grade: 85
Charlie's Math grade: 78
```

### Sets
Sets are unordered collections of unique items. In Jac, sets are declared with the `set` type.

```jac
with entry {
    # Track unique courses
    alice_courses: set[str] = {"Math", "Science", "English"};
    bob_courses: set[str] = {"Math", "History", "Art"};

    # Find common courses
    common_courses = alice_courses.intersection(bob_courses);
    print(f"Common courses: {common_courses}");

    # All unique courses
    all_courses = alice_courses.union(bob_courses);
    print(f"All courses: {all_courses}");
}
```
<br />
In the example above, we use the `intersection` method to identify courses that both Alice and Bob are enrolled in, and the `union` method to combine their courses into a single set of unique entries. These are standard operations provided by Python’s built-in `set` type, and Jac supports them as well. For a more comprehensive overview of collection-related functions in Python, refer to the [official Python documentation](https://docs.python.org/3/tutorial/datastructures.html).


## Collection Comprehensions
---
Jac supports list and dictionary comprehensions, allowing for concise and expressive data processing. In the following example we will explore how to use comprehensions to filter and transform data in a gradebook.

Lets say we have a list of test scores stored in the variable `test_scores` and we want to filter out passing grades:
```jac
with entry {
    # Raw test scores
    test_scores: list[int] = [78, 85, 92, 69, 88, 95, 72];

    # Get passing grades (70 and above)
    passing_scores: list[int] = [score for score in test_scores if score >= 70];
    print(f"Passing scores: {passing_scores}");
}
```
<br />

The list comprehension syntax in Jac is similar to Python:
```[expression for item in iterable if condition]``` where `expression` is the value to include in the new list, `item` is the variable representing each element in the original collection, `iterable` is the collection being processed, and `condition` is an optional filter.

Suppose we want to apply a curve to the scores by adding 5 points to each score, we can use a comprehension to create a new list of curved scores:

```jac
with entry {
    # Raw test scores
    test_scores: list[int] = [78, 85, 92, 69, 88, 95, 72];

    # Get passing grades (70 and above)
    passing_scores: list[int] = [score for score in test_scores if score >= 70];
    print(f"Passing scores: {passing_scores}");

    # Apply curve (+5 points)
    curved_scores: list[int] = [score + 5 for score in test_scores];
    print(f"Curved scores: {curved_scores}");
}
```
<br />

## Control Flow with Curly Braces
---
Earlier in this chapter, we defined a simple calculator. However, our `divide` function had a critical oversight—it didn’t account for division by zero. In the interest of both robust code and global stability, we’ll now implement proper control flow to safely handle this case and enhance our calculator’s reliability.


### If Statements
An `if` statement allows you to execute code conditionally based on whether a certain condition is true. In Jac, we use curly braces `{}` to define the block of code that should be executed if the condition is met.

```jac
def divide(a: float, b: float) -> float | str {
    if b == 0.0 {
        return "Error: Cannot divide by zero!";
    }
    return a / b;
}
```
<br />
In the example above, we check if `b` is zero via the statement `if b == 0.0` before performing the division. If it is, we return an error message instead of attempting the division.

### Conditional Logic `if-elif-else`

Jac supports `if-elif-else` statements for multiple conditions. This allows you to handle various cases in a structured way. Lets extend our simple grading system to classify grades based on score ranges. In the following example, we will classify scores into letter grades by combining `if`, `elif`, and `else` statements along list comprehensions to apply the classification to a list of test scores.

```jac
def classify_grade(score: int) -> str {
    if score >= 90 {
        return "A";
    } elif score >= 80 {
        return "B";
    } elif score >= 70 {
        return "C";
    } elif score >= 60 {
        return "D";
    } else {
        return "F";
    }
}

with entry {
    # Raw test scores
    test_scores: list[int] = [78, 85, 92, 69, 88, 95, 72];

    # Get passing grades (70 and above)
    passing_scores: list[int] = [score for score in test_scores if score >= 70];
    print(f"Passing scores: {passing_scores}");

    # Apply curve (+5 points)
    curved_scores: list[int] = [score + 5 for score in test_scores];
    print(f"Curved scores: {curved_scores}");

    # Classify each score
    grades: list[str] = [classify_grade(score) for score in test_scores];
    print(f"Grades: {grades}");
}
```
<br />

```text
$ jac run example.jac
Passing scores: [78, 85, 92, 88, 95, 72]
Curved scores: [83, 90, 97, 74, 93, 100, 77]
Grades: ['C', 'B', 'A', 'D', 'B', 'A', 'C']
```

## Working with Loops
---
Jac provides multiple loop constructs including traditional `for` loops, Jac's unique `for-to-by` loops, and clear, structured `while` loops.

### Traditional For Loops

The traditional for loop is useful when iterating over collections, such as lists or dictionaries.

```jac
def process_class_grades(grades: dict[str, list[int]]) -> None {
    for (student, student_grades) in grades.items() {
        total = 0;
        for grade in student_grades {
            total += grade;
        }
        average = total / len(student_grades);
        print(f"{student}: Average = {average}");
    }
}

with entry {
    class_grades = {
        "Alice": [88, 92, 85],
        "Bob": [79, 83, 77],
        "Charlie": [95, 89, 92]
    };

    # Process all students
    process_class_grades(class_grades);
}
```
 <br />

### Jac's Unique For-to-by Loops
Jac introduces the unique `for-to-by` loop, allowing clear and explicit iteration control.

```jac
with entry {
    print("Scaled scores (0-100 to 0-4.0 GPA):");
    for score = 60 to score <= 100 by score += 10 {
        gpa = (score - 60) * 4.0 / 40.0;
        print(f"Score {score} -> GPA {gpa}");
    }
}
```
<br />

### While Loops
Jac supports traditional `while` loops with clear curly brace syntax for iterative logic.

```jac
with entry {
    count: int = 1;
    total: int = 0;
    while count <= 5 {
        print(f"Adding {count} to total");
        total += count;
        count += 1;
    }
    print(f"Final total: {total}");
}
```
<br />


## Pattern Matching for Complex Logic
---
Use pattern matching to handle complex grading scenarios elegantly.

```jac
def process_grade_input(input: any) -> str {
    match input {
        case int() if 90 <= input <= 100:
            return f"Excellent work! Score: {input}";
        case int() if 80 <= input < 90:
            return f"Good job! Score: {input}";
        case int() if 70 <= input < 80:
            return f"Satisfactory. Score: {input}";
        case int() if 0 <= input < 70:
            return f"Needs improvement. Score: {input}";
        case str() if input in ["A", "B", "C", "D", "F"]:
            return f"Letter grade received: {input}";
        case list() if len(input) > 0:
            avg = sum(input) / len(input);
            return f"Average of {len(input)} grades: {avg}";
        case _:
            return "Invalid grade input";
    }
}

with entry {
    print(process_grade_input(95));        # Number grade
    print(process_grade_input("A"));       # Letter grade
    print(process_grade_input([88, 92, 85])); # List of grades
}
```
<br />


## Exception Handling
---
Handle errors gracefully when processing student data.

```jac
def safe_calculate_gpa(grades: list[int]) -> float {
    try {
        if len(grades) == 0 {
            raise ValueError("No grades provided");
        }
        total = sum(grades);
        return total / len(grades);
    } except ValueError as e {
        print(f"Error: {e}");
        return 0.0;
    }
}

def validate_grade(grade: int) -> None {
    if grade < 0 or grade > 100 {
        raise ValueError(f"Grade {grade} is out of valid range (0-100)");
    }
}

with entry {
    # Test safe calculation
    valid_grades = [85, 90, 78];
    gpa = safe_calculate_gpa(valid_grades);
    print(f"GPA: {gpa}");

    # Test error handling
    try {
        validate_grade(150);  # Invalid grade
    } except ValueError as e {
        print(f"Validation error: {e}");
    }
}
```
<br />

## Comments in Jac
---
Comments help document your Jac code clearly. Jac supports both single-line and multiline comments.

```jac
with entry {
    # This is a single-line comment
    student_name: str = "Alice";

    #*
        This is a
        multi-line comment.
    *#

    grades: list[int] = [88, 92, 85];

    print(student_name);
    print(grades);
}
```
<br />

## Project Structure Conventions
---
Jac encourages separating interface declarations from implementations, making code more maintainable as projects grow.

As your projects grow, following these conventions will help:

```
my_project/
├── main.jac              # Main program
├── models/
│   ├── user.jac          # User interface
│   ├── user.impl.jac     # User implementation
│   └── user.test.jac     # User tests
└── utils/
    ├── helpers.jac       # Helper functions
    └── constants.jac     # Application constants
```
<br />
### Interface and Implementation Separation
You many notice that from the project structure above, there is a file `user.jac` and `user.impl.jac`. This is a common pattern in Jac projects where interfaces are defined separately from their implementations. This allows for better organization and easier testing.

Lets consider a simple example of a user interface and its implementation. The user has a `name` and `email` attributes, and we want to validate the email format and provide a display name via the `get_display_name` and `validate` methods.

We can first define the interface in `user.jac`:
```jac
# user.jac - Interface declaration
obj User {
    has name: str;
    has email: str;

    def validate() -> bool;
    def get_display_name() -> str;
}
```
<br />

Next, we implement the interface in `user.impl.jac`:
```jac
# user.impl.jac - Implementation
impl User.validate {
    return "@" in self.email and len(self.name) > 0;
}

impl User.get_display_name {
    return f"{self.name} <{self.email}>";
}
```
<br />








## Common Beginner Mistakes and Solutions
---
Most beginner issues stem from Jac's stricter type requirements compared to Python. Here are the most common mistakes and their solutions.

| **Issue** | **Solution** |
|-----------|--------------|
| Missing semicolons | Add `;` at the end of statements |
| Missing type annotations | Add types to all variables: `x: int = 5;` |
| No entry block | Add `with entry { ... }` for executable scripts |
| Python-style indentation | Use `{ }` braces instead of indentation |

### Example of Common Fixes
Someone unfamiliar with Jac might write code like this:

```jac
# This won't work - missing types and semicolons
def greet(name) {
    return f"Hello, {name}"
}

# Missing entry block
print(greet("World"))
```
<br />

The corrected version of the code would be:
```jac
# This works - proper types and syntax
def greet(name: str) -> str {
    return f"Hello, {name}";
}

with entry {
    print(greet("World"));
}
```
<br />




## Complete Example: Simple Grade Book System
---
Lets put everything together in a complete example of a simple grade book system. This example will demonstrate Jac's type system, functions, control flow, and collections in action. The grade book will allow adding students, recording grades, calculating averages, and displaying results.

<div class="code-block">
```jac
obj GradeBook {
    has students: dict[str, list[int]] = {};

    def add_student(name: str) -> None;
    def add_grade(student: str, grade: int) -> None;
    def get_average(student: str) -> float;
    def get_all_averages() -> dict[str, float];
}

impl GradeBook.add_student(name: str) -> None {
    if name not in self.students {
        self.students[name] = [];
        print(f"Added student: {name}");
    } else {
        print(f"Student {name} already exists");
    }
}

impl GradeBook.add_grade(student: str, grade: int) -> None {
    if grade < 0 or grade > 100 {
        print(f"Invalid grade: {grade}");
        return;
    }

    if student in self.students {
        self.students[student].append(grade);
        print(f"Added grade {grade} for {student}");
    } else {
        print(f"Student {student} not found");
    }
}

impl GradeBook.get_average(student: str) -> float {
    if student not in self.students or len(self.students[student]) == 0 {
        return 0.0;
    }
    grades = self.students[student];
    return sum(grades) / len(grades);
}

impl GradeBook.get_all_averages() -> dict[str, float] {
    averages: dict[str, float] = {};
    for (student, grades) in self.students.items() {
        if len(grades) > 0 {
            averages[student] = sum(grades) / len(grades);
        }
    }
    return averages;
}

with entry {
    # Create gradebook
    gradebook = GradeBook();

    # Add students
    gradebook.add_student("Alice");
    gradebook.add_student("Bob");

    # Add grades
    gradebook.add_grade("Alice", 88);
    gradebook.add_grade("Alice", 92);
    gradebook.add_grade("Bob", 85);
    gradebook.add_grade("Bob", 79);

    # Get results
    all_averages = gradebook.get_all_averages();
    for (student, avg) in all_averages.items() {
        letter = "A" if avg >= 90 else "B" if avg >= 80 else "C" if avg >= 70 else "F";
        print(f"{student}: {avg} ({letter})");
    }
}
```
</div>
<br />



## Wrapping Up
---
This chapter introduced Jac's type system, functions, control flow, and collections. We built a simple calculator, explored object-oriented programming, and learned how to handle errors gracefully. We also covered common beginner mistakes and provided solutions to help you avoid them.
These foundational concepts will serve as the building blocks for more advanced Jac programming. In the next chapter, we will explore Jac's advanced features, including AI integration and more sophisticated data structures taking advantage of Jac's powerful type system and syntax.


---

*Now that you understand Jac's type system and syntax, let's build more sophisticated programs with functions and AI integration!*
