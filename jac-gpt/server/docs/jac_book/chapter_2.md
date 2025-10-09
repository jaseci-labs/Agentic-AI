# 1. Starting Jac, Variables and Types
---
Getting started with Jac is straightforward - you'll have your development environment ready and your first program running in just a few minutes. This chapter covers installation, IDE setup, and writing your first Jac programs.


> Jac builds on Python's ecosystem while adding powerful new features. You'll need Python 3.12+ and can use any text editor, though VS Code provides the best experience with syntax highlighting and debugging tools.

## Installation and IDE Setup
---
### System Requirements
- Python 3.12 or higher
- pip package manager
- 4GB RAM minimum (8GB recommended)
- 500MB storage for Jac and dependencies


### Installing Jac
Installing Jac is as simple as installing any Python package:

#### Quick Install via pip

```bash
# Install Jac from PyPI
$ pip install jaclang

# Verify installation
$ jac --version
```
<br />

#### Via Virtual Environment (Recommended)

For project isolation, consider using a virtual environment:

**Linux/MacOS**

```bash
# Create virtual environment
$ python -m venv jac-env

# Activate it (Linux/Mac)
$ source jac-env/bin/activate

# Install Jac
$ pip install jaclang
```
<br />

**Windows**
```powershell
# Create virtual environment
python -m venv jac-env

# Activate it (Windows)
jac-env\Scripts\activate

# Install Jac
pip install jaclang
```
<br />

### VS Code Extension
For the best development experience, install the Jac VS Code extension:

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "Jac"
4. Install the official Jac extension

Alternatively, visit the [VS Code marketplace](https://marketplace.visualstudio.com/items?itemName=jaseci-labs.jaclang-extension) directly.

The extension provides:

- Syntax highlighting for Jac-specific constructs
- Error detection and type checking
- Code formatting and snippets
- Graph visualization for nodes and edges

### Basic CLI Commands
Jac provides a simple command-line interface (CLI) for running scripts and managing projects. This cli provides developers the ability to either run scripts locally for testing or [even serve them as web applications](../chapter_12). Here are the most common commands:
```bash
# Run a Jac file
$ jac run filename.jac

# Get help
$ jac --help

# Serve as web application (advanced)
$ jac serve filename.jac
```
<br />

## Hello World in Jac
---
Let's start with the traditional first program:

```jac
# hello.jac
with entry {
    print("Hello, Jac World!");
}
```
<br />

Run your first Jac program:
```bash
$ jac run hello.jac
Hello, Jac World!
```
<br />

## Entry Blocks and Basic Execution
---
The `with entry` block is Jac's equivalent to Python's `if __name__ == "__main__":` - it defines where program execution begins.

### Single Entry Blocks
```jac
# Entry block - program starts here
with entry {
    print("Hello single entry block!");
}
```
<br />

### Multiple Entry Blocks

Jac allows multiple entry blocks that execute in order:

```jac
# First entry block
with entry {
    print("Hello first entry block!");
}

# Second entry block
with entry {
    print("Hello second entry block!");
}

# Third entry block
with entry {
    print("Hello third entry block!");
}
```
<br />


## Variables, Types, and Basic Syntax
---
**Variables** are the building blocks of any programming language, and Jac is no exception. A variable is a named storage location that holds a value. The **type** of a variable determines what kind of values it can hold, such as numbers, words, or more complex structures.


**Jac enforces strong typing and explicit variable declarations**, ensuring that the types of all variables and function parameters are known at compile time. For example, if a function expects a `number`, it cannot be accidentally passed a `string`. Unlike Python, where type annotations are optional and often ignored at runtime, Jac requires type annotations across the board. This design choice eliminates a class of runtime type errors and improves both code clarity and maintainability, especially in large or complex projects.


### Variable Declarations
Variable declarations in Jac are similar to that of Python, but with mandatory type annotations.
```jac
with entry {
    # Basic type annotations (mandatory)
    student_name: str = "Alice";
    grade: int = 95;
    gpa: float = 3.8;
    is_honor_student: bool = True;
}
```
<br />

A **literal** is a fixed value that can be assigned to a variable. Like Python, Jac's literals can either be a *string*, *integer*, *float*, or *boolean*. However, Jac introduces an additional literal of the type called **architype**. We briefly touched on architypes in the previous chapter (e.g. node, edges, walkers) and will explore them further in chapter 9, however, it is from these architypes that Jac derives a lof of its power and flexibility.


### Integers
An integer is a whole number, positive or negative, without decimals. In Jac, integers are declared with the `int` type.

```jac
with entry {
    student_id: int = 12345;
    print(student_id);
}
```
<br />

### Floats
A float is a number that has a decimal point. In Jac, floats are declared with the `float` type.
```jac
with entry {
    gpa: float = 3.85;
    print(gpa);
}
```
<br />

### Strings
Strings are sequences of characters enclosed in quotes. In Jac, strings are declared with the `str` type.

```jac
with entry {
    student_name: str = "Alice Johnson";
    print(f"Student Name: {student_name}");
}
```
<br />

The following line `print(f"Student Name: {student_name}");` uses an f-string to format the output, similar to Python's f-strings.

### Booleans
Booleans represent truth values: `True` or `False`. In Jac, booleans are declared with the `bool` type.
```jac
with entry {
    is_enrolled: bool = True;
    print(f"Is enrolled: {is_enrolled}");
}
```
<br />




### Any Type for Flexibility
---
For those that require flexibility in their variable types, Jac provides the `any` type. This allows you to store any data type in a single variable, similar to Python's dynamic typing.

```jac
with entry {
    # Flexible grade storage
    grade_data: any = 95;
    print(f"Grade as number: {grade_data}");

    grade_data = "A";  # Now a letter grade
    print(f"Grade as letter: {grade_data}");
}
```
<br />




## Jac REPL
---
!!! warning "Warning"
    Currently, the Jac REPL feature is not available. Please use standard Jac script execution for testing and running your code.

## Wrapping Up
---
We've covered the basics of Jac, including installation, IDE setup, and writing your first program. You've learned about variables, types, and how to structure your code with entry blocks.
This foundation will help you as we explore Jac's enhanced syntax and type system.


!!! tip "Try It Yourself"
    Practice the basics by creating:
    - A simple temperature converter
    - A basic inventory management system
    - A calculator with different operations
    - A text processing utility

    Remember: Focus on proper typing and project structure from the beginning!

---

