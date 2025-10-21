# Firebase Setup Guide - REQUIRED

## ⚠️ CRITICAL: You Must Complete This Setup

The authentication system requires Firebase Firestore to be properly configured. Follow these steps **exactly**:

---

## Step 1: Configure Firestore Security Rules

### Go to Firebase Console:
1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your project: **yesorno-85a02**
3. Click **Firestore Database** in the left sidebar
4. Click the **Rules** tab at the top

### Replace the existing rules with this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - Allow authenticated users to manage their own profile
    match /users/{userId} {
      // Allow any authenticated user to create their profile
      allow create: if request.auth != null 
                    && request.auth.uid == userId
                    && request.resource.data.deviceId is string;
      
      // Allow users to read and update their own profile
      allow read, update: if request.auth != null 
                          && request.auth.uid == userId;
      
      // Prevent deleting profiles for safety
      allow delete: if false;
    }
    
    // Add other collection rules here as needed
  }
}
```

### Click **Publish** button

---

## Step 2: Verify Anonymous Authentication is Enabled

1. In Firebase Console, click **Authentication** in the left sidebar
2. Click the **Sign-in method** tab
3. Find **Anonymous** in the list
4. Make sure it shows **Enabled**
5. If not, click on it, toggle **Enable**, and click **Save**

---

## Step 3: Test the Setup

1. Run your Flutter app:
   ```bash
   flutter run
   ```

2. Tap the **Quick Start** button

3. Check the console - you should see:
   ```
   flutter: QuickStart Step 1: Retrieving device ID...
   flutter: Device ID retrieved: [UUID]
   flutter: QuickStart Step 2: Authenticating user...
   flutter: New anonymous user created: [UID]
   flutter: QuickStart Step 3: Checking if profile exists...
   flutter: QuickStart Step 4B: Creating new user profile...
   flutter: User profile created: [UID]
   flutter: New user profile created: PlayerXXXX
   ```

4. Verify in Firebase Console:
   - **Authentication → Users**: You should see a new anonymous user
   - **Firestore Database → users collection**: You should see a new document with the user's data

---

## Common Issues

### Issue: "Permission Denied" Error
**Solution:** Make sure you published the Firestore security rules exactly as shown above

### Issue: "Anonymous sign-in is disabled"
**Solution:** Enable Anonymous authentication in Authentication → Sign-in method

### Issue: Rules don't save
**Solution:** 
- Check for syntax errors in the rules
- Make sure you clicked **Publish** not just Save

---

## Your Current Firebase Project

Based on your files, your Firebase project is:
- **Project ID:** yesorno-85a02
- **Bundle ID (iOS):** com.example.yesOrNo

Make sure you're configuring the correct project in Firebase Console.

---

## Need Help?

If you continue to see errors:
1. Double-check the rules are published
2. Wait 1-2 minutes for rules to propagate
3. Restart your Flutter app
4. Check Firebase Console → Firestore → Rules tab shows the new rules

---

**Last Updated:** 2025-10-21
