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
"MongoDB connection and operations handler for chat sessions."
class MongoDB {
    "Initialize MongoDB connection."
    def __init__(self: MongoDB) {
        self.client = None;
        self.db = None;
        self.sessions_collection = None;
        self.messages_collection = None;
        self.connect();
    }
    "Establish connection to MongoDB."
    def connect(self: MongoDB) {
        try {
            mongo_uri = os.getenv("MONGODB_URI");
            if not mongo_uri {
                logger.warning("MONGODB_URI not found! Falling back to localhost...");
                mongo_uri = "mongodb://localhost:27017/";
            }
            db_name = os.getenv("MONGODB_DATABASE", "jac_gpt");
            self.client = MongoClient(mongo_uri);
            self.db = self.client[db_name];
            self.sessions = self.db.sessions;
            self.messages = self.db.messages;
            self.client.admin.command("ping");
            logger.info(f"Connected to MongoDB: { db_name }");
        } except Exception as e {
            logger.error(f"Failed to connect to MongoDB: { e }");
            raise ;
        }
    }
    "Create a new session in the database."
    def create_session(self: MongoDB, session_id: str) -> <>dict {
        try {
            session_data =

                {"_id" : session_id , "created_at" : datetime.utcnow() , "updated_at" : datetime.utcnow() , "status" : "active" };
            existing = self.sessions.find_one({"_id" : session_id });
            if existing {
                logger.info(f"Session { session_id } already exists");
                return existing;
            }
            result = self.sessions.insert_one(session_data);
            logger.info(f"Created new session: { session_id }");
            return session_data;
        } except Exception as e {
            logger.error(f"Error creating session { session_id }: { e }");
            return None;
        }
    }
    "Get session data from the database."
    def get_session(self: MongoDB, session_id: str) -> <>dict {
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
    "Save a message to the database."
    def save_message(self: MongoDB, session_id: str, role: str, content: str) -> bool {
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
    "Retrieve chat history for a session."
    def get_chat_history(self: MongoDB, session_id: str, limit: int = 50) -> List[Dict] {
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
    "Get statistics for a session."
    def get_session_stats(self: MongoDB, session_id: str) -> Dict {
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
    "Mark a session as closed."
    def close_session(self: MongoDB, session_id: str) {
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
    "Close the MongoDB connection."
    def close_connection(self: MongoDB) {
        if self.client {
            self.client.close();
            logger.info("MongoDB connection closed");
        }
    }
}
with entry {
    _db_instance = None;
}
'"""Get database instance."""'
def get_database()  -> MongoDB {
    global _database_instance;
    if (_database_instance is None) {
        _database_instance = MongoDB();
    } else {
        logger.info("Using existing database instance");
    }
    return _database_instance;
}
'"""Close the global database connection."""'
def close_database() {
    global _db_instance;
    if _db_instance {
        _db_instance.close_connection();
        _db_instance = None;
    }
}