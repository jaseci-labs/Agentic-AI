"""
Stores and manages an agent's memory.
"""
obj memory {
    has items: list = [];  # List of memory entries

    """
    Adds an item to memory.
    """
    def append(item: dict) -> None {
        self.items.append(item);
    }

    """
    Gets recent memory items.
    """
    def get_context(k: int = 20) -> list {
        return self.items[-k:];
    }

    """
    Takes a snapshot of memory.
    """
    def snapshot() -> dict {
        return {"items": self.items};
    }
}
