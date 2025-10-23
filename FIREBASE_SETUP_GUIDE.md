# 🔥 Firebase Setup Guide for StrideBase

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. Enter project name: `stridebase` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Choose your region

## Step 2: Add Android App

1. In Firebase Console, click **"Add app"** → **Android**
2. **Package name**: `com.mycompany.CounterApp`
3. **App nickname**: `StrideBase Android`
4. Click **"Register app"**
5. **Download** the `google-services.json` file
6. **Replace** the file at `android/app/google-services.json` with your downloaded file

## Step 3: Add Web App

1. Click **"Add app"** → **Web**
2. **App nickname**: `StrideBase Web`
3. Click **"Register app"**
4. **Copy** the Firebase configuration object (it looks like this):

```javascript
const firebaseConfig = {
  apiKey: "your-api-key",
  authDomain: "your-project-id.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project-id.appspot.com",
  messagingSenderId: "123456789",
  appId: "your-app-id"
};
```

5. **Replace** the config in `web/index.html` with your actual config

## Step 4: Enable Authentication

1. Go to **Authentication** → **Sign-in method**
2. Click **Email/Password**
3. **Enable** the first toggle (Email/Password)
4. Click **Save**

## Step 5: Enable Firestore Database

1. Go to **Firestore Database**
2. Click **Create database**
3. Choose **"Start in test mode"** (for development)
4. Select a location close to your users
5. Click **Done**

## Step 6: Test Your App

1. Run your app:
   ```bash
   flutter run
   ```

2. Try to sign up with a new email
3. Try to sign in
4. Add items to cart
5. Check if everything works!

## Troubleshooting

### If you get "Firebase is not initialized" error:
- Make sure you replaced `android/app/google-services.json` with your real file
- Make sure you updated the config in `web/index.html`
- Run `flutter clean` and `flutter pub get`

### If authentication doesn't work:
- Check that Email/Password is enabled in Firebase Console
- Make sure your package name matches exactly: `com.mycompany.CounterApp`

### If cart doesn't save:
- Check that Firestore Database is created
- Make sure you're signed in before adding to cart

## Your Firebase Collections

The app will automatically create these collections in Firestore:

- `users` - User profiles
- `shoes` - Product catalog
- `cart` - Shopping cart items
- `orders` - Order history

## Security Rules (Optional)

For production, update your Firestore rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Cart items are user-specific
    match /cart/{cartItemId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Orders are user-specific
    match /orders/{orderId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Shoes are readable by everyone
    match /shoes/{shoeId} {
      allow read: if true;
      allow write: if false; // Only admins should write shoes
    }
  }
}
```

## That's it! 🎉

Your StrideBase app is now fully connected to Firebase and ready to use!
