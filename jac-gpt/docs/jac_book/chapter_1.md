# **1. Introduction to Jac**
---
Welcome to Jac, a revolutionary programming language that transforms how we think about computation and data relationships. This chapter introduces you to Jac's core concepts and shows why it represents a fundamental shift in programming paradigms.


> Jac introduces Object-Spatial Programming (OSP), where computation moves to data rather than data moving to computation, enabling naturally distributed and scale-agnostic applications.

## **What is Jac and Why It Exists**
---
Jac emerged from the need to better handle interconnected, graph-like data structures that are common in modern applications - social networks, knowledge graphs, distributed systems, and AI workflows. Traditional programming languages treat relationships as secondary concerns, but Jac makes them first-class citizens.
<br/>
### **Traditional Approach to Modelling Relationships**

In traditional programming, relationships can be modelled with a number of structures such as functions, methods, classes, pointer references, or even databases.

Lets consider how we might model a simple social network with friends and mutual connections in Python. First we define a `Person` class. A person class may contain a list of references to other `Person` objects to represent friendships.

```python
class Person:
    def __init__(self, name):
        self.name = name
        self.friends = []

    def add_friend(self, friend):
        self.friends.append(friend)
        friend.friends.append(self)
```
<br/>

Since friendships are a two-way relationship, we need to ensure that when one person adds a friend, the other person also has that friendship established. This requires additional logic in our methods.
```python
# Create people and relationships
alice = Person("Alice")
bob = Person("Bob")
charlie = Person("Charlie")

# Establish relationships
alice.add_friend(bob)
bob.add_friend(alice)  # This is redundant but necessary in Python
bob.add_friend(charlie)
charlie.add_friend(bob)  # Again, redundant but necessary
```
<br/>

### **Modelling Relationships Naturally**

Lets see how we might define these relationships in Jac, a language designed to handle relationships naturally and concisely.

First lets define a `Person` node and a `FriendsWith` edge to represent the friendship relationship. We will discuss nodes and edges in detail later, but for now, think of nodes as entities with state and edges as typed relationships between those entities.

```jac
node Person {
    has name: str;
}

edge FriendsWith;
```
<br/>
That single line of code defines a `Person` node with a `name` attribute and a `FriendsWith` edge type. Now we can create people and establish friendships in a much more natural way:

```jac
# Create people
alice = root ++> Person(name="Alice");
bob = root ++> Person(name="Bob");
charlie = root ++> Person(name="Charlie");

# Create relationships naturally
alice <+:FriendsWith:+> bob;
bob <+:FriendsWith:+> charlie;
```
<br/>

The Jac version is not only more concise but also naturally handles the spatial relationships between entities.

## **Object-Spatial Programming Paradigm Overview**
---
Object-Spatial Programming (OSP) is built on three fundamental concepts:

- **Nodes**: Stateful entities that hold data
- **Edges**: Typed relationships between nodes
- **Walkers**: Mobile computation that traverses the graph

### **Nodes: Data with Location**

Nodes are like enhanced objects that exist in a spatial graph:

```jac
node User {
    has username: str;
    has email: str;
    has created_at: str;
}

node Post {
    has title: str;
    has content: str;
    has likes: int = 0;
}

with entry {
    # Create nodes in the graph
    user = root ++> User(
        username="alice",
        email="alice@example.com",
        created_at="2024-01-01"
    );

    post = user ++> Post(
        title="Hello Jac!",
        content="My first post in Jac"
    );

    print(f"User {user[0].username} created post: {post[0].title}");
}
```
<br/>

### **Edges: First-Class Relationships**

Edges represent typed connections between nodes:

```jac
node Person {
    has name: str;
    has age: int;
}

edge FamilyRelation {
    has relationship_type: str;
}

with entry {
    # Create family members
    parent = root ++> Person(name="John", age=45);
    child1 = root ++> Person(name="Alice", age=20);
    child2 = root ++> Person(name="Bob", age=18);

    # Create family relationships
    parent +>:FamilyRelation(relationship_type="parent"):+> child1;
    parent +>:FamilyRelation(relationship_type="parent"):+> child2;
    child1 +>:FamilyRelation(relationship_type="sibling"):+> child2;

    # Query relationships
    children = [parent[0]->:FamilyRelation:relationship_type=="parent":->(`?Person)];

    print(f"{parent[0].name} has {len(children)} children:");
    for child in children {
        print(f"  - {child.name} (age {child.age})");
    }
}
```
<br/>


### **Walkers: Mobile Computation**

Walkers are computational entities that move through the graph:

```jac
node Person {
    has name: str;
    has visited: bool = False;
}

edge FriendsWith;

walker GreetFriends {
    can greet with Person entry {
        if not here.visited {
            here.visited = True;
            print(f"Hello, {here.name}!");

            # Visit all friends
            visit [->:FriendsWith:->];
        }
    }
}

with entry {
    # Create friend network
    alice = root ++> Person(name="Alice");
    bob = root ++> Person(name="Bob");
    charlie = root ++> Person(name="Charlie");

    # Connect friends
    alice +>:FriendsWith:+> bob +>:FriendsWith:+> charlie;
    alice +>:FriendsWith:+> charlie;  # Alice also friends with Charlie

    # Spawn walker to greet everyone
    alice[0] spawn GreetFriends();
}
```
<br/>

## Scale-Agnostic Programming Concept
---
One of Jac's most powerful features is scale-agnostic programming - code written for one user automatically scales to multiple users and distributed systems.


> The same Jac code works whether you have 1 user or 1 million users, running on a single machine or distributed across the globe.

### **Automatic Persistence**
Jac automatically persists data connected to the root node, so you don't need to manage databases or storage manually. This allows you to focus on relationships and computation rather than infrastructure.

The following example demonstrates a simple counter that persists automatically when deployed to a Jac server:
```jac
node Counter {
    has count: int = 0;

    def increment() -> None;
}

impl Counter.increment {
    self.count += 1;
    print(f"Counter is now: {self.count}");
}

with entry {
    # Get or create counter
    counters = [root-->(`?Counter)];
    if not counters {
        counter = root ++> Counter();
        print("Created new counter");
    }

    # Increment and save automatically
    counter[0].increment();
}
```
<br/>

### **Multi-User Isolation**

Each user automatically gets their own isolated graph space:

```jac
node UserProfile {
    has username: str;
    has bio: str = "";
}

walker GetProfile {
    can get_user_info with entry {
        # 'root' automatically refers to current user's space
        profiles = [root-->(`?UserProfile)];
        if profiles {
            profile = profiles[0];
            print(f"Profile: {profile.username}");
            print(f"Bio: {profile.bio}");
        } else {
            print("No profile found");
        }
    }
}

walker CreateProfile {
    has username: str;
    has bio: str;

    can create with entry {
        # Each user gets their own isolated root
        profile = root ++> UserProfile(
            username=self.username,
            bio=self.bio
        );
        print(f"Created profile for {profile[0].username}");
    }
}

with entry {
    # This code works for any user automatically
    CreateProfile(username="alice", bio="Jac developer") spawn root;
    GetProfile() spawn root;
}
```
<br/>

## Comparison with Python and Traditional Languages
---

While Jac maintains familiar syntax for Python developers, it introduces powerful new concepts:

### **Syntax Familiarity**

```jac
# Variables and functions work similarly
def calculate_average(numbers: list[float]) -> float {
    if len(numbers) == 0 {
        return 0.0;
    }
    return sum(numbers) / len(numbers);
}

with entry {
    scores = [85.5, 92.0, 78.5, 96.0, 88.5];
    avg = calculate_average(scores);
    print(f"Average score: {avg}");

    # Control flow is familiar
    if avg >= 90.0 {
        print("Excellent performance!");
    } elif avg >= 80.0 {
        print("Good performance!");
    } else {
        print("Needs improvement.");
    }
}
```
<br/>


### Key Differences

| Aspect | Python | Jac |
|--------|--------|-----|
| **Relationships** | Manual references | First-class edges |
| **Persistence** | External database | Automatic |
| **Multi-user** | Manual session management | Built-in isolation |
| **Distribution** | Complex setup | Transparent |
| **Graph Operations** | Manual traversal | Spatial queries |
| **Type System** | Optional hints | Mandatory annotations |

## Simple Friend Network Example
---

Let's build a complete friend network example that demonstrates Jac's core concepts.


### Creating nodes
First lets define our `Person` node and a `FriendsWith` edge to represent friendships:
```jac
node Person {
    has name: str;
    has age: int;
    has interests: list[str] = [];
}

edge FriendsWith {
    has since: str;
    has closeness: int;  # 1-10 scale
}
```
<br/>

We can now create simple friends and establish friendships with metadata:
```jac
# Create friend network
alice = root ++> Person(
    name="Alice",
    age=25,
    interests=["coding", "music", "hiking"]
);

bob = root ++> Person(
    name="Bob",
    age=27,
    interests=["music", "sports", "cooking"]
);

charlie = root ++> Person(
    name="Charlie",
    age=24,
    interests=["coding", "gaming", "music"]
);

# Create friendships with metadata
alice +>:FriendsWith(since="2020-01-15", closeness=8):+> bob;
alice +>:FriendsWith(since="2021-06-10", closeness=9):+> charlie;
bob +>:FriendsWith(since="2020-12-03", closeness=7):+> charlie;
```
<br/>

### Creating the walker
Next, lets create a walker to analyze the friend network and find common interests:
```jac
walker FindCommonInterests {
    has target_person: Person;
    has common_interests: list[str] = [];

    can find_common with Person entry {
        if here == self.target_person {
            return;  # Skip self
        }

        # Find shared interests
        shared = [];
        for interest in here.interests {
            if interest in self.target_person.interests {
                shared.append(interest);
            }
        }

        if shared {
            self.common_interests.extend(shared);
            print(f"{here.name} and {self.target_person.name} both like: {', '.join(shared)}");
        }
    }
}
```
<br/>

To use the walker, you need to spawn it on a node of type `Person`—this node is provided as the first argument to the walker. As the walker traverses the graph, it maintains a list of common interests which is stored in the `common_interests` attribute and updates whenever it visits other `Person` nodes. The walker’s `find_common` ability is automatically triggered each time it encounters a `Person` node, where it compares interests with the target person and prints any shared interests it finds.


### Bringing it all together
Finally, we can use the walker to analyze Alice's friends and find common interests:

<div class="code-block">
```jac
node Person {
    has name: str;
    has age: int;
    has interests: list[str] = [];
}

edge FriendsWith {
    has since: str;
    has closeness: int;  # 1-10 scale
}

walker FindCommonInterests {
    has target_person: Person;
    has common_interests: list[str] = [];

    can find_common with Person entry {
        if here == self.target_person {
            return;  # Skip self
        }

        # Find shared interests
        shared = [];
        for interest in here.interests {
            if interest in self.target_person.interests {
                shared.append(interest);
            }
        }

        if shared {
            self.common_interests.extend(shared);
            print(f"{here.name} and {self.target_person.name} both like: {', '.join(shared)}");
        }
    }
}

with entry {
    # Create friend network
    alice = root ++> Person(
        name="Alice",
        age=25,
        interests=["coding", "music", "hiking"]
    );

    bob = root ++> Person(
        name="Bob",
        age=27,
        interests=["music", "sports", "cooking"]
    );

    charlie = root ++> Person(
        name="Charlie",
        age=24,
        interests=["coding", "gaming", "music"]
    );

    # Create friendships with metadata
    alice +>:FriendsWith(since="2020-01-15", closeness=8):+> bob;
    alice +>:FriendsWith(since="2021-06-10", closeness=9):+> charlie;
    bob +>:FriendsWith(since="2020-12-03", closeness=7):+> charlie;

    print("=== Friend Network Analysis ===");

    # Find Alice's friends
    alice_friends = [alice[0]->:FriendsWith:->(`?Person)];
    print(f"Alice's friends: {[f.name for f in alice_friends]}");

    # Find common interests between Alice and her friends
    finder = FindCommonInterests(target_person=alice[0]);
    for friend in alice_friends {
        friend spawn finder;
    }

    # Find close friendships (closeness >= 8)
    close_friendships = [root-->->:FriendsWith:closeness >= 8:->];
    print(f"Close friendships ({len(close_friendships)} found):");
}
```
</div>
<br/>

This example demonstrates how Jac's Object-Spatial Programming model allows you to express complex relationships and computations in a natural, intuitive way. The walker traverses the graph, finding common interests and printing them out, all while maintaining the relationships defined by edges.


## Key Takeaways
---
**Core Concepts:**

- **Object-Spatial Programming (OSP)** moves computation to data through nodes, edges, and walkers
- **Nodes** are enhanced objects that exist in spatial relationships
- **Edges** represent first-class, typed relationships between nodes
- **Walkers** are mobile computational entities that traverse graphs

**Key Advantages:**

- **Scale-agnostic programming**: Code automatically works from single-user to distributed systems
- **Automatic persistence**: Data connected to root persists without manual database management
- **Natural relationships**: Graph traversal is intuitive and expressive
- **Multi-user isolation**: Built-in user separation without complex session management
- **Python familiarity**: Familiar syntax with powerful new capabilities


Start thinking about problems in your domain that involve relationships:
- Social networks and user connections
- Knowledge graphs and information relationships
- Workflow systems and process connections
- Data pipelines and transformation chains

!!! Note
    Remember: Jac shines when your problem naturally involves connected data!

---

*Ready to start your Object-Spatial Programming journey? Let's get your environment set up and build your first Jac application!*
