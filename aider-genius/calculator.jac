walker Calculator {
    can add(a: float, b: float) -> float {
        return a + b;
    }

    can subtract(a: float, b: float) -> float {
        return a - b;
    }

    can multiply(a: float, b: float) -> float {
        return a * b;
    }

    can divide(a: float, b: float) -> float {
        if b == 0 {
            std.err("Error: Division by zero");
            return 0;  // or handle as needed
        }
        return a / b;
    }

    can parse_input() -> void {
        std.out("Enter operation (add, subtract, multiply, divide): ");
        let operation = std.in();
        
        std.out("Enter first number: ");
        let a_str = std.in();
        let a = try float(a_str) else {
            std.err("Invalid input for first number.");
            return;
        };

        std.out("Enter second number: ");
        let b_str = std.in();
        let b = try float(b_str) else {
            std.err("Invalid input for second number.");
            return;
        };

        match operation {
            "add" => std.out("Result: " + add(a, b)),
            "subtract" => std.out("Result: " + subtract(a, b)),
            "multiply" => std.out("Result: " + multiply(a, b)),
            "divide" => std.out("Result: " + divide(a, b)),
            _ => std.err("Invalid operation.")
        }
    }
}
