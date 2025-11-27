import from byllm.lib { Model }

glob llm = Model(model_name="gpt-4o");

# Backend Walkers
walker learn_topic {
    has topic: str;
    has level: str = "beginner";
    
    def explain_topic(topic: str, level: str) -> str by llm(
        reason=True,
        temperature=0.7,
        incl_info=(
            "You are an expert teacher. Explain the topic clearly and engagingly. "
            "Adjust the complexity based on the level (beginner, intermediate, advanced). "
            "Use analogies, examples, and break down complex concepts. "
            "Format your response with sections: Overview, Key Concepts, Examples, and Summary."
        )
    );
    
    can learn with `root entry {
        explanation = self.explain_topic(topic=self.topic, level=self.level);
        report {
            "topic": self.topic,
            "level": self.level,
            "explanation": explanation
        };
    }
}

walker generate_quiz {
    has topic: str;
    has difficulty: str = "medium";
    has num_questions: int = 5;
    
    def create_quiz(topic: str, difficulty: str, num_questions: int) -> list by llm(
        method="Chain of Thought",
        temperature=0.8,
        incl_info=(
            "You are a quiz generator. Create multiple choice questions about the topic. "
            "Return ONLY a JSON array of questions with question, options (4 choices), and correct (index 0-3). "
            "Create exactly 5 questions at the given difficulty level."
        )
    );
    
    can generate with `root entry {
        quiz_data = self.create_quiz(
            topic=self.topic,
            difficulty=self.difficulty,
            num_questions=self.num_questions
        );
        report {
            "topic": self.topic,
            "difficulty": self.difficulty,
            "questions": quiz_data
        };
    }
}

walker chat_tutor {
    has message: str;
    has context: list[dict] = [];
    
    def respond_to_question(message: str, conversation_history: str) -> str by llm(
        reason=True,
        temperature=0.7,
        incl_info=(
            "You are a friendly and knowledgeable AI tutor. Help students learn by: "
            "1. Answering questions clearly and accurately "
            "2. Encouraging critical thinking with follow-up questions "
            "3. Providing examples and analogies "
            "4. Being patient and supportive "
            "5. Breaking down complex topics into simpler parts. "
            "Previous conversation context is provided for continuity."
        )
    );
    
    can chat with `root entry {
        history_text = "\n".join([f"{msg['role']}: {msg['content']}" for msg in self.context[-6:]]);
        response = self.respond_to_question(
            message=self.message,
            conversation_history=history_text
        );
        report {
            "message": self.message,
            "response": response
        };
    }
}

walker suggest_learning_path {
    has goal: str;
    has current_knowledge: str = "beginner";
    
    def create_learning_path(goal: str, knowledge_level: str) -> dict by llm(
        reason=True,
        temperature=0.7,
        incl_info=(
            "You are a learning path advisor. Create a structured learning path to achieve the goal. "
            "Return a JSON object with path (array of steps with step number, title, description, duration), "
            "tips (array of strings), and resources (array of strings). "
            "Include 5-8 steps, practical tips, and resource suggestions."
        )
    );
    
    can suggest with `root entry {
        path_data = self.create_learning_path(
            goal=self.goal,
            knowledge_level=self.current_knowledge
        );
        report {
            "goal": self.goal,
            "learning_path": path_data
        };
    }
}
