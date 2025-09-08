glob TONE_SAMPLES = {
    "Professional": {
        "description": "Formal, objective, and data-driven. Suitable for research papers or business reports.",
        "sample": (
            "The integration of Large Language Models into enterprise workflows has yielded a significant increase in operational efficiency. "
            "Our analysis indicates a 30% reduction in manual data processing tasks, which correlates with a marked improvement in employee productivity metrics."
        )
    },
    "Casual": {
        "description": "Friendly, conversational, and uses simple language. Great for blog posts or social media.",
        "sample": (
            "We’ve all heard of CrewAI and AutoGen, but did you know there are dozens of open-source agentic frameworks out there — "
            "and many of them have been released in the last year."
            "I’ve briefly tested some of the more popular ones to get a feel for how they work and how easy they are to get started with. "
            "So follow along as I go through what each one brings to the table."
            "Agentic AI is basically about building systems around LLMs so they can have accurate knowledge, access to data, and the ability to act. "
            "You can think of it as using natural language to automate processes and tasks."
        )
    },
    "Educational": {
        "description": "Clear, instructive, and aims to teach the reader. Uses analogies and step-by-step explanations.",
        "sample": (
            "This tutorial is based on the philosophy of learning by doing. By the end of it, you will have a multi-agent system that will work to "
            "fulfil a clear objective. Let's get started."
            "Step 1: Install the packages"
            "!pip install crewai crewai_tools arxiv"
            "Step 2: Set up Environment Variables"
            "Create an OpenAI API key and set it as an environment variable as follows. "
            "CrewAI, by default uses gpt-4o-mini to build agents."
            "# Set up environment variables"
            "import os"
            "os.environ[OPENAI_API_KEY] = YOUR_API_KEY"
            "os.environ[OPENAI_MODEL_NAME] = gpt-4o-mini"
        )
    },
    "Storytelling": {
        "description": "Narrative-driven, uses personal anecdotes or examples to engage the reader emotionally.",
        "sample": (
            "It was 2 AM when I finally got my first AI agent to work. For hours, it had been stuck in a frustrating loop. "
            "But when it successfully booked a test flight using a real API, the feeling was electric. It wasn't just code anymore; it was a system with a purpose."
        )
    }
};