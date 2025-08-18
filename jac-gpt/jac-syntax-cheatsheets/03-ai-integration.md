# Jac AI Integration (MTLLM) Cheat Sheet

## Setup and Configuration

### Basic MTLLM Setup
```jac
import from mtllm { Model }

# Configure different models
glob openai_model = Model(model_name="gpt-4-turbo");
glob gemini_model = Model(model_name="gemini/gemini-2.0-flash");
glob claude_model = Model(model_name="claude-3-sonnet");
glob ollama_model = Model(model_name="ollama/llama2");
```

### Environment Variables
```bash
# Set API keys for different providers
export OPENAI_API_KEY="your-openai-key"
export GEMINI_API_KEY="your-gemini-key"
export ANTHROPIC_API_KEY="your-claude-key"
```

## AI-Integrated Functions

### Basic AI Function
```jac
import from mtllm { Model }

glob llm = Model(model_name="gpt-4-turbo");

# Simple AI function - LLM generates implementation
def categorize_sentiment(text: str) -> str by llm();

with entry {
    review = "This product is amazing!";
    sentiment = categorize_sentiment(review);
    print(f"Sentiment: {sentiment}");
}
```

### AI Function with Return Types
```jac
# Enum for structured output
enum Personality {
    INTROVERT = "Introvert",
    EXTROVERT = "Extrovert", 
    AMBIVERT = "Ambivert"
}

# AI function that returns enum
def analyze_personality(name: str) -> Personality by llm();

# AI function with complex return type
def extract_info(text: str) -> dict[str, str] by llm();

with entry {
    person_type = analyze_personality("Albert Einstein");
    print(f"Personality: {person_type.value}");
    
    info = extract_info("John Doe, 30 years old, Software Engineer");
    print(f"Extracted: {info}");
}
```

### AI Function with Context
```jac
# Include additional context/information
def generate_response(user_input: str, context: dict) -> str by llm(incl_info=(context));

def analyze_with_history(current_text: str, history: list[str]) -> str by llm(incl_info=(history));

with entry {
    context = {"user_name": "Alice", "preference": "technical"};
    response = generate_response("Explain AI", context);
    print(response);
}
```

## AI-Powered Objects and Nodes

### AI-Enhanced Objects
```jac
obj SmartAssistant {
    has name: str;
    has expertise: list[str];
    
    # AI-powered method
    def answer_question(question: str) -> str by llm(incl_info=(self.expertise));
    
    def generate_advice(topic: str) -> str by llm();
}

with entry {
    assistant = SmartAssistant(
        name="TechBot",
        expertise=["Python", "Machine Learning", "Web Development"]
    );
    
    answer = assistant.answer_question("How do I debug Python code?");
    print(answer);
}
```

### AI-Enabled Nodes
```jac
node IntelligentAgent {
    has knowledge_base: list[str] = [];
    has memory: dict = {};
    
    # AI ability triggered by walker visits
    can provide_insights with QueryWalker entry {
        insights = self.generate_insights(here.query, self.knowledge_base);
        here.results.append(insights);
    }
    
    def generate_insights(query: str, knowledge: list[str]) -> str by llm(incl_info=(knowledge));
}

walker QueryWalker {
    has query: str;
    has results: list[str] = [];
    
    can search with entry {
        visit [-->(`?IntelligentAgent)];
    }
}
```

## Semantic Strings (AI-Powered String Processing)

### Basic Semantic Strings
```jac
# Semantic string for AI processing
def process_semantic_text(content: str) -> str {
    result = f"""
    Analyze the following text and provide insights:
    {content}
    
    Focus on:
    - Main themes
    - Sentiment
    - Key entities
    """ by llm();
    
    return result;
}
```

### Semantic String with Templates
```jac
def generate_email(recipient: str, topic: str, tone: str) -> str {
    email = f"""
    Generate a professional email to {recipient} about {topic}.
    
    Requirements:
    - Tone: {tone}
    - Include proper greeting and closing
    - Keep it concise
    - Professional format
    """ by llm();
    
    return email;
}

with entry {
    email = generate_email("Dr. Smith", "project updates", "formal");
    print(email);
}
```

## AI Walkers and Graph Intelligence

### Intelligent Graph Walker
```jac
walker AIExplorer {
    has objective: str;
    has findings: list[str] = [];
    
    can explore_intelligently with entry {
        # Use AI to decide navigation strategy
        strategy = self.plan_exploration(here, self.objective);
        self.execute_strategy(strategy);
    }
    
    def plan_exploration(current_node: str, goal: str) -> str by llm();
    
    def execute_strategy(strategy: str) {
        # Parse AI-generated strategy and execute
        if "visit_all" in strategy.lower() {
            visit [-->];
        } elif "selective" in strategy.lower() {
            visit [-->(`?ImportantNode)];
        }
    }
}
```

### Adaptive Node Behavior
```jac
node AdaptiveService {
    has service_data: dict;
    has interaction_history: list[str] = [];
    
    can adapt_response with SmartWalker entry {
        # AI adapts response based on walker's history
        response = self.generate_adaptive_response(
            here.request, 
            here.history, 
            self.service_data
        );
        here.response = response;
        self.interaction_history.append(f"Served: {here.request}");
    }
    
    def generate_adaptive_response(
        request: str, 
        walker_history: list[str], 
        context: dict
    ) -> str by llm(incl_info=(walker_history, context));
}
```

## Multi-Agent AI Systems

### Coordinated AI Agents
```jac
walker ResearchAgent {
    has specialization: str;
    has findings: list[str] = [];
    
    can research with entry {
        if self.is_relevant_node(here) {
            finding = self.analyze_node(here, self.specialization);
            self.findings.append(finding);
        }
        visit [-->];
    }
    
    def is_relevant_node(node: str) -> bool by llm();
    def analyze_node(node: str, specialty: str) -> str by llm(incl_info=(specialty));
}

walker Coordinator {
    can orchestrate_research with entry {
        # Spawn specialized agents
        data_agent = ResearchAgent(specialization="data analysis") spawn here;
        ml_agent = ResearchAgent(specialization="machine learning") spawn here;
        
        # Collect and synthesize results
        combined_findings = self.synthesize_findings(
            data_agent.findings, 
            ml_agent.findings
        );
    }
    
    def synthesize_findings(data_findings: list[str], ml_findings: list[str]) -> str by llm();
}
```

### AI-Powered Decision Making
```jac
walker DecisionMaker {
    has options: list[str];
    has criteria: dict;
    
    can make_decision with entry {
        decision = self.evaluate_options(self.options, self.criteria, here);
        self.execute_decision(decision);
    }
    
    def evaluate_options(
        options: list[str], 
        criteria: dict, 
        context: str
    ) -> str by llm(incl_info=(criteria, context));
    
    def execute_decision(decision: str) {
        print(f"Decision made: {decision}");
        # Execute based on AI recommendation
    }
}
```

## Error Handling and Validation

### AI Response Validation
```jac
def safe_ai_function(input_text: str) -> str {
    try {
        result = unsafe_ai_call(input_text);
        validated_result = validate_ai_response(result);
        return validated_result;
    } except Exception as e {
        return f"AI processing failed: {e}";
    }
}

def unsafe_ai_call(text: str) -> str by llm();
def validate_ai_response(response: str) -> str by llm();
```

### Fallback Strategies
```jac
walker RobustAIWalker {
    has backup_model: str = "simple-model";
    
    can process_with_fallback with entry {
        try {
            result = self.primary_ai_function(here.data);
        } except ModelError {
            result = self.fallback_processing(here.data);
        }
        here.processed_data = result;
    }
    
    def primary_ai_function(data: str) -> str by llm();
    def fallback_processing(data: str) -> str {
        # Simple rule-based fallback
        return f"Processed: {data}";
    }
}
```

## Model Configuration and Advanced Features

### Model Selection and Parameters
```jac
# Different models for different tasks
glob creative_model = Model(
    model_name="gpt-4-turbo",
    temperature=0.8,
    max_tokens=500
);

glob analytical_model = Model(
    model_name="claude-3-sonnet",
    temperature=0.2,
    max_tokens=1000
);

def creative_writing(prompt: str) -> str by creative_model();
def data_analysis(data: str) -> str by analytical_model();
```

### Custom Model Configuration
```jac
# Advanced model configuration
glob custom_model = Model(
    model_name="gpt-4-turbo",
    api_base="https://custom-endpoint.com",
    api_key="custom-key",
    temperature=0.5,
    top_p=0.9,
    frequency_penalty=0.1
);

def specialized_task(input: str) -> str by custom_model();
```
