# Deployment Guide - Real-Time 1v1 Multiplayer Game

## Prerequisites

- Firebase Project created
- Firebase CLI installed (`npm install -g firebase-tools`)
- Node.js 22+ installed
- Flutter SDK installed (Dart 3.9.2+)
- Google Cloud CLI installed (for Cloud Scheduler)

---

## 1. Firebase Project Setup

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or use existing
3. Enable Firestore Database (Native mode)
4. Enable Authentication → Anonymous sign-in

### 1.2 Configure Firebase for Flutter
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
flutterfire configure
```

This generates `firebase_options.dart` with your project configuration.

---

## 2. Cloud Functions Deployment

### 2.1 Install Dependencies
```bash
cd functions
npm install
```

### 2.2 Configure Gemini API Key
```bash
firebase functions:config:set ai.key="YOUR_GEMINI_API_KEY"
```

Get your API key from: https://ai.google.dev/

### 2.3 Deploy Functions
```bash
# Deploy all functions
firebase deploy --only functions

# Or deploy specific functions
firebase deploy --only functions:joinMatchmaking
firebase deploy --only functions:createGame
firebase deploy --only functions:submitQuestion
firebase deploy --only functions:processRound
firebase deploy --only functions:makeFinalGuess
firebase deploy --only functions:finalizeGame
firebase deploy --only functions:handleTimeout
```

### 2.4 Verify Deployment
Check Firebase Console → Functions to ensure all functions are deployed:
- ✅ judgeQuestion (Callable)
- ✅ joinMatchmaking (Callable)
- ✅ submitQuestion (Callable)
- ✅ makeFinalGuess (Callable)
- ✅ createGame (Trigger - onCreate)
- ✅ processRound (Trigger - onUpdate)
- ✅ finalizeGame (Trigger - onUpdate)
- ✅ handleTimeout (Scheduled - every 30s)

---

## 3. Firestore Configuration

### 3.1 Deploy Security Rules
```bash
firebase deploy --only firestore:rules
```

### 3.2 Deploy Firestore Indexes
```bash
firebase deploy --only firestore:indexes
```

### 3.3 Verify Indexes
- Go to Firebase Console → Firestore → Indexes
- Ensure composite indexes are created:
  - **matchmakingQueue**: `joinTime (ASC)`
  - **games**: `state (ASC), roundTimerEndsAt (ASC)`

---

## 4. Cloud Scheduler Setup

The `handleTimeout` function runs every 30 seconds to process expired game timers.

### 4.1 Enable Cloud Scheduler API
```bash
gcloud services enable cloudscheduler.googleapis.com --project=YOUR_PROJECT_ID
```

### 4.2 Verify Scheduler Job
After deploying functions, check Google Cloud Console → Cloud Scheduler:
- Job name: `firebase-schedule-handleTimeout-europe-west1`
- Frequency: `every 30 seconds`
- Target: Cloud Functions
- Function: `handleTimeout`

**Note**: Cloud Scheduler automatically creates the job when you deploy the scheduled function.

### 4.3 Manual Job Creation (if needed)
If the job wasn't created automatically:
```bash
gcloud scheduler jobs create pubsub handleTimeout \
  --schedule="every 30 seconds" \
  --topic="firebase-schedule-handleTimeout-europe-west1" \
  --message-body="{}" \
  --project=YOUR_PROJECT_ID
```

---

## 5. Testing Cloud Functions

### 5.1 Local Testing with Emulators
```bash
# Start Firebase emulators
firebase emulators:start

# In another terminal, run Flutter app
cd ..
flutter run
```

### 5.2 Emulator Configuration
The emulators will run on:
- Firestore: `localhost:8080`
- Functions: `localhost:5001`
- Auth: `localhost:9099`

Configure Flutter to use emulators (in development mode):
```dart
// lib/main.dart
if (kDebugMode) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
}
```

### 5.3 Test Matchmaking Flow
1. Open two instances of the app (or use two devices)
2. Both users sign in anonymously
3. Both users click "Quick Match"
4. Verify game creation and round progression
5. Check Firestore emulator UI for data changes

---

## 6. Flutter App Deployment

### 6.1 Update Dependencies
```bash
flutter pub get
```

### 6.2 Build for Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### 6.3 Build for iOS
```bash
flutter build ipa --release
```

### 6.4 Configure App Signing
- **Android**: Set up keystore in `android/key.properties`
- **iOS**: Configure signing in Xcode

---

## 7. Monitoring & Logs

### 7.1 View Function Logs
```bash
# Real-time logs
firebase functions:log

# Or view in Firebase Console
# Functions → Logs
```

### 7.2 Monitor Cloud Scheduler
Google Cloud Console → Cloud Scheduler → View execution history

### 7.3 Firestore Usage Monitoring
Firebase Console → Firestore → Usage tab

---

## 8. Environment Variables

### Required Function Configurations
```bash
# Gemini API Key (REQUIRED)
firebase functions:config:set ai.key="YOUR_API_KEY"

# View current config
firebase functions:config:get
```

---

## 9. Troubleshooting

### Issue: Functions timing out
**Solution**: Increase timeout in `functions/index.js`:
```javascript
exports.processRound = functions
    .region('europe-west1')
    .runWith({ timeoutSeconds: 120 })
    .firestore.document('games/{gameId}')
    .onUpdate(async (change, context) => { ... });
```

### Issue: Firestore permission denied
**Solution**: Deploy security rules and verify user is authenticated:
```bash
firebase deploy --only firestore:rules
```

### Issue: handleTimeout not executing
**Solution**: 
1. Verify Cloud Scheduler job exists in Google Cloud Console
2. Check Cloud Scheduler has permissions to invoke the function
3. View execution logs in Cloud Scheduler

### Issue: AI adjudication failing
**Solution**:
1. Verify Gemini API key is set: `firebase functions:config:get`
2. Check function logs for API errors
3. Ensure safety settings aren't blocking requests

---

## 10. Cost Optimization

### Firestore Optimization
- **Minimize reads**: Use snapshot listeners efficiently
- **Use indexes**: Ensure composite indexes are created
- **Delete old games**: Implement TTL cleanup (future enhancement)

### Functions Optimization
- **Use minimum instances**: Set to 0 for low-traffic functions
- **Regional deployment**: Deploy to region closest to users
- **Cold start mitigation**: Consider min instances for critical functions

### Example Cost-Optimized Configuration
```javascript
exports.joinMatchmaking = functions
    .region('europe-west1')
    .runWith({
        timeoutSeconds: 60,
        memory: '256MB',
        minInstances: 0, // or 1 for instant response
        maxInstances: 100,
    })
    .https.onCall(async (data, context) => { ... });
```

---

## 11. Production Checklist

- [ ] Gemini API key configured
- [ ] All 8 Cloud Functions deployed successfully
- [ ] Firestore security rules deployed
- [ ] Firestore indexes created
- [ ] Cloud Scheduler job running
- [ ] Firebase Authentication enabled (Anonymous)
- [ ] Flutter app connected to production Firebase
- [ ] Error monitoring enabled (optional: Crashlytics)
- [ ] Analytics enabled (optional: Firebase Analytics)
- [ ] Rate limiting configured (optional)

---

## 12. Rollback Procedure

### Rollback Cloud Functions
```bash
# List function versions
firebase functions:list

# Deploy previous version
firebase deploy --only functions --version <VERSION_NUMBER>
```

### Rollback Firestore Rules
```bash
# Download current rules backup
firebase firestore:rules:get > firestore.rules.backup

# Deploy previous rules
firebase deploy --only firestore:rules --force
```

---

## Support & Resources

- **Firebase Documentation**: https://firebase.google.com/docs
- **Gemini API Documentation**: https://ai.google.dev/docs
- **Cloud Functions Docs**: https://firebase.google.com/docs/functions
- **Cloud Scheduler Docs**: https://cloud.google.com/scheduler/docs

---

**Last Updated**: 2025-10-25
**Version**: 1.0.0
