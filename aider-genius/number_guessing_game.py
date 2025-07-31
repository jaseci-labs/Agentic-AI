import random

def play_game():
    number = random.randint(1, 100)
    attempts = 0

    print("Welcome to the Number Guessing Game!")
    print("I'm thinking of a number between 1 and 100.")

    while True:
        try:
            guess = int(input("Make a guess: "))
            attempts += 1
            if guess < number:
                print("Too low.")
            elif guess > number:
                print("Too high.")
            else:
                print(f"Congratulations! You guessed the number in {attempts} attempts.")
                break
        except ValueError:
            print("Please enter a valid integer.")

if __name__ == '__main__':
    play_game()
