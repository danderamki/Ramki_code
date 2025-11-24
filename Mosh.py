
import math
print("Hello Ram!")
print("*" * 5)

2 + 4

x = 1
y = 2
print(x+y)

# Variable Types
students_count = 1000
rating = 4.99
is_published = True
course_name = "Python for Beginners"
print(students_count)
print(rating)
print(is_published)
print(course_name)


# Strings
course_name = "Python for Beginners"
course_length = len(course_name)
print(course_length)

print(course_name[0])
print(course_name[-1])
print(course_name[0])
print(course_name[0:3])
print(course_name[0:])
print(course_name[:5])

# escape sequences
course_description = "Python's course for Beginners"
print(course_description)
#  or using single quotes
course_description = 'Python\'s course for Beginners'
print(course_description)
#  or using double quotes
course_description = "Python \"for\" Beginners"
print(course_description)
# new line and tab
course_description = "Python \n for \t Beginners"
print(course_description)
course_description = "Python's \"course for Beginners"
print(course_description)

# Formatted Strings
first_name = "Ram"
last_name = "Kiran"
# or using concatenation
full_name = first_name + " " + last_name
print(full_name)
#  or using formatted strings
full_name = f"{first_name} {last_name}"
print(full_name)

# or using format method
full_name = "{} {}".format(first_name, last_name)
print(full_name)
# or using % operator
full_name = "%s %s" % (first_name, last_name)
print(full_name)

# String Methods
course_name = "python for beginners"
print(course_name.upper())
print(course_name.lower())
print(course_name.title())
print(course_name.find("for"))  # Index of substring
print(course_name.find("xyz"))  # -1 if substring not found
print(course_name.replace("beginners", "absolute beginners"))
print("python" in course_name)  # Boolean expression
print("Java" in course_name)
print("Python" not in course_name)
print("Java" not in course_name)
print(course_name.capitalize())  # First letter capitalized
print(course_name.index("for"))  # Index of substring
print(course_name.count("n"))  # Number of occurrences of substring
print(course_name.startswith("python"))  # Boolean expression
print(course_name.endswith("beginners"))  # Boolean expression
print(course_name.split(" "))
print(course_name.strip())
print(course_name.center(50))
print(course_name.ljust(50))
print(course_name.rjust(50))
# print(course_name.zfill(50))
print(course_name.islower())
print(course_name.isupper())
print(course_name.istitle())
print(course_name.isalpha())
print(course_name.isalnum())
print(course_name.isdigit())

# Numbers
x = 10
x = 1.1
x = 1+2j
print(x)


print(10+3)
print(10-3)
print(10*3)
print(10/3)  # float division
print(10//3)  # integer division
print(10 % 3)  # modulus
print(10**3)  # exponentiation
x = 10
x += 3
print(x)
x -= 3
print(x)
x *= 3
print(x)
x /= 3
print(x)
x //= 3
print(x)
x %= 3
print(x)
x **= 3
print(x)
print(round(2.9))
print(abs(-2.9))

print(math.ceil(2.1))
print(math.floor(2.9))
print(math.sqrt(16))


# Type Conversion
# x = input("Enter a number: ")
# y = input("Enter another number: ")
# print("Sum: " + str(int(x) + int(y)))
# print("Sum: " + str(float(x) + float(y)))
int()
float()
str()
complex()
bool()

fruit = "Apple"
print(fruit[1])
print(fruit[-1:1])
print(fruit[1:-1])

# comparison operators
# print(10 == 3)
print(10 > 3)
print(10 != 3)
print("bag" == "BAG")
print("bag".lower() == "BAG".lower())
print("apple" < "banana")

# Conditional Statements
temperature = 15
if temperature > 30:
    print("It's a hot day")
    print("Drink plenty of water")
elif temperature > 20:
    print("It's a nice day")
else:
    print("It's a cold day")
    print("Wear warm clothes")

age = int(input("Enter the age :"))
if age == 5:
    print(" Reya's birthday")
elif age == 10:
    print("Myra's birthday")
else:
    print("Vardhaan's birthday")

# turnary operator
age = 15
if age < 10:
    print(" Reya's birthday")
else:
    print("Myra's birthday")
# or
age = 15
print("Reya's birthday" if age < 10 else "Myra's birthday")
# or
age = 15
message = "Reya's birthday" if age < 10 else "Myra's birthday"
print(message)
# Nested if
age = int(input("Enter the age :"))
if age < 10:
    print(" Reya's birthday")
elif age >= 10:
    print("Myra's birthday")
    if age >= 18:
        print("Vardhaan's birthday")

score = 100
update = "Eligible" if score >= 50 else "Not Eligible"
print(update)

# Logical Operators
high_income = False
good_credit = True
student = False
if high_income and good_credit:
    print("Eligible for loan")
if high_income and student:
    print("Eligible for loan")
if high_income and not student:
    print("Eligible for loan")
else:
    print("Not eligible for loan")

    # short-circuiting
high_income = True
good_credit = False
if high_income or good_credit:
    print("Eligible for loan")
else:
    print("Not eligible for loan")

 # chaining comparison operators
 # age between 18 and 65
age = 25
if 18 <= age < 65:
    print("Eligible")
else:
    print("Not eligible")

    # for loop
for number in range(1, 10, 4):
    print(number)

# for else
for number in range(1, 4):
    print(number)

# nested loops
for x in range(4):
    for y in range(3):
        print(f"({x}, {y})")

# iterables
for x in "Python":
    print(x)
for x in ["Ram", "Kiran", "Myra"]:  # list
    print(x)
for x in ("Ram", "Kiran", "Myra"):  # tuple
    print(x)
for x in {"name": "Ram", "age": 25}:  # dictionary
    print(x)
for x in {"Ram", "Kiran", "Myra"}:  # set
    print(x)


# while loop
i = 1
while i <= 5:
    print(i)
    i += 1

x = 100
while x > 0:
    print(x)
    x //= 2

    command = ""
while command.lower() != "quit":
    command = input(">")
    print("ECHO", command)

    # break and continue
while True:
    command = input(">")
    if command.lower() == "quit":
        break
    print("ECHO", command)

 # excerpt to count even numbers between 1 and 10
count = 0
for x in range(1, 10):
    if x % 2 == 0:
        count += 1
        print(x)
print(f"Total even numbers: {count}")


# functions creation and calling

# perform a task
def greet_user():
    print("Hello User!")


greet_user()

#


def greet_user(first_name, last_name):
    print(f"Hello {first_name} {last_name}!")
    print("Welcome aboard")


greet_user("Ram", "Kiran")


def greet_user(first_name, last_name):
    return f"Hello {first_name} {last_name}!"


message = greet_user("Myra", "D")
print(message)

# perform a calculation & return a value


def square(number):
    return number * number


result = square(4)
print(result)

# default parameters/ optional parameters come after required parameters at last


def increment(number, by=1):
    return number + by


result = increment(5)
print(result)


# xargs and **kwargs

def multiply(x, y):
    return x * y


result = multiply(5, 4)
print(result)


def multiply(*numbers):
    total = 1
    for number in numbers:
        total *= number
    return total


result = multiply(2, 3, 4)
print(result)


def save_user(**user):
    print(user)


save_user(id=1, name="Ram", age=25)
save_user(id=2, name="Kiran", age=30, city="New York")


def save_user(**user):
    for key, value in user.items():
        print(f"{key}: {value}")


save_user(id=1, name="Ram", age=25)
