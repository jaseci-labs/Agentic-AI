import os;
import pymongo;
import from pymongo { MongoClient }
import from datetime { datetime }
import from typing { List, Dict, Optional }
import logging;
import from dotenv { load_dotenv }

with entry {
    load_dotenv(override=True);
    logging.basicConfig(level=logging.INFO);
    logger = logging.getLogger(__name__);
    _database_instance = None;
}

obj MongoDB {
    has client: object = None;
    has db: object = None;
    has sessions: object = None;
    has messages: object = None;
    has users: object = None;

    def postinit {
        self.connect();
    }
    def connect {
        try {
            mongo_uri = os.getenv("DATABASE_HOST");
            if not mongo_uri {
                logger.warning("DATABASE_HOST not found! Falling back to localhost...");
                mongo_uri = "mongodb://localhost:27017/";
            }
            db_name = os.getenv("DATABASE_NAME", "jac_gpt");
            self.client = MongoClient(mongo_uri);
            self.db = self.client[db_name];
            self.sessions = self.db.sessions;
            self.messages = self.db.messages;
            self.users = self.db.users;
            self.client.admin.command("ping");
            logger.info(f"Connected to MongoDB: { db_name }");
        } except Exception as e {
            logger.error(f"Failed to connect to MongoDB: { e }");
            raise ;
        }
    }
    def create_session(session_id: str, user_email: str = "") -> <>dict {
        try {
            session_data = {
                "_id": session_id,
                "user_email": user_email,
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow(),
                "status": "active"
            };
            existing = self.sessions.find_one({"_id": session_id});
            if existing {
                logger.info(f"Session {session_id} already exists");
                # Update user_email if provided and not already set
                if user_email and not existing.get("user_email") {
                    self.sessions.update_one(
                        {"_id": session_id},
                        {"$set": {"user_email": user_email, "updated_at": datetime.utcnow()}}
                    );
                }
                return existing;
            }
            result = self.sessions.insert_one(session_data);
            logger.info(f"Created new session: {session_id} for user: {user_email}");
            return session_data;
        } except Exception as e {
            logger.error(f"Error creating session {session_id}: {e}");
            return None;
        }
    }
    def get_session(session_id: str) -> <>dict {
        try {
            session = self.sessions.find_one({"_id" : session_id });
            if session {
                logger.info(f"Found session: { session_id }");
            } else {
                logger.warning(f"Session not found: { session_id }");
            }
            return session;
        } except Exception as e {
            logger.error(f"Error getting session { session_id }: { e }");
            return None;
        }
    }
    def save_message(session_id: str, role: str, content: str) -> bool {
        try {
            message_data =

                {"session_id" : session_id , "role" : role , "content" : content , "timestamp" : datetime.utcnow() };
            result = self.messages.insert_one(message_data);
            update_result =
                self.sessions.update_one(
                    {"_id" : session_id },
                    {"$set" : {"updated_at" : datetime.utcnow() } }
                );
            logger.info(
                f"Saved { role } message for session { session_id }"
            );
            return True;
        } except Exception as e {
            logger.error(
                f"Error saving message for session { session_id }: { e }"
            );
            return False;
        }
    }
    def get_chat_history(session_id: str, limit: int = 50) -> List[Dict] {
        try {
            messages =
                <>list(
                    self.messages.find({"session_id" : session_id }).sort(
                        "timestamp",
                        1
                    ).limit(
                        limit
                    )
                );
            chat_history = [];
            for msg in messages {
                chat_history.append(
                    {"role" : msg["role"] , "content" : msg["content"] }
                );
            }
            return chat_history;
        } except Exception as e {
            logger.error(
                f"Error retrieving chat history for session { session_id }: { e }"
            );
            return [];
        }
    }
    def get_session_stats(session_id: str) -> Dict {
        try {
            session = self.get_session(session_id);
            if not session {
                return {};
            }
            message_count =
                self.messages.count_documents({"session_id" : session_id });
            user_messages =
                self.messages.count_documents(
                    {"session_id" : session_id , "role" : "user" }
                );
            assistant_messages =
                self.messages.count_documents(
                    {"session_id" : session_id , "role" : "assistant" }
                );
            return
            {"session_id" : session_id , "total_messages" : message_count , "user_messages" : user_messages , "assistant_messages" : assistant_messages , "created_at" : session["created_at"] , "updated_at" : session["updated_at"] };
        } except Exception as e {
            logger.error(
                f"Error getting session stats for { session_id }: { e }"
            );
            return {};
        }
    }
    def close_session(session_id: str) {
        try {
            self.sessions.update_one(
                {"_id" : session_id },

                {"$set" :
                {"status" : "closed" , "updated_at" : datetime.utcnow() } }
            );
            logger.info(f"Closed session: { session_id }");
        } except Exception as e {
            logger.error(f"Error closing session { session_id }: { e }");
        }
    }
    
    def create_or_update_user(email: str, password: str, name: str = "", role: str = "user") -> <>dict {
        try {
            existing_user = self.users.find_one({"email": email});
            if existing_user {
                logger.info(f"User { email } already exists");
                return existing_user;
            }
            
            user_data = {
                "email": email,
                "password": password,  # In real app, this should be hashed
                "name": name,
                "role": role,
                "created_at": datetime.utcnow(),
                "last_login": datetime.utcnow()
            };
            
            result = self.users.insert_one(user_data);
            user_data["_id"] = result.inserted_id;
            logger.info(f"Created new user: { email }");
            return user_data;
        } except Exception as e {
            logger.error(f"Error creating user { email }: { e }");
            return None;
        }
    }
    
    def get_user_by_email(email: str) -> <>dict {
        try {
            user = self.users.find_one({"email": email});
            return user;
        } except Exception as e {
            logger.error(f"Error getting user { email }: { e }");
            return None;
        }
    }
    
    def update_user_login(email: str) -> bool {
        try {
            self.users.update_one(
                {"email": email},
                {"$set": {"last_login": datetime.utcnow()}}
            );
            return True;
        } except Exception as e {
            logger.error(f"Error updating login for { email }: { e }");
            return False;
        }
    }
    
    def get_all_users(limit: int = 100) -> List[Dict] {
        try {
            users = <>list(
                self.users.find({}, {"password": 0}).limit(limit)
            );
            return users;
        } except Exception as e {
            logger.error(f"Error getting all users: { e }");
            return [];
        }
    }
    
    def get_all_sessions_with_user_info(limit: int = 100) -> List[Dict] {
        try {
            # Get all sessions
            sessions = <>list(
                self.sessions.find({}).sort("updated_at", -1).limit(limit)
            );
            
            # For each session, get basic stats and user info if available
            enriched_sessions = [];
            for session in sessions {
                session_id = session["_id"];
                
                # Get message count
                message_count = self.messages.count_documents({"session_id": session_id});
                
                # Get first message to try to identify user (if any)
                first_message = self.messages.find_one(
                    {"session_id": session_id, "role": "user"},
                    sort=[("timestamp", 1)]
                );
                
                session_info = {
                    "session_id": session_id,
                    "created_at": session["created_at"],
                    "updated_at": session["updated_at"],
                    "status": session.get("status", "active"),
                    "message_count": message_count,
                    "first_message": first_message["content"] if first_message else None,
                    "first_message_time": first_message["timestamp"] if first_message else None
                };
                
                enriched_sessions.append(session_info);
            }
            
            return enriched_sessions;
        } except Exception as e {
            logger.error(f"Error getting all sessions: { e }");
            return [];
        }
    }
    
    def get_all_messages_by_session(session_id: str) -> List[Dict] {
        try {
            messages = <>list(
                self.messages.find({"session_id": session_id}).sort("timestamp", 1)
            );
            return messages;
        } except Exception as e {
            logger.error(f"Error getting messages for session { session_id }: { e }");
            return [];
        }
    }
    
    def get_user_sessions(email: str) -> List[Dict] {
        try {
            # Since sessions don't directly link to users, we'll need to find sessions
            # that contain messages from this email if they identify themselves
            # This is a simplified approach - in a real app you'd link sessions to users
            user_sessions = [];
            
            # Get all sessions and check if they contain messages that might identify the user
            all_sessions = <>list(self.sessions.find({}));
            
            for session in all_sessions {
                session_id = session["_id"];
                # Check if any message in this session mentions the user email
                # This is a basic approach - you might want to improve this
                messages_with_email = self.messages.find({
                    "session_id": session_id,
                    "content": {"$regex": email, "$options": "i"}
                }).limit(1);
                
                if messages_with_email.count() > 0 {
                    session_stats = self.get_session_stats(session_id);
                    user_sessions.append(session_stats);
                }
            }
            
            return user_sessions;
        } except Exception as e {
            logger.error(f"Error getting sessions for user { email }: { e }");
            return [];
        }
    }
    
    def create_user_profile(email: str, name: str, role: str = "user") -> bool {
        try {
            profile_data = {
                "_id": email,
                "email": email,
                "name": name,
                "role": role,
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow()
            };
            
            # Check if profile already exists
            existing = self.users.find_one({"_id": email});
            if existing {
                # Update existing profile
                self.users.update_one(
                    {"_id": email},
                    {"$set": {"name": name, "role": role, "updated_at": datetime.utcnow()}}
                );
                logger.info(f"Updated user profile for: {email}");
            } else {
                # Create new profile
                self.users.insert_one(profile_data);
                logger.info(f"Created user profile for: {email} with role: {role}");
            }
            
            return True;
        } except Exception as e {
            logger.error(f"Error creating user profile for {email}: {e}");
            return False;
        }
    }
    
    def get_user_profile(email: str) -> <>dict {
        try {
            profile = self.users.find_one({"_id": email});
            if profile {
                logger.info(f"Found user profile: {email}");
                return {
                    "email": profile["email"],
                    "name": profile["name"],
                    "role": profile["role"],
                    "created_at": profile.get("created_at"),
                    "updated_at": profile.get("updated_at")
                };
            } else {
                logger.warning(f"User profile not found: {email}");
                return None;
            }
        } except Exception as e {
            logger.error(f"Error getting user profile {email}: {e}");
            return None;
        }
    }
    
    def get_all_users() -> List[Dict] {
        try {
            users = <>list(self.users.find({}));
            user_list = [];
            for user in users {
                user_list.append({
                    "email": user["email"],
                    "name": user["name"],
                    "role": user["role"],
                    "created_at": user.get("created_at"),
                    "updated_at": user.get("updated_at")
                });
            }
            logger.info(f"Retrieved {len(user_list)} users");
            return user_list;
        } except Exception as e {
            logger.error(f"Error getting all users: {e}");
            return [];
        }
    }
    
    def get_all_sessions_with_users() -> List[Dict] {
        try {
            sessions = <>list(self.sessions.find({}));
            session_list = [];
            for session in sessions {
                session_info = {
                    "session_id": session["_id"],
                    "user_email": session.get("user_email", ""),
                    "created_at": session.get("created_at"),
                    "updated_at": session.get("updated_at"),
                    "status": session.get("status", "unknown"),
                    "message_count": self.messages.count_documents({"session_id": session["_id"]})
                };
                session_list.append(session_info);
            }
            logger.info(f"Retrieved {len(session_list)} sessions");
            return session_list;
        } except Exception as e {
            logger.error(f"Error getting all sessions: {e}");
            return [];
        }
    }
    
    def close_connection {
        if self.client {
            self.client.close();
            logger.info("MongoDB connection closed");
        }
    }
}




def get_database() -> MongoDB {
    global _database_instance;
    if (_database_instance is None) {
        _database_instance = MongoDB();
    } else {
        logger.info("Using existing database instance");
    }
    return _database_instance;
}
def close_database() {
    global _db_instance;
    if _db_instance {
        _db_instance.close_connection();
        _db_instance = None;
    }
}