node Calculator {
    has current_value: float = 0.0;

    def add(value: float) -> float {
        current_value += value;
        return current_value;
    }

    def multiply(value: float) -> float {
        current_value *= value;
        return current_value;
    }

    def get_result() -> float {
        return current_value;
    }
}

with entry {
    let calc = Calculator();
    print(calc.add(5));        # Adds 5
    print(calc.multiply(2));   # Multiplies by 2
    print(calc.get_result());   # Displays the current value
}