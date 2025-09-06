glob full_language: str = """# Jac Examples Documentation

This document provides a comprehensive overview of all examples in the Jac language repository.

Generated on: Tue Sep  2 03:23:34 PM +0530 2025

## Table of Contents

- [Data_Spatial](#data-spatial)
- [Guess_Game](#guess-game)
- [Littlex](#littlex)
- [Manual_Code](#manual-code)
- [Medical](#medical)
- [Micro](#micro)
- [Myca](#myca)
- [Plugins](#plugins)
- [Reference](#reference)
- [Rpg_Game](#rpg-game)
- [Shopping_Cart](#shopping-cart)

## Data_Spatial

**JAC Files:**

#### `data_spatial/create_node.jac`

**File Info:**
- Lines: 12
- Non-empty lines: 9
- Features: Nodes

**Code:**
```jac
node MyNode{}

with entry{
    first_tier =[MyNode() for i in range(2)];
    second_tier =[MyNode() for i in range(2)];

    root ++> first_tier;
    first_tier ++> second_tier;

    end_tier = MyNode();
    second_tier ++> end_tier;
}
```

#### `data_spatial/custom_edge.jac`

**File Info:**
- Lines: 23
- Non-empty lines: 17
- Features: Nodes, Edges

**Code:**
```jac
node MyNode{
    has val:int =0;
}

edge a{}

edge b{}

edge c{}

with entry{
    Start = MyNode(5);
    root +>:a:+> Start;
    Start +>:b:+> MyNode(10) +>:c:+> MyNode(15);
    Start +>:b:+> MyNode(20) +>:a:+> MyNode(25);

    print([root-->]);
    print([root<--]);
    print([root->:a:->]);
    print([root->:a:-> ->:b:->]);
    print([root->:a:-> ->:b:->->:c:->]);

}
```

#### `data_spatial/define_walker.jac`

**File Info:**
- Lines: 26
- Non-empty lines: 19
- Features: Nodes, Edges, Walkers

**Code:**
```jac
node A{
    has val:int =0;
}

edge a{
}

walker W{
    can create with `root entry;
}

impl W.create {
    Start = A(5);
    here +>:a:+> Start;
    Start +>:a:+> A(10) +>:a:+> A(15);
    Start +>:a:+> A(20) +>:a:+> A(25);
}



with entry{
    root spawn W();
    print([root-->-->(`?A)]);
    print([root--> --> -->(`?A)]);
}

```

#### `data_spatial/ds_entry_exit.jac`

**File Info:**
- Lines: 36
- Non-empty lines: 30
- Features: Classes, Nodes, Walkers

**Code:**
```jac
node test_node {
    has value: int;
}

walker test_walker {
    has visited_nodes: list = [];
    has entry_count: int = 0;
    has exit_count: int = 0;

    can traverse with `root entry {
        visit [-->](`?test_node);
    }

    can log_entry with entry {
        print("Entering at the beginning of walker: ",here);
        self.entry_count += 1;
    }

    can log_visit with test_node exit {
        print("Visiting node : ", here);
        self.visited_nodes.append(here);
    }

    can log_exit with exit {
        print("Exiting at the end of walker: ",here);
        self.exit_count += 1;
    }
}

with entry {
    for i in range(10) {
        root ++> (next:=test_node(value=i));
    }
    wlk_obj = root spawn test_walker();
    print(wlk_obj);
}
```

#### `data_spatial/edge_filtering.jac`

**File Info:**
- Lines: 26
- Non-empty lines: 21
- Features: Nodes, Edges

**Code:**
```jac
node A{
    has val:int =0;
}

edge a{
    has val:int = 0;
}
edge b{
    has val:int = 0;
}

with entry{

    root +>:a:val=10:+> A(10);
    root +>:a:val=20:+> A(20);
    root +>:b:val=30:+> A(30);

    print([root--> ]);
    print([root->:a:-> ]);
    print([root->:a:val<=15:-> ]);
    # print([root->:a:?val<=15:-> ]); # Syntax error
    print([root->:a:val>=20:-> ]);
    print([root->:a:val<=15:->(`?A)](?val==10)); # complete example
    print([root->:a:val<=15:->(`?A)](?val!=10)); # complete example
}

```

#### `data_spatial/filtering.jac`

**File Info:**
- Lines: 33
- Non-empty lines: 28
- Features: Nodes, Edges

**Code:**
```jac
node A{
    has val:int =0;
}
node B{
    has val:int =0;
}
node C{
    has val:int =0;
}

edge a{}

edge b{}

edge c{}

with entry{
    Start = A(5);
    Intermediate = B(10);
    End = C(25);
    root +>:a:+> Start;
    Start +>:b:+> Intermediate +>:c:+> C(15);
    Start +>:b:+> A(20) +>:a:+> End;
    Intermediate +>:c:+> End;

    print([root-->->:b:->(`?A)]);
    print([root->:a:-> ->:b:-> ->:a:->(`?C)]);
    print([root->:a:-> ->:b:-> ->:c:->(`?C)]);
    print([root->:a:-> ->:b:-> ->:c:->(`?C)](?val==25));
    # print([root->:a:-> ->:b:-> ->:c:->(`?C)(?val==25)]); # syntax error
    print([root->:a:-> ->:b:-> ->:c:->(?val<20)]);
    print([root->:a:-> ->:b:-> ->:c:->](?val<20)); # both are similar
}
```

#### `data_spatial/node_connections.jac`

**File Info:**
- Lines: 25
- Non-empty lines: 20
- Features: Nodes, Edges

**Code:**
```jac
node a{
    has value:int =10;
}

edge b{
    has value:int = 20;
}

with entry{
    node_1 = a(value=5);
    node_2 = a();
    node_3 = a(value=15);
    node_4 = a(value=20);
    node_5 = a(value=25);

    root ++> node_1;
    node_1 +>:edge_1:= b(value=5):+> node_2;
    node_1 +>:edge_2:=b(value=10):+> node_3;
    node_1 +>:edge_3:=b(value=15):+> node_4;
    node_1 +>:edge_4:=b():+> node_5;

    node_1 del --> node_2;
    del node_3;

}
```

#### `data_spatial/visiting.jac`

**File Info:**
- Lines: 20
- Non-empty lines: 14
- Features: Nodes, Edges

**Code:**
```jac
node MyNode{
    has Name:str;
}

edge a{}


with entry{
    Start = MyNode("Start");
    End = MyNode("End");
    root <+:a:<+ Start;
    root +>:a:+> End;

    print([root-->]);
    print([root<--]);
    print([Start-->]);
    print([End<--]);


}
```

## Guess_Game

**JAC Files:**

#### `guess_game/guess_game1.jac`

**Description:** A Number Guessing Game

**File Info:**
- Lines: 60
- Non-empty lines: 50
- Features: Classes, Functions, Imports

**Code:**
```jac
\"\"\"A Number Guessing Game\"\"\"

import random;


class Game {
    def init(self: Game, attempts: int = 10) {
        self.attempts = attempts;
        self.won = False;
    }

    def play(self: Game) {
        raise NotImplementedError("Subclasses must implement this method.") ;
    }
}


class GuessTheNumberGame(Game) {
    def init(self: GuessTheNumberGame, attempts: int = 10) {
        super.init(attempts);
        self.correct_number = random.randint(1, 10);
    }

    def play(self: GuessTheNumberGame) {
        while self.attempts > 0 {
            guess = input("Guess a number between 1 and 10: ");
            if guess.isdigit() {
                self.process_guess(int(guess));
                if self.won {
                    break;
                }
            } else {
                print("That's not a valid number! Try again.");
            }
        }
        if not self.won {
            print("Sorry, you didn't guess the number. Better luck next time!");
        }
    }

    def process_guess(self: GuessTheNumberGame, guess: int) {
        if guess > self.correct_number {
            print("Too high!");
        } elif guess < self.correct_number {
            print("Too low!");
        } else {
            print("Congratulations! You guessed correctly.");
            self.won = True;
            return;
        }
        self.attempts -= 1;
        print(f"You have {self.attempts} attempts left.");
    }
}


with entry {
    game = GuessTheNumberGame();
    game.play();
}
```

#### `guess_game/guess_game2.jac`

**Description:** A Number Guessing Game

**File Info:**
- Lines: 55
- Non-empty lines: 45
- Features: Classes, Functions, Imports

**Code:**
```jac
\"\"\"A Number Guessing Game\"\"\"

import random;


obj Game {
    has attempts: int, won: bool = False;

    def play {
        raise NotImplementedError("Subclasses must implement this method.");
    }
}


obj GuessTheNumberGame (Game) {
    has attempts: int = 10, correct_number: int = random.randint(1, 10);

    def play {
        while self.attempts > 0 {
            guess = input("Guess a number between 1 and 10: ");
            if guess.isdigit() {
                self.process_guess(int(guess));
                if self.won {
                    break;
                }
            } else {
                print("That's not a valid number! Try again.");
            }
        }
        if not self.won {
            print("Sorry, you didn't guess the number. Better luck next time!");
        }
    }

    def process_guess(guess: int) {
        if guess > self.correct_number {
            print("Too high!");
        } elif guess < self.correct_number {
            print("Too low!");
        } else {
            print("Congratulations! You guessed correctly.");
            self.won = True;
            return;
        }
        self.attempts -= 1;
        print(f"You have {self.attempts} attempts left.");
    }
}


# Run the game
with entry {
    game = GuessTheNumberGame();
    game.play();
}
```

#### `guess_game/guess_game3.impl.jac`

**File Info:**
- Lines: 42
- Non-empty lines: 35

**Code:**
```jac
impl Game.play{
    raise NotImplementedError("Subclasses must implement this method.") ;
}


impl GuessTheNumberGame.init{
    self.attempts = 10;
    self.correct_number = random.randint(1, 10);
}


impl GuessTheNumberGame.play{
    while self.attempts > 0 {
        guess = input("Guess a number between 1 and 10: ");
        if guess.isdigit() {
            self.process_guess(int(guess));
        } else {
            print("That's not a valid number! Try again.");
        }
    }
    if not self.won {
        print("Sorry, you didn't guess the number. Better luck next time!");
    }
}


impl GuessTheNumberGame.process_guess(guess: int) {
    if guess > self.correct_number {
        print("Too high!");
        self.attempts -= 1;
    } elif guess < self.correct_number {
        print("Too low!");
        self.attempts -= 1;
    } else {
        print("Congratulations! You guessed correctly.");
        self.won = True;
        self.attempts = 0;
        return;
    }
    print(f"You have {self.attempts} attempts left.");
}

```

#### `guess_game/guess_game3.jac`

**Description:** A Number Guessing Game

**File Info:**
- Lines: 24
- Non-empty lines: 17
- Features: Classes, Functions, Imports

**Code:**
```jac
\"\"\"A Number Guessing Game\"\"\"
import random;


obj Game {
    has attempts: int, won: bool = False;

    def play;
}


obj GuessTheNumberGame (Game) {
    has correct_number: int = random.randint(1, 10);

    def init;
    override def play;
    def process_guess(guess: int);
}

# Run the game
 with entry {
    game = GuessTheNumberGame();
    game.play();
}
```

#### `guess_game/guess_game4.impl.jac`

**File Info:**
- Lines: 31
- Non-empty lines: 26

**Code:**
```jac
impl turn.check{
    guess = input("Guess a number between 1 and 10: ");
    if guess.isdigit() {
        visitor.process_guess(int(guess));
    } else {
        print("That's not a valid number! Try again.");
    }
    visit [-->];
}


impl GuessGame.start_game{
    end: `root | turn = here;
    for i = 0 to i < 10 by i += 1 {
        end ++> (end := turn());
    }
    visit [-->];
}


impl GuessGame.process_guess(guess: int) {
    if guess > self.correct_number {
        print("Too high!");
    } elif guess < self.correct_number {
        print("Too low!");
    } else {
        print("Congratulations! You guessed correctly.");
        disengage;
    }
}

```

#### `guess_game/guess_game4.jac`

**Description:** A Number Guessing Game

**File Info:**
- Lines: 20
- Non-empty lines: 14
- Features: Functions, Nodes, Walkers, Imports

**Code:**
```jac
\"\"\"A Number Guessing Game\"\"\"

import random;

walker GuessGame {
    has correct_number: int = random.randint(1, 10);
    
    can start_game with `root entry;
    def process_guess(guess: int);
}

node turn {
    can check with GuessGame entry;
}

# Run the game
 with entry {
    GuessGame() spawn root;
}

```

#### `guess_game/guess_game5.impl.jac`

**File Info:**
- Lines: 27
- Non-empty lines: 24

**Code:**
```jac
impl GuessGame.start {
    if not [root --> (`?turn)] {
        next = root ++> turn(random.randint(1, 10));
    } else {
        next = [root --> (`?turn)];
    }
    visit next;
}

impl GuessGame.process_guess {
    if [-->] {
        visit [-->];
    } else {
        if self.guess < here.correct_number {
            print("Too high!");
            here ++> turn(here.correct_number);
        } elif self.guess > here.correct_number {
            print("Too low!");
            here ++> turn(here.correct_number);
        } else {
            print("Congratulations! You guessed correctly.");
            disengage;
        }
    }

}

```

#### `guess_game/guess_game5.jac`

**Description:** A Number Guessing Game

**File Info:**
- Lines: 23
- Non-empty lines: 17
- Features: Nodes, Walkers, Imports

**Code:**
```jac
\"\"\"A Number Guessing Game\"\"\"

import random;

walker GuessGame {
    has guess: int;

    can start with `root entry;
    can process_guess with turn entry;
}

node turn {
    has correct_number: int = random.randint(1, 10);
}

# Will run when in CLI mode (not in cloud)
 with entry:__main__ {
    root spawn GuessGame(3);
    root spawn GuessGame(4);
    root spawn GuessGame(5);
    root spawn GuessGame(6);
}

```

#### `guess_game/guess_game6.impl.jac`

**File Info:**
- Lines: 26
- Non-empty lines: 24

**Code:**
```jac
impl GuessGame.start {
    if not [root --> (`?turn)] {
        next = root ++> turn(random.randint(1, 10));
    } else {
        next = [root --> (`?turn)];
    }
    visit next;
}

impl GuessGame.process_guess {
    if [-->] {
        visit [-->];
    } else {
        if self.guess < here.correct_number {
            print(give_hint(self.guess, here.correct_number));
            here ++> turn(here.correct_number);
        } elif self.guess > here.correct_number {
            print(give_hint(self.guess, here.correct_number));
            here ++> turn(here.correct_number);
        } else {
            print("Congratulations! You guessed correctly.");
            disengage;
        }
    }

}
```

#### `guess_game/guess_game6.jac`

**Description:** A Number Guessing Game

**File Info:**
- Lines: 30
- Non-empty lines: 22
- Features: Functions, Nodes, Walkers, Imports

**Code:**
```jac
\"\"\"A Number Guessing Game\"\"\"

import random;
import from byllm.llm { Model }

# glob llm = Model(model_name="gpt-4o",verbose=False);
 glob llm = Model(model_name="gemini/gemini-2.0-flash", verbose=False);

\"\"\"Provide a fun hint if guess is incorrect\"\"\"
def give_hint(guess: int, correct_number: int) -> str by llm();

walker GuessGame {
    has guess: int;

    can start with `root entry;
    can process_guess with turn entry;
}

node turn {
    has correct_number: int = random.randint(1, 10);
}

# Will run when in CLI mode (not in cloud)
 with entry:__main__ {
    root spawn GuessGame(3);
    root spawn GuessGame(4);
    root spawn GuessGame(5);
    root spawn GuessGame(6);
}

```

**Python Files:**

- `guess_game/guess_game.py`

## Littlex

**JAC Files:**

#### `littleX/littleX.impl.jac`

**File Info:**
- Lines: 129
- Non-empty lines: 108
- Features: Nodes, Edges

**Code:**
```jac

impl search_tweets {
    transformed = vectorizer.fit_transform([query, tweet]);
    similarity = cosine_similarity(transformed[0], transformed[1])[0];
    return similarity;
}

impl Profile.update {
    self.username = visitor.new_username;
    report self;
}

impl Profile.get {
        follwers=[{"id": jid(i), "username": i.username} for i in [self-->(`?Profile)]];
        report {"user": self, "followers": follwers};
    }

impl Profile.follow{
        current_profile = [root-->(`?Profile)];
        current_profile[0] +>:Follow():+> self;
        report self;
    }

impl Profile.un_follow {
        current_profile = [root-->(`?Profile)];
        follow_edge = [edge current_profile[0] ->:Follow:-> self];
        del follow_edge[0];
        report self;
    }

impl Tweet.update {
        self.content = visitor.updated_content;
        report self;
    }

impl Tweet.delete {
        del self;
        disengage;
    }

impl Tweet.like_tweet {
        current_profile = [root-->(`?Profile)];
        self +>:Like():+> current_profile[0];
        report self;
    }

impl Tweet.remove_like {
        current_profile = [root-->(`?Profile)];
        like_edge = [edge self ->:Like:-> current_profile[0]];
        del like_edge[0];
        report self;
    }

impl Tweet.comment {
        current_profile = [root-->(`?Profile)];
        comment_node = current_profile[0] +>:Post():+> Comment(content=visitor.content);
        grant(comment_node[0], level=ConnectPerm);
        self ++> comment_node[0];
        report comment_node[0];
    }

impl Tweet.get_info {
        return TweetInfo(
            username=[self<-:Post:<-][0].username,
            id=jid(self),
            content=self.content,
            embedding=self.embedding,
            likes=[i.username for i in [self->:Like:->]],
            comments=[{"username": [i<--(`?Profile)][0].username, "id": jid(i), "content": i.content} for i in [self-->(`?Comment)]]
        );
    }

impl Tweet.get {
        tweet_info = self.get_info();
        similarity = search_tweets(visitor.search_query, tweet_info.content);
        visitor.results.append({"Tweet_Info": tweet_info, "similarity": similarity});
    }

impl Comment.update {
        self.content = visitor.updated_content;
        report self;
    }

impl Comment.delete {
        del self;
        disengage;
    }

impl visit_profile.visit_profile {
        visit [-->(`?Profile)] else {
            new_profile = here ++> Profile();
            grant(new_profile[0], level=ConnectPerm);
            visit new_profile;
        }
    }

impl load_user_profiles.load_profiles {
        self.profiles: list = [];

        for each_root in allroots() {
            profile = [each_root --> (`?Profile)][0];
            self.profiles.append(
                {"name": profile.username, "id": jid(profile)}
            );
        }
    }

impl load_user_profiles.report_profiles {
    report self.profiles;
}

impl create_tweet.tweet {
        embedding = vectorizer.fit_transform([self.content]).toarray().tolist();
        tweet_node = here +>:Post():+> Tweet(content=self.content, embedding=embedding);
        grant(tweet_node[0], level=ConnectPerm);
        report tweet_node;
    }

impl load_feed.load {
        visit [-->(`?Tweet)];
        for user_node in [->:Follow:->(`?Profile)] {
            visit [user_node-->(`?Tweet)];
        }
    }

impl load_feed.report_feed {
        self.results.sort(key=lambda x:dict:x['similarity'][0], reverse=True);
        report self.results;
}
```

#### `littleX/littleX.jac`

**File Info:**
- Lines: 122
- Non-empty lines: 80
- Features: Classes, Functions, Nodes, Edges, Walkers, Imports

**Code:**
```jac
import datetime;
import numpy;
import from sklearn.feature_extraction.text { TfidfVectorizer }
import from sklearn.metrics.pairwise { cosine_similarity }

glob vectorizer = TfidfVectorizer();

def search_tweets(query: str, tweet:str) -> int;

node Profile {
    has username: str = "";

    can update with update_profile entry;

    can get with get_profile entry;

    can follow with follow_request entry;

    can un_follow with un_follow_request entry;
}

obj TweetInfo {
    has username: str;
    has id: str;
    has content: str;
    has embedding: list;
    has likes: list;
    has comments: list;
}

node Tweet {
    has content: str;
    has embedding: list;
    has created_at: str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S");

    can update with update_tweet exit;

    can delete with remove_tweet exit;

    can like_tweet with like_tweet entry;

    can remove_like with remove_like entry;

    can comment with comment_tweet entry;

    def get_info()-> TweetInfo;

    can get with load_feed entry;
}

node Comment {
    has content: str;

    can update with update_comment entry;

    can delete with remove_comment entry;
}

edge Follow {}

edge Like {}

edge Post {}

walker visit_profile {
    can visit_profile with `root entry;
}

walker update_profile(visit_profile) {
    has new_username: str;
}

walker get_profile(visit_profile) {}

walker load_user_profiles {
    obj __specs__ {
        static has auth: bool = False;
    }
    can load_profiles with `root entry;

    can report_profiles with exit;
}

walker follow_request {}

walker un_follow_request {}

walker create_tweet(visit_profile) {
    has content: str;

    can tweet with Profile entry;
}

walker update_tweet {
    has updated_content: str;
}

walker remove_tweet {}

walker like_tweet {}

walker remove_like {}

walker comment_tweet {
    has content: str;
}

walker update_comment {
    has updated_content: str;
}

walker remove_comment {}

walker load_feed(visit_profile) {
    has search_query: str = "";
    has results: list = [];

    can load with Profile entry;

    can report_feed with exit;

}
```

#### `littleX/littleX.test.jac`

**File Info:**
- Lines: 105
- Non-empty lines: 92
- Features: Walkers

**Code:**
```jac
test visit_profile {
    root spawn visit_profile();
    profile = [root --> (`?Profile)][0];
    check isinstance(profile,Profile);
}

test update_profile {
    root spawn update_profile(
        new_username = "test_user",
    );
    profile = [root --> (`?Profile)][0];
    check profile.username == "test_user";
}

test follow_request {
    followee = Profile("Sam");
    followee spawn follow_request();
    followee_profile = [root --> (`?Profile)->:Follow:->(`?Profile)][0];
    check followee_profile.username == "Sam";
}

test un_follow_request {
    followee = [root --> (`?Profile)->:Follow:->(`?Profile)][0];
    followee spawn un_follow_request();
    check len([root --> (`?Profile)->:Follow:->(`?Profile)]) == 0;
}

test create_tweet {
    root spawn create_tweet(
        content = "test_tweet",
    );
    test1 = [root --> (`?Profile) --> (`?Tweet)][0];
    check test1.content == "test_tweet";
}

test update_tweet {
    tweet1 = [root --> (`?Profile) --> (`?Tweet)][0];
    tweet1 spawn update_tweet(
        updated_content = "new_tweet",
    );
    check tweet1.content == "new_tweet";
}

test remove_tweet {
    tweet2 =  [root --> (`?Profile)--> (`?Tweet)][0];
    tweet2 spawn remove_tweet();
    check len([root --> (`?Profile) --> (`?Tweet)]) == 0;
}

test like_tweet {
    root spawn create_tweet(
        content = "test_like",
    );
    tweet1 = [root --> (`?Profile) --> (`?Tweet)][0];
    tweet1 spawn like_tweet();
    test1 = [tweet1 ->:Like:-> ][0];
    check test1.username == "test_user";
}

test remove_like {
    tweet1 = [root --> (`?Profile) --> (`?Tweet)][0];
    tweet1 spawn remove_like();
    check len([tweet1 ->:Like:-> ]) == 0;
}

test comment_tweet {
    tweet = [root --> (`?Profile) --> (`?Tweet)](?content == "test_like")[0];
    tweet spawn comment_tweet(
        content = "test_comment",
    );
    comment = [tweet --> (`?Comment)][0];
    check comment.content == "test_comment";
}

test update_comment {
    tweet = [root --> (`?Profile) --> (`?Tweet)](?content == "test_like")[0];
    comment = [tweet --> (`?Comment)][0];
    comment spawn update_comment(
        updated_content = "new_comment",
    );
    check comment.content == "new_comment";
}

test remove_comment {
    comment = [root --> (`?Profile) --> (`?Tweet) --> (`?Comment)][0];
    comment spawn remove_comment();
    check len([root --> (`?Profile) --> (`?Tweet) --> (`?Comment)]) == 0;
}

test load_feed {
    profile1 = Profile("Mars");
    profile1 spawn follow_request();
    profile1 spawn create_tweet("How are working man");
    profile1 spawn create_tweet("How are u");
    profile1 spawn create_tweet("how are u doing");
    feeds = root spawn load_feed("How");
    check all(
        [ (feeds.results[i]['similarity'][0] >= feeds.results[i + 1]['similarity'][0]) for i in range(len(feeds.results) - 1) ]
    );
}

test test_load_user_profiles {
    load_user_walker = root spawn load_user_profiles();
    check load_user_walker.profiles;
}
```

#### `littleX/littleX_single.jac`

**File Info:**
- Lines: 236
- Non-empty lines: 168
- Features: Classes, Functions, Nodes, Edges, Walkers, Imports

**Code:**
```jac
import datetime;
import numpy;
import from sklearn.feature_extraction.text { TfidfVectorizer }
import from sklearn.metrics.pairwise { cosine_similarity }


glob vectorizer = TfidfVectorizer();


def search_tweets(query: str, tweet: str) -> int {
    transformed = vectorizer.fit_transform([query, tweet]);
    similarity = cosine_similarity(transformed[0], transformed[1])[0];
    return similarity;
}


node Profile {
    has username: str = "";

    can update with update_profile entry {
        self.username = visitor.new_username;
        report self;
    }

    can get with get_profile entry {
        follwers = [{"id": jid(i), "username": i.username} for i in [self-->(`?Profile)]];
        report {"user": self, "followers": follwers};
    }

    can follow with follow_request entry {
        current_profile = [root-->(`?Profile)];
        current_profile[0] +>:Follow():+> self;
        report self ;
    }

    can un_follow with un_follow_request entry {
        current_profile = [root-->(`?Profile) ];
        follow_edge = [edge current_profile[0]->:Follow:->self];
        del follow_edge[0] ;
        report self ;
    }
}


obj TweetInfo {
    has username: str;
    has id: str;
    has content: str;
    has embedding: list;
    has likes: list;
    has comments: list;
}


node Tweet {
    has content: str;
    has embedding: list;
    has created_at: str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S");

    can update with update_tweet exit {
        self.content = visitor.updated_content;
        report self ;
    }

    can delete with remove_tweet exit {
        del self ;
        disengage;
    }

    can like_tweet with like_tweet entry {
        current_profile = [root-->(`?Profile)];
        self +>: Like() :+> current_profile[0];
        report self ;
    }

    can remove_like with remove_like entry {
        current_profile = [root-->(`?Profile)];
        like_edge = [edge self->:Like :->current_profile[0]];
        del like_edge[0] ;
        report self ;
    }

    can comment with comment_tweet entry {
        current_profile = [root-->( ` ? Profile ) ];
        comment_node =
            current_profile[0] +>:Post():+> Comment(content=visitor.content);
        grant(comment_node[0], level=ConnectPerm);
        self ++> comment_node[0];
        report comment_node[0] ;
    }

    def get_info() -> TweetInfo {
        return TweetInfo(
            username=[self<-:Post:<-][0].username, id=jid(self), content=self.content, embedding=self.embedding, likes=[ i.username for i in [self->:Like:->]], comments=[
            {"username" : [i<--(`?Profile)][0].username, "id": jid(i) , "content" : i.content} for i in [self-->(`?Comment)]]
        );
    }

    can get with load_feed entry {
        tweet_info = self.get_info();
        similarity = search_tweets(visitor.search_query, tweet_info.content);
        visitor.results.append(
            {"Tweet_Info" : tweet_info , "similarity" : similarity }
        );
    }
}


node Comment {
    has content: str;

    can update with update_comment entry {
        self.content = visitor.updated_content;
        report self ;
    }

    can delete with remove_comment entry {
        del self ;
        disengage;
    }
}


edge Follow {}


edge Like {}


edge Post {}


walker visit_profile {
    can visit_profile with `root entry {
        visit [-->(`?Profile)] else {
            new_profile = here ++> Profile();
            grant(new_profile[0], level=ConnectPerm);
            visit new_profile;
        }
    }
}


walker update_profile(visit_profile) {
    has new_username: str;
}


walker get_profile(visit_profile) {}


walker load_user_profiles {
    obj __specs__ {
        static has auth: bool = False;
    }

    can load_profiles with `root entry {
        self.profiles: list = [];
        
        for each_root in allroots() {
            profile = [each_root --> (`?Profile)][0];
            self.profiles.append(
                {"name": profile.username, "id": jid(profile)}
            );
        }
    }

    can report_profiles with exit {
        report self.profiles ;
    }
}


walker follow_request {}


walker un_follow_request {}


walker create_tweet ( visit_profile ) {
    has content: str;

    can tweet with Profile entry {
        embedding = vectorizer.fit_transform([self.content]).toarray().tolist();
        tweet_node =
            here +>: Post() :+> Tweet(content=self.content, embedding=embedding);
        grant(tweet_node[0], level=ConnectPerm);
        report tweet_node ;
    }
}


walker update_tweet {
    has updated_content: str;
}


walker remove_tweet {}


walker like_tweet {}


walker remove_like {}


walker comment_tweet {
    has content: str;
}


walker update_comment {
    has updated_content: str;
}


walker remove_comment {}


walker load_feed ( visit_profile ) {
    has search_query: str = "";
    has results: list = [];

    can load with Profile entry {
        visit [-->(`?Tweet)];
        for user_node in [->:Follow:->(`?Profile)] {
            visit [user_node-->(`?Tweet)];
        }
    }

    can report_feed with exit {
        self.results.sort(key=lambda  x: dict: x['similarity'][0], reverse=True);
        report self.results ;
    }
}

```

## Manual_Code

**JAC Files:**

#### `manual_code/circle.jac`

**Description:** This module demonstrates a simple circle class and a function to calculate
the area of a circle in all of Jac's glory.

**File Info:**
- Lines: 78
- Non-empty lines: 63
- Features: Classes, Functions, Imports

**Code:**
```jac
\"\"\"
This module demonstrates a simple circle class and a function to calculate
the area of a circle in all of Jac's glory.
\"\"\"

import math;
# Module-level global var

glob RAD = 5;

\"\"\"Function to calculate the area of a circle.\"\"\"
def calculate_area(radius: float) -> float {
    return math.pi * radius * radius;
}
#* (This is multiline comments in Jac)
Above we have the demonstration of a function to calculate the area of a circle.
Below we have the demonstration of a class to calculate the area of a circle.
*#

\"\"\"Enum for shape types\"\"\"
enum ShapeType {
    CIRCLE = "Circle",
    UNKNOWN = "Unknown"
}

\"\"\"Base class for a shape.\"\"\"
obj Shape {
    has shape_type: ShapeType;

    \"\"\"Abstract method to calculate the area of a shape.\"\"\"
    def area -> float abs;
}

\"\"\"Circle class inherits from Shape.\"\"\"
obj Circle(Shape) {
    def init(radius: float) {
        super.init(ShapeType.CIRCLE);
        self.radius = radius;
    }

    \"\"\"Overridden method to calculate the area of the circle.\"\"\"
    override def area -> float {
        return math.pi * self.radius * self.radius;
    }
}

with entry {
    c = Circle(RAD);
}
# Global also works here

with entry:__main__ {
    # To run the program functionality
    print(
        f"Area of a circle with radius {RAD} using function: {calculate_area(RAD)}"
    );
    print(
        f"Area of a {c.shape_type.value} with radius {RAD} using class: {c.area()}"
    );
}
# Unit Tests!

glob expected_area = 78.53981633974483;

test calc_area {
    check almostEqual(calculate_area(RAD), expected_area);
}

test circle_area {
    c = Circle(RAD);
    check almostEqual(c.area(), expected_area);
}

test circle_type {
    c = Circle(RAD);
    check c.shape_type == ShapeType.CIRCLE;
}

```

#### `manual_code/circle_clean.impl.jac`

**Description:** Enum for shape types

**File Info:**
- Lines: 31
- Non-empty lines: 24
- Features: Imports

**Code:**
```jac
\"\"\"Enum for shape types\"\"\"

import math;

impl ShapeType {
    CIRCLE="Circle",
    UNKNOWN="Unknown"
}

\"\"\"Function to calculate the area of a circle.\"\"\"
impl calculate_area
(radius: float) -> float {
    return math.pi * radius * radius;
}

impl Circle.init
(radius: float) {
    self.radius = radius;
    super.init(ShapeType.CIRCLE);
}

\"\"\"Overridden method to calculate the area of the circle.\"\"\"
impl Circle.area -> float {
    return math.pi * self.radius * self.radius;
}

impl main_run {
    print(f"Area of a circle with radius {RAD} using function: {calculate_area(RAD)}");
    print(f"Area of a {c.shape_type.value} with radius {RAD} using class: {c.area()}");
}

```

#### `manual_code/circle_clean.jac`

**Description:** This module demonstrates a simple circle class and a function to calculate
the area of a circle in all of Jac's glory.

**File Info:**
- Lines: 33
- Non-empty lines: 24
- Features: Classes, Functions

**Code:**
```jac
\"\"\"
This module demonstrates a simple circle class and a function to calculate
the area of a circle in all of Jac's glory.
\"\"\"

enum ShapeType;

def calculate_area(radius: float) -> float;
def main_run;

\"\"\"Base class for a shape.\"\"\"
obj Shape {
    has shape_type: ShapeType;

    def area -> float abs;
}

\"\"\"Circle class inherits from Shape.\"\"\"
obj Circle(Shape) {
    has radius: float;

    def init(radius: float);
    override def area -> float;
}
# Radius of the demo circle

glob RAD = 5, c = Circle(radius=RAD);

\"\"\"Here we run the main program.\"\"\"
with entry:__main__ {
    main_run();
}

```

#### `manual_code/circle_clean_tests.jac`

**File Info:**
- Lines: 18
- Non-empty lines: 13
- Features: Imports

**Code:**
```jac
import circle_clean;

glob expected_area = 78.53981633974483;

test {
    check almostEqual(calculate_area(RAD), expected_area);
}

test {
    c = Circle(RAD);
    check almostEqual(c.area(), expected_area);
}

test {
    c = Circle(RAD);
    check c.shape_type == ShapeType.CIRCLE;
}

```

#### `manual_code/circle_pure.impl.jac`

**Description:** Enum for shape types

**File Info:**
- Lines: 33
- Non-empty lines: 27

**Code:**
```jac
\"\"\"Enum for shape types\"\"\"

impl ShapeType {
    CIRCLE = "Circle",
    UNKNOWN = "Unknown"
}

\"\"\"Function to calculate the area of a circle.\"\"\"
impl calculate_area
(radius: float) -> float {
    return math.pi * radius * radius;
}

impl Circle.init
(radius: float) {
    self.radius = radius;
    super.init(ShapeType.CIRCLE);
}

\"\"\"Overridden method to calculate the area of the circle.\"\"\"
impl Circle.area -> float {
    return math.pi * self.radius * self.radius;
}

impl main_run {
    print(
        f"Area of a circle with radius {RAD} using function: {calculate_area(RAD)}"
    );
    print(
        f"Area of a {c.shape_type.value} with radius {RAD} using class: {c.area()}"
    );
}

```

#### `manual_code/circle_pure.jac`

**Description:** This module demonstrates a simple circle class and a function to calculate
the area of a circle in all of Jac's glory.

**File Info:**
- Lines: 35
- Non-empty lines: 25
- Features: Classes, Functions, Imports

**Code:**
```jac
\"\"\"
This module demonstrates a simple circle class and a function to calculate
the area of a circle in all of Jac's glory.
\"\"\"

import math;

enum ShapeType;

def calculate_area(radius: float) -> float;
def main_run;

\"\"\"Base class for a shape.\"\"\"
obj Shape {
    has shape_type: ShapeType;

    def area -> float abs;
}

\"\"\"Circle class inherits from Shape.\"\"\"
obj Circle(Shape) {
    has radius: float;

    def init(radius: float);
    override def area -> float;
}
# Radius of the demo circle

glob RAD = 5, c = Circle(radius=RAD);

\"\"\"Here we run the main program.\"\"\"
with entry:__main__ {
    main_run();
}

```

#### `manual_code/circle_pure.test.jac`

**File Info:**
- Lines: 16
- Non-empty lines: 12

**Code:**
```jac
glob expected_area = 78.53981633974483;

test a1 {
    check almostEqual(calculate_area(RAD), expected_area);
}

test a2 {
    c = Circle(RAD);
    check almostEqual(c.area(), expected_area);
}

test a3 {
    c = Circle(RAD);
    check c.shape_type == ShapeType.CIRCLE;
}

```

**Python Files:**

- `manual_code/circle.py`

## Medical

**Description files:**
- `medical/medical.md`

**JAC Files:**

#### `medical/doctor.jac`

**File Info:**
- Lines: 112
- Non-empty lines: 85
- Features: Functions, Nodes, Edges, Walkers

**Code:**
```jac
node Person{
    has name: str;
}

edge has_role{}

node Doctor{
    has specialty: str;
    has receivables: int = 0;
}

node Patient{
    has balance: int = 0;
}

edge is_treating{}
edge treated_by{}

node Insurance{
    has name: str;
    has fraction: float = 0.8;
}

edge in_network_with{}
edge has_insurance{}

node Claim{
    has cost: int;
    has status: str = "Processing";
    has insurance_pays: int = 0;
}

edge files_claim{}
edge is_processed_by{}

def is_connected(start: node, connection: edge, end: node) -> bool{
    if end is None{
        return len([start->:connection:->]) > 0;
    }

    return len([start->:connection:->end]) > 0;
}

walker ClaimProcessing{
    has claim: Claim;
    has fraction: float = 0; #Example: we pay 80% of the claim cost
    has insurance_pays: int = 0;


    can update_doctor with Doctor entry {
        here.receivables += self.insurance_pays;
    }

    can update_patient with Patient entry{
        here.balance += self.claim.cost - self.insurance_pays;
    }

    can update_person with Person entry {
        visit [here ->:has_role:->];
        visit [here --> (`?Person) ->:has_role:->];
    }

    can traverse with Claim entry { 
        patient = [here <-:files_claim:<-][0];
        insurance = [patient ->:has_insurance:->];
        doctor = [patient->:treated_by:->][0];

        if len(insurance) > 0 {
            if is_connected(doctor, in_network_with, insurance[0]){
                self.fraction = insurance[0].fraction;
                here.status = "Approved";
            }   
        }

        self.insurance_pays = int(self.claim.cost * self.fraction);
        here.insurance_pays = self.insurance_pays;
        visit [here <-:files_claim:<-];
    }

}

walker PrintClaim{
    can traverse with Claim entry {
        print("Claim status: ", here.status);
        print("Insurance pays: ", here.insurance_pays);
        print("Claim cost: ", here.cost);
        print("You Pay: ", here.cost - here.insurance_pays);
    }
}


with entry{
    blue_cross = Insurance(" Blue Cross Health Insurance");

    dr_house = Person("Gregory House");
    dr_house +>:has_role:+> Doctor(specialty = "Internal Medicine");
    dr_house +>:in_network_with:+> blue_cross;

    john_smith = Person("John Smith");
    john_smith +>:has_role:+> Patient();
    john_smith +>:has_insurance:+> blue_cross;

    dr_house +>:is_treating:+> john_smith;
    john_smith +>:treated_by:+> dr_house;

    claim = Claim(cost = 2500);
    john_smith +>:files_claim:+> claim;
    claim +>:is_processed_by:+> blue_cross;

    ClaimProcessing(claim) spawn claim;
    PrintClaim() spawn claim;
}
```

**Python Files:**

- `medical/doctor.py`

## Micro

**JAC Files:**

#### `micro/access_info.jac`

**Description:** No more `_` and `__` for access/visibility directives.

**File Info:**
- Lines: 14
- Non-empty lines: 10
- Features: Classes, Functions

**Code:**
```jac
\"\"\"No more `_` and `__` for access/visibility directives.\"\"\"

obj MyObj {
    has : protect a: int;

    def : priv init(a: int) -> None {
        self.a = a;
    }

    def : pub set_a(val: int) -> None {
        self.a = val;
    }
}

```

#### `micro/basic_class.jac`

**Description:** Basic class implementation and spawning example.

**File Info:**
- Lines: 22
- Non-empty lines: 16
- Features: Classes, Functions

**Code:**
```jac
\"\"\"Basic class implementation and spawning example.\"\"\"

obj Person {
    has : protect age: int; # no need ot use `_age`
    has : pub name: str;

    def : priv init(name: str, age: int) -> None {
        self.name = name;
        self.age = age;
    }

    def : pub greet() -> None { # public is default if `pub` is not specified

    print("Hello, my name is ", self.name, " and I'm ", self.age, " years old.");
    }
}

with entry {
    my_guy = Person("John", 42);
    my_guy.greet();
}

```

#### `micro/basic_class_pylike.jac`

**Description:** A bit more chill approach.

**File Info:**
- Lines: 20
- Non-empty lines: 15
- Features: Classes, Functions

**Code:**
```jac
\"\"\"A bit more chill approach.\"\"\"

obj rson {
    has age: int,
        name: str;

    def init(name: str, age: int) -> None {
        self.name = name;
        self.age = age;
    }

    def greet() -> None {
        print("Hello, my name is ", self.name, " and I'm ", self.age, " years old.");
    }
}

with entry {
    Person("John", 42).greet();
}

```

#### `micro/bunch_of_statements.jac`

**Description:** A mega example of a bunch of statements and expressions.

**File Info:**
- Lines: 64
- Non-empty lines: 56
- Features: Functions

**Code:**
```jac
\"\"\"A mega example of a bunch of statements and expressions.\"\"\"


\"\"\"
This function takes a list of numbers and returns a
generator of even numbers.
\"\"\"
def example_function(numbers: list[int]) -> int {

    # multi string
    print("this function processes the provided list."
          "It then yields the even numbers."
          "It will stop once an even number greater than 20 is found.");

    # assignments and expressions
    counter = 0;
    even_numbers = [];

    # for loop and comprehension
    for number in [i+1 for i in numbers] {
        # walrus operation (assignment expressions, appears Python 3.8 and later, and Jac!)
        # if (result := number % 2) == 0 {  # Python compaitble version
        result = 100;
        result %= 2;
        if result == 0 { # Jac improved version
            even_numbers.append(number);
            counter += 1;
            # assert
            assert counter <= len(numbers), "Counter should not exceed the length of the list";
            # yield
            yield f"Even number {counter}: {number}";  # f-string
            # if-elif-else
            if number > 20 {
                print("Encountered even number greater than 20, breaking loop");
                break;  # break
            }
            elif number == 20 {
                print("Encountered 20, skipping this number");
                continue;  # continue
            }
        }
        else {
            print(f"{number} is not an even number");
        }
    }

    # while loop
    while len(even_numbers) > 0 {
        # delete
        del even_numbers[0];
    }

    print("All done!");
}

# testing the function
with entry {
    # iteration for loop
    for i=1 to i < 5 by i+=1 {
        for result in example_function([1, 2, 3, 4, 5, 21, 22, 23, 24]) {
            print(result);
        }
    }
}
```

#### `micro/class_inherit.jac`

**Description:** Super simple example of inheritance.

**File Info:**
- Lines: 19
- Non-empty lines: 15
- Features: Classes, Functions

**Code:**
```jac
\"\"\"Super simple example of inheritance.\"\"\"

obj Parent {
    def init {
    # Parent initialization
    }

    def speak() -> None {
    # Parent speaking
    }
}

obj Child(Parent) {
    def init {
    # Child initialization
    Parent.init(); # Initialize parent, :o: is alias for :obj
    }
}

```

#### `micro/class_multi_inherit.jac`

**Description:** Example of multiple inheritance.

**File Info:**
- Lines: 40
- Non-empty lines: 32
- Features: Classes, Functions

**Code:**
```jac
\"\"\"Example of multiple inheritance.\"\"\"

obj Parent {
    def init {
    # Parent initialization
    }
    def speak() -> None abs;# Abstract method
}

obj Mom(Parent) {
    def init {
    # Mom initialization
    Parent.init();
    }

    def speak() -> None {
        print("I'm good at swimming!");
    }
}

obj Dad(Parent) {
    def init {
    # Dad initialization
    Parent.init();
    }

    def speak() -> None {
        print("I'm good at running!");
    }
}

obj Child(Mom, Dad) { #Child inherits from Mom and Dad

def speak() -> None {
# Child initialization
Mom.speak();
Dad.speak();
}
}

```

#### `micro/decl_defs.jac`

**Description:** Separating Defs and Decls in a single File

**File Info:**
- Lines: 42
- Non-empty lines: 35
- Features: Classes, Functions

**Code:**
```jac
\"\"\"Separating Defs and Decls in a single File\"\"\"

# Declaration
def my_print(messag: str) -> str;

# Definition
impl my_print
(message: str) -> str {
    output = f"from me: {message}";
    print("from me: {message}");
    return output;
}

# Declaration
obj MyPrinter {
    def my_print(messag: str) -> str; # method declaration
}

# Definition
impl MyPrinter.my_print
(message: str) -> str {
    output = f"from me: {message}";
    print("from me: {message}");
    return output;
}

# Decl/Def Combined
def your_print(messag: str) -> str {
    output = f"from me: {message}";
    print("from me: {message}");
    return output;
}

# Decl/Def Combined
obj YourPrinter {
    def your_print(messag: str) -> str {
        output = f"from me: {message}";
        print("from me: {message}");
        return output;
    }
}

```

#### `micro/decl_defs_main.impl.jac`

**Description:** Definitions of the walker and abilities.

**File Info:**
- Lines: 10
- Non-empty lines: 8
- Features: Walkers

**Code:**
```jac
\"\"\"Definitions of the walker and abilities.\"\"\"

impl travelor.say_hello {
    "Hello" |> print;  # |> is a pipe forward operator
}

# :w: and :c: are aliases for :walker: and :abilitiy:
impl travelor.say_whatever(msg: str) -> None {
    msg |> print;
}
```

#### `micro/decl_defs_main.jac`

**Description:** Example for separation between declaration and definition.

A object-spatial object is shown in this example, however it applies
to all types of object classes.

**File Info:**
- Lines: 17
- Non-empty lines: 14
- Features: Functions, Walkers, Abilities

**Code:**
```jac
\"\"\"Example for separation between declaration and definition.

A object-spatial object is shown in this example, however it applies
to all types of object classes.
\"\"\"

walker travelor {
    can say_hello with entry;
    # object spatial ability declared
     def say_whatever(msg: str) -> None;
    # traditional method declared
     # inline ability definition (python only supports this)
     def say_goodbye {
        "Goodbye" |> print;
    }
}

```

#### `micro/empty.jac`

**File Info:**
- Lines: 1
- Non-empty lines: 0

**Code:**
```jac

```

#### `micro/exceptions.jac`

**Description:** Exception example in Jac.

**File Info:**
- Lines: 28
- Non-empty lines: 26
- Features: Functions

**Code:**
```jac
\"\"\"Exception example in Jac.\"\"\"

def divide_numbers(a: float, b: float) -> float {
    try {
        result = a / b;
    }
    except ZeroDivisionError as e {
        print("Error: Cannot divide by zero!", e);
        result = None;
        raise;  # Re-raise the exception
    }
    finally {
        print("Division operation completed.");
    }
    return result;
}

with entry {
    try {
        numerator = int(input("Enter the numerator: "));
        denominator = int(input("Enter the denominator: "));
        result = divide_numbers(numerator, denominator);
        print("Result:", result);
    }
    except ValueError {
        print("Error: Invalid input! Please entry valid integers.");
    }
}
```

#### `micro/free_code.jac`

**Description:** Organized free coding at module level.

**File Info:**
- Lines: 47
- Non-empty lines: 39
- Features: Classes, Functions

**Code:**
```jac
\"\"\"Organized free coding at module level.\"\"\"

obj Obj1 {
    has var: int;

    def init {
        self.var = 1;
    }
}
# with entry {  # allowed but discouraged
#    o1 = spawn Obj1; o1::init;
# }

obj Obj2 {
    has var: int;

    def init {
        self.var = 2;
    }
}
# with entry {  # allowed but discouraged
#     o2 = spawn Obj2; o2::init;
# }

obj Obj3 {
    has var: int;

    def init {
        self.var = 3;
    }
}
# with entry {  # allowed but discouraged
#     o3 = spawn Obj1; o3::init;
# }

with entry {
    o1 = spawn Obj1;
    |> o1.init;
    o2 = spawn Obj2;
    |> o2.init;
    o3 = spawn Obj3;
    |> o3.init;
    print(o1.var);
    print(o2.var);
    print(o3.var);
}

```

#### `micro/func.jac`

**Description:** Functions in Jac.

**File Info:**
- Lines: 13
- Non-empty lines: 11
- Features: Functions

**Code:**
```jac
\"\"\"Functions in Jac.\"\"\"

def factorial(n: int) -> str {
    if n == 0 { return 1; }
    else { return n * factorial(n-1); }
}

def factorial_recount(n: int) -> int {
    count = 0;
    count += 1; count |> print;
    if n == 0 { return 1; }
    else { return n * factorial(n-1); }
}
```

#### `micro/globals.jac`

**Description:** Globals are explicitly defined.

**File Info:**
- Lines: 14
- Non-empty lines: 12
- Features: Functions

**Code:**
```jac
\"\"\"Globals are explicitly defined.\"\"\"

glob age = 25, temperature = 98.6, name = "John Doe";
glob fruits = ["apple", "banana", "orange"];
glob person = {"name": "Alice", "age": 30, "city": "New York"};

def print_globs() -> None {
    global fruits,age;
    age = 30;
    fruits = ["pear", "grape", "kiwi"];
    print(age, temperature, name);  # global <name> references global vs local
    fruits |> print;
    person |> print;
}
```

#### `micro/hodge_podge.jac`

**File Info:**
- Lines: 4
- Non-empty lines: 4

**Code:**
```jac
with entry {
    a=4+5;
    print(f"Hello, World! {a}");
}
```

#### `micro/imports.jac`

**Description:** You can import python modules freely.

**File Info:**
- Lines: 23
- Non-empty lines: 18
- Features: Imports

**Code:**
```jac
\"\"\"You can import python modules freely.\"\"\"

import random;
import from math { sqrt as square_root }  # list of as clauses comes at end
import datetime as dt;
import defs.mod_defs;  # includes are useful when brigning definitions into scope
import from defs.main_defs { jactastic }

with entry {  # code that executes on module load or script run
    random_number = random.randint(1, 10);
    print("Random number:", random_number);
    # or, f"Random Number: {random_number}" |> print;

    s_root = square_root(16);
    print("Square root:", s_root);
    # or, f"Square root: {s_root}" |> print;

    current_time = dt.datetime.now();
    print("Current time:", current_time);
    # or, f"Current time: {current_time}" |> print;

    jactastic.Jactastic() |> print;
}
```

#### `micro/jac_cli.jac`

**Description:** This is the implementation of the command line interface tool for the
Jac languages. It's built with the Jac language V2 via bootstraping and
represents the first such production Jac program.

**File Info:**
- Lines: 122
- Non-empty lines: 106
- Features: Classes, Functions, Imports

**Code:**
```jac
\"\"\"
This is the implementation of the command line interface tool for the
Jac languages. It's built with the Jac language V2 via bootstraping and
represents the first such production Jac program.
\"\"\"

import inspect;
import from argparse { ArgumentParser, ArgumentError }
import cmd;
import from typing { Any, Callable }

obj Interface {
    has functions: list[callable] = [];

    def register(func: callable) -> callable;
    def create_parser -> ArgumentParser;
    def run_from_cli;
    def run_shell;
}

obj ShellCmd(cmd.Cmd) {
    has reg: Interface,
        prompt: str = "> ";

    def init(registry: Interface, *args: list, **kwargs: dict);
    def default(line: str);
    def do_quit(arg: str) -> bool;
}

with entry {
    interface = Interface();
    @interface.register
    def function_one(a: int, b: str, c: bool=False) {
        print(f"Function One -> a: {a}, b: {b}, c: {c}");
    }

    @interface.register
    def function_two(x: float, y: float) {
        print(f"Function Two -> x: {x}, y: {y}");
    }

    @interface.register
    def function_three(name: str, age: int, country: str='Unknown') {
        print(f"Function Three -> name: {name}, age: {age}, country: {country}");
    }
    # Run CLI or Shell mode
    # interface.run_from_cli()
    interface.run_shell();
}
#***Implementation***#

impl Interface.register
(func: callable) -> callable {
    self.functions.append(func);
    return func;
}

impl Interface.create_parser -> ArgumentParser {
    parser = ArgumentParser();
    parser.add_argument("base", choices=[f.__name__  for f in functions], help="The function to run");
    for func in self.functions {
        sig = inspect.signature(func);
        for (name, param) in sig.parameters.items() {
            kwargs = {};
            if param.default == inspect.Parameter.empty {
                kwargs = {'required':True };
            } else {
                kwargs = {'default':param.default };
            }
            parser.add_argument(f"--{func.__name__}.{name}", **kwargs);
        }
    }
    return parser;
}

impl Interface.run_from_cli {
    parser = self.create_parser();
    args = parser.parse_args();
    for f in self.functions {
        if f.__name__ == args.base {
            func = f;
            break;
        }
    }
    func_args = {k.split('.')[1]:v  for (k, v) in vars(args).items() if k.startswith(func.__name__)};
    func(**func_args);
}

impl Interface.run_shell {
    ShellCmd(self).cmdloop();
}

impl ShellCmd.init
(registry: Interface, *args: list, **kwargs: dict) {
    self.cmd.Cmd.__init__(*args, **kwargs);
    self.reg = registry;
}

impl ShellCmd.default
(line: str) {
    args = line.split();
    parser = self.reg.create_parser();
    try  {
        parsed_args = parser.parse_args(args);
        for f in self.reg.functions {
            if f.__name__ == parsed_args.base {
                func = f;
                break;
            }
        }
        func_args = {k.split('.')[1]:v  for (k, v) in vars(parsed_args).items() if k.startswith(func.__name__)};
        func(**func_args);
    } except ArgumentError as e  {
        print(f"Error: {str(e)}");
    }
}

impl ShellCmd.do_quit
(arg: str) -> bool {
    return True;
}

```

#### `micro/match.jac`

**File Info:**
- Lines: 50
- Non-empty lines: 39
- Features: Classes, Functions

**Code:**
```jac
obj Outer {
    obj Inner {
        obj Point {
            has x: float, y: float;
        }
    }
}

def match_example(data: dict) {

    match data {
        # MatchValue
        case 42:
            print("Matched the value 42.");

        # MatchSingleton
        case True:
            print("Matched the singleton True.");
        case None:
            print("Matched the singleton None.");

        # MatchSequence
        case [1, 2, 3]:
            print("Matched a specific sequence [1, 2, 3].");

        # MatchStar
        case [1, *rest, 3]:
            print(f"Matched a sequence starting with 1 and ending with 3. Middle: {rest}");

        # MatchMapping
        case {"key1": 1, "key2": 2, **rest}:
            print(f"Matched a mapping with key1 and key2. Rest: {rest}");

        # MatchClass
        case Outer.Inner.Point(int(a), y=0):
            print(f"Point with x={a} and y=0");

        # MatchAs
        case [1, 2, rest_val as value]:
            print(f"Matched a sequence and captured the last value: {value}");

        # MatchOr
        case [1, 2] | [3, 4]:
            print("Matched either the sequence [1, 2] or [3, 4].");

        case _:
            print("No match found.");
    }
}

```

#### `micro/module_structure.jac`

**Description:** A Docstring
Is required at the head of every
module

**File Info:**
- Lines: 51
- Non-empty lines: 38
- Features: Classes, Functions, Nodes, Edges, Walkers, Imports

**Code:**
```jac
\"\"\"
A Docstring
Is required at the head of every
module
\"\"\"

# This is a single line comment

#* This is
A Multiline
Comment *#

glob ver = "0.0.1";  # global variable

import defs.utils;  # import a module
import os; # import a python module
import defs.mod_defs;  # includes a file

obj mytype {}  # define a new type

node mynode(this,that) {}  # define a new node

edge parent {}  # define a new edge

\"\"\"
Doc strings can only appear before
a declaration of an element,
and should target users, Use comments otherwise
\"\"\"
walker travelor {  # define a new walker
    def say_hello;
}

#* Declarations and definitions
can be separate in Jac *#
impl travelor.say_hello {
    "Hello" |> print;  # |> is a pipe forward operator
}

def myablty -> int {} # define a data spacial freestyle ability

def myfunc() -> None {} # define a function

with entry {
    # module level freestyle code
}

\"\"\"A test of my functionality\"\"\"
test mytest {
   # test code here
}
```

#### `micro/no_here.jac`

**Description:** Not focusing on the self is cleaner.

**File Info:**
- Lines: 14
- Non-empty lines: 10
- Features: Classes, Functions

**Code:**
```jac
\"\"\"Not focusing on the self is cleaner.\"\"\"

obj MyObj {
    has a: int;

    def init(a: int) -> None {
        self.a = a;
    }

    def set_a(val: int) -> None {
        self.a = val;
    }
}

```

#### `micro/semi_only.jac`

**File Info:**
- Lines: 7
- Non-empty lines: 6
- Features: Functions

**Code:**
```jac
def do_nothing () {
    ;
}

with entry {
    do_nothing();
}
```

#### `micro/separate_defs.jac`

**Description:** Modified for separate defs/decls.

**File Info:**
- Lines: 17
- Non-empty lines: 12
- Features: Classes, Functions

**Code:**
```jac
\"\"\"Modified for separate defs/decls.\"\"\"

obj MyObj {
    has : protect a: int;

    def : priv init(a: int) -> None;
    def : pub set_a(val: int) -> None;
}

impl MyObj.init {
    self.a = a;
}

impl MyObj.set_a {
    self.a = val;
}

```

#### `micro/simple_walk.jac`

**Description:** Example of simple walker walking nodes.

**File Info:**
- Lines: 53
- Non-empty lines: 38
- Features: Functions, Nodes, Edges, Walkers

**Code:**
```jac
\"\"\"Example of simple walker walking nodes.\"\"\"

node Item {
    has value: int = 1;
}


edge Checking {}


walker Creator {
    has count: int = 0;
    
    can create with `root | Item entry {
        here ++> Item();
        self.count += 1;
        if self.count < 10 {
            visit [-->];
        }
    }
}


walker Walk {
    has count: int = 0;
    
    can skip_root with `root entry {
        visit [-->];
    }
    
    can step with Item entry {
        here.value = self.count;
        self.count += 1;
        visit [-->] else {
            print(f'Final Value: {here.value - 1}');
            "Done walking." |> print;
            disengage;
        }
        f"Value: {here.value - 1}" |> print;
    }
}


def test_run {
    root spawn Creator();
    Walk() spawn root;
}


with entry : __main__ {
    test_run();
}

```

#### `micro/simple_walk_by_edge.jac`

**Description:** Example of simple walker walking nodes.

**File Info:**
- Lines: 24
- Non-empty lines: 17
- Features: Nodes, Edges, Walkers

**Code:**
```jac
\"\"\"Example of simple walker walking nodes.\"\"\"

node A {}

walker Walk {
    has id: int = 0;

    can skip_root with `root entry {
        visit [-->];
    }

    can step with A entry {
        print(f'Visited {self.id}');
    }
}

with entry {
    root ++> (a:=A());
    ae = [edge root-->a][0];

    Walk(id = 1) spawn ae;
    ae spawn Walk(id=2);
}

```

#### `micro/type_hints.jac`

**Description:** Type hints aren't that much work.

**File Info:**
- Lines: 20
- Non-empty lines: 14
- Features: Classes, Functions

**Code:**
```jac
\"\"\"Type hints aren't that much work.\"\"\"

def foo(a: int, b: str) -> int { # type hint needed here

c = a + (b |> int);# no type hint needed here
return c;
}

obj Bar {
    has a_list: list[int] = [1, 2, 3]; # type hint needed here
    has b_list: list[str] = ["5", "6", "7"];

    def init() -> None {

        for i in self.b_list {
            foo(5, i) |> print;
        }
    }
}

```

#### `micro/type_info.jac`

**File Info:**
- Lines: 20
- Non-empty lines: 16
- Features: Classes, Functions, Imports

**Code:**
```jac
import pygame;

obj Spritesheet {
    def init(file: str);
    def get_sprite(x: int, y: int, width: int, height: int) -> pygame.Surface;
}

impl Spritesheet.init
(file: str) {
    self.sheet = pygame.image.load(file).convert();
}

impl Spritesheet.get_sprite
(x: int, y: int, width: int, height: int) {
    sprite = pygame.Surface([width, height]);
    sprite.blit(self.sheet, (0, 0), (x, y, width, height));
    sprite.set_colorkey(BLACK);
    return sprite;
}

```

#### `micro/typed_filter_compr.jac`

**File Info:**
- Lines: 21
- Non-empty lines: 18
- Features: Nodes

**Code:**
```jac
node MyObj {
    has a: int;
}

node MyObj2 {
    has a: int;
}

with entry {
    my_list = [];
    for i=0 to i<10 by i+=1  {
        my_list.append(MyObj(a=i));
        my_list.append(MyObj2(a=i+2));
    }
    #[-->](`?`MyObj:a<4, b<5);
    print(my_list(?a < 4));
    print(my_list(`?MyObj:a < 4, a<3));
    my_list(=a=5);
    print(my_list);
}

```

#### `micro/whitespace.jac`

**Description:** Same functionality 3 white space styles.

**File Info:**
- Lines: 14
- Non-empty lines: 11

**Code:**
```jac
\"\"\"Same functionality 3 white space styles.\"\"\"

with entry {  # very pythonic
    a = "hello";
    b = len(a);
    print(b); }

with entry {  # a bit more Jac like
    a = "hello" |> len;
    a |> print;
}

with entry { "hello" |> len |> print; }  # more concise
with entry { print(len("hello")); }  # same, but no pipe
```

#### `micro/wierd_syntax.jac`

**Description:** No more `_` and `__` for access/visibility directives.

**File Info:**
- Lines: 11
- Non-empty lines: 10
- Features: Classes

**Code:**
```jac
\"\"\"No more `_` and `__` for access/visibility directives.\"\"\"

obj MyObj {
    has:protect a: int;
    def:priv init(a: int) -> None {
        self.a = a;
    }
    def:pub set_a(val: int) -> None {
        self.a = val;;;;;
    }
}
```

### defs

**JAC Files:**

#### `micro/defs/main_defs.jac`

**Description:** Dummy file for micro test case.

**File Info:**
- Lines: 1
- Non-empty lines: 1

**Code:**
```jac
\"\"\"Dummy file for micro test case.\"\"\"
```

#### `micro/defs/mod_defs.jac`

**Description:** Dummy file for micro test case.

**File Info:**
- Lines: 1
- Non-empty lines: 1

**Code:**
```jac
\"\"\"Dummy file for micro test case.\"\"\"
```

#### `micro/defs/random.jac`

**Description:** Dummy file for micro test case.

**File Info:**
- Lines: 1
- Non-empty lines: 1

**Code:**
```jac
\"\"\"Dummy file for micro test case.\"\"\"
```

#### `micro/defs/utils.jac`

**Description:** Dummy file for micro test case.

**File Info:**
- Lines: 1
- Non-empty lines: 1

**Code:**
```jac
\"\"\"Dummy file for micro test case.\"\"\"
```

## Myca

**JAC Files:**

#### `myca/myca.jac`

**Description:** Myca Lite to serve as example for Myca in Jaclang

**File Info:**
- Lines: 23
- Non-empty lines: 16
- Features: Functions, Nodes, Edges, Imports

**Code:**
```jac
\"\"\"Myca Lite to serve as example for Myca in Jaclang\"\"\"
import from datetime {datetime}

edge next_epoc {}
edge prev_epoc {}

node epoc {
    has date: datetime;
    def quantize {}
}

node life(epoc) { def quantize {} }
node year(epoc) { def quantize {} }
node month(epoc) { def quantize {} }
node week(epoc) { def quantize {} }
node day(epoc) { def quantize {} }



node item {
    has title: str;
}

```

## Plugins

### cmd_show

**Python Files:**

- `plugins/cmd_show/setup.py`

### cmd_show

**Python Files:**

- `plugins/cmd_show/cmd_show/__init__.py`
- `plugins/cmd_show/cmd_show/show.py`

### jaclang_walkerapi

**Python Files:**

- `plugins/jaclang_walkerapi/setup.py`

### jaclang_walkerapi

**Python Files:**

- `plugins/jaclang_walkerapi/jaclang_walkerapi/__init__.py`
- `plugins/jaclang_walkerapi/jaclang_walkerapi/walkerapi.py`

## Reference

**Description files:**
- `reference/archetype_bodies.md`
- `reference/archetypes.md`
- `reference/arithmetic_expressions.md`
- `reference/assert_statements.md`
- `reference/assignments.md`
- `reference/atom.md`
- `reference/atomic_expressions.md`
- `reference/atomic_pipe_back_expressions.md`
- `reference/base_module_structure.md`
- `reference/bitwise_expressions.md`
- `reference/builtin_types.md`
- `reference/check_statements.md`
- `reference/codeblocks_and_statements.md`
- `reference/collection_values.md`
- `reference/concurrent_expressions.md`
- `reference/connect_expressions.md`
- `reference/context_managers.md`
- `reference/control_statements.md`
- `reference/delete_statements.md`
- `reference/disengage_statements.md`
- `reference/enumerations.md`
- `reference/expressions.md`
- `reference/f_string_tokens.md`
- `reference/for_statements.md`
- `reference/free_code.md`
- `reference/function_calls.md`
- `reference/functions_and_abilities.md`
- `reference/global_and_nonlocal_statements.md`
- `reference/global_variables.md`
- `reference/if_statements.md`
- `reference/implementations.md`
- `reference/import_include_statements.md`
- `reference/inline_python.md`
- `reference/introduction.md`
- `reference/lambda_expressions.md`
- `reference/lexer_tokens.md`
- `reference/logical_and_compare_expressions.md`
- `reference/match_capture_patterns.md`
- `reference/match_class_patterns.md`
- `reference/match_literal_patterns.md`
- `reference/match_mapping_patterns.md`
- `reference/match_patterns.md`
- `reference/match_sequence_patterns.md`
- `reference/match_singleton_patterns.md`
- `reference/match_statements.md`
- `reference/names_and_references.md`
- `reference/object_spatial_calls.md`
- `reference/object_spatial_references.md`
- `reference/object_spatial_spawn_expressions.md`
- `reference/object_spatial_typed_context_blocks.md`
- `reference/object_spatial_walker_statements.md`
- `reference/pipe_back_expressions.md`
- `reference/pipe_expressions.md`
- `reference/raise_statements.md`
- `reference/references_(unused).md`
- `reference/report_statements.md`
- `reference/return_statements.md`
- `reference/semstrings.md`
- `reference/special_comprehensions.md`
- `reference/subscripted_and_dotted_expressions.md`
- `reference/tests.md`
- `reference/try_statements.md`
- `reference/tuples_and_jac_tuples.md`
- `reference/unpack_expressions.md`
- `reference/visit_statements.md`
- `reference/walrus_assignments.md`
- `reference/while_statements.md`
- `reference/yield_statements.md`

**JAC Files:**

#### `reference/archetype_bodies.jac`

**File Info:**
- Lines: 21
- Non-empty lines: 17
- Features: Classes, Functions

**Code:**
```jac
obj Car {
    has make: str,
        model: str,
        year: int;
    static has wheels: int = 4;

    def display_car_info {
        print(f"Car Info: {self.year} {self.make} {self.model}");
    }

    static def get_wheels -> int {
        return Car.wheels;
    }
}

with entry {
    car = Car("Toyota", "Camry", 2020);
    car.display_car_info();
    print("Number of wheels:", Car.get_wheels());
}

```

#### `reference/archetypes.jac`

**File Info:**
- Lines: 23
- Non-empty lines: 15
- Features: Classes, Functions, Nodes, Walkers

**Code:**
```jac
def print_base_classes(cls: type) -> type {
    print(
        f"Base classes of {cls.__name__}: {[c.__name__ for c in cls.__bases__]}"
    );
    return cls;
}

class Animal {}

obj Domesticated {}

@print_base_classes
node Pet(Animal, Domesticated) {}

walker Person(Animal) {}

walker Feeder(Person) {}

@print_base_classes
walker Zoologist(Feeder) {}

async walker MyWalker {}

```

#### `reference/arithmetic_expressions.jac`

**File Info:**
- Lines: 10
- Non-empty lines: 9

**Code:**
```jac
with entry {
    p = print;
    p("Multiply:", 7 * 2);
    p("Division:", 15 / 3);
    p("Floor:", 15 // 3);
    p("Modulo:", 17 % 5);
    p("Expon:", 2 ** 3);
    p("combo:", (9 + 2) * 9 - 2);
}

```

#### `reference/assert_statements.jac`

**File Info:**
- Lines: 12
- Non-empty lines: 10
- Features: Functions

**Code:**
```jac
def foo(value: int) {
    assert value > 0 , "Value must be positive";
}

with entry {
    try  {
        foo(-5);
    } except AssertionError as e  {
        print("Asserted:", e);
    }
}

```

#### `reference/assignments.jac`

**File Info:**
- Lines: 12
- Non-empty lines: 11

**Code:**
```jac
with entry {
    a = b=16;
    let c = 18;
    print(a, b, c);
    a >>= 2;
    print(a);
    a <<= 2;
    print(a);
    c //= 4;
    print(c);
}

```

#### `reference/atom.jac`

**File Info:**
- Lines: 21
- Non-empty lines: 16

**Code:**
```jac
impl x {
    aa=67,
    y="aaa" + f"b{aa}bbcc"
}

glob c = (3, 4, 5), list1 = [2, 3, 4, 5];

with entry {
    a = "abcde....";
    b = True;
    c = bin(12);
    d = hex(78);
    print(list1, a, b, c, d);

    # pp=0x4e;
    # print(0b1100);

    enum x;
    print(x.y.value);
}

```

#### `reference/atomic_expressions.jac`

**File Info:**
- Lines: 5
- Non-empty lines: 4

**Code:**
```jac
with entry {
    "Hello world!" :> print;
    "Welcome" :> type :> print;
}

```

#### `reference/atomic_pipe_back_expressions.jac`

**File Info:**
- Lines: 8
- Non-empty lines: 7

**Code:**
```jac
with entry {
    print <: "Hello world!";
    a = [2, 4, 5, 7, 8];
    b = [4, 8, 9, 13, 20];
    c = len <: a + b :> len;
    print(c);
}

```

#### `reference/base_module_structure.jac`

**Description:** A Docstring can be added the head of any module.

Any element in the module can also have a docstring.
If there is only one docstring before the first element,
it is assumed to be a module docstring.

**File Info:**
- Lines: 21
- Non-empty lines: 16
- Features: Functions

**Code:**
```jac
\"\"\"A Docstring can be added the head of any module.

Any element in the module can also have a docstring.
If there is only one docstring before the first element,
it is assumed to be a module docstring.
\"\"\"

\"\"\"A docstring for add function\"\"\"
def add(a: int, b: int) -> int {
    return a + b;
}
# No docstring for subtract function

def subtract(a: int, b: int) -> int {
    return a - b;
}

with entry:__main__ {
    print(add(1, subtract(3, 1)));
}

```

#### `reference/bitwise_expressions.jac`

**File Info:**
- Lines: 10
- Non-empty lines: 9

**Code:**
```jac
with entry {
    p = print;
    p("&:", 5 & 3);
    p("|:", 5 | 3);
    p("^:", 5 ^ 3);
    p("~:", ~5);
    p("<<:", 5 << 1);
    p(">>:", 5 >> 1);
}

```

#### `reference/builtin_types.jac`

**File Info:**
- Lines: 21
- Non-empty lines: 12

**Code:**
```jac
glob a = 9.2;

glob b = 44;

glob c = [2, 4, 6, 10];

glob d = {'name':'john', 'age':28 };

glob e = ("jaseci", 5, 4, 14);

glob f = True;

glob g = "Jaseci";

glob h = {5, 8, 12, "unique"};

with entry {
    print(type(a), '\\n', type(b), '\\n', type(c), '\\n', type(d), '\\n', type(e));
    print(type(f), '\\n', type(g), '\\n', type(h));
}

```

#### `reference/check_statements.jac`

**File Info:**
- Lines: 17
- Non-empty lines: 13

**Code:**
```jac
glob a = 5, b = 2;

test test1 {
    check almostEqual(a, 6);
}

test test2 {
    check a != b;
}

test test3 {
    check "d" in "abc";
}

test test4 {
    check a - b == 3;
}
```

#### `reference/codeblocks_and_statements.jac`

**File Info:**
- Lines: 8
- Non-empty lines: 7
- Features: Functions

**Code:**
```jac
with entry {
    print("Welcome to the world of Jaseci!");
    def add(x: int, y: int) -> int {
        return (x + y);
    }
    print(add(10, 89));
}

```

#### `reference/collection_values.jac`

**File Info:**
- Lines: 20
- Non-empty lines: 17

**Code:**
```jac
with entry {
    squares = {num: num ** 2  for num in range(1, 6)};
    even_squares_set = {num ** 2  for num in range(1, 11) if num % 2 == 0};
    squares_generator = (num ** 2  for num in range(1, 6));
    squares_list = [num ** 2 for num in squares_generator if num != 9];

    print(
        "\\n".join(
            [str(squares), str(even_squares_set), str(squares_list)]
        )
    );

    print(
        {"a": "b", "c": "d"}, # Dictionary
        {"a"}, # Set
        ("a", ), # Tuple
        ['a'] # List
    );
}

```

#### `reference/concurrent_expressions.jac`

**File Info:**
- Lines: 39
- Non-empty lines: 30
- Features: Functions, Nodes, Walkers, Imports

**Code:**
```jac
import from time { sleep }

node A {
    has val: int = 0;

    can do with entry {
        print("Started");
        sleep(2);
        print(visitor);

    }
}

walker B {
    has name: str;

}

def add(x: int, y: int) -> int {
    print(x);
    z = x + y;
    sleep(2);
    print(x);
    return z;
}

with entry {
    t1 = flow A() spawn B("Hi") ;

    task1 = flow add(1, 10) ;
    task2 = flow add(2, 11) ;
    print("All are started");
    res1 = wait task1 ;
    res2 = wait task2 ;
    print("All are done");
    print(res1);
    print(res2);
}

```

#### `reference/connect_expressions.jac`

**File Info:**
- Lines: 35
- Non-empty lines: 29
- Features: Nodes, Edges, Walkers

**Code:**
```jac
node node_a {
    has value: int;
}

walker Creator {
    can create with `root entry;
    can travel with `root | node_a entry;
}

edge MyEdge {
    has val: int = 5;
}

impl Creator.create {
    end = here;
    for i=0 to i<7 by i+=1  {
        if i % 2 == 0 {
            end ++> (end := node_a(value=i));
        } else {
            end +>:MyEdge:val=i:+> (end := node_a(value=i + 10));
        }
    }
}

impl Creator.travel {
    for i in [->:MyEdge:val <= 6:->] {
        print(i.value);
    }
    visit [-->];
}

with entry :__main__ {
    root spawn Creator();
}

```

#### `reference/context_managers.jac`

**File Info:**
- Lines: 6
- Non-empty lines: 5

**Code:**
```jac
with entry {
    with open(__file__, 'r') as file {
        print(file.read());
    }
}

```

#### `reference/control_statements.jac`

**File Info:**
- Lines: 16
- Non-empty lines: 15

**Code:**
```jac
with entry {
    for i in range(9) {
        if i > 2 {
            print("loop is stopped!!");
            break;
        }
        print(i);
    }
    for j in "WIN" {
        if j == "W" {
            continue;
        }
        print(j);
    }
}

```

#### `reference/delete_statements.jac`

**File Info:**
- Lines: 7
- Non-empty lines: 6

**Code:**
```jac
with entry {
    x = [2, 4, 5, 7, 9];
    print("Before Delete:", x);
    del x[3];
    print("After Delete:", x);
}

```

#### `reference/disengage_statements.jac`

**File Info:**
- Lines: 22
- Non-empty lines: 19
- Features: Nodes, Walkers

**Code:**
```jac
walker Visitor {
    can travel with `root entry {
        visit [-->] else {
            visit root;
        }
    }
}

node item {
    can speak with Visitor entry {
        print("Hey There!!!");
        disengage;
    }
}

with entry {
    for i=0 to i<5 by i+=1  {
        root ++> item();
    }
    root spawn Visitor();
}

```

#### `reference/enumerations.jac`

**File Info:**
- Lines: 26
- Non-empty lines: 20
- Features: Functions, Imports

**Code:**
```jac
import from enum { unique }

@unique
enum Color;

impl Color {
    RED = 1,
    GREEN = 2
}

enum :protect Role {
    ADMIN = 'admin',
    USER = 'user'

    with entry {
        print('Initializing role system..');
        def foo -> str {
            return 'Accessing privileged Data';
        }
    }

}
with entry {
    print(Color.RED.value, Role.foo());
}

```

#### `reference/expressions.jac`

**File Info:**
- Lines: 5
- Non-empty lines: 4

**Code:**
```jac
with entry {
    x = 1 if 5 / 2 == 1 else 2;
    print(x);
}

```

#### `reference/f_string_tokens.jac`

**File Info:**
- Lines: 14
- Non-empty lines: 13

**Code:**
```jac
with entry {
    x = "a";
    y = 25;
    print(f"Hello {x} {y} {{This is an escaped curly brace}}");
    person = {"name":"Jane", "age":25 };
    print(f"Hello, {person['name']}! You're {person['age']} years old.");
    print("This is the first line.\\n This is the second line.");
    print("This will not print.\\r This will be printed");
    print("This is \\t tabbed.");
    print("Line 1\\fLine 2");
    words = ["Hello", "World!", "I", "am", "a", "Jactastic!"];
    print(f"{'\\n'.join(words)}");
}

```

#### `reference/for_statements.jac`

**File Info:**
- Lines: 10
- Non-empty lines: 9

**Code:**
```jac
with entry {
    for i in "ban" {
        for j in range(1, 3) {
            for k=1 to k<3 by k+=1  {
                print(i, j, k);
            }
        }
    }
}

```

#### `reference/free_code.jac`

**File Info:**
- Lines: 24
- Non-empty lines: 18
- Features: Classes, Functions, Imports

**Code:**
```jac
import math;

obj circle {
    def init(radius: float) {
        self.radius = radius;
    }

    def area -> float {
        return math.pi * self.radius * self.radius;
    }
}

def foo(n_1: float) {
    return n_1 ** 2;
}

with entry {
    print("Hello World!");
    print(foo(7));
    print(int(circle(10).area()));

    #code block
}

```

#### `reference/function_calls.jac`

**File Info:**
- Lines: 10
- Non-empty lines: 8
- Features: Functions

**Code:**
```jac
def foo(x: int, y: int, z: int) {
    return (x * y, y * z);
}

with entry {
    a = 5;
    output = foo(x=4, y=4 if a % 3 == 2 else 3, z=9);
    print(output);
}

```

#### `reference/functions_and_abilities.jac`

**File Info:**
- Lines: 35
- Non-empty lines: 30
- Features: Classes, Functions

**Code:**
```jac
obj Divider {
    def divide(x: float, y: float) -> float {
        return (x / y);
    }
}
#this is an abstract class as it has the abstract method

obj Calculator {
    static def:priv multiply(a: float, b: float) -> float {
        return a * b;
    }
    def substract -> float abs;
    def add(number: float, *a: tuple) -> float;
}

obj Substractor(Calculator) {
    def substract(x: float, y: float) -> float {
        return (x - y);
    }
}

impl Calculator.add
(number: float, *a: tuple) -> float {
    return (number * sum(a));
}

with entry {
    div = Divider();
    sub = Substractor();
    print(div.divide(55, 11));
    print(Calculator.multiply(9, -2));
    print(sub.add(5, 20, 34, 56));
    print(sub.substract(9, -2));
}

```

#### `reference/global_and_nonlocal_statements.jac`

**File Info:**
- Lines: 20
- Non-empty lines: 16
- Features: Functions

**Code:**
```jac
glob x = "Jaclang ";

def outer_func -> None {
    global x;

    x = 'Jaclang is ';
    y = 'Awesome';
    def inner_func -> tuple[str, str] {
        nonlocal y;

        y = "Fantastic";
        return (x, y);
    }
    print(x, y);
    print(inner_func());
}

with entry {
    outer_func();
}
```

#### `reference/global_variables.jac`

**File Info:**
- Lines: 14
- Non-empty lines: 8

**Code:**
```jac
let:priv a = 5;

glob:pub X = 10;

glob:protect y = 15;

glob z = 20;

obj:priv Myobj{}

with entry:__main__ {
    print(a, X, y, z);
}

```

#### `reference/if_statements.jac`

**File Info:**
- Lines: 11
- Non-empty lines: 10

**Code:**
```jac
with entry {
    x = 15;
    if 0 <= x<= 5 {
        print("Not Bad");
    } elif 6 <= x<= 10 {
        print("Average");
    } else {
        print("Good Enough");
    }
}

```

#### `reference/implementations.jac`

**File Info:**
- Lines: 27
- Non-empty lines: 20
- Features: Classes, Functions

**Code:**
```jac
def foo -> str;

obj vehicle;

enum Size; #implementations

impl foo -> str {
    return ("Hello");
}

impl vehicle  {
    has name: str = "Car";
}

impl Size {
    Small=1,
    Medium=2,
    Large=3
}

with entry {
    car = vehicle();
    print(foo());
    print(car.name);
    print(Size.Medium.value);
}

```

#### `reference/import_include_statements.jac`

**File Info:**
- Lines: 14
- Non-empty lines: 12
- Features: Imports

**Code:**
```jac
include os;
import datetime as dt;
import from math { sqrt as square_root, log }

with entry {
    for i in range(int(square_root(dt.datetime.now().year))) {
        print(
            getcwd(),
            square_root(i),
            int(log(i + 1))
        );
    }
}

```

#### `reference/inline_python.jac`

**File Info:**
- Lines: 11
- Non-empty lines: 8
- Features: Functions

**Code:**
```jac
with entry {
    print("hello ");
}

::py::
def foo():
    print("world")

foo()
::py::

```

#### `reference/lambda_expressions.jac`

**File Info:**
- Lines: 5
- Non-empty lines: 4

**Code:**
```jac
with entry {
    x = lambda a: int, b: int : b + a;
    print(x(5, 4));
}

```

#### `reference/lexer_tokens.jac`

**File Info:**
- Lines: 4
- Non-empty lines: 3

**Code:**
```jac
with entry {
    print("Example not applicable.");
}

```

#### `reference/logical_and_compare_expressions.jac`

**File Info:**
- Lines: 16
- Non-empty lines: 15

**Code:**
```jac
with entry {
    if 5 > 4 {
        print("True");
    } elif "a" != "b" {
        print("'a' is 'a' ");
    } else {
        print("No");
    }
    a = [1, 2, 3];
    b = [1, 2, 3];
    print(a is b);
    print(3 in a);
    print(True or False);
    print(False and False);
}

```

#### `reference/match_capture_patterns.jac`

**File Info:**
- Lines: 10
- Non-empty lines: 9

**Code:**
```jac
with entry {
    day = " sunday";
    match day {
        case "monday":
            print("confirmed");
        case _:
            print("other");
    }
}

```

#### `reference/match_class_patterns.jac`

**File Info:**
- Lines: 15
- Non-empty lines: 13
- Features: Classes

**Code:**
```jac
obj Point {
    has x: float,
        y: float;
}

with entry {
    data = Point(x=9, y=0);
    match data {
        case Point(int(a), y = 0):
            print(f"Point with x={a} and y=0");
        case _:
            print("Not on the x-axis");
    }
}

```

#### `reference/match_literal_patterns.jac`

**File Info:**
- Lines: 10
- Non-empty lines: 9

**Code:**
```jac
with entry {
    num = 89;
    match num {
        case 89:
            print("Correct");
        case 8:
            print("Nope");
    }
}

```

#### `reference/match_mapping_patterns.jac`

**File Info:**
- Lines: 10
- Non-empty lines: 9

**Code:**
```jac
with entry {
    data = {"key1": 1, "key2": 2, "232": 3453};
    match data {
        case {"key1" : 1, "key2" : 2, **rest}:
            print(
                f"Matched a mapping with key1 and key2. Rest: {rest}"
            );
    }
}

```

#### `reference/match_patterns.jac`

**File Info:**
- Lines: 56
- Non-empty lines: 45
- Features: Classes, Functions

**Code:**
```jac
obj Point {
    has x: float,
        y: float;
}

def match_example(data: any) {
    match data {
        # MatchValue
        case 42:
            print("Matched the value 42.");

        # MatchSingleton
        case True:
            print("Matched the singleton True.");
        case None:
            print("Matched the singleton None.");

        # MatchSequence
        case [1, 2, 3]:
            print("Matched a specific sequence [1, 2, 3].");

        # MatchStar
        case [1, *rest, 3]:
            print(
                f"Matched a sequence starting with 1 and ending with 3. Middle: {rest}"
            );

        # MatchMapping
        case {"key1" : 1, "key2" : 2, **rest}:
            print(
                f"Matched a mapping with key1 and key2. Rest: {rest}"
            );

        # MatchClass
        case Point(int(a), y = 0):
            print(f"Point with x={a} and y=0");

        # MatchAs
        case [1, 2, rest_val as value]:
            print(
                f"Matched a sequence and captured the last value: {value}"
            );

        # MatchOr
        case [1, 2] | [3, 4]:
            print("Matched either the sequence [1, 2] or [3, 4].");

        case _:
            print("No match found.");
    }
}

with entry {
    match_example(Point(x=9, y=0));
}

```

#### `reference/match_sequence_patterns.jac`

**File Info:**
- Lines: 10
- Non-empty lines: 9

**Code:**
```jac
with entry {
    data = [1, 2, 3];
    match data {
        case [1, 2, 3]:
            print("Matched");
        case _:
            print("Not Found");
    }
}

```

#### `reference/match_singleton_patterns.jac`

**File Info:**
- Lines: 12
- Non-empty lines: 10

**Code:**
```jac
with entry {
    data = True;
    match True {

        # MatchSingleton
        case True:
            print("Matched the singleton True.");
        case None:
            print("Matched the singleton None.");
    }
}

```

#### `reference/match_statements.jac`

**File Info:**
- Lines: 10
- Non-empty lines: 9

**Code:**
```jac
with entry {
    a = 8;
    match a {
        case 7:
            print("doable");
        case _:
            print("Undoable");
    }
}

```

#### `reference/names_and_references.jac`

**File Info:**
- Lines: 31
- Non-empty lines: 24
- Features: Classes, Functions

**Code:**
```jac
obj Animal {
    has species: str;
    has sound: str;

}

obj Dog(Animal) {
    has breed: str;
    has trick: str by postinit;

    def postinit {
        self.trick = "Roll over";
    }
}

obj Cat(Animal) {
    def init(fur_color: str) {
        super.init(species="Cat", sound="Meow!");
        self.fur_color = fur_color;
    }
}

with entry {
    dog = Dog(breed="Labrador", species="Dog", sound="Woof!");
    cat = Cat(fur_color="Tabby");

    print(dog.breed, dog.sound, dog.trick);
    # print(f"The dog is a {dog.breed} and says '{dog.sound}'");
    # print(f"The cat's fur color is {cat.fur_color}");
}

```

#### `reference/object_spatial_calls.jac`

**File Info:**
- Lines: 28
- Non-empty lines: 22
- Features: Nodes, Walkers

**Code:**
```jac
walker Creator {
    can func2 with `root entry;
}

node node_1 {
    has val: int;

    can func_1 with Creator entry;
}

impl node_1.func_1 {
    print("visiting ", self);
    visit [-->];
}

impl Creator.func2 {
    end = here;
    for i=0 to i<5 by i+=1  {
        end ++> (end := node_1(val=i + 1));
    }
    visit [-->];
}

with entry {
    root spawn :> Creator;
    root spawn |> Creator;
}

```

#### `reference/object_spatial_references.jac`

**File Info:**
- Lines: 36
- Non-empty lines: 29
- Features: Nodes, Edges, Walkers

**Code:**
```jac
walker Creator {
    can create with `root entry;
}

node node_a {
    has val: int;

    can make_something with Creator entry;
}

edge connector {
    has value: int = 10;
}

impl Creator.create {
    end = here;
    for i=0 to i<3 by i+=1  {
        end ++> (end := node_a(val=i));
    }
    end +>:connector:value=i:+> (end := node_a(val=i + 10));
    root <+:connector:value=i:<+ (end := node_a(val=i + 10));
    visit [-->];
}

impl node_a.make_something {
    i = 0;
    while i < 5 {
        print(f"wlecome to {self}");
        i += 1;
    }
}

with entry {
    root spawn Creator();
}

```

#### `reference/object_spatial_spawn_expressions.jac`

**File Info:**
- Lines: 27
- Non-empty lines: 21
- Features: Nodes, Walkers

**Code:**
```jac
walker Adder {
    can do with `root entry;
}

node node_a {
    has x: int = 0,
        y: int = 0;

    can add with Adder entry;
}

impl Adder.do {
    here ++> node_a();
    visit [-->];
}

impl node_a.add {
    self.x = 550;
    self.y = 450;
    print(int(self.x) + int(self.y));
}

with entry {
    # spawn will iniiate the walker Adder from root node
    Adder() spawn root;
}

```

#### `reference/object_spatial_typed_context_blocks.jac`

**File Info:**
- Lines: 27
- Non-empty lines: 21
- Features: Nodes, Walkers

**Code:**
```jac
walker Producer {
    can produce with `root entry;
}

node Product {
    has number: int;

    can make with Producer entry;
}

impl Producer.produce {
    end = here;
    for i=0 to i<3 by i+=1  {
        end ++> (end := Product(number=i + 1));
    }
    visit [-->];
}

impl Product.make {
    print(f"Hi, I am {self} returning a String");
    visit [-->];
}

with entry {
    root spawn Producer();
}

```

#### `reference/object_spatial_walker_statements.jac`

**File Info:**
- Lines: 12
- Non-empty lines: 10
- Features: Walkers

**Code:**
```jac
walker Visitor {
    can self_destruct with entry {
        print("get's here");
        disengage;
        print("but not here");
    }
}

with entry {
    root spawn Visitor();
}

```

#### `reference/pipe_back_expressions.jac`

**File Info:**
- Lines: 10
- Non-empty lines: 8
- Features: Functions

**Code:**
```jac
def double(x: int) -> int {
    return (x * 2);
}

with entry {
    number = 5;
    result = double <| number;
    print(result);
}

```

#### `reference/pipe_expressions.jac`

**File Info:**
- Lines: 10
- Non-empty lines: 8
- Features: Functions

**Code:**
```jac
def square(x: int) -> int {
    return (x ** 2);
}

with entry {
    number = 5;
    result = number |> square;
    print(result);
}

```

#### `reference/raise_statements.jac`

**File Info:**
- Lines: 14
- Non-empty lines: 12
- Features: Functions

**Code:**
```jac
def foo(value: int) {
    if value < 0 {
        raise ValueError("Value must be non-negative");
    }
}

with entry {
    try  {
        foo(-1);
    } except ValueError as e  {
        print("Raised:", e);
    }
}

```

#### `reference/references_(unused).jac`

**File Info:**
- Lines: 4
- Non-empty lines: 3

**Code:**
```jac
with entry {
    print("Not used.");
}

```

#### `reference/report_statements.jac`

**File Info:**
- Lines: 4
- Non-empty lines: 3

**Code:**
```jac
with entry {
    print("Not used.");
}

```

#### `reference/return_statements.jac`

**File Info:**
- Lines: 9
- Non-empty lines: 7
- Features: Functions

**Code:**
```jac
def foo -> int{
    a = 42;
    return a;
}

with entry {
    print("Returned:", foo());
}

```

#### `reference/semstrings.jac`

**File Info:**
- Lines: 26
- Non-empty lines: 18
- Features: Functions, Imports

**Code:**
```jac
import from byllm { Model }

glob llm = Model(
    model_name="gpt-4o",
);


def generate_password()  -> str by llm();


sem generate_password= \"\"\"\\
Generates and returns password that:
- contain at least 8 characters
- contain at least one uppercase letter
- contain at least one lowercase letter
- contain at least one digit
- contain at least one special character
\"\"\";


with entry {
    password = generate_password();
    print('Generated password:', password);
}

```

#### `reference/special_comprehensions.jac`

**Description:** Filter comprehension

**File Info:**
- Lines: 32
- Non-empty lines: 26
- Features: Classes, Imports

**Code:**
```jac
#Filter comprehension
import random;

obj TestObj {
    has x: int = random.randint(0, 15),
        y: int = random.randint(0, 15),
        z: int = random.randint(0, 15);
}

with entry {
    random.seed(42);
    apple = [];
    for i=0 to i<100 by i+=1  {
        apple.append(TestObj());
    }

    # check if all apple's x are random between 0 and 15
    print(apple(?x >= 0, x <= 15) == apple);
}

obj MyObj {
    has apple: int = 0,
        banana: int = 0;
}

with entry {
    x = MyObj();
    y = MyObj();
    mvar = [x, y](=apple=5, banana=7);
    print(mvar);
}

```

#### `reference/subscripted_and_dotted_expressions.jac`

**File Info:**
- Lines: 11
- Non-empty lines: 8
- Features: Classes

**Code:**
```jac
obj Sample {
    has my_list: list = [1, 2, 3],
        my_dict: dict = {"name":"John", "age": 30};
}

glob (first, second) = (Sample().my_list[2], Sample().my_dict["name"]);

with entry {
    print(first, second);
}

```

#### `reference/tests.jac`

**File Info:**
- Lines: 21
- Non-empty lines: 17
- Features: Imports

**Code:**
```jac
test test1 {
    check almostEqual(4.99999, 4.99999);
}

test test2 {
    check 5 == 5;
}

test test3 {
    check "e" in "qwerty";
}

with entry:__main__ {
    import subprocess;
    result = subprocess.run(
        ["jac", "test", f"{__file__}"],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
    );
    print(result.stderr);
}

```

#### `reference/try_statements.jac`

**File Info:**
- Lines: 8
- Non-empty lines: 7

**Code:**
```jac
with entry {
    try  {
        print("Result", 5 / 0);
    } except Exception as e  {
        print(e);
    }
}

```

#### `reference/tuples_and_jac_tuples.jac`

**File Info:**
- Lines: 13
- Non-empty lines: 10
- Features: Functions

**Code:**
```jac
def foo(first: int, second: int) -> None {
    print(first, second);
}

with entry {
    val1 = (3, ) + (4, );
    val2 = (val1[0] * val1[1], val1[0] + val1[1]);

    # Jac-style Tuples
    (second=val2[1], first=val2[0]) |> foo;
    (first=val2[0], second=val2[1]) |> foo;
}

```

#### `reference/unpack_expressions.jac`

**File Info:**
- Lines: 24
- Non-empty lines: 18
- Features: Functions

**Code:**
```jac
def combine_via_func(a: int, b: int, c: int, d: int) -> int {
    return a + b + c + d;
}

with entry {
    first_list = [1, 2, 3, 4, 5];
    second_list = [5, 8, 7, 6, 9];
    combined_list = [*first_list, *second_list];
    print(combined_list);

    # Original dictionary
    first_dict = {'a':1, 'b':2 };

    # Another dictionary
    second_dict = {'c':3, 'd':4 };

    # Combining dictionaries using dictionary unpacking
    combined_dict = {**first_dict, **second_dict };

    # Printing the combined dictionary
    print(combine_via_func(**combined_dict));
    print(combine_via_func(**first_dict, **second_dict));
}

```

#### `reference/visit_statements.jac`

**File Info:**
- Lines: 22
- Non-empty lines: 19
- Features: Nodes, Walkers

**Code:**
```jac
walker Visitor {
    can travel with `root entry {
        visit [-->] else {
            visit root;
            disengage;
        }
    }
}

node item {
    can speak with Visitor entry {
        print("Hey There!!!");
    }
}

with entry {
    for i=0 to i<5 by i+=1  {
        root ++> item();
    }
    root spawn Visitor();
}

```

#### `reference/walrus_assignments.jac`

**File Info:**
- Lines: 7
- Non-empty lines: 6

**Code:**
```jac
with entry {
    a = 5;
    if (b := a + a // 2) > 5 {
        print("b is grater than 5");
    }
}

```

#### `reference/while_statements.jac`

**File Info:**
- Lines: 8
- Non-empty lines: 7

**Code:**
```jac
with entry {
    i = 1;
    while i < 6 {
        print(i);
        i+=1;
    }
}

```

#### `reference/yield_statements.jac`

**File Info:**
- Lines: 14
- Non-empty lines: 12
- Features: Functions

**Code:**
```jac
def myFunc {
    yield "Hello";
    yield 91;
    yield "Good Bye";
    yield ;
}

with entry {
    x = myFunc();
    for z in x {
        print(z);
    }
}

```

**Python Files:**

- `reference/archetype_bodies.py`
- `reference/archetypes.py`
- `reference/arithmetic_expressions.py`
- `reference/assert_statements.py`
- `reference/assignments.py`
- `reference/atom.py`
- `reference/atomic_expressions.py`
- `reference/atomic_pipe_back_expressions.py`
- `reference/base_module_structure.py`
- `reference/bitwise_expressions.py`
- `reference/builtin_types.py`
- `reference/check_statements.py`
- `reference/codeblocks_and_statements.py`
- `reference/collection_values.py`
- `reference/concurrent_expressions.py`
- `reference/connect_expressions.py`
- `reference/context_managers.py`
- `reference/control_statements.py`
- `reference/delete_statements.py`
- `reference/disengage_statements.py`
- `reference/enumerations.py`
- `reference/expressions.py`
- `reference/f_string_tokens.py`
- `reference/for_statements.py`
- `reference/free_code.py`
- `reference/function_calls.py`
- `reference/functions_and_abilities.py`
- `reference/global_and_nonlocal_statements.py`
- `reference/global_variables.py`
- `reference/if_statements.py`
- `reference/implementations.py`
- `reference/import_include_statements.py`
- `reference/inline_python.py`
- `reference/lambda_expressions.py`
- `reference/lexer_tokens.py`
- `reference/logical_and_compare_expressions.py`
- `reference/match_capture_patterns.py`
- `reference/match_class_patterns.py`
- `reference/match_literal_patterns.py`
- `reference/match_mapping_patterns.py`
- `reference/match_patterns.py`
- `reference/match_sequence_patterns.py`
- `reference/match_singleton_patterns.py`
- `reference/match_statements.py`
- `reference/names_and_references.py`
- `reference/object_spatial_calls.py`
- `reference/object_spatial_references.py`
- `reference/object_spatial_spawn_expressions.py`
- `reference/object_spatial_typed_context_blocks.py`
- `reference/object_spatial_walker_statements.py`
- `reference/pipe_back_expressions.py`
- `reference/pipe_expressions.py`
- `reference/raise_statements.py`
- `reference/references_(unused).py`
- `reference/report_statements.py`
- `reference/return_statements.py`
- `reference/semstrings.py`
- `reference/special_comprehensions.py`
- `reference/subscripted_and_dotted_expressions.py`
- `reference/tests.py`
- `reference/try_statements.py`
- `reference/tuples_and_jac_tuples.py`
- `reference/unpack_expressions.py`
- `reference/visit_statements.py`
- `reference/walrus_assignments.py`
- `reference/while_statements.py`
- `reference/yield_statements.py`

## Rpg_Game

### jac_impl

**Description files:**
- `rpg_game/jac_impl/README.md`

### jac_impl_6

**JAC Files:**

#### `rpg_game/jac_impl/jac_impl_6/game_obj.jac`

**Description:** This is an RPG game built using Jaclang

**File Info:**
- Lines: 40
- Non-empty lines: 35
- Features: Classes, Functions, Imports

**Code:**
```jac
\"\"\"This is an RPG game built using Jaclang\"\"\"

# This game is built using the pygame module which is imported here
import pygame;

# Including Jac codebase
include sprites;
include settings.config;
include settings.map;

\"\"\"
The Game base class
\"\"\"
obj Game {
    has screen:pygame.surface.Surface = pygame.display.set_mode((WIN_WIDTH, WIN_HEIGHT)),
        clock:pygame.time.Clock = pygame.time.Clock(),
        running:bool = True,
        won:bool = False,
        score:int = 0,
        deaths:int = 0,
        character_spritesheet:pygame.surface.Surface = Spritesheet('../img/character.png'),
        terrain_spritesheet:pygame.surface.Surface = Spritesheet('../img/terrain.png'),
        enemy_spritesheet:pygame.surface.Surface = Spritesheet('../img/enemy.png'),
        attack_spritesheet:pygame.surface.Surface = Spritesheet('../img/attack.png'),
        intro_background:pygame.surface.Surface = pygame.image.load('../img/introbackground.png'),
        go_background:pygame.surface.Surface = pygame.image.load('../img/gameover.png'),
        GameMap:Map = Map();

    def postinit;
    def createTilemap;
    def new;
    def events;
    def update;
    def draw;
    def main;
    def intro_screen;
    def game_won;
    def game_over;

}
```

#### `rpg_game/jac_impl/jac_impl_6/main.jac`

**Description:** This is the Object-Spatial Implementation of the RPG Game

**File Info:**
- Lines: 51
- Non-empty lines: 35
- Features: Nodes, Edges, Walkers, Imports

**Code:**
```jac
\"\"\"This is the Object-Spatial Implementation of the RPG Game\"\"\"

# This game is built using the pygame module which is imported here
 import pygame;
import random;
import time;

# Importing Jac codebase
 include sprites;
include game_obj;
include settings.config;
include settings.map;
include utils.level_manager;


'''The walker that initiates the game and runs an instance of the game'''
walker game {
    has g: Game = None , last_level_id: str = '1_1000' , current_level: int = 1 , fwd_dir: bool = True , manager: LevelManager = LevelManager();

    can start_game with `root entry;
}


edge play {
    has level_id: str = '1_1000';
}


'''Start screen node which operate as the virtual root node'''
node start_screen {
    has game_started: bool = False;

    can intro_screen with game entry;
    can exit_game with game exit;
}


'''Level node which (should) have unique (ai generated) attributes'''
node level {
    has game_level: int = 1 , level_id: str = '1_1000' , played: bool = False , level_config: Map = Map() , level_time: float = 500000;

    can run_game with game entry;
    can exit_game with game exit;
}


'''Run the game'''
with entry {
    root spawn game();
}

```

#### `rpg_game/jac_impl/jac_impl_6/sprites.jac`

**Description:** This file containes all definitions of sprites that apear in the game

**File Info:**
- Lines: 127
- Non-empty lines: 111
- Features: Classes, Functions, Imports

**Code:**
```jac
\"\"\"This file containes all definitions of sprites that apear in the game\"\"\"

# Importing python libraries
import pygame, random, math;
import from pygame.sprite { AbstractGroup }

# Importing settings data
include settings.config;
include settings.map;

\"\"\"
Object for impoting sprite character images.
\"\"\"
obj Spritesheet {
    has file:str;

    def postinit;
    def get_sprite(x: int, y: int, width: int, height: int) -> pygame.Surface;
}

\"\"\"
Object for the player with type pygame.sprite.Sprite
\"\"\"
obj Player(pygame.sprite.Sprite) {
    has game: Game,
        x: int,
        y: int;
    has _layer: int = PLAYER_LAYER,
        width: int = TILESIZE,
        height: int = TILESIZE,
        x_change: int = 0,
        y_change: int = 0,
        facing: str = 'down',
        animation_loop: float = 1;

    def postinit;
    def update;
    def movement;
    def collide_enemy;
    def animate;
    def collide_blocks(direction: str);
}

\"\"\"
Object for enemies with type pygame.sprite.Sprite
\"\"\"
obj Enemy(pygame.sprite.Sprite) {
    has game: Game,
        x: int,
        y: int;
    has _layer: int = ENEMY_LAYER,
        width: inr = TILESIZE,
        height: int = TILESIZE,
        x_change: int = 0,
        y_change: int = 0,
        animation_loop: float = 0,
        movement_loop: int = 0;

    def postinit;
    def update;
    def movement;
    def animate;
    def collide_blocks(direction: str);
}

\"\"\"
Object for blocks (Walls) with type pygame.sprite.Sprite
\"\"\"
obj Block(pygame.sprite.Sprite) {
    has game: Game,
        x: int,
        y: int;
    has _layer: int = BLOCK_LAYER,
        width: int = TILESIZE,
        height: int = TILESIZE;

    def postinit;
}

\"\"\"
Object for ground with type pygame.sprite.Sprite
\"\"\"
obj Ground(pygame.sprite.Sprite) {
    has game: Game,
        x: int,
        y: int;
    has _layer: int = GROUND_LAYER,
        width: int = TILESIZE,
        height: int = TILESIZE;

    def postinit;
}

\"\"\""
Object class for attacks by the player
\"\"\"
obj Attack(pygame.sprite.Sprite) {
    has game: Game,
        x: int,
        y: int;
    has _layer: int = ATTACK_LAYER,
        width: int = TILESIZE,
        height: int = TILESIZE,
        animation_loop: float = 0;

    def postinit;
    def update;
    def collide;
    def animate;
}

\"\"\"
Object class for buttons used in the game (Start, Restart)
\"\"\"
obj Button {
    has x: int,
        y: int,
        width: int,
        height: int,
        fg: tuple,
        bg: tuple,
        content: str,
        fontsize: int;

    def postinit;
    def is_pressed(pos: tuple, pressed: tuple) -> bool;
}
```

### game_obj.impl

**JAC Files:**

#### `rpg_game/jac_impl/jac_impl_6/game_obj.impl/game.impl.jac`

**Description:** =Object=Abilities ===================================================

**File Info:**
- Lines: 170
- Non-empty lines: 160

**Code:**
```jac
#=Object=Abilities ===================================================

impl Game.postinit {
        pygame.<>init();
        self.font: pygame.font.Font = pygame.font.Font(GENERAL_FONT, 32);
}

impl Game.createTilemap {
    for (i, row) in enumerate(self.GameMap.map){
        for (j, column) in enumerate(row){
            Ground(self,j,i);
            if column == "B"{
                Block(self,j,i);
            }
            if column == "E"{
                Enemy(self,j,i);
            }
            if column == "P"{
                self.player = Player(self,j,i);
            }
        }
    }
}

# Start a new game
impl Game.new{
    self.playing = True;
    self.won = False;
    self.all_sprites = pygame.sprite.LayeredUpdates();
    self.blocks = pygame.sprite.LayeredUpdates();
    self.enemies = pygame.sprite.LayeredUpdates();
    self.attacks = pygame.sprite.LayeredUpdates();
    self.createTilemap();
}

# Update pygame events to check if the game is quitted or attacked.
impl Game.events{
    for events in pygame.event.get() {
        if events.type == pygame.QUIT {
            self.playing = False;
            self.running = False;
        }
        keys = pygame.key.get_pressed();
        if keys[pygame.K_SPACE] {
            if self.player.facing == 'up' {
                Attack(self, self.player.rect.x, self.player.rect.y - TILESIZE);
            }
            if self.player.facing == 'down'{
                Attack(self, self.player.rect.x, self.player.rect.y + TILESIZE);
            }
            if self.player.facing == 'right'{
                Attack(self, self.player.rect.x + TILESIZE, self.player.rect.y);
            }
            if self.player.facing == 'left'{
                Attack(self, self.player.rect.x - TILESIZE, self.player.rect.y);
            }
        }
    }
}
# Update all sprites

impl Game.update {
    self.all_sprites.update();
}
# Display the game

impl Game.draw {
    self.screen.fill(BLACK);
    self.all_sprites.draw(self.screen);
    self.clock.tick(FPS);
    pygame.display.update();
}
# Game runtime

impl Game.main {
    while self.playing {
        self.events();
        self.update();
        self.draw();
        if len(self.enemies.sprites()) == 0 {
            self.won = True;
            self.playing = False;
        }
    }
}
# Game over screen

impl Game.game_over {
    self.score -= 2;
    text = self.font.render('GaMe OvEr', True, RED);
    text_rect = text.get_rect(center = (WIN_WIDTH/2, WIN_HEIGHT/2));
    restart_button = Button(10,WIN_HEIGHT-135, 120, 125, WHITE, BLACK, 'Restart', 32);
    for sprite in self.all_sprites {
        sprite.kill();
    }
    while self.running {
        for event in pygame.event.get() {
            if event.type == pygame.QUIT {
                self.running = False;
            }
        }
        mouse_pos = pygame.mouse.get_pos();
        mouse_pressed = pygame.mouse.get_pressed();
        if restart_button.is_pressed(mouse_pos, mouse_pressed) {
            self.won = False;
            self.new();
            break;
        }
        self.screen.blit(self.go_background, (0,0));
        self.screen.blit(text, text_rect);
        self.screen.blit(restart_button.image, restart_button.rect);
        self.clock.tick(FPS);
        pygame.display.update();
    }
}
# Introduction Screen

impl Game.intro_screen {
    intro = True;
    title = self.font.render('Spud-nik : SOLO', True, BLUE);
    title_rect = title.get_rect(x=WIN_WIDTH/2-100,y=100);
    play_button = Button(WIN_WIDTH/2-50, 200, 100, 100, WHITE, BLACK, 'Play', 32);
    while intro {
        for event in pygame.event.get() {
            if event.type == pygame.QUIT {
                intro = False;
                self.running = False;
            }
        }
        mouse_pos = pygame.mouse.get_pos();
        mouse_pressed = pygame.mouse.get_pressed();
        if play_button.is_pressed(mouse_pos, mouse_pressed) {
            intro = False;
        }
        self.screen.blit(self.intro_background, (0,0));
        self.screen.blit(title, title_rect);
        self.screen.blit(play_button.image, play_button.rect);
        self.clock.tick(FPS);
        pygame.display.update();
    }
}
# Game won

impl Game.game_won {
    self.score += 5;
    text = self.font.render('YOU WON!', True, BLUE);
    text_rect = text.get_rect(center = (WIN_WIDTH/2, WIN_HEIGHT/2));
    restart_button = Button(10,WIN_HEIGHT-135, 120, 125, WHITE, BLACK, 'Restart', 32);
    for sprite in self.all_sprites {
        sprite.kill();
    }
    while self.running {
        for event in pygame.event.get() {
            if event.type == pygame.QUIT {
                self.running = False;
            }
        }
        mouse_pos = pygame.mouse.get_pos();
        mouse_pressed = pygame.mouse.get_pressed();
        if restart_button.is_pressed(mouse_pos, mouse_pressed) {
            self.new();
            break;
        }
        self.screen.blit(self.intro_background, (0,0));
        self.screen.blit(text, text_rect);
        self.screen.blit(restart_button.image, restart_button.rect)   ;
        self.clock.tick(FPS);
        pygame.display.update();
    }
}
```

### main.impl

**JAC Files:**

#### `rpg_game/jac_impl/jac_impl_6/main.impl/game_walker.impl.jac`

**File Info:**
- Lines: 5
- Non-empty lines: 5

**Code:**
```jac
impl game.start_game {
    self.g = Game();
    here ++> start_screen();
    visit [-->];
}
```

#### `rpg_game/jac_impl/jac_impl_6/main.impl/level.impl.jac`

**File Info:**
- Lines: 64
- Non-empty lines: 61
- Features: Imports

**Code:**
```jac
import sys;

impl level.run_game {
    # print("Walker Entry ->", self.level_id);

    if self.played == False {
        if visitor.current_level != self.game_level {
            visitor.current_level = self.game_level;
        }
        if visitor.manager.current_level != self.game_level {
            if self.game_level != 1 {
                visitor.manager.current_level = self.game_level;
                next_level = visitor.manager.get_next_level(self.game_level);
                self.level_config.map = next_level;
            }
        } else {
            self.level_config.map = [[<--][0] -->](`?level)(?level_id==visitor.last_level_id)[0].level_config.map;
        }
        visitor.g.GameMap.map = self.level_config.map;
        visitor.g.new();
        print(":-: Playing Level :", self.game_level, "| Level ID :",  self.level_id, "| Played :", str(self.played));
        start_time = time.time();
        visitor.g.main();
        end_time = time.time();
        visitor.last_level_id = self.level_id;
        if visitor.g.won == True{
            self.level_time = end_time - start_time;
            if visitor.manager.prev_levels {
                visitor.manager.prev_levels[-1].time = self.level_time;
            }
            visitor.g.game_won();
            self.played = True;
            visitor.g.won = False;
            visitor.fwd_dir =True;
            new_ID = str(self.game_level+1) + "_" + str(random.randint(1000, 9000));
            self +>:play:level_id=new_ID:+> level(game_level = self.game_level+1, level_id = new_ID);
            visit [->:play:level_id==new_ID:->];
        } else {
            visitor.g.game_over();
            # visitor.map_directory[str(self.game_level)].nos_retry += 1;
            self.played = True;
            visitor.g.won = False;
            visitor.fwd_dir = False;
            visit [<-:play:<-];
        }
    } elif visitor.fwd_dir == False{
        new_ID = str(self.game_level+1) + "_" + str(random.randint(1000, 9000));
        print(":-: Visiting Level :", self.game_level, "| Level ID :",  self.level_id, "| Played :", str(self.played), '| Created Level ID :', new_ID);
        visitor.fwd_dir = True;
        self +>:play:level_id=new_ID:+> level(game_level = self.game_level+1, level_id = new_ID);
        visit [->:play:level_id==new_ID:->];
    } else {
        print(":-: Visiting Level :", self.game_level, "| Level ID :",  self.level_id, "| Played :", str(self.played));
        visit [<--];
    }
}

impl level.exit_game {
    if visitor.g.running == False {
        pygame.quit();
        sys.exit();
        disengage;
    }
}
```

#### `rpg_game/jac_impl/jac_impl_6/main.impl/start_screen.impl.jac`

**File Info:**
- Lines: 26
- Non-empty lines: 24

**Code:**
```jac
impl start_screen.intro_screen {
    # print("Walker Entry -> Intro Screen");
    if self.game_started == False {
        self.game_started = True;
        visitor.g.intro_screen();
        new_ID = str(1) + "_" + str(random.randint(1000, 9000));
        self +>:play:level_id=new_ID:+> level(game_level = 1, level_id = new_ID);
        visitor.fwd_dir = True;
        visit [->:play:level_id==new_ID:->];
    } else {
        new_ID = str(1) + "_" + str(random.randint(1000, 9000));
        self +>:play:level_id=new_ID:+> level(game_level = 1, level_id = new_ID);
        print(":-: Visiting Intro Screen | Created Level ID :", new_ID);
        visitor.fwd_dir = True;
        visit [->:play:level_id==new_ID:->];

    }
}

impl start_screen.exit_game {
    if visitor.g.running == False {
        pygame.quit();
        sys.exit();
        disengage;
    }
}
```

### settings

**JAC Files:**

#### `rpg_game/jac_impl/jac_impl_6/settings/config.jac`

**File Info:**
- Lines: 20
- Non-empty lines: 16

**Code:**
```jac
glob WIN_WIDTH = 640;
glob WIN_HEIGHT = 480;
glob TILESIZE = 32;
glob FPS = 60;

glob ATTACK_LAYER = 5;
glob ENEMY_LAYER = 4;
glob PLAYER_LAYER = 3;
glob BLOCK_LAYER = 2;
glob GROUND_LAYER = 1;

glob PLAYER_SPEED = 3;
glob ENEMY_SPEED = 2;

glob RED = (255, 0, 0);
glob BLACK = (0, 0, 0);
glob BLUE = (0, 0, 255);
glob WHITE = (255, 255, 255);

glob GENERAL_FONT = '../fonts/8bitoperator_jve.ttf';
```

#### `rpg_game/jac_impl/jac_impl_6/settings/map.jac`

**File Info:**
- Lines: 23
- Non-empty lines: 22
- Features: Classes

**Code:**
```jac
obj Map {
    has Level_no:int = 1;
    has time_to_win_level:float = 60.0;
    has nos_retry:int = 0;
    has map   :list[str] = [
                                'BBBBBBBBBBBBBBBBBBBB',
                                'B...E..............B',
                                'B.......B..........B',
                                'B....BBBB..........B',
                                'B..................B',
                                'B..................B',
                                'B.........P........B',
                                'B..................B',
                                'B.............E....B',
                                'B..................B',
                                'B..................B',
                                'B.........B........B',
                                'B.........B........B',
                                'B.........B........B',
                                'BBBBBBBBBBBBBBBBBBBB'

                            ];
}
```

### sprites.impl

**JAC Files:**

#### `rpg_game/jac_impl/jac_impl_6/sprites.impl/attack.impl.jac`

**File Info:**
- Lines: 56
- Non-empty lines: 53

**Code:**
```jac
impl Attack.postinit {
    self._groups = (self.game.all_sprites, self.game.attacks);
    pygame.sprite.Sprite.init(self, self._groups);
    self.image = self.game.attack_spritesheet.get_sprite(0, 0, self.width, self.height);
    self.rect = self.image.get_rect();
    self.rect.x = self.x;
    self.rect.y = self.y;
}
# Update the attack interations

impl Attack.update {
    self.animate();
    self.collide();
}
# Ability to collide with enemies without passing through.

impl Attack.collide {
    hits = pygame.sprite.spritecollide(self, self.game.enemies, True);
}
# Anminate the attacks.

impl Attack.animate() {
    direction = self.game.player.facing;
    right_animations = [self.game.attack_spritesheet.get_sprite(0, 64, self.width, self.height), self.game.attack_spritesheet.get_sprite(32, 64, self.width, self.height), self.game.attack_spritesheet.get_sprite(64, 64, self.width, self.height), self.game.attack_spritesheet.get_sprite(96, 64, self.width, self.height), self.game.attack_spritesheet.get_sprite(128, 64, self.width, self.height)];
    down_animations = [self.game.attack_spritesheet.get_sprite(0, 32, self.width, self.height), self.game.attack_spritesheet.get_sprite(32, 32, self.width, self.height), self.game.attack_spritesheet.get_sprite(64, 32, self.width, self.height), self.game.attack_spritesheet.get_sprite(96, 32, self.width, self.height), self.game.attack_spritesheet.get_sprite(128, 32, self.width, self.height)];
    left_animations = [self.game.attack_spritesheet.get_sprite(0, 96, self.width, self.height), self.game.attack_spritesheet.get_sprite(32, 96, self.width, self.height), self.game.attack_spritesheet.get_sprite(64, 96, self.width, self.height), self.game.attack_spritesheet.get_sprite(96, 96, self.width, self.height), self.game.attack_spritesheet.get_sprite(128, 96, self.width, self.height)];
    up_animations = [self.game.attack_spritesheet.get_sprite(0, 0, self.width, self.height), self.game.attack_spritesheet.get_sprite(32, 0, self.width, self.height), self.game.attack_spritesheet.get_sprite(64, 0, self.width, self.height), self.game.attack_spritesheet.get_sprite(96, 0, self.width, self.height), self.game.attack_spritesheet.get_sprite(128, 0, self.width, self.height)];
    if direction == 'up' {
        self.image = up_animations[math.floor(self.animation_loop)];
        self.animation_loop+=0.5;
        if self.animation_loop >= 5 {
            self.kill();
        }
    }
    if direction == 'down' {
        self.image = down_animations[math.floor(self.animation_loop)];
        self.animation_loop+=0.5;
        if self.animation_loop >= 5 {
            self.kill();
        }
    }
    if direction == 'left' {
        self.image = left_animations[math.floor(self.animation_loop)];
        self.animation_loop+=0.5;
        if self.animation_loop >= 5 {
            self.kill();
        }
    }
    if direction == 'right' {
        self.image = right_animations[math.floor(self.animation_loop)];
        self.animation_loop+=0.5;
        if self.animation_loop >= 5 {
            self.kill();
        }
    }
}
```

#### `rpg_game/jac_impl/jac_impl_6/sprites.impl/enemy.impl.jac`

**File Info:**
- Lines: 119
- Non-empty lines: 115

**Code:**
```jac
impl Enemy.postinit {
    self._groups = (self.game.all_sprites, self.game.enemies);
    pygame.sprite.Sprite.__init__(self, self._groups);
    self.x*=TILESIZE;
    self.y*=TILESIZE;
    self.image = self.game.enemy_spritesheet.get_sprite(3, 2, self.width, self.height);
    self.facing = random.choice(['up', 'down', 'left', 'right']);
    self.max_travel = random.randint(7, 30);
    self.rect = self.image.get_rect();
    self.rect.x = self.x;
    self.rect.y = self.y;
}
# Update the enemy actions

impl Enemy.update {
    self.movement();
    self.animate();
    self.rect.x+=self.x_change;
    self.collide_blocks('x');
    self.rect.y+=self.y_change;
    self.collide_blocks('y');
    self.x_change = 0;
    self.y_change = 0;
}
# Movement controls.

impl Enemy.movement {
    if self.facing == 'left' {
        self.x_change-=ENEMY_SPEED;
        self.movement_loop-=1;
        if self.movement_loop <= -self.max_travel {
            self.facing = 'right';
        }
    }
    if self.facing == 'right' {
        self.x_change+=ENEMY_SPEED;
        self.movement_loop+=1;
        if self.movement_loop >= self.max_travel {
            self.facing = 'left';
        }
    }
    if self.facing == 'up' {
        self.y_change+=ENEMY_SPEED;
        self.movement_loop+=1;
        if self.movement_loop >= self.max_travel {
            self.facing = 'down';
        }
    }
    if self.facing == 'down' {
        self.y_change-=ENEMY_SPEED;
        self.movement_loop-=1;
        if self.movement_loop <= -self.max_travel {
            self.facing = 'up';
        }
    }
}
# Anminate the enemy character.

impl Enemy.animate {
    down_animations = [self.game.enemy_spritesheet.get_sprite(3, 2, self.width, self.height), self.game.enemy_spritesheet.get_sprite(35, 2, self.width, self.height), self.game.enemy_spritesheet.get_sprite(68, 2, self.width, self.height)];
    up_animations = [self.game.enemy_spritesheet.get_sprite(3, 34, self.width, self.height), self.game.enemy_spritesheet.get_sprite(35, 34, self.width, self.height), self.game.enemy_spritesheet.get_sprite(68, 34, self.width, self.height)];
    left_animations = [self.game.enemy_spritesheet.get_sprite(3, 98, self.width, self.height), self.game.enemy_spritesheet.get_sprite(35, 98, self.width, self.height), self.game.enemy_spritesheet.get_sprite(68, 98, self.width, self.height)];
    right_animations = [self.game.enemy_spritesheet.get_sprite(3, 66, self.width, self.height), self.game.enemy_spritesheet.get_sprite(35, 66, self.width, self.height), self.game.enemy_spritesheet.get_sprite(68, 66, self.width, self.height)];
    if self.facing == "down" {
        self.image = down_animations[math.floor(self.animation_loop)];
        self.animation_loop+=0.1;
        if self.animation_loop >= 3 {
            self.animation_loop = 1;
        }
    }
    if self.facing == "up" {
        self.image = up_animations[math.floor(self.animation_loop)];
        self.animation_loop+=0.1;
        if self.animation_loop >= 3 {
            self.animation_loop = 1;
        }
    }
    if self.facing == "right" {
        self.image = right_animations[math.floor(self.animation_loop)];
        self.animation_loop+=0.1;
        if self.animation_loop >= 3 {
            self.animation_loop = 1;
        }
    }
    if self.facing == "left" {
        self.image = left_animations[math.floor(self.animation_loop)];
        self.animation_loop+=0.1;
        if self.animation_loop >= 3 {
            self.animation_loop = 1;
        }
    }
}
# Ability to collide with blocks without passing through.

impl Enemy.collide_blocks
(direction: str) {
    if direction == "x" {
        hits = pygame.sprite.spritecollide(self, self.game.blocks, False);
        if hits {
            if self.x_change > 0 {
                self.rect.x = hits[0].rect.left - self.rect.width;
            }
            if self.x_change < 0 {
                self.rect.x = hits[0].rect.right;
            }
        }
    }
    if direction == "y" {
        hits = pygame.sprite.spritecollide(self, self.game.blocks, False);
        if hits {
            if self.y_change > 0 {
                self.rect.y = hits[0].rect.top - self.rect.height;
            }
            if self.y_change < 0 {
                self.rect.y = hits[0].rect.bottom;
            }
        }
    }
}
```

#### `rpg_game/jac_impl/jac_impl_6/sprites.impl/inanimates.impl.jac`

**File Info:**
- Lines: 22
- Non-empty lines: 21

**Code:**
```jac
impl Block.postinit {
    self._groups = (self.game.all_sprites, self.game.blocks);
    pygame.sprite.Sprite.init(self, self._groups);
    self.x*=TILESIZE;
    self.y*=TILESIZE;
    self.image = self.game.terrain_spritesheet.get_sprite(960, 448, self.width, self.height);
    self.rect = self.image.get_rect();
    self.rect.x = self.x;
    self.rect.y = self.y;
}

impl Ground.postinit
(game: None, x: int, y: int) {
    self._groups = self.game.all_sprites;
    pygame.sprite.Sprite.init(self, self._groups);
    self.x*=TILESIZE;
    self.y*=TILESIZE;
    self.image = self.game.terrain_spritesheet.get_sprite(64, 352, self.width, self.height);
    self.rect = self.image.get_rect();
    self.rect.x = self.x;
    self.rect.y = self.y;
}
```

#### `rpg_game/jac_impl/jac_impl_6/sprites.impl/interface.impl.jac`

**File Info:**
- Lines: 23
- Non-empty lines: 22

**Code:**
```jac
impl Button.postinit {
    self.font = pygame.font.Font(GENERAL_FONT, self.fontsize);
    self.image = pygame.Surface((self.width, self.height));
    self.image.fill(self.bg);
    self.rect = self.image.get_rect();
    self.rect.x = self.x;
    self.rect.y = self.y;
    self.text = self.font.render(self.content, True, self.fg);
    self.text_rect = self.text.get_rect(center=(self.width / 2, self.width / 2));
    self.image.blit(self.text, self.text_rect);
}
# Determine if thebutton is pressed.

impl Button.is_pressed
(pos: tuple, pressed: tuple) {
    if self.rect.collidepoint(pos) {
        if pressed[0] {
            return True;
        }
        return False;
    }
    return False;
}
```

#### `rpg_game/jac_impl/jac_impl_6/sprites.impl/player.impl.jac`

**File Info:**
- Lines: 157
- Non-empty lines: 152

**Code:**
```jac
impl Player.postinit {
    self._layer = PLAYER_LAYER;
    self._groups = self.game.all_sprites;
    pygame.sprite.Sprite.init(self, self._groups);
    self.x*=TILESIZE;
    self.y*=TILESIZE;
    self.image = self.game.character_spritesheet.get_sprite(3, 2, self.width-5, self.height-5);
    self.rect = self.image.get_rect();
    self.rect.x = self.x;
    self.rect.y = self.y;
}
# Update the player actions

impl Player.update {
    self.movement();
    self.animate();
    self.collide_enemy();
    self.rect.x+=self.x_change;
    self.collide_blocks('x');
    self.rect.y+=self.y_change;
    self.collide_blocks('y');
    self.x_change = 0;
    self.y_change = 0;
}
# Movement controls based on arrow key pushes.

impl Player.movement {
    keys = pygame.key.get_pressed();
    if keys[pygame.K_LEFT] {
        for sprite in self.game.all_sprites {
            sprite.rect.x+=PLAYER_SPEED;
        }
        self.x_change-=PLAYER_SPEED;
        self.facing = 'left';
    }
    if keys[pygame.K_RIGHT] {
        for sprite in self.game.all_sprites {
            sprite.rect.x-=PLAYER_SPEED;
        }
        self.x_change+=PLAYER_SPEED;
        self.facing = 'right';
    }
    if keys[pygame.K_UP] {
        for sprite in self.game.all_sprites {
            sprite.rect.y+=PLAYER_SPEED;
        }
        self.y_change-=PLAYER_SPEED;
        self.facing = 'up';
    }
    if keys[pygame.K_DOWN] {
        for sprite in self.game.all_sprites {
            sprite.rect.y-=PLAYER_SPEED;
        }
        self.y_change+=PLAYER_SPEED;
        self.facing = 'down';
    }
}
# Player death when collidong with an enemy.

impl Player.collide_enemy {
    hits = pygame.sprite.spritecollide(self, self.game.enemies, False);
    if hits {
        self.kill();
        self.game.playing = False;
    }
}
# Anminate the player character.

impl Player.animate {
    down_animations = [self.game.character_spritesheet.get_sprite(3, 2, self.width, self.height), self.game.character_spritesheet.get_sprite(35, 2, self.width, self.height), self.game.character_spritesheet.get_sprite(68, 2, self.width, self.height)];
    up_animations = [self.game.character_spritesheet.get_sprite(3, 34, self.width, self.height), self.game.character_spritesheet.get_sprite(35, 34, self.width, self.height), self.game.character_spritesheet.get_sprite(68, 34, self.width, self.height)];
    left_animations = [self.game.character_spritesheet.get_sprite(3, 98, self.width, self.height), self.game.character_spritesheet.get_sprite(35, 98, self.width, self.height), self.game.character_spritesheet.get_sprite(68, 98, self.width, self.height)];
    right_animations = [self.game.character_spritesheet.get_sprite(3, 66, self.width, self.height), self.game.character_spritesheet.get_sprite(35, 66, self.width, self.height), self.game.character_spritesheet.get_sprite(68, 66, self.width, self.height)];
    if self.facing == "down" {
        if self.y_change == 0 {
            self.image = self.game.character_spritesheet.get_sprite(3, 2, self.width, self.height);
        } else {
            self.image = down_animations[math.floor(self.animation_loop)];
            self.animation_loop+=0.1;
            if self.animation_loop >= 3 {
                self.animation_loop = 1;
            }
        }
    }
    if self.facing == "up" {
        if self.y_change == 0 {
            self.image = self.game.character_spritesheet.get_sprite(3, 34, self.width, self.height);
        } else {
            self.image = up_animations[math.floor(self.animation_loop)];
            self.animation_loop+=0.1;
            if self.animation_loop >= 3 {
                self.animation_loop = 1;
            }
        }
    }
    if self.facing == "right" {
        if self.x_change == 0 {
            self.image = self.game.character_spritesheet.get_sprite(3, 66, self.width, self.height);
        } else {
            self.image = right_animations[math.floor(self.animation_loop)];
            self.animation_loop+=0.1;
            if self.animation_loop >= 3 {
                self.animation_loop = 1;
            }
        }
    }
    if self.facing == "left" {
        if self.x_change == 0 {
            self.image = self.game.character_spritesheet.get_sprite(3, 98, self.width, self.height);
        } else {
            self.image = left_animations[math.floor(self.animation_loop)];
            self.animation_loop+=0.1;
            if self.animation_loop >= 3 {
                self.animation_loop = 1;
            }
        }
    }
}
# Ability to collide with blocks without passing through.

impl Player.collide_blocks
(direction: str) {
    if direction == "x" {
        hits = pygame.sprite.spritecollide(self, self.game.blocks, False);
        if hits {
            if self.x_change > 0 {
                self.rect.x = hits[0].rect.left - self.rect.width;
                for sprite in self.game.all_sprites {
                    sprite.rect.x+=PLAYER_SPEED;
                }
            }
            if self.x_change < 0 {
                self.rect.x = hits[0].rect.right;
                for sprite in self.game.all_sprites {
                    sprite.rect.x-=PLAYER_SPEED;
                }
            }
        }
    }
    if direction == "y" {
        hits = pygame.sprite.spritecollide(self, self.game.blocks, False);
        if hits {
            if self.y_change > 0 {
                self.rect.y = hits[0].rect.top - self.rect.height;
                for sprite in self.game.all_sprites {
                    sprite.rect.y+=PLAYER_SPEED;
                }
            }
            if self.y_change < 0 {
                self.rect.y = hits[0].rect.bottom;
                for sprite in self.game.all_sprites {
                    sprite.rect.y-=PLAYER_SPEED;
                }
            }
        }
    }
}
```

#### `rpg_game/jac_impl/jac_impl_6/sprites.impl/spritesheet.impl.jac`

**File Info:**
- Lines: 12
- Non-empty lines: 11

**Code:**
```jac
impl Spritesheet.postinit
(file: str) {
    self.sheet = pygame.image.load(self.file).convert();
}

impl Spritesheet.get_sprite
(x: int, y: int, width: int, height: int) {
    sprite = pygame.Surface([width, height]);
    sprite.blit(self.sheet, (0, 0), (x, y, width, height));
    sprite.set_colorkey(BLACK);
    return sprite;
}
```

### utils

**JAC Files:**

#### `rpg_game/jac_impl/jac_impl_6/utils/level_manager.impl.jac`

**File Info:**
- Lines: 50
- Non-empty lines: 42

**Code:**
```jac
impl LevelManager.get_next_level {

        # Keeping Only the Last 3 Levels
        if len(self.prev_levels) > 3 {
            self.prev_levels.pop(0);
            self.prev_level_maps.pop(0);
        }
        # Generating the New Level
        new_level = self.create_next_level(
            self.prev_levels,
            self.current_difficulty
        );
        self.prev_levels.append(new_level);

        # Using the llm to fill un the attributes of Map_tiles object instance
        new_level_map = self.create_next_map(new_level);
        self.prev_level_maps.append(new_level_map);

        # Increasing the Difficulty for end of every 2 Levels
        if self.current_level % 2 == 0 {
            self.current_difficulty += 1;
        }

        new_map = self.get_map(new_level_map);
        return new_map;
}

impl LevelManager.get_map{
        map_tiles:list[list[str]] = [['.' for _ in range(map.level.width)] for _ in range(map.level.height)];

        for wall in map.walls {
            for x in range(wall.start_pos.x, wall.end_pos.x + 1) {
                for y in range(wall.start_pos.y, wall.end_pos.y + 1) {
                    map_tiles[y][x] = 'B';
                }
            }
        }

        for obs in map.small_obstacles {
            map_tiles[obs.y][obs.x] = 'B';
        }

        for enemy in map.enemies {
            map_tiles[enemy.y][enemy.x] = 'E';
        }
        map_tiles[map.player_pos.y][map.player_pos.x] = 'P';
        map_tiles:list[list[str]] = [['B'] + row + ['B'] for row in map_tiles];
        map_tiles:list[list[str]] = [['B' for _ in range(map.level.width + 2)]] + map_tiles + [['B' for _ in range(map.level.width + 2)]];
        return [''.join(row) for row in map_tiles];
}
```

#### `rpg_game/jac_impl/jac_impl_6/utils/level_manager.jac`

**File Info:**
- Lines: 50
- Non-empty lines: 39
- Features: Classes, Functions, Imports

**Code:**
```jac
import from byllm { Model }

glob llm = Model(model_name="gpt-4o", verbose=True);

obj Position {
    has x: int,
        y: int;
}

obj Wall {
    has start_pos: Position,
        end_pos: Position;
}

obj Map_tiles {
    has level: Level;
    has walls: list[Wall],
        small_obstacles: list[Position];
    has enemies: list[Position];
    has player_pos: Position;
}

obj Level {
    has name: int,
        difficulty: int,
        time: int;
    has width: int,
        height: int,
        num_wall: int,
        num_enemies: int;
}

obj LevelManager {
    has current_level: int = 0,
        current_difficulty: int = 1,
        prev_levels: list[Level] = [],
        prev_level_maps: list[Map_tiles] = [];

    def create_next_level(last_levels: list[Level], difficulty: int)
    -> Level by llm(temperature=0.8);

    def create_next_map(level: Level) -> Map_tiles by llm(temperature=0.8);

    '''Get the Next Level'''
    def get_next_level (current_level: int) -> tuple(Level, Map_tiles);

    '''Get the map of the level'''
    def get_map(map: Map_tiles) -> str;

}
```

### lib_mode

**Python Files:**

- `rpg_game/lib_mode/config.py`
- `rpg_game/lib_mode/main.py`
- `rpg_game/lib_mode/map.py`
- `rpg_game/lib_mode/sprites.py`

### python_impl

**Python Files:**

- `rpg_game/python_impl/config.py`
- `rpg_game/python_impl/main.py`
- `rpg_game/python_impl/map.py`
- `rpg_game/python_impl/sprites.py`

## Shopping_Cart

**Description files:**
- `shopping_cart/shopping_cart.md`

**JAC Files:**

#### `shopping_cart/main.impl.jac`

**File Info:**
- Lines: 107
- Non-empty lines: 90
- Features: Classes

**Code:**
```jac
impl get_base_price.get {
    report here.core_info.price;
}

impl calculate_discount.calculate {
    discount_amount = here.core_info.price * here.discount.discount_rate;
    report discount_amount;
}

impl calculate_tax.calculate {
    tax_rate = 0.08;
    tax_amount = here.core_info.price * tax_rate;
    report tax_amount;
}

impl calculate_final_price.calculate {
    base_price = here.core_info.price;
    discount_amount = base_price * here.discount.discount_rate;
    tax_amount = (base_price - discount_amount) * 0.08;
    final_price = base_price - discount_amount + tax_amount;
    report final_price;
}

impl calculate_shipping.calculate {
    base_shipping = 5.0;  # Base shipping cost
    weight_cost = here.shipping.weight * 0.5;  # $0.5 per unit weight
    
    if here.shipping.shipping_class == "express" {
        shipping_cost = (base_shipping + weight_cost) * 2;
    } elif here.shipping.shipping_class == "overnight" {
        shipping_cost = (base_shipping + weight_cost) * 3;
    } else {
        shipping_cost = base_shipping + weight_cost;
    }
    
    if here.shipping.is_fragile {
        shipping_cost += 10.0;  # Fragile handling fee
    }
    
    report shipping_cost;
}

impl is_eligible_for_free_shipping.is_eligible {
    # Free shipping for orders over $50 or lightweight items
    is_eligible = here.core_info.price >= 50.0 or here.shipping.weight <= 1.0;
    report is_eligible;
}

impl calculate_shipping_weight.calculate {
    total_weight = here.shipping.weight * here.core_info.quantity;
    report total_weight;
}

impl apply_coupon.apply {
    if self.coupon_code in here.discount.eligible_coupons {
        # Apply 15% additional discount for valid coupons
        coupon_discount = here.core_info.price * 0.15;
        report coupon_discount;
    } else {
        report 0.0;
    }
}

impl is_discount_applicable.is_discount {
    # Discount applicable if discount rate > 0 and item quantity > 0
    is_applicable = here.discount.discount_rate > 0 and here.core_info.quantity > 0;
    report is_applicable;
}

impl apply_bulk_discount.apply {
    if self.quantity >= here.discount.bulk_discount_threshold {
        bulk_discount = here.discount.bulk_discount_amount * self.quantity;
        report bulk_discount;
    } else {
        report 0.0;
    }
}

impl is_gift_eligible.is_gift {
    report here.gift_option.is_gift_eligible;
}

impl calculate_gift_wrap_fee.calculate {
    if here.gift_option.is_gift_eligible {
        report here.gift_option.gift_wrap_price;
    } else {
        report 0.0;
    }
}

impl get_category.get {
    report here.core_info.category;
}

impl get_tags.get {
    report here.core_info.tags;
}

impl get_inventory_status.get {
    if here.inventory.stock_level > 0 {
        report "In Stock";
    } elif here.inventory.backorder_allowed {
        report "Available for Backorder";
    } else {
        report "Out of Stock";
    }
}
```

#### `shopping_cart/main.jac`

**File Info:**
- Lines: 145
- Non-empty lines: 117
- Features: Classes, Nodes, Walkers, Imports

**Code:**
```jac

import datetime;

obj Metadata {
    has brand:str;
    has model_number:str;
    has release_date:str;
    has echo_friendly:bool;
    has digital_download:bool;
}

obj Gift {
    has is_gift_eligible:bool;
    has gift_wrap_price:float;
    has gift_message_allowed:bool;
}

obj Inventory {
    has stock_level:int;
    has backorder_allowed:bool;
    has estimated_restock_date:str;
}

obj Discounts {
    has discount_rate:float;
    has eligible_coupons:list[str];
    has bulk_discount_threshold:int;
    has bulk_discount_amount:float;
}

obj Shipping {
    has weight:float;
    has dimensions:tuple;
    has is_fragile:bool;
    has shipping_class:str;
    has origin_location:str;
}

obj CoreInfo {
    has id:str;
    has name:str;
    has category:str;
    has price:float;
    has quantity:int;
    has tags:list[str] = [];

}

obj Pricing {
    has tax_rate: float = 0;
    has price: float = 0;
    has discount_rate: float = 0;
    has final_price: float = 0;
}

node Item {
    has core_info:CoreInfo;
    has shipping:Shipping;
    has discount:Discounts;
    has inventory:Inventory;
    has gift_option:Gift;
    has metadata:Metadata;
    has pricing: Pricing;
}

walker create_item {
    has core_info:CoreInfo;
    has shipping:Shipping;
    has discount:Discounts;
    has inventory:Inventory;
    has gift_option:Gift;
    has metadata:Metadata;
    has tax_rate: float;

    can create with `root entry {
        final_price = self.core_info.price*(1-self.discount.discount_rate + self.tax_rate);
        pricing = Pricing(self.tax_rate,self.core_info.price, self.discount.discount_rate,final_price);
        root ++> Item(self.core_info, self.shipping, self.discount, self.inventory, self.gift_option, self.metadata, pricing);
        print([root -->]);
        report [root -->];
    }
}

walker get_base_price {
    can get with Item entry;
}

walker calculate_discount {
    can calculate with Item entry;
}

walker calculate_tax {
    can calculate with Item entry;
}

walker calculate_final_price {
    can calculate with Item entry;
}

walker calculate_shipping {
    can calculate with Item entry;
}

walker is_eligible_for_free_shipping {
    can is_eligible with Item entry;
}

walker calculate_shipping_weight {
    can calculate with Item entry;
}

walker apply_coupon {
    has coupon_code:str="";

    can apply with Item entry;
}

walker is_discount_applicable {
    can is_discount with Item entry;
}

walker apply_bulk_discount {
    has quantity:int;
    can apply with Item entry;
}

walker is_gift_eligible {
    can is_gift with Item entry;
}

walker calculate_gift_wrap_fee {
    can calculate with Item entry;
}

walker get_category {
    can get with Item entry;
}

walker get_tags {
    can get with Item entry;
}

walker get_inventory_status {
    can get with Item entry;
}
```

## Summary

- **Total Examples**: 12 categories
- **Total Files**: 305
- **JAC Files**: 150
- **Python Files**: 84
- **Documentation Files**: 71""";