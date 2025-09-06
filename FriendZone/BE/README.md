# FriendZone Backend

FriendZone backend is built using jaclang and jac-cloud framework, providing AI-powered memory management and social sharing capabilities.

## Prerequisites

- Python 3.12 or higher
- jaclang and jac-cloud installed
- Required API keys (see Environment Variables section)

## Environment Variables

Before running the server, make sure to set up the following environment variables:

```bash
OPENAI_API_KEY=your_openai_api_key_here
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
AWS_S3_BUCKET_NAME=your_aws_s3_bucket_name_here
AWS_REGION=your_aws_region_here
AWS_ACCESS_KEY_ID=your_aws_access_key_id_here
AWS_SECRET_ACCESS_KEY=your_aws_secret_access_key_here
```

## Installation & Setup

1. **Create and activate a Python virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up environment variables:**

4. **Run the server:**
   ```bash
   cd app
   jac serve main.jac
   ```

The server will start on `http://localhost:8000` by default.

## Project Structure

```
BE/
├── app/
│   ├── main.jac              # Main application 
│   ├── user.jac              # User management and authentication
│   ├── profile.jac           # User profile management
│   ├── session.jac           # Memory session management
│   ├── memory.jac            # Memory storage and retrieval
│   ├── friends.jac           # Friend connections and management
│   ├── share_memory.jac      # Memory sharing functionality
│   ├── comments.jac          # Comment system for shared memories
│   ├── storage.jac           # File storage and AWS S3 integration
│   ├── google_maps_service.jac # Location services integration
│   └── utils.jac             # Utility functions and helpers
├── requirements.txt          # Python dependencies
└── README.md                 # This file
```

## Key Features

- **JWT Authentication:** Secure user authentication and session management
- **AI-Powered Memory Analysis:** Automatic extraction of context from images
- **Location Integration:** Google Maps API for location-based memories
- **File Upload:** AWS S3 integration for image storage
- **Social Features:** Friend connections and memory sharing
- **RESTful API:** Comprehensive API endpoints for all functionality

## API Documentation

Replace `{{HOST}}` with your server's host URL (e.g., `http://localhost:8080`)

### 1. Authentication

#### Register User
- **URL:** `{{HOST}}/user/register/`
- **Method:** POST
- **Payload:**
```json
{
    "password": "permission",
    "email": "permission@gmail.com",
    "name": "permission"
}
```
- **Response:**
```json
{
    "message": "Successfully Registered!"
}
```

#### Login User
- **URL:** `{{HOST}}/user/login/`
- **Method:** POST
- **Payload:**
```json
{
    "password": "permission",
    "email": "permission@gmail.com"
}
```
- **Response:**
```json
{
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
        "id": "688a39c1d393c27ab826fa70",
        "email": "permission@gmail.com",
        "root_id": "688a39c1d393c27ab826fa6f",
        "is_activated": true,
        "is_admin": false,
        "expiration": 1754007978,
        "state": "1FQYgt35"
    }
}
```

### 2. Initialization

#### Initialize User
- **URL:** `{{HOST}}/walker/init_user`
- **Method:** POST
- **Payload:**
```json
{}
```
- **Response:**
```json
{
    "status": 200,
    "reports": []
}
```

### 3. Profile Management

#### Update Profile
- **URL:** `{{HOST}}/walker/update_profile`
- **Method:** POST
- **Payload:**
```json
{
    "first_name": "kashmith",
    "last_name": "nisakya"
}
```
- **Response:**
```json
{
    "status": 200,
    "reports": [
        {
            "message": "Profile updated successfully",
            "profile": {
                "email": "permission@gmail.com",
                "first_name": "kashmith",
                "last_name": "nisakya",
                "profile_picture_url": ""
            }
        }
    ]
}
```

### 4. Session Management

#### Initialize Session
- **URL:** `{{HOST}}/walker/init_session`
- **Method:** POST
- **Payload:**
```json
{
    "image_url": "https://example.com/image.jpg",
    "location": {
        "latitude": 33.601836666666664,
        "longitude": -117.87143
    },
    "date": "2024:10:31 20:24:46"
}
```
- **Response:**
```json
{
    "status": 200,
    "reports": [
        {
            "session_id": "3b3d54db8f1e49ceb0ceb3e9b0038c61",
            "follow_up_questions": "What was the occasion for this gathering? Do you remember any special moments from that day?",
            "summary": "On October 31, 2024, two people spent time together in Newport Beach, smiling and appearing to enjoy themselves indoors near a bright window with a view of palm trees. The mood is warm and friendly, suggesting a memorable and happy occasion.",
            "when": "2024-10-31",
            "who": [
                "Two people (one male, one female)"
            ],
            "where": [
                "Newport Beach"
            ],
            "what": "A friendly gathering or moment captured with two people smiling together indoors.",
            "conversation": [
                {
                    "assistant": "What was the occasion for this gathering? Do you remember any special moments from that day?"
                }
            ],
            "save_memory": true,
            "show_summary": true
        }
    ]
}
```

#### Continue Session
- **URL:** `{{HOST}}/walker/continue_session`
- **Method:** POST
- **Payload:**
```json
{
    "session_id": "a8ae17efced5433dbd41088bcf0eae59",
    "utterance": "it is not special for me"
}
```
- **Response:**
```json
{
    "status": 200,
    "reports": [
        {
            "session_id": "3b3d54db8f1e49ceb0ceb3e9b0038c61",
            "follow_up_questions": "Would you like to add any more details about the day or how you were feeling when this photo was taken?",
            "summary": "On October 31, 2024, Pat and his wife Soniya spent time together in Newport Beach, smiling and enjoying themselves indoors near a bright window with a view of palm trees. The mood was warm and friendly, suggesting a memorable and happy occasion.",
            "when": "2024-10-31",
            "who": [
                "Pat",
                "Soniya"
            ],
            "where": [
                "Newport Beach"
            ],
            "what": "A joyful moment shared between Pat and his wife Soniya, captured indoors with a scenic view, reflecting a warm and memorable occasion.",
            "conversation": [
                {
                    "assistant": "What was the occasion for this gathering? Do you remember any special moments from that day?"
                },
                {
                    "user": "this is my wife, Soniya and me, Pat",
                    "assistant": "Would you like to add any more details about the day or how you were feeling when this photo was taken?"
                }
            ],
            "save_memory": true,
            "show_summary": true
        }
    ]
}
```

### 5. Memory Management

#### Save Memory
- **URL:** `{{HOST}}/walker/save_memory`
- **Method:** POST
- **Payload:**
```json
{
    "session_id": "92eb044603c34b0898232e4b3d663f8e"
}
```
- **Response:**
```json
{
    "status": 200,
    "reports": [
        {
            "memory_id": "6826bd2c720940cc85a9d065f13a9e02",
            "session_id": "92eb044603c34b0898232e4b3d663f8e",
            "summary": "On October 31, 2024, in Newport Beach, Clark and his wife Soniya took a cheerful selfie indoors, likely at a social event or celebration. The atmosphere appears relaxed and friendly, with daylight streaming through large windows behind them.",
            "when": "2024-10-31",
            "who": [
                "Clark",
                "Soniya"
            ],
            "where": [
                "Newport Beach"
            ],
            "what": "Clark and his wife Soniya captured a happy moment together in a selfie, possibly during a celebration or social gathering.",
            "image_url": "",
            "conversation": [
                {
                    "assistant": "Do you remember what event or occasion you were celebrating? Who else was present?"
                },
                {
                    "user": "This me, Clark and my wife Soniya",
                    "assistant": "What brought you and Soniya to Newport Beach on that day? Was it a special celebration or just a casual outing?"
                }
            ],
            "created_at": "2025-07-31 18:46:03",
            "updated_at": "2025-07-31 18:46:03",
            "save_memory": true,
            "show_summary": true
        }
    ]
}
```

## Usage Flow

1. **Register/Login:** Create an account or login to get an authentication token
2. **Initialize User:** Set up the user profile and preferences  
3. **Update Profile:** Add personal information like first and last name
4. **Initialize Session:** Start a new memory session by uploading an image with location and date
5. **Continue Session:** Engage in conversation to add more context to the memory
6. **Save Memory:** Persist the memory with all collected information

## Development

### Testing the API

You can test the API endpoints using tools like:
- **Postman**: Import the API endpoints and test with different payloads
- **curl**: Use command-line HTTP requests
- **HTTP files**: Use VS Code REST Client extension

### Common Issues

1. **Authentication Errors**: Ensure JWT tokens are included in requests headers as `Authorization: Bearer <token>`
2. **Environment Variables**: Verify all required environment variables are set correctly
3. **Image URLs**: Ensure image URLs are accessible and in supported formats (jpg, png, etc.)
4. **Location Data**: Latitude and longitude should be valid decimal numbers

### Server Logs

Monitor server logs for debugging:
```bash
jac serve main.jac --verbose
```

## Support

For issues and questions:
- Check the main project documentation
- Review API response error messages for troubleshooting
- Ensure all prerequisites and environment variables are properly configured
