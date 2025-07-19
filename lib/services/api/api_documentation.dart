// API Endpoints Documentation for Backend Team
//
// This file documents the REST API endpoints needed for the WasteSorter app.
// Backend team should implement these endpoints with the specified request/response formats.

/* 
==========================================
AI CLASSIFICATION SERVICE
==========================================

POST /api/v1/classify
Content-Type: multipart/form-data

Request:
- image: File (JPEG, PNG, HEIC up to 10MB)
- userId: String (optional, for analytics)

Response 200:
{
  "success": true,
  "data": {
    "category": "Recyclable|Compostable|Landfill|Hazardous",
    "confidence": 0.92,
    "itemType": "Plastic Bottle",
    "material": "PET Plastic",
    "instructions": [
      "Remove Cap",
      "Rinse Item", 
      "Place in Blue Bin"
    ],
    "environmentalImpact": {
      "co2Saved": "0.2 kg",
      "energySaved": "1.5 kWh",
      "description": "Recycling this bottle saves energy equivalent to running a 60W bulb for 25 hours!"
    },
    "alternativeUses": [
      "Plant pot for small herbs",
      "Storage container for small items"
    ],
    "processingTimeMs": 2800
  }
}

Response 400:
{
  "success": false,
  "error": {
    "code": "INVALID_IMAGE",
    "message": "Image format not supported"
  }
}

Response 500:
{
  "success": false,
  "error": {
    "code": "CLASSIFICATION_FAILED",
    "message": "AI service temporarily unavailable"
  }
}

==========================================
USER AUTHENTICATION
==========================================

POST /api/v1/auth/signup
Content-Type: application/json

Request:
{
  "email": "user@example.com",
  "password": "securePassword123",
  "username": "EcoWarrior"
}

Response 201:
{
  "success": true,
  "data": {
    "user": {
      "id": "user_12345",
      "username": "EcoWarrior",
      "email": "user@example.com",
      "totalPoints": 0,
      "currentStreak": 0,
      "totalScans": 0,
      "joinedAt": "2025-07-01T10:30:00Z"
    },
    "token": "jwt_token_here"
  }
}

POST /api/v1/auth/signin
Content-Type: application/json

Request:
{
  "email": "user@example.com",
  "password": "securePassword123"
}

Response 200:
{
  "success": true,
  "data": {
    "user": { ... }, // Same user object as signup
    "token": "jwt_token_here"
  }
}

POST /api/v1/auth/signout
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "message": "Successfully signed out"
}

GET /api/v1/auth/me
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "data": {
    "user": { ... } // Current user object
  }
}

==========================================
USER PROGRESS & SCANNING
==========================================

POST /api/v1/user/scan
Authorization: Bearer {token}
Content-Type: application/json

Request:
{
  "category": "Recyclable",
  "pointsEarned": 5,
  "classificationData": "{...}", // JSON string of full classification result
  "scannedAt": "2025-07-01T10:30:00Z"
}

Response 200:
{
  "success": true,
  "data": {
    "pointsAwarded": 5,
    "newTotalPoints": 125,
    "streakUpdated": true,
    "currentStreak": 7,
    "achievementsUnlocked": ["First Scan", "Week Warrior"]
  }
}

GET /api/v1/user/stats
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "data": {
    "totalPoints": 125,
    "currentStreak": 7,
    "longestStreak": 12,
    "totalScans": 45,
    "weeklyPoints": 35,
    "monthlyPoints": 125,
    "categoryCounts": {
      "Recyclable": 25,
      "Compostable": 15,
      "Landfill": 3,
      "Hazardous": 2
    }
  }
}

GET /api/v1/user/history?limit=50&offset=0
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "data": {
    "scans": [
      {
        "id": "scan_12345",
        "imagePath": "/uploads/user_12345/scan_12345.jpg",
        "classificationResult": "{...}",
        "pointsEarned": 5,
        "scannedAt": "2025-07-01T10:30:00Z"
      }
    ],
    "total": 45,
    "hasMore": true
  }
}

PUT /api/v1/user/location
Authorization: Bearer {token}
Content-Type: application/json

Request:
{
  "location": "San Francisco, CA"
}

Response 200:
{
  "success": true,
  "message": "Location updated successfully"
}

==========================================
LEADERBOARDS
==========================================

GET /api/v1/leaderboard/weekly?limit=50
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "data": {
    "leaderboard": [
      {
        "rank": 1,
        "username": "EcoChampion",
        "points": 245,
        "avatarUrl": null,
        "isCurrentUser": false
      },
      {
        "rank": 5,
        "username": "EcoWarrior",
        "points": 125,
        "avatarUrl": null,
        "isCurrentUser": true
      }
    ],
    "userRank": 5,
    "userPoints": 125
  }
}

GET /api/v1/leaderboard/monthly?limit=50
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "data": {
    // Same format as weekly
  }
}

GET /api/v1/leaderboard/local?location=San%20Francisco,%20CA&limit=50
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "data": {
    // Same format as weekly/monthly
  }
}

GET /api/v1/user/rankings
Authorization: Bearer {token}

Response 200:
{
  "success": true,
  "data": {
    "weeklyRank": 5,
    "monthlyRank": 12,
    "overallRank": 234,
    "localRank": 3
  }
}

==========================================
ERROR RESPONSES
==========================================

All error responses follow this format:

{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": { ... } // Optional additional details
  }
}

Common error codes:
- UNAUTHORIZED: Invalid or missing token
- VALIDATION_ERROR: Request validation failed
- USER_NOT_FOUND: User doesn't exist
- DUPLICATE_EMAIL: Email already registered
- INVALID_CREDENTIALS: Wrong email/password
- RATE_LIMIT_EXCEEDED: Too many requests
- INTERNAL_ERROR: Server error

==========================================
AUTHENTICATION
==========================================

Use JWT tokens for authentication.
Include in requests as: Authorization: Bearer {token}

Token should contain:
- userId
- email
- exp (expiration)
- iat (issued at)

Tokens expire after 24 hours.
Refresh token endpoint should be implemented if needed.

==========================================
FILE UPLOADS
==========================================

For image uploads (/api/v1/classify):
- Max file size: 10MB
- Supported formats: JPEG, PNG, HEIC
- Store images securely with proper cleanup
- Generate unique filenames to avoid conflicts
- Consider implementing image compression/optimization

==========================================
RATE LIMITING
==========================================

Suggested rate limits:
- Authentication endpoints: 5 requests/minute
- Classification endpoint: 10 requests/minute
- Other endpoints: 100 requests/minute

==========================================
DATABASE CONSIDERATIONS
==========================================

Suggested tables/collections:
- users (id, email, username, password_hash, created_at, etc.)
- scans (id, user_id, image_path, classification_result, points, created_at)
- user_stats (user_id, total_points, current_streak, etc.)
- leaderboards (cached/materialized views for performance)

Index on:
- users.email
- scans.user_id, scans.created_at
- user_stats.total_points (for leaderboards)

==========================================
CACHING STRATEGY
==========================================

Cache the following for performance:
- Leaderboards (refresh every 5-10 minutes)
- User stats (refresh on scan submission)
- Classification results (cache common items)
- Disposal instructions (static data)

*/
