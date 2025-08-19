# Chapter 4: More Functions
---
Jac provides a powerful function system with mandatory type annotations, built-in AI capabilities, decorators, and first-class support for functional programming patterns. This chapter builds a math functions library with AI-powered features and timing capabilities to demonstrate these features.


> In Jac, functions are first-class citizens and can be passed around, returned from other functions, and stored in data structures.

## Functional Programming in Jac
---
Functional programming is a programming paradigm that treats computation as the evaluation of mathematical functions. While Jac is not a strict functional programming language, it supports functional programming concepts with features like first-class functions, higher-order functions, and lambda expressions.

### Function as First-Class Citizens
When we say that functions are first-class citizens in Jac, it means that functions can be treated like any other data type. They can be passed as arguments to other functions, returned from functions, and assigned to variables.

Lets return to our calculator example from Chapter 3, but this time we will use functions as first-class citizens to create a more flexible calculator.

```jac
# Define a basic calculator function
def calculator(a: float, b: float, operation: callable) -> float {
    return operation(a, b);
}
```
<br />

This `calculator` function takes two numbers and an operation (which is a function) as arguments. It applies the operation to the two numbers and returns the result. We annotate the `operation` parameter with the type `callable`, indicating that it can be type that represents a function.

Next lets use a `dict` to map operation names to the actual functions that we previously defined. This allows us to easily extend the calculator with new operations without modifying the core logic.

```jac
glob operations: dict[str, callable] = {
    "add": add,
    "subtract": subtract,
    "multiply": multiply,
    "divide": divide
};
```
<br />

Finally, lets put it all together in a simple interactive calculator that allows users to choose an operation and perform calculations.

```jac
# Define a basic calculator function
def calculator(a: float, b: float, operation: callable) -> float {
    return operation(a, b);
}

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
    if b == 0 {
        raise ValueError("Cannot divide by zero");
    }
    return a / b;
}

glob operations: dict[str, callable] = {
    "add": add,
    "subtract": subtract,
    "multiply": multiply,
    "divide": divide
};

# Main entry point
with entry {
    a: float = 10.0;
    b: float = 5.0;

    # Change this to "subtract", "multiply", or "divide" to test other operations
    operation_name: str = "add";

    if operation_name in operations {
        result: float = calculator(a, b, operations[operation_name]);
        print(f"Result of {operation_name}({a}, {b}) = {result}");
    } else {
        print(f"Operation '{operation_name}' not supported.");
    }
}
```
<br />


### Lambda Functions
Lambda functions are anonymous functions that can be defined in a single line. They are useful for short, throwaway functions that are not reused elsewhere.

Lambda functions follow the syntax `lambda parameters: return_type: expression` and can be assigned to variables or used directly in expressions. They are particularly useful for functional programming patterns like map, filter, and reduce.

For example, lets redefine the add function from the previous example using a lambda function:

```jac
add = lambda x: float, y: float: x + y;
```
<br />
Here, `add` is assigned a lambda function that takes two parameters `x` and `y`, both of type `float`, and returns their sum and can be used just like a regular function.

```jac
with entry {
    add = lambda x: float, y: float: x + y;

    a: float = 10.0;
    b: float = 5.0;

    # Using the lambda function
    result: float = add(a, b);
    print(f"Result of add({a}, {b}) = {result}");
}
```
<br />

### Higher-Order Functions
Higher-order functions are functions that can take other functions as arguments or return functions as results. This allows for powerful abstractions and code reuse.

```jac
# Higher-order function that applies operation to list
def apply_operation(numbers: list[float], operation: callable) -> list[float] {
    return [operation(num) for num in numbers];
}

# Function that creates specialized functions
def create_multiplier(factor: float) -> callable[[float], float] {
    return lambda x: float: x * factor;
}

# Function composition
def compose(f: callable, g: callable) -> callable {
    return lambda x: any: f(g(x));
}

with entry {
    print("=== Higher-Order Functions Demo ===");

    numbers = [1.0, 2.0, 3.0, 4.0, 5.0];

    # Create specialized multiplier functions
    triple = create_multiplier(3.0);
    quadruple = create_multiplier(4.0);

    # Apply operations
    tripled = apply_operation(numbers, triple);
    quadrupled = apply_operation(numbers, quadruple);

    print(f"Original: {numbers}");
    print(f"Tripled: {tripled}");
    print(f"Quadrupled: {quadrupled}");
}
```
<br />

### Built-in Higher-Order Functions `map`, `filter`, and `sorted`
Jac provides built-in higher-order functions via Python that are applied to lists and other iterable data structures. These functions allow you to apply a function to each element of a list, filter elements based on a condition, and sort lists with custom criteria.

### *filter*
The higher-order function `filter` takes two arguments, a function that returns a boolean value and an iterable, returning a new iterable containing only the elements for which the function returns `True`.

Lets consider the gradebook example from Chapter 3, where we had a list of student grades and we used list comprehensions to filter out passing grades.

```jac
with entry {
    # Raw test scores
    test_scores: list = [78, 85, 92, 69, 88, 95, 72];

    # Get passing grades (70 and above)
    passing_scores: list = [score for score in test_scores if score >= 70];
    print(f"Passing scores: {passing_scores}");
}
```
<br />

The same result can be achieved using the `filter` function along with a lambda function to define the filtering condition.

```jac
with entry {
    # Raw test scores
    test_scores = [78, 85, 92, 69, 88, 95, 72];

    # Get passing grades (70 and above)
    passing_scores = list(filter(lambda x: float: x >= 70, test_scores));
    print(f"Passing scores: {passing_scores}");
}
```
<br />


### *map*
The `map` function applies a given function to each item of an iterable (like a list) and returns a new iterable with the results. This is useful for transforming data without writing explicit loops.

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
    test_scores = [78, 85, 92, 69, 88, 95, 72];

    # Get passing grades (70 and above)
    passing_scores = list(filter(lambda x: float: x >= 70, test_scores));
    print(f"Passing scores: {passing_scores}");

    grades = list(map(classify_grade, passing_scores));
    print(f"Grades: {grades}");
}
```
<br />

### *sorted*
The `sorted` function sorts an iterable and returns a new sorted list. You can provide a custom sorting function using the `key` parameter to define how elements should be compared.

```jac
with entry {
    # Raw test scores
    test_scores = [78, 85, 92, 69, 88, 95, 72];

    # Get passing grades (70 and above)
    passing_scores = list(filter(lambda x: float: x >= 70, test_scores));
    print(f"Passing scores: {passing_scores}");

    sorted_scores = sorted(passing_scores);
    print(f"Sorted passing scores: {sorted_scores}");
}
```
<br />



## Decorators for Enhanced Functionality
---
A decorator is a higher-order function that takes another function as an argument and extends its behavior without modifying its core logic. Decorators are commonly used for cross-cutting concerns like logging, timing, caching, and error handling.


Consider the following example of a simple decorator that adds pre- and post-processing logic to a function. The decorator function call `decorator_name` takes a function `func` as an argument and wraps it in a new function `wrapper` that adds additional behavior before and after calling the original function. The decorator returns the `wrapper` function, which is then used to replace the original function when the decorator is applied.

```jac
def decorator_name(func: callable) -> callable {
    def wrapper(*args: any, **kwargs: any) -> any {
        # Pre-processing logic
        result = func(*args, **kwargs);
        # Post-processing logic
        return result;
    }
    return wrapper;
```

!!! note
    `*args` is a python contruct that allows a function to accept a variable number of positional arguments, while `**kwargs` allows it to accept a variable number of keyword arguments.


Decorators provide a clean way to add functionality to functions without modifying their core logic. The general syntax for using decorators in Jac is:

```jac
@decorator_name
def function_name(parameters) -> return_type {
    # function body
}
```
<br />


### Decorator Stacking Order
Decorator stacking applies decorators from bottom to top. The decorator closest to the function definition is applied first.

```jac
import time;

def decorator_a(func: callable) -> callable {
    def wrapper(*args: any, **kwargs: any) -> any {
        print("Decorator A Start");
        result = func(*args, **kwargs);
        print("Decorator A End");
        return result;
    }
    return wrapper;
}

def decorator_b(func: callable) -> callable {
    def wrapper(*args: any, **kwargs: any) -> any {
        print("Decorator B Start");
        result = func(*args, **kwargs);
        print("Decorator B End");
        return result;
    }
    return wrapper;
}

@decorator_a
@decorator_b
def greet(name: str) -> None {
    print(f"Hello, {name}!");
}

with entry {
    greet("Alice");
}
```
<br />

### Parameterized Decorators
Decorators can accept parameters, making them highly flexible.

```jac
def repeat(times: int) -> callable {
    def decorator(func: callable) -> callable {
        def wrapper(*args: any, **kwargs: any) -> any {
            result: any;
            for i in range(times) {
                print(f"Execution {i+1} of {times}");
                result = func(*args, **kwargs);
            }
            return result;
        }
        return wrapper;
        }
    return decorator;
}

@repeat(3)
def say_hello(name: str) -> None {
    print(f"Hello, {name}");
}

with entry {
    say_hello("Bob");
}
```
<br />

### Error Handling in Decorators

Decorators in Jac can handle exceptions, retry operations, and log errors gracefully.

```jac
import time;

def retry_decorator(max_retries: int, delay: float) -> callable {
    def decorator(func: callable) -> callable {
        def wrapper(*args: any, **kwargs: any) -> any {
            attempts: int = 0;
            while attempts < max_retries {
                try {
                    return func(*args, **kwargs);
                } except Exception as e {
                    attempts += 1;
                    print(f"Attempt {attempts} failed: {e}");
                    time.sleep(delay);
                }
            }
            raise Exception("Maximum retries exceeded");
        }
        return wrapper;
    }
    return decorator;
}

@retry_decorator(max_retries=3, delay=1.0)
def risky_operation() -> None {
    import random;
    if random.random() < 0.7 {
        raise ValueError("Random failure");
    }
    print("Operation succeeded!");
}

with entry {
    risky_operation();
}
```
<br />

### Timing Decorator
A timing decorator measures and logs execution time for performance monitoring.

```jac
import time;

# Timing decorator to measure function performance
def timing_decorator(func: callable) -> callable {
    def wrapper(*args: any, **kwargs: any) -> any {
        start_time = time.time();
        result = func(*args, **kwargs);
        end_time = time.time();
        execution_time = end_time - start_time;
        print(f"{func.__name__} executed in {execution_time} seconds");
        return result;
    }
    return wrapper;
}

# Apply timing to our math functions
@timing_decorator
def slow_fibonacci(n: int) -> int {
    if n <= 1 {
        return n;
    }
    return slow_fibonacci(n - 1) + slow_fibonacci(n - 2);
}

@timing_decorator
def slow_factorial(n: int) -> int {
    if n <= 1 {
        return 1;
    }
    return n * slow_factorial(n - 1);
}

with entry {
    print("=== Timing Decorator Demo ===");
    result1 = slow_fibonacci(2);
    print(f"Fibonacci(2) = {result1}");

    result2 = slow_factorial(3);
    print(f"Factorial(3) = {result2}");
}
```
<br />

### Caching (Memoization) Decorator
A caching decorator stores results for expensive calls, improving performance on repeated invocations.

```jac
import time;

# Timing decorator to measure function performance
def timing_decorator(func: callable) -> callable {
    def wrapper(*args: any, **kwargs: any) -> any {
        start_time = time.time();
        result = func(*args, **kwargs);
        end_time = time.time();
        execution_time = end_time - start_time;
        print(f"{func.__name__} executed in {execution_time} seconds");
        return result;
    }
    return wrapper;
}

# Caching decorator for expensive computations
def cache_decorator(func: callable) -> callable {
    cache: dict[str, any] = {};

    def wrapper(*args: any) -> any {
        # Create a simple cache key from arguments
        cache_key = str(args);

        if cache_key in cache {
            print(f"Cache hit for {func.__name__}{args}");
            return cache[cache_key];
        }

        print(f"Computing {func.__name__}{args}");
        result = func(*args);
        cache[cache_key] = result;
        return result;
    }
    return wrapper;
}

# Combine timing and caching decorators
@timing_decorator
@cache_decorator
def optimized_fibonacci(n: int) -> int {
    if n <= 1 {
        return n;
    }
    return optimized_fibonacci(n - 1) + optimized_fibonacci(n - 2);
}

@timing_decorator
@cache_decorator
def expensive_calculation(n: int) -> int {
    # Simulate expensive computation
    result = 0;
    for i in range(n * 1000) {
        result += i;
    }
    return result;
}

with entry {
    print("=== Cached Functions Demo ===");

    # First call - computed and cached
    result1 = optimized_fibonacci(3);
    print(f"Fibonacci(3) = {result1}");

    # Second call - retrieved from cache
    result2 = optimized_fibonacci(3);
    print(f"Fibonacci(3) again = {result2}");

    # Expensive calculation test
    result3 = expensive_calculation(10);
    print(f"Expensive calculation result: {result3}");

    # Second call to expensive calculation
    result4 = expensive_calculation(10);
    print(f"Expensive calculation again: {result4}");
}
```
<br />


## Async Functions
---
Jac supports async functions for handling concurrent operations and non-blocking I/O.

### Basic Async Functions

```jac
import asyncio;
import time;

# Async function for simulated API calls
async def fetch_data(source: str, delay: float) -> dict[str, any] {
    print(f"Starting to fetch from {source}...");
    await asyncio.sleep(delay);  # Simulate network delay

    return {
        "source": source,
        "data": f"Data from {source}",
        "timestamp": time.time()
    };
}

# Async function that processes multiple sources
async def gather_all_data() -> list[dict[str, any]] {
    # Run multiple async operations concurrently
    tasks = [
        fetch_data("API-1", 1.0),
        fetch_data("API-2", 0.5),
        fetch_data("API-3", 1.5)
    ];

    results = await asyncio.gather(*tasks);
    return results;
}

# Regular function that uses async
def run_async_example() -> None {
    print("=== Async Functions Demo ===");

    # Run the async function
    results = asyncio.run(gather_all_data());

    print("All data fetched:");
    for result in results {
        print(f"  {result['source']}: {result['data']}");
    }
}

with entry {
    run_async_example();
}
```
<br />

## Best Practices
---
- **Use descriptive names**: Function names should clearly indicate their purpose
- **Keep functions focused**: Each function should have a single, well-defined responsibility
- **Handle errors gracefully**: Use appropriate return types and exception handling
- **Leverage decorators**: Use decorators for cross-cutting concerns like timing and caching
- **Document with types**: Let type annotations serve as documentation
- **Consider async**: Use async functions for I/O-bound operations

## Wrapping Up
---

In this chapter, we looked at higher order functions, decorators, and async functions in Jac. We explored how to use these features to create flexible, reusable code that can handle complex operations efficiently.


*Ready to explore advanced AI operations? Continue to [Chapter 5: Advanced AI Operations](chapter_5.md)!*

