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
}
