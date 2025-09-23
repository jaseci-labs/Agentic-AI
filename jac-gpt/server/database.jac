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
    has users: object = None;  # This will point to JAC Cloud's built-in 'user' collection
    has user_locations: object = None;  # Separate collection for user location data

    def postinit {
        self.connect();
    }
    def connect {
        try {
            mongo_uri = os.getenv("DATABASE_HOST");
            if not mongo_uri {
                print("DATABASE_HOST not found! Falling back to localhost...");
                mongo_uri = "mongodb://localhost:27017/";
            }
            db_name = os.getenv("DATABASE_NAME", "jaseci");
            
            self.client = MongoClient(mongo_uri);
            self.db = self.client[db_name];
            self.sessions = self.db.sessions;
            self.messages = self.db.messages;
            self.users = self.db.user;  # Use JAC Cloud's built-in 'user' collection
            self.user_locations = self.db.user_locations;  # Separate collection for location data
            self.client.admin.command("ping");
            print(f"Connected to MongoDB: { db_name }");
        } except Exception as e {
            print(f"Failed to connect to MongoDB: { e }");
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
            return session_data;
        } except Exception as e {
            print(f"Error creating session {session_id}: {e}");
            return None;
        }
    }
    def get_session(session_id: str) -> <>dict {
        try {
            session = self.sessions.find_one({"_id" : session_id });
            if session {
                print(f"Found session: { session_id }");
            } else {
                print(f"Session not found: { session_id }");
            }
            return session;
        } except Exception as e {
            print(f"Error getting session { session_id }: { e }");
            return None;
        }
    }
    def save_message(session_id: str, role: str, content: str) -> bool {
        try {
            message_data = {"session_id" : session_id , "role" : role , "content" : content , "timestamp" : datetime.utcnow() };
            result = self.messages.insert_one(message_data);
            update_result =
                self.sessions.update_one(
                    {"_id" : session_id },
                    {"$set" : {"updated_at" : datetime.utcnow() } }
                );
            print(
                f"Saved { role } message for session { session_id }"
            );
            return True;
        } except Exception as e {
            print(
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
            print(
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
            print(
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
            print(f"Closed session: { session_id }");
        } except Exception as e {
            print(f"Error closing session { session_id }: { e }");
        }
    }
    
    # User management methods removed - now using JAC Cloud's built-in user management
    # The built-in /user/register and /user/login endpoints handle user creation and authentication
    # User data is automatically stored in the 'user' collection by JAC Cloud
    
    # def get_all_users(limit: int = 100) -> List[Dict] {
    #     try {
    #         # Query JAC Cloud's built-in user collection
    #         # JAC Cloud users have different structure than custom users
    #         users = <>list(
    #             self.users.find({}, {"password": 0}).limit(limit)
    #         );
    #         return users;
    #     } except Exception as e {
    #         logger.error(f"Error getting all users: { e }");
    #         return [];
    #     }
    # }
    
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
            print(f"Error getting all sessions: { e }");
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
            print(f"Error getting messages for session { session_id }: { e }");
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
            print(f"Error getting sessions for user { email }: { e }");
            return [];
        }
    }
    
    def create_user_profile(email: str, name: str = "", role: str = "user") -> bool {
        try {
            # JAC Cloud automatically creates users in the 'user' collection
            # We should avoid modifying the user collection directly to prevent schema conflicts
            # JAC Cloud handles user creation and management automatically
            
            # Check if user exists in JAC Cloud's user collection
            existing_user = self.users.find_one({"email": email});
            if existing_user {
                print(f"User profile found for: {email} (admin status managed by JAC Cloud)");
                
                # We can only update very specific fields that JAC Cloud allows
                # Avoid adding any custom fields like updated_at, role, etc.
                # Only update is_admin if it's the admin email and not already set
                if email == "admin.jacgpt@jaseci.org" and not existing_user.get("is_admin", False) {
                    try {
                        self.users.update_one(
                            {"email": email},
                            {"$set": {"is_admin": True}}
                        );
                        print(f"Set admin privileges for: {email}");
                    } except Exception as update_e {
                        print(f"Could not update admin status for {email}: {update_e}");
                    }
                }
            } else {
                print(f"User {email} not found in JAC Cloud user collection");
                return False;
            }
            
            return True;
        } except Exception as e {
            print(f"Error accessing user profile for {email}: {e}");
            return False;
        }
    }
    
    def get_user_profile(email: str) -> <>dict {
        try {
            # Query JAC Cloud's user collection
            profile = self.users.find_one({"email": email});
            if profile {
                print(f"Found user profile: {email}");
                
                is_admin = profile.get("is_admin", False) or email == "admin.jacgpt@jaseci.org";
                # Determine role based on is_admin flag instead of role field
                role = "admin" if is_admin else "user";
                
                # Ensure database is updated with correct admin status if needed
                if email == "admin.jacgpt@jaseci.org" and not profile.get("is_admin", False) {
                    try {
                        self.users.update_one(
                            {"email": email},
                            {"$set": {"is_admin": True}}
                        );
                        print(f"Updated admin privileges for {email}");
                        is_admin = True;
                        role = "admin";
                    } except Exception as update_e {
                        print(f"Could not update admin status for {email}: {update_e}");
                    }
                }
                
                return {
                    "email": profile["email"],
                    "name": profile.get("name", ""),  # May not exist for older users
                    "role": role,  # Computed from is_admin, not stored directly
                    "is_admin": is_admin,
                    "is_activated": profile.get("is_activated", True),
                    "created_at": profile.get("created_at"),
                    "updated_at": profile.get("updated_at")
                };
            } else {
                print(f"User profile not found: {email}");
                return None;
            }
        } except Exception as e {
            print(f"Error getting user profile {email}: {e}");
            return None;
        }
    }
    
    def get_all_users() -> List[Dict] {
        try {
            # Query JAC Cloud's user collection
            users = <>list(self.users.find({}));
            user_list = [];
            for user in users {
                email = user["email"];
                is_admin = user.get("is_admin", False) or email == "admin.jacgpt@jaseci.org";
                role = "admin" if is_admin else "user";
                
                # Get location data from separate user_locations collection
                location_info = self.get_user_location_full(email);
                location = location_info.get("location", {}) if location_info else {};
                location_updated_at = location_info.get("location_updated_at") if location_info else None;
                
                user_list.append({
                    "email": email,
                    "name": user.get("name", ""),  # May not exist for all users
                    "role": role,  # Computed from is_admin, not stored directly
                    "is_admin": is_admin,
                    "is_activated": user.get("is_activated", True),
                    "location": location,  # Location data from user_locations collection
                    "created_at": user.get("created_at"),
                    "updated_at": user.get("updated_at"),
                    "location_updated_at": location_updated_at
                });
            }
            print(f"Retrieved {len(user_list)} users from JAC Cloud user collection");
            return user_list;
        } except Exception as e {
            print(f"Error getting all users: {e}");
            return [];
        }
    }
    
    def save_user_location(email: str, location: dict) -> bool {
        try {
            # Save location data to separate collection instead of modifying user document
            location_data = {
                "email": email,
                "location": {
                    "latitude": location.get("latitude"),
                    "longitude": location.get("longitude"),
                    "city": location.get("city", ""),
                    "country": location.get("country", ""),
                    "ip": location.get("ip", "")
                },
                "location_updated_at": datetime.utcnow()
            };
            
            # Use upsert to update existing or create new location record
            result = self.user_locations.update_one(
                {"email": email},
                {"$set": location_data, "$setOnInsert": {"created_at": datetime.utcnow()}},
                upsert=True
            );
            
            if result.upserted_id or result.modified_count > 0 {
                print(f"Location saved for user: {email}");
                return True;
            } else {
                print(f"Failed to save location for user: {email}");
                return False;
            }
        } except Exception as e {
            print(f"Error saving location for {email}: {e}");
            return False;
        }
    }
    
    def get_user_location(email: str) -> Optional[dict] {
        try {
            location_doc = self.user_locations.find_one({"email": email});
            if location_doc {
                return location_doc.get("location", {});
            }
            return None;
        } except Exception as e {
            print(f"Error getting location for {email}: {e}");
            return None;
        }
    }
    
    def get_user_location_full(email: str) -> Optional[dict] {
        try {
            print(f"Looking for location data for email: {email}");
            location_doc = self.user_locations.find_one({"email": email});
            print(f"Found location document: {location_doc}");
            if location_doc {
                result = {
                    "location": location_doc.get("location", {}),
                    "location_updated_at": location_doc.get("location_updated_at")
                };
                print(f"Returning location data: {result}");
                return result;
            }
            print(f"No location document found for email: {email}");
            return None;
        } except Exception as e {
            print(f"Error getting full location data for {email}: {e}");
            return None;
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
            print(f"Retrieved {len(session_list)} sessions");
            return session_list;
        } except Exception as e {
            print(f"Error getting all sessions: {e}");
            return [];
        }
    }
    
    def close_connection {
        if self.client {
            self.client.close();
            print("MongoDB connection closed");
        }
    }
}

def get_database() -> MongoDB {
    global _database_instance;
    if (_database_instance is None) {
        _database_instance = MongoDB();
    } else {
        print("Using existing database instance");
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