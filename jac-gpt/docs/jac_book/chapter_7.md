# Chapter 7: Enhanced OOP - Objects and Classes
---
Jac takes the familiar concepts of object-oriented programming and enhances them with modern features like **automatic constructors**, **implementation separation**, and **improved access control**. This chapter shows how Jac builds on traditional OOP while making it more powerful and convenient.

Jac's enhanced OOP features eliminate boilerplate code while providing better type safety and code organization than traditional approaches, making object-oriented design more intuitive and maintainable.

## Jac `obj` Archetype
---
The `obj` archetype is jac's high-level type for defining objects, similar to Python's `class`. It provides a clean syntax for defining properties and methods while automatically generating constructors.

```jac
obj Pet {
    has name: str;
    has species: str;
    has age: int;
    has is_adopted: bool = False;  # Automatic default

    def adopt() -> None {
        self.is_adopted = True;
        print(f"{self.name} has been adopted!");
    }

    def get_info() -> str {
        status = "adopted" if self.is_adopted else "available";
        return f"{self.name} is a {self.age}-year-old {self.species} ({status})";
    }
}

with entry {
    # Automatic constructor from 'has' declarations
    pet = Pet(name="Buddy", species="dog", age=3);
    print(pet.get_info());
    pet.adopt();
}
```
<br />

In our pet example, the `Pet` object has properties like `name`, `species`, and `age`, along with methods to adopt the pet and get its information. The constructor is automatically generated based on the `has` declarations, eliminating the need for boilerplate code.



### Advanced Constructor Features
Jac allows you to define constructors with more advanced features like `postinit` methods, which run after the automatic constructor is generated.

Lets enhance our pet shop example to include a `postinit` method that sets the shop's open status based on the number of pets that are present:

```jac
obj PetShop {
    has name: str;
    has pets: list[Pet] = [];
    has capacity: int = 10;
    has is_open: bool by postinit;  # Set in postinit

    def postinit() -> None {
        # Run after automatic initialization
        self.is_open = len(self.pets) < self.capacity;
        print(f"{self.name} shop initialized with {len(self.pets)} pets");
    }
}
```
<br />

## Object Inheritance
---
Jac supports inheritance, allowing you to create subclasses that extend or override parent class behavior.

### Simple Inheritance Example

```jac
obj Animal {
    has name: str;
    has species: str;
    has age: int;

    def make_sound() -> None {
        print(f"{self.name} makes a sound.");
    }
}

obj Dog(Animal) {
    has breed: str;

    def make_sound() -> None {
        print(f"{self.name} barks.");
    }
}

obj Cat(Animal) {
    has color: str;

    def make_sound() -> None {
        print(f"{self.name} meows.");
    }
}
```
<br />
In this example, `Dog` and `Cat` inherit from the `Animal` class. They can override the `make_sound` method to provide specific behavior for each animal type.

## Access Control with `:pub`, `:priv`, `:protect`
---
Unlike Python's naming conventions, Jac provides explicit access control that's enforced at runtime.

### Public Access
Public members are accessible from anywhere.

```jac
obj PublicExample {
    has :pub public_property: str;

    def :pub public_method() -> str {
        return "This is a public method";
    }
}
with entry {
    example = PublicExample(public_property="Hello");
    print(example.public_method());
    print(example.public_property);
}
```
<br />

### Private Access
Private members are only accessible within the class itself.
```jac
obj PrivateExample {
    has :priv private_property: str;
    has :priv another_private_property: int = 42;

    def :priv private_method() -> str {
        return "This is a private method";
    }

    def :pub public_method() -> str {
        return self.private_method();
    }
}
with entry {
    example = PrivateExample(private_property="Secret");
    print(example.public_method());
    # print(example.private_property);  # This would raise an error
}
```
<br />

### Protected Access
Protected members are accessible within the class and its subclasses.
```jac
obj ProtectedExample {
    has :protect protected_property: str = "Protected";
    has :protect protected_list: list[int] = [];
    has :protect protected_dict: dict[str, int] = {"key": 1};
    def :protect protected_method() -> str {
        return "This is a protected method";
    }
}
obj SubProtectedExample(ProtectedExample) {
    def :pub public_method() -> str {
        return self.protected_method();
    }
}
with entry {
    example = SubProtectedExample();
    print(example.public_method());
    print(example.protected_property);
    print(example.protected_list);
    print(example.protected_dict);
}
```
<br />


### Example: Pet Record System
In this example, we create a `PetRecord` class with public, private, and protected members to demonstrate access control in a practical scenario.


<div class="code-block">
```jac
obj PetRecord {
    # Public - anyone can access
    has :pub name: str;
    has :pub species: str;

    # Private - only this class
    has :priv owner_contact: str;
    has :priv microchip_id: str;

    # Protected - only this class and subclasses
    has :protect medical_history: list[str] = [];
    has :protect last_checkup: str = "";

    # Public method
    def :pub get_basic_info() -> str {
        return f"{self.name} is a {self.species}";
    }

    # Protected method - for vets and staff
    def :protect add_medical_record(record: str) -> None {
        self.medical_history.append(record);
        print(f"Medical record added for {self.name}");
    }

    # Private method - internal use only
    def :priv validate_contact(contact: str) -> bool {
        return "@" in contact and len(contact) > 5;
    }

    def :pub update_owner_contact(new_contact: str) -> bool {
        if self.validate_contact(new_contact) {
            self.owner_contact = new_contact;
            return True;
        }
        return False;
    }
}

obj VetRecord(PetRecord) {
    has :protect vet_notes: str = "";

    def :pub add_vet_note(note: str) -> None {
        # Can access protected members from parent
        self.add_medical_record(f"Vet note: {note}");
        self.vet_notes = note;
    }

    def :pub get_medical_summary() -> str {
        # Can access protected data
        record_count = len(self.medical_history);
        return f"{self.name} has {record_count} medical records";
    }
}

with entry {
    # Create a pet record
    pet = PetRecord(
        name="Fluffy",
        species="cat",
        owner_contact="owner@example.com",
        microchip_id="123456789"
    );

    # Public access works
    print(pet.get_basic_info());
    print(f"Pet name: {pet.name}");

    # Update contact through public method
    success = pet.update_owner_contact("new_owner@example.com");
    print(f"Contact updated: {success}");

    # Vet record with access to protected methods
    vet_record = VetRecord(
        name="Rex",
        species="dog",
        owner_contact="owner2@example.com",
        microchip_id="987654321"
    );

    vet_record.add_vet_note("Annual checkup - healthy");
    print(vet_record.get_medical_summary());
}
```
</div>
<br />



## Key Differences from Python OOP
- **Automatic Constructors**: No need to write `__init__` methods
- **Enforced Access Control**: `:pub`, `:priv`, `:protect` are actually enforced
- **Clean Inheritance**: Automatic constructor chaining in inheritance
- **Type Safety**: All method parameters and returns must be typed
- **Implementation Separation**: Can separate interface from implementation


## Wrapping Up
---

In this chapter, we explored the enhanced object-oriented features of Jac, including automatic constructors, enforced access control, and clean inheritance. We also examined practical examples to illustrate these concepts in action. In the next chapter, make the leap from Object Oriented to Object Spatial Programming (OSP), where we will see how Jac's OOP features are extended to handle spatial data and operations, making it a powerful tool for many scenarios that OOP generally struggles with.

---

*You now have powerful object-oriented tools at your disposal. Let's discover how OSP takes these concepts to the next level!*
