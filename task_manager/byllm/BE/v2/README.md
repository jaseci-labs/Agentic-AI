# byLLM Task Manager v2

>This version is a significant improvement over v1, focusing on modularity, scalability, and maintainability.

## Improvements over v1

- **Modular Structure:** Code is split into interface (`main.jac`), implementation (`main.impl.jac`), and shared core (`agent_core.jac`).
- **Abstraction:** Uses abstract base classes and separates logic from interface, making it easier to extend and maintain.
- **Better Routing & Session Management:** Moves these concerns to `agent_core.jac` for cleaner code.
- **Scalability:** Designed for larger projects; new features and nodes can be added easily.

## Main Files
- `main.jac` - Defines agent nodes and their interfaces (TaskHandling, EmailHandling, GeneralChat)
- `main.impl.jac` - Implements node methods (task management, email sending, etc.)
- `agent_core.jac` - Shared components (Memory, Session, Toolbox base class, routing logic)
- `utils.jac` - Utility functions
- `.env` - Environment variables

See `main.jac` for how the agent is started and refer to other files for implementation details.

---

-> Visit v1 [here](../v1/README.md).