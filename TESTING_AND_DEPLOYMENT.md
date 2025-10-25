# Testing and Deployment Guide

## Overview
This document provides comprehensive instructions for testing and deploying the Real-Time 1v1 AI-Adjudicated Multiplayer Game.

## Testing

### Prerequisites
```bash
# Install test dependencies
cd functions
npm install
cd ..

flutter pub get
```

### Running Tests

#### 1. Backend Unit Tests (Cloud Functions)
```bash
cd functions
npm test
```

**Test Coverage:**
- `test/matchmaking.test.js`: Matchmaking and queue management
- `test/gameplay.test.js`: Game flow, submissions, and finalization

**Example Output:**
```
Matchmaking Functions
  joinMatchmaking
    ✓ should add user to queue when no opponent available
    ✓ should create game when opponent found in queue
    ✓ should throw error when user not authenticated
  createGame
    ✓ should initialize game with secret word and player data
    ✓ should not process if state is not MATCHING

Gameplay Functions
  submitQuestion
    ✓ should accept valid question and update game state
    ✓ should reject question that is too short
    ✓ should reject question that is too long
```

#### 2. Flutter Widget Tests
```bash
flutter test test/widgets/
```

**Test Files:**
- `test/widgets/player_panel_widget_test.dart`: Player display components
- `test/widgets/countdown_timer_widget_test.dart`: Timer functionality

#### 3. Flutter Controller Tests
```bash
flutter test test/controllers/
```

**Test Files:**
- `test/controllers/multiplayer_game_controller_test.dart`: Business logic validation

#### 4. Integration Tests
```bash
flutter test integration_test/multiplayer_flow_test.dart
```

**Tests:**
- Complete game flow (matchmaking → game → finalize)
- Queue cancellation
- State transitions

#### 5. Edge Case Tests
```bash
flutter test integration_test/edge_cases_test.dart
```

**Coverage:**
- Network timeouts
- Disconnections
- Race conditions
- Invalid inputs
- Security rules

#### Run All Tests
```bash
chmod +x scripts/run_tests.sh
./scripts/run_tests.sh
```

### Test Results
All tests should pass before deployment:
```
================================
Test Results Summary:
================================
Backend Tests: ✅ PASSED
Widget Tests: ✅ PASSED
Controller Tests: ✅ PASSED
Integration Tests: ✅ PASSED
Edge Case Tests: ✅ PASSED
================================
✅ All tests passed!
```

## Local Development with Firebase Emulator

### Setup Emulator
```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize emulators (if not done)
firebase init emulators
```

### Start Emulator Suite
```bash
firebase emulators:start
```

**Available Emulators:**
- **Firestore**: http://localhost:8080
- **Functions**: http://localhost:5001
- **Auth**: http://localhost:9099
- **Emulator UI**: http://localhost:4000

### Connect Flutter App to Emulator
In `main.dart`:
```dart
Future<void> main() async {
  WidgetsBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Connect to emulator (development only)
  if (kDebugMode) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }
  
  runApp(const MyApp());
}
```

## Deployment

### Prerequisites
1. Firebase project created in Firebase Console
2. Firebase CLI installed: `npm install -g firebase-tools`
3. Authenticated: `firebase login`
4. Project selected: `firebase use <project-id>`

### Environment Setup

#### 1. Configure Firebase Project
```bash
# Create .firebaserc with your project IDs
cat > .firebaserc << EOF
{
  "projects": {
    "default": "your-staging-project-id",
    "staging": "your-staging-project-id",
    "production": "your-production-project-id"
  }
}
EOF
```

#### 2. Configure Gemini API Key
```bash
cd functions
firebase functions:config:set gemini.api_key="YOUR_GEMINI_API_KEY"
```

#### 3. Enable Required APIs
In Google Cloud Console:
- Vertex AI API
- Cloud Functions API
- Cloud Firestore API
- Cloud Scheduler API

### Staging Deployment

```bash
# Use staging environment
firebase use staging

# Deploy all components
./scripts/deploy.sh
```

**Deployment Steps:**
1. ✅ Firestore Security Rules
2. ✅ Firestore Indexes
3. ✅ Cloud Functions (7 functions)
4. ✅ Cloud Scheduler Job (handleTimeout)

### Production Deployment

```bash
# Use production environment
firebase use production

# Run all tests first
./scripts/run_tests.sh

# Deploy if tests pass
./scripts/deploy.sh
```

### Manual Deployment Commands

#### Deploy Firestore Rules Only
```bash
firebase deploy --only firestore:rules
```

#### Deploy Firestore Indexes Only
```bash
firebase deploy --only firestore:indexes
```

#### Deploy Specific Cloud Function
```bash
firebase deploy --only functions:joinMatchmaking
```

#### Deploy All Cloud Functions
```bash
firebase deploy --only functions
```

### Verify Deployment

#### 1. Check Cloud Functions
```bash
firebase functions:list
```

Expected output:
```
┌─────────────────┬──────────────────────────────┬───────┐
│ Function        │ Trigger                      │ State │
├─────────────────┼──────────────────────────────┼───────┤
│ joinMatchmaking │ https                        │ READY │
│ createGame      │ firestore.onCreate           │ READY │
│ submitQuestion  │ https                        │ READY │
│ processRound    │ firestore.onUpdate           │ READY │
│ makeFinalGuess  │ https                        │ READY │
│ finalizeGame    │ firestore.onUpdate           │ READY │
│ handleTimeout   │ Cloud Scheduler (every 30s)  │ READY │
│ judgeQuestion   │ https                        │ READY │
└─────────────────┴──────────────────────────────┴───────┘
```

#### 2. Check Cloud Scheduler
```bash
gcloud scheduler jobs list --location=europe-west1
```

#### 3. Test Deployed Functions
```bash
# Test joinMatchmaking
firebase functions:shell
> joinMatchmaking({}, { auth: { uid: 'test_user' } })
```

#### 4. Monitor Logs
```bash
# Real-time logs
firebase functions:log --only joinMatchmaking

# All functions
firebase functions:log
```

## Flutter App Deployment

### Android

#### 1. Configure Firebase for Android
```bash
# Download google-services.json from Firebase Console
# Place in: android/app/google-services.json
```

#### 2. Build APK
```bash
flutter build apk --release
```

#### 3. Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS

#### 1. Configure Firebase for iOS
```bash
# Download GoogleService-Info.plist from Firebase Console
# Place in: ios/Runner/GoogleService-Info.plist
```

#### 2. Build iOS App
```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## Monitoring

### Cloud Functions Logs
```bash
# View logs in Firebase Console
# https://console.firebase.google.com/project/YOUR_PROJECT/functions/logs

# Or via CLI
firebase functions:log
```

### Firestore Usage
Monitor in Firebase Console:
- Document reads/writes
- Storage usage
- Active connections

### Performance Monitoring
Integrate Firebase Performance Monitoring:
```dart
import 'package:firebase_performance/firebase_performance.dart';

// Track game start
final trace = FirebasePerformance.instance.newTrace('multiplayer_game');
await trace.start();
// ... game logic ...
await trace.stop();
```

## Troubleshooting

### Common Issues

#### 1. Cloud Functions Timeout
**Problem:** Function exceeds 60s timeout
**Solution:** Optimize AI calls, use parallel processing

#### 2. Firestore Permission Denied
**Problem:** Security rules blocking access
**Solution:** Verify rules in `firestore.rules`, check user authentication

#### 3. Cloud Scheduler Not Running
**Problem:** handleTimeout not executing
**Solution:** 
```bash
gcloud scheduler jobs run handleTimeout-scheduler --location=europe-west1
```

#### 4. Gemini API Errors
**Problem:** AI adjudication fails
**Solution:** Check API key, quota, and error logs

### Debug Mode

Enable verbose logging:
```dart
// In main.dart
if (kDebugMode) {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}
```

## Cost Optimization

### Firestore
- Use composite indexes efficiently
- Implement data pagination
- Clean up old games periodically

### Cloud Functions
- Optimize cold start time
- Use appropriate memory allocation
- Implement caching where possible

### Gemini API
- Cache common responses
- Implement retry logic with exponential backoff
- Monitor usage quotas

## Security Checklist

- [x] Firestore security rules implemented
- [x] Server-side validation for all inputs
- [x] API keys secured in Firebase Config
- [x] User authentication required
- [x] Rate limiting on Cloud Functions (recommended)
- [x] HTTPS-only communication
- [x] Sanitize user inputs
- [x] Validate all game state transitions

## Rollback Procedure

If deployment issues occur:

```bash
# Rollback Cloud Functions
firebase functions:delete <function-name>
firebase deploy --only functions:<function-name>

# Rollback Firestore Rules
# Manually restore previous version in Firebase Console

# Check deployment history
firebase functions:log
```

## Next Steps

1. ✅ Run all tests
2. ✅ Deploy to staging
3. ⏳ Conduct beta testing
4. ⏳ Monitor error rates
5. ⏳ Optimize based on metrics
6. ⏳ Deploy to production
7. ⏳ Enable Analytics
8. ⏳ Setup alerts and monitoring

## Support

For issues or questions:
- Check Firebase Console logs
- Review Cloud Functions documentation
- Check Flutter error logs
- Monitor user feedback

---

**Last Updated:** 2024
**Version:** 1.0.0
