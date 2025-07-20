# Firebase Integration Setup Instructions

## Overview
This document provides step-by-step instructions to integrate your Flutter waste sorter app with Firebase and the RapidAPI waste classification service.

## Prerequisites
- Flutter SDK installed
- Firebase account
- RapidAPI account with access to the garbage detection API

## Setup Steps

### 1. Install Dependencies
Run the following command to install the required packages:
```bash
flutter pub get
```

### 2. API Key Configuration
1. Open `lib/core/config/app_config.dart`
2. Replace `YOUR_RAPID_API_KEY_HERE` with your actual RapidAPI key:
   ```dart
   static const String rapidApiKey = 'your_actual_rapid_api_key_here';
   ```

### 3. Firebase Storage Setup
1. Go to your Firebase Console (https://console.firebase.google.com)
2. Select your project: `waste-sorter-7f046`
3. Navigate to Storage in the left sidebar
4. Click "Get started" if not already set up
5. Choose "Start in test mode" for development
6. Set up storage rules (for production, implement proper security rules):
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

### 4. Firestore Database Setup
1. In Firebase Console, navigate to Firestore Database
2. Create the following collections and initial documents:

#### Collection: `rules`
Document ID: `kigali`
```json
{
  "plastic": "Blue",
  "organic": "Green", 
  "paper": "Yellow",
  "e-waste": "Red",
  "hazardous": "Black",
  "metal": "Blue",
  "glass": "Blue"
}
```

#### Collection: `tips` (Optional)
Document ID: `tip1`
```json
{
  "title": "Plastic Recycling Tips",
  "content": "Always rinse plastic containers before recycling to remove food residue...",
  "imageUrl": "",
  "postedAt": "2025-07-20T10:00:00Z"
}
```

### 5. Firestore Security Rules
Update your Firestore security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read/write their own scans
    match /scans/{scanId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Rules are readable by all authenticated users
    match /rules/{city} {
      allow read: if request.auth != null;
    }
    
    // Leaderboard is readable by all authenticated users
    match /leaderboard/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // For updating scores
    }
    
    // Tips are readable by all authenticated users
    match /tips/{tipId} {
      allow read: if request.auth != null;
    }
    
    // Badges are readable by users for their own data
    match /badges/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 6. Test the Integration

#### 6.1 Build and Run
```bash
flutter run
```

#### 6.2 Test Authentication
1. Create a new account through the signup flow
2. Verify the user document is created in Firestore

#### 6.3 Test Scanning (With Mock Data)
Since the API requires a valid key, you can test with mock data first:
1. Navigate to the scan screen
2. Take a photo or select from gallery
3. The app should show the analysis screen

#### 6.4 Test with Real API
1. Add your RapidAPI key to the config
2. Take a photo of waste items
3. Verify the classification results appear

### 7. Features Implemented

#### Core Scanning Features
- ✅ Image capture and upload to Firebase Storage
- ✅ Integration with RapidAPI waste classification
- ✅ Automatic bin color assignment based on city rules
- ✅ Multiple items detection and grouping
- ✅ Disposal instructions generation

#### User Management
- ✅ Firebase Authentication
- ✅ User profiles with points and streaks
- ✅ Location-based bin rules

#### Leaderboard System
- ✅ Daily, weekly, and monthly leaderboards
- ✅ Points system (5 points per detected item)
- ✅ User rankings and statistics

#### Data Structure
- ✅ Scan results grouped by bin color
- ✅ Session tracking for multiple items in single scan
- ✅ User points and streak calculation
- ✅ Comprehensive scan history

### 8. API Key Security

⚠️ **Important Security Note:**
- Never commit API keys to version control
- Add `lib/core/config/app_config.dart` to your `.gitignore`
- For production, consider using environment variables or Firebase Remote Config

### 9. Database Schema

#### Users Collection
```json
{
  "uid": "string",
  "email": "string", 
  "name": "string",
  "role": "string",
  "location": "string",
  "streakCount": 0,
  "totalPoints": 0,
  "profilePicture": "string",
  "createdAt": "timestamp"
}
```

#### Scans Collection
```json
{
  "scanId": "string",
  "userId": "string",
  "imageUrl": "string",
  "detectedItems": [
    {
      "itemName": "string",
      "category": "string", 
      "confidence": 0.95,
      "binColor": "string",
      "instructions": ["string"]
    }
  ],
  "city": "string",
  "timestamp": "timestamp",
  "scanSessionId": "string"
}
```

### 10. Troubleshooting

#### Common Issues

**Issue**: Firebase not initialized
**Solution**: Ensure Firebase.initializeApp() is called in main.dart

**Issue**: API returns error
**Solution**: Verify RapidAPI key is correct and has sufficient credits

**Issue**: Image upload fails
**Solution**: Check Firebase Storage rules and authentication status

**Issue**: Classification returns no results
**Solution**: Ensure image URL is publicly accessible

#### Debugging Tips
- Check Flutter console for error messages
- Verify Firestore data in Firebase Console
- Test API calls manually using curl or Postman
- Enable Firebase debug logging for detailed error info

### 11. Next Steps for Production

1. **Implement proper error handling**
   - Network connectivity checks
   - Graceful API failure handling
   - User-friendly error messages

2. **Optimize performance**
   - Image compression before upload
   - Caching for bin rules and tips
   - Pagination for scan history

3. **Add offline capabilities**
   - Store scans locally when offline
   - Sync when connection restored

4. **Enhanced security**
   - Implement proper Firestore security rules
   - Use Firebase App Check for API protection
   - Implement rate limiting

5. **Additional features**
   - Push notifications for streaks
   - Social sharing capabilities
   - Achievement badges system
   - Waste tracking analytics

## Support

For technical issues or questions:
1. Check the Firebase console for errors
2. Review Flutter debug console output
3. Verify API key validity and credits
4. Test individual components separately

This integration provides a complete waste sorting solution with real-time classification, user management, and gamification features.
