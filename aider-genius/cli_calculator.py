import argparse
from calculator import Calculator

def main():
    parser = argparse.ArgumentParser(description="Simple CLI Calculator")
    parser.add_argument("operation", choices=["add", "subtract", "multiply", "divide"], help="Operation to perform")
    parser.add_argument("a", type=float, help="First operand")
    parser.add_argument("b", type=float, help="Second operand")

    args = parser.parse_args()

    calculator = Calculator()

    try:
        if args.operation == "add":
            result = calculator.add(args.a, args.b)
        elif args.operation == "subtract":
            result = calculator.subtract(args.a, args.b)
        elif args.operation == "multiply":
            result = calculator.multiply(args.a, args.b)
        elif args.operation == "divide":
            result = calculator.divide(args.a, args.b)

        print(f"The result of {args.operation}ing {args.a} and {args.b} is: {result}")

    except ValueError as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
import argparse
from calculator import Calculator

def main():
    parser = argparse.ArgumentParser(description="Simple CLI Calculator")
    parser.add_argument("operation", choices=["add", "subtract", "multiply", "divide"],
                        help="The operation to perform: add, subtract, multiply, or divide")
    parser.add_argument("a", type=float, help="The first operand")
    parser.add_argument("b", type=float, help="The second operand")

    args = parser.parse_args()

    calculator = Calculator()

    try:
        if args.operation == "add":
            result = calculator.add(args.a, args.b)
        elif args.operation == "subtract":
            result = calculator.subtract(args.a, args.b)
        elif args.operation == "multiply":
            result = calculator.multiply(args.a, args.b)
        elif args.operation == "divide":
            result = calculator.divide(args.a, args.b)

        print(f"The result of {args.operation}ing {args.a} and {args.b} is: {result}")

    except ValueError as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
