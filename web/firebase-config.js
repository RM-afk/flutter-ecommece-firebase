// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyBNEAaHly0Jb7RMeCSaFJwfQlTlB7i4UZc",
  authDomain: "flutter-demo-7afeb.firebaseapp.com",
  projectId: "flutter-demo-7afeb",
  storageBucket: "flutter-demo-7afeb.firebasestorage.app",
  messagingSenderId: "922169531651",
  appId: "1:922169531651:web:3d0cc9df82ffaa37c01d36"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase Authentication and get a reference to the service
export const auth = getAuth(app);

// Initialize Cloud Firestore and get a reference to the service
export const db = getFirestore(app);
