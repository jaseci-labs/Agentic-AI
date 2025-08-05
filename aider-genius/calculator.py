class Calculator:
    """
    A simple calculator class to perform basic arithmetic operations.

    Methods:
        add(a, b): Returns the sum of a and b.
        subtract(a, b): Returns the difference of a and b.
        multiply(a, b): Returns the product of a and b.
        divide(a, b): Returns the division of a by b, raises an error if b is zero.
    """

    def add(self, a, b):
        """
        Return the sum of a and b.

        Parameters:
            a (float): The first number.
            b (float): The second number.

        Returns:
            float: The sum of a and b.
        """
        return a + b

    def subtract(self, a, b):
        """
        Return the difference of a and b.

        Parameters:
            a (float): The first number.
            b (float): The second number.

        Returns:
            float: The difference of a and b.
        """
        return a - b

    def multiply(self, a, b):
        """
        Return the product of a and b.

        Parameters:
            a (float): The first number.
            b (float): The second number.

        Returns:
            float: The product of a and b.
        """
        return a * b

    def divide(self, a, b):
        """
        Return the division of a by b. Raise an error if b is zero.

        Parameters:
            a (float): The numerator.
            b (float): The denominator.

        Returns:
            float: The result of dividing a by b.

        Raises:
            ValueError: If b is zero.
        """
        if b == 0:
            raise ValueError("Cannot divide by zero.")
        return a / b
class Calculator:
    """
    A simple calculator class to perform basic arithmetic operations.

    Methods:
        add(a, b): Returns the sum of a and b.
        subtract(a, b): Returns the difference of a and b.
        multiply(a, b): Returns the product of a and b.
        divide(a, b): Returns the division of a by b, raises an error if b is zero.
    """

    def add(self, a, b):
        return a + b

    def subtract(self, a, b):
        return a - b

    def multiply(self, a, b):
        return a * b

    def divide(self, a, b):
        if b == 0:
            raise ZeroDivisionError("Cannot divide by zero.")
        return a / b
class Calculator:
    """
    A simple calculator class to perform basic arithmetic operations.

    Methods:
        add(a, b): Returns the sum of a and b.
        subtract(a, b): Returns the difference of a and b.
        multiply(a, b): Returns the product of a and b.
        divide(a, b): Returns the division of a by b, raises an error if b is zero.
    """

    def add(self, a, b):
        """Return the sum of a and b."""
        return a + b

    def subtract(self, a, b):
        """Return the difference of a and b."""
        return a - b

    def multiply(self, a, b):
        """Return the product of a and b."""
        return a * b

    def divide(self, a, b):
        """Return the division of a by b. Raise ValueError if b is zero."""
        if b == 0:
            raise ValueError("Cannot divide by zero.")
        return a / b
class Calculator:
    """
    A simple calculator class to perform basic arithmetic operations.

    Methods:
        add(a, b): Returns the sum of a and b.
        subtract(a, b): Returns the difference of a and b.
        multiply(a, b): Returns the product of a and b.
        divide(a, b): Returns the division of a by b, raises an error if b is zero.
    """

    def add(self, a, b):
        return a + b

    def subtract(self, a, b):
        return a - b

    def multiply(self, a, b):
        return a * b

    def divide(self, a, b):
        if b == 0:
            raise ValueError("Cannot divide by zero.")
        return a / b
