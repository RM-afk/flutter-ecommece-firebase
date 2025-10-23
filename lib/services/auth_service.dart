import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stridebase/models/user_model.dart';
import 'package:stridebase/services/backend_status.dart';

class AuthService {
  FirebaseAuth get _auth {
    if (!BackendStatus.isFirebaseAvailable) {
      throw StateError(
          'Firebase is not initialized. Please check your Firebase configuration.');
    }
    return FirebaseAuth.instance;
  }

  FirebaseFirestore get _firestore {
    if (!BackendStatus.isFirebaseAvailable) {
      throw StateError(
          'Firebase is not initialized. Please check your Firebase configuration.');
    }
    return FirebaseFirestore.instance;
  }

  User? get currentUser {
    if (!BackendStatus.isFirebaseAvailable) return null;
    return FirebaseAuth.instance.currentUser;
  }

  Stream<User?> get authStateChanges {
    if (!BackendStatus.isFirebaseAvailable) {
      // When backend isn't available, expose a stable stream of null.
      return Stream<User?>.value(null);
    }
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<UserModel?> signUp(
      {required String email,
      required String password,
      required String name}) async {
    if (!BackendStatus.isFirebaseAvailable) {
      throw StateError(
          'Sign up requires Firebase. Please check your Firebase configuration.');
    }
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    if (credential.user != null) {
      final now = DateTime.now();
      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        createdAt: now,
        updatedAt: now,
      );
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toJson());
      return userModel;
    }
    return null;
  }

  Future<UserModel?> signIn(
      {required String email, required String password}) async {
    if (!BackendStatus.isFirebaseAvailable) {
      throw StateError(
          'Sign in requires Firebase. Please check your Firebase configuration.');
    }
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (currentUser != null) {
      return await getUserData(currentUser!.uid);
    }
    return null;
  }

  Future<void> signOut() async {
    if (!BackendStatus.isFirebaseAvailable) return;
    await _auth.signOut();
  }

  Future<UserModel?> getUserData(String userId) async {
    if (!BackendStatus.isFirebaseAvailable) return null;
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }
}
