# Jac Cloud & Deployment Cheat Sheet

## Scale-Agnostic Design

### Local to Cloud Transition
```jac
# Same code runs locally and in cloud
walker APIWalker {
    has request_data: dict;
    has response: dict = {};
    
    can process_request with entry {
        # Business logic - same for local and cloud
        self.response = self.handle_request(self.request_data);
    }
    
    def handle_request(data: dict) -> dict {
        return {"status": "processed", "data": data};
    }
}

# Local execution
with entry {
    walker = APIWalker(request_data={"user": "alice"}) spawn root;
    print(walker.response);
}

# Cloud deployment: jac serve filename.jac
# Automatically becomes HTTP API endpoint
```

### Cloud-Ready Walker Design
```jac
walker UserService {
    has user_id: str;
    has operation: str;
    has result: dict = {};
    
    can serve_request with entry {
        if self.operation == "get_profile" {
            self.result = self.get_user_profile(self.user_id);
        } elif self.operation == "update_profile" {
            self.result = self.update_user_profile(self.user_id);
        } else {
            self.result = {"error": "Unknown operation"};
        }
    }
    
    def get_user_profile(user_id: str) -> dict {
        # Database query logic
        return {"user_id": user_id, "name": "User Name"};
    }
    
    def update_user_profile(user_id: str) -> dict {
        # Update logic
        return {"status": "updated", "user_id": user_id};
    }
}
```

## Server Configuration

### Basic Server Setup
```bash
# Serve Jac application as web service
jac serve myapp.jac

# Serve on specific port
jac serve myapp.jac --port 8080

# Serve with specific host
jac serve myapp.jac --host 0.0.0.0 --port 8080

# Development mode with auto-reload
jac serve myapp.jac --reload
```

### Environment Configuration
```jac
# Environment-aware configuration
glob environment: str = "development";  # Override with ENV var
glob database_url: str = "sqlite:///local.db";
glob api_key: str = "";

# Load from environment
import {os} with "://" py "import os";

with entry {
    # Override from environment variables
    :g: environment, database_url, api_key;
    environment = os.getenv("JAC_ENV", environment);
    database_url = os.getenv("DATABASE_URL", database_url);
    api_key = os.getenv("API_KEY", api_key);
}
```

## HTTP API Patterns

### REST API Walker
```jac
walker UserAPI {
    has method: str;  # GET, POST, PUT, DELETE
    has user_id: str = "";
    has data: dict = {};
    has response: dict = {};
    has status_code: int = 200;
    
    can handle_request with entry {
        if self.method == "GET" and self.user_id {
            self.response = self.get_user(self.user_id);
        } elif self.method == "POST" {
            self.response = self.create_user(self.data);
            self.status_code = 201;
        } elif self.method == "PUT" and self.user_id {
            self.response = self.update_user(self.user_id, self.data);
        } elif self.method == "DELETE" and self.user_id {
            self.response = self.delete_user(self.user_id);
            self.status_code = 204;
        } else {
            self.response = {"error": "Invalid request"};
            self.status_code = 400;
        }
    }
    
    def get_user(user_id: str) -> dict {
        return {"id": user_id, "name": "John Doe"};
    }
    
    def create_user(data: dict) -> dict {
        return {"id": "new_id", "created": True, **data};
    }
    
    def update_user(user_id: str, data: dict) -> dict {
        return {"id": user_id, "updated": True, **data};
    }
    
    def delete_user(user_id: str) -> dict {
        return {"id": user_id, "deleted": True};
    }
}
```

### API Response Formatting
```jac
walker APIResponse {
    has data: dict = {};
    has success: bool = True;
    has message: str = "";
    has status_code: int = 200;
    
    can format_response with entry {
        response = {
            "success": self.success,
            "data": self.data,
            "message": self.message,
            "timestamp": self.get_timestamp()
        };
        
        # Set appropriate status code
        if not self.success {
            self.status_code = 400;
        }
    }
    
    def get_timestamp() -> str {
        import {datetime} with "://" py "from datetime import datetime";
        return datetime.now().isoformat();
    }
}
```

## Database Integration

### Database Walker Pattern
```jac
walker DatabaseService {
    has connection_string: str;
    has query: str = "";
    has params: dict = {};
    has results: list = [];
    
    can execute_query with entry {
        # Database connection and query execution
        conn = self.get_connection();
        self.results = self.run_query(conn, self.query, self.params);
        self.close_connection(conn);
    }
    
    def get_connection() {
        # Database connection logic
        import {sqlite3} with "://" py "import sqlite3";
        return sqlite3.connect(self.connection_string);
    }
    
    def run_query(conn, query: str, params: dict) -> list {
        cursor = conn.cursor();
        cursor.execute(query, params);
        return cursor.fetchall();
    }
    
    def close_connection(conn) {
        conn.close();
    }
}
```

### ORM-Style Data Access
```jac
node DataModel {
    has table_name: str;
    has fields: dict = {};
    
    def save() -> bool {
        # Save to database
        db_service = DatabaseService(
            connection_string="sqlite:///app.db",
            query=f"INSERT INTO {self.table_name} VALUES (?)",
            params=self.fields
        ) spawn root;
        return len(db_service.results) > 0;
    }
    
    def load(id: str) -> dict {
        # Load from database
        db_service = DatabaseService(
            connection_string="sqlite:///app.db",
            query=f"SELECT * FROM {self.table_name} WHERE id = ?",
            params={"id": id}
        ) spawn root;
        return db_service.results[0] if db_service.results else {};
    }
}

node User(DataModel) {
    has id: str;
    has name: str;
    has email: str;
    
    def init() {
        self.table_name = "users";
        self.fields = {"id": self.id, "name": self.name, "email": self.email};
    }
}
```

## Middleware and Authentication

### Authentication Walker
```jac
walker AuthMiddleware {
    has token: str;
    has user_id: str = "";
    has is_authenticated: bool = False;
    has permissions: list[str] = [];
    
    can authenticate with entry {
        if self.validate_token(self.token) {
            user_data = self.get_user_from_token(self.token);
            self.user_id = user_data.get("user_id", "");
            self.permissions = user_data.get("permissions", []);
            self.is_authenticated = True;
        }
    }
    
    def validate_token(token: str) -> bool {
        # Token validation logic
        return len(token) > 10;  # Simplified validation
    }
    
    def get_user_from_token(token: str) -> dict {
        # Decode token and get user data
        return {"user_id": "user123", "permissions": ["read", "write"]};
    }
    
    def has_permission(permission: str) -> bool {
        return permission in self.permissions;
    }
}
```

### Protected Route Pattern
```jac
walker ProtectedRoute {
    has auth: AuthMiddleware;
    has required_permission: str;
    has response: dict = {};
    
    can handle_protected_request with entry {
        if not self.auth.is_authenticated {
            self.response = {"error": "Authentication required"};
            return;
        }
        
        if not self.auth.has_permission(self.required_permission) {
            self.response = {"error": "Insufficient permissions"};
            return;
        }
        
        # Proceed with protected operation
        self.response = self.execute_protected_operation();
    }
    
    def execute_protected_operation() -> dict {
        return {"data": "Protected data", "user": self.auth.user_id};
    }
}
```

## Async Operations and Background Tasks

### Async Walker Pattern
```jac
walker AsyncWorker {
    has task_id: str;
    has status: str = "pending";
    has result: dict = {};
    has background: bool = True;
    
    can execute_async with entry {
        self.status = "running";
        
        # Long-running operation
        self.result = self.process_long_task();
        
        self.status = "completed";
        self.notify_completion();
    }
    
    def process_long_task() -> dict {
        # Simulate long-running task
        import {time} with "://" py "import time";
        time.sleep(5);  # 5 second task
        return {"processed": True, "items": 100};
    }
    
    def notify_completion() {
        # Send notification or update database
        print(f"Task {self.task_id} completed");
    }
}
```

### Task Queue Pattern
```jac
node TaskQueue {
    has pending_tasks: list[dict] = [];
    has running_tasks: list[str] = [];
    has completed_tasks: list[str] = [];
    
    can schedule_task with TaskScheduler entry {
        task = {
            "id": here.task_id,
            "type": here.task_type,
            "data": here.task_data,
            "priority": here.priority
        };
        self.pending_tasks.append(task);
    }
    
    can process_tasks with TaskProcessor entry {
        if self.pending_tasks {
            task = self.pending_tasks.pop(0);  # FIFO
            self.running_tasks.append(task["id"]);
            
            # Spawn async worker
            worker = AsyncWorker(task_id=task["id"]) spawn here;
            
            # Move to completed when done
            self.completed_tasks.append(task["id"]);
            self.running_tasks.remove(task["id"]);
        }
    }
}
```

## WebSocket Support

### Real-time Communication
```jac
walker WebSocketHandler {
    has connection_id: str;
    has message_type: str;
    has payload: dict;
    has response: dict = {};
    
    can handle_websocket with entry {
        if self.message_type == "chat_message" {
            self.response = self.handle_chat_message(self.payload);
        } elif self.message_type == "status_update" {
            self.response = self.handle_status_update(self.payload);
        } else {
            self.response = {"error": "Unknown message type"};
        }
        
        # Broadcast to other connections if needed
        self.broadcast_to_others(self.response);
    }
    
    def handle_chat_message(payload: dict) -> dict {
        return {
            "type": "chat_message",
            "from": payload.get("user"),
            "message": payload.get("text"),
            "timestamp": self.get_timestamp()
        };
    }
    
    def handle_status_update(payload: dict) -> dict {
        return {
            "type": "status_update",
            "user": payload.get("user"),
            "status": payload.get("status")
        };
    }
    
    def broadcast_to_others(message: dict) {
        # Broadcast logic to other connected clients
        print(f"Broadcasting: {message}");
    }
    
    def get_timestamp() -> str {
        import {datetime} with "://" py "from datetime import datetime";
        return datetime.now().isoformat();
    }
}
```

## Monitoring and Logging

### Logging Walker
```jac
walker Logger {
    has level: str = "INFO";  # DEBUG, INFO, WARN, ERROR
    has message: str;
    has context: dict = {};
    
    can log_message with entry {
        timestamp = self.get_timestamp();
        log_entry = {
            "timestamp": timestamp,
            "level": self.level,
            "message": self.message,
            "context": self.context
        };
        
        self.write_log(log_entry);
    }
    
    def write_log(entry: dict) {
        # Write to file, database, or external service
        import {json} with "://" py "import json";
        print(json.dumps(entry));
    }
    
    def get_timestamp() -> str {
        import {datetime} with "://" py "from datetime import datetime";
        return datetime.now().isoformat();
    }
}

# Usage in other walkers
walker BusinessLogic {
    can process_with_logging with entry {
        # Log start
        Logger(level="INFO", message="Processing started", context={"node": here}) spawn root;
        
        try {
            result = self.do_processing();
            # Log success
            Logger(level="INFO", message="Processing completed", context={"result": result}) spawn root;
        } except Exception as e {
            # Log error
            Logger(level="ERROR", message="Processing failed", context={"error": str(e)}) spawn root;
        }
    }
    
    def do_processing() -> str {
        return "Processed successfully";
    }
}
```

## Health Checks and Monitoring

### Health Check Walker
```jac
walker HealthCheck {
    has checks: list[str] = ["database", "cache", "external_api"];
    has results: dict = {};
    has overall_status: str = "healthy";
    
    can perform_health_check with entry {
        for check in self.checks {
            try {
                status = self.check_component(check);
                self.results[check] = {"status": "healthy", "response_time": status};
            } except Exception as e {
                self.results[check] = {"status": "unhealthy", "error": str(e)};
                self.overall_status = "unhealthy";
            }
        }
    }
    
    def check_component(component: str) -> float {
        # Simulate health check
        import {time, random} with "://" py "import time, random";
        time.sleep(random.uniform(0.1, 0.5));  # Simulate check time
        return random.uniform(0.1, 0.5);
    }
}
```
