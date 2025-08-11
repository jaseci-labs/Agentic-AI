import math

class AdvancedCalculator:
    def add(self, a, b):
        return a + b

    def subtract(self, a, b):
        return a - b

    def multiply(self, a, b):
        return a * b

    def divide(self, a, b):
        if b == 0:
            raise ValueError("Cannot divide by zero")
        return a / b

    def power(self, base, exponent):
        return math.pow(base, exponent)

    def square_root(self, x):
        if x < 0:
            raise ValueError("Cannot take the square root of a negative number")
        return math.sqrt(x)

    def logarithm(self, x, base=math.e):
        if x <= 0:
            raise ValueError("Logarithm undefined for non-positive values")
        return math.log(x, base)

    def sine(self, angle):
        return math.sin(math.radians(angle))

    def cosine(self, angle):
        return math.cos(math.radians(angle))

    def tangent(self, angle):
        return math.tan(math.radians(angle))
