# Multi-Agentic Travel Planner 🌍✈️

A multi-agent travel planning system that collaborates intelligently to create comprehensive travel plans. The system uses natural language understanding and specialized agents to handle every aspect of trip planning, from flights to activities.

## Features

- Multi-agent collaboration system
- Context-aware travel recommendations
- Budget optimization and cost breakdown
- Dynamic itinerary generation with expert agents

## Prerequisites

- Python 3.12 or higher

## Setup Instructions

1. Create and activate a virtual environment:
```bash
# On macOS/Linux
python3 -m venv venv
source venv/bin/activate

# On Windows
python -m venv venv
.\venv\Scripts\activate
```

2. Navigate to the project directory:
```bash
cd Travel_planner
```

3. Install the required dependencies:
```bash
pip install -r requirements.txt
```

## Environment Configuration

1. Copy the environment template:
```bash
cp .env.example .env
```

2. Set up your API key:
   - Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Add it to your `.env` file:
```
GEMINI_API_KEY=...
```

## Run the App

### 1. Run the frontend
```bash
streamlit run main/frontend/streamlit_app.py
```

The application will be available at `http://localhost:8501`

### 2. Run the Backend
*To be added*...

## License

This project is licensed under the MIT License - see the LICENSE file for details.