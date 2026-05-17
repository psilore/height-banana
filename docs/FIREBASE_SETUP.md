# Firebase Setup Guide

Complete guide for configuring Firebase for Height Banana.

## Prerequisites
- Google account
- Flutter installed
- Project cloned

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name: `height-banana`
4. Click "Create project"

## Step 2: Add Android App

1. Click "Add app" → Android
2. Package name: `com.psilore.height_banana`
3. Download `google-services.json`
4. Place in `android/app/`

## Step 3: Enable Authentication

1. Go to Authentication → Sign-in method
2. Enable Google provider
3. Add support email

## Step 4: Enable Firestore

1. Go to Firestore Database
2. Click "Create database"
3. Start in production mode
4. Add security rules (see below)

### Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /training_sessions/{sessionId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
  }
}
```

## Step 5: Update Android Config

Add to `android/build.gradle`:
```gradle
classpath 'com.google.gms:google-services:4.4.1'
```

Add to `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

Done! Run `flutter run` to test.
