# Quick Start Guide - Waste Sorter App Firebase Integration

## 🚀 Quick Setup (5 minutes)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure API Key
```bash
# Copy the template config file
cp lib/core/config/app_config.dart.template lib/core/config/app_config.dart

# Edit the file and add your RapidAPI key
# Get key from: https://rapidapi.com/reciclapi/api/garbage-detection
```

### 3. Run the App
```bash
flutter run
```

## ✨ Features Implemented

### Core Functionality
- 📸 **Image Capture & Upload** - Takes photos and uploads to Firebase Storage
- 🤖 **AI Waste Classification** - Uses RapidAPI to identify waste types
- 🗃️ **Smart Bin Assignment** - Automatically assigns correct bin colors based on city rules
- 📱 **Real-time Processing** - Live analysis with progress indicators

### User Experience
- 👤 **User Authentication** - Firebase Auth with profiles
- 🏆 **Points & Streaks** - Gamification with 5 points per item
- 📊 **Leaderboards** - Daily, weekly, monthly rankings
- 📈 **Progress Tracking** - Personal stats and achievements

### Data Management
- 🔄 **Session Grouping** - Multiple items from same scan grouped together
- 📍 **Location-based Rules** - City-specific bin color rules
- 💾 **Comprehensive History** - All scans stored with detailed metadata
- 🏙️ **Multi-city Support** - Easily extensible to new cities

## 🏗️ Architecture Overview

```
User Takes Photo → Upload to Firebase Storage → Get Public URL → 
Send to RapidAPI → Classify Items → Apply City Rules → 
Group by Bin Color → Store in Firestore → Update User Points → 
Show Instructions
```

## 📱 App Flow

1. **Scan Screen** - Camera interface with photo capture
2. **Analysis Screen** - AI processing with progress indicator  
3. **Results Screen** - Bin-specific disposal instructions
4. **Points Award** - Instant gratification with points
5. **Leaderboard Update** - Automatic ranking updates

## 🗄️ Database Structure

### Collections Created:
- `users` - User profiles, points, streaks
- `scans` - Individual scan results with detected items
- `rules` - City-specific bin color mappings
- `leaderboard` - Daily ranking snapshots

### Key Features:
- **Grouped Scanning**: Items from same photo share `scanSessionId`
- **Bin Color Logic**: Items automatically sorted by disposal rules
- **Points System**: 5 points per detected item
- **Streak Tracking**: Daily scanning streaks

## 🎯 Example Usage

```dart
// Process a scan
final result = await ScanService.processScan(
  imageFile: capturedImage,
  city: 'Kigali',
);

// Result contains:
// - Multiple ScanResult objects (one per bin color)
// - Points awarded
// - Detailed disposal instructions
```

## 📋 Current City Rules (Kigali)

| Category | Bin Color | Examples |
|----------|-----------|----------|
| Plastic | Blue | Bottles, containers, bags |
| Organic | Green | Food waste, compostables |
| Paper | Yellow | Newspapers, cardboard |
| Metal | Blue | Cans, aluminum |
| Glass | Blue | Bottles, jars |
| E-Waste | Red | Electronics, batteries |
| Hazardous | Black | Chemicals, oils |

## 🔧 Customization

### Adding New Cities
```dart
// Add to Firestore rules collection
await _firestore.collection('rules').doc('kampala').set({
  'plastic': 'Green',
  'organic': 'Brown',
  'paper': 'Blue',
  // ... other categories
});
```

### Adjusting Points System
```dart
// In app_config.dart
static const int pointsPerItem = 10; // Increase points
```

## 🚨 Important Notes

- **API Key Required**: Get RapidAPI key for waste classification
- **Firebase Setup**: Ensure Storage and Firestore are enabled
- **Security**: API keys are gitignored for security
- **Testing**: Start with mock data before using real API

## 🔍 Troubleshooting

| Issue | Solution |
|-------|----------|
| Firebase not initialized | Check main.dart Firebase.initializeApp() |
| API returns error | Verify RapidAPI key and credits |
| Upload fails | Check Firebase Storage rules |
| No classification | Ensure image URL is public |

## 🎉 Ready to Use!

The app now has full waste sorting capabilities with:
- Real AI-powered classification
- Firebase backend integration  
- User management and gamification
- Comprehensive disposal guidance
- Scalable architecture for multiple cities

Just add your API key and start scanning! 📱♻️
