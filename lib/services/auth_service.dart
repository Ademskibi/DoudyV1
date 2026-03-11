import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';
import 'firestore_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  User? firebaseUser;
  AppUser? appUser;

  AuthService() {
    _auth.authStateChanges().listen((u) async {
      firebaseUser = u;
      if (u != null) {
        appUser = await _firestore.getUser(u.uid);
      } else {
        appUser = null;
      }
      notifyListeners();
    });
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    String role = 'parent',
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    final app = AppUser(
      uid: user.uid,
      name: name,
      email: email,
      role: role,
      createdAt: Timestamp.now(),
    );
    await _firestore.createUserDoc(app);
    appUser = app;
    notifyListeners();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final u = cred.user!;
    appUser = await _firestore.getUser(u.uid);
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCred = await _auth.signInWithCredential(credential);
    final user = userCred.user!;
    final existing = await _firestore.getUser(user.uid);
    if (existing == null) {
      final app = AppUser(
        uid: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        role: 'parent',
        createdAt: Timestamp.now(),
      );
      await _firestore.createUserDoc(app);
      appUser = app;
    } else {
      appUser = existing;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    appUser = null;
    firebaseUser = null;
    notifyListeners();
  }
}
