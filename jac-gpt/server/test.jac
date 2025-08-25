# Import necessary modules

# Define the Calculator node
node Calculator {
    # Function to add two numbers
    def add(a: int, b: int) -> int {
        return a + b;
    }

    # Function to subtract two numbers
    def subtract(a: int, b: int) -> int {
        return a - b;
    }

    # Function to multiply two numbers
    def multiply(a: int, b: int) -> int {
        return a * b;
    }

    # Function to divide two numbers
    def divide(a: int, b: int) -> float {
        if b == 0 {
            # Handle division by zero
            return 0.0;
        }
        return a / b;
    }
}

# Main entry point
with entry {
    # Create an instance of the Calculator
    calc: Calculator = Calculator();
    # Example usage
    let sum: int = calc.add(5, 3);
    let difference: int = calc.subtract(5, 3);
    let product: int = calc.multiply(5, 3);
    let quotient: float = calc.divide(5, 0);
}