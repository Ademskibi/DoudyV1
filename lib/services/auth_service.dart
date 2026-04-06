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

  // ─── Auth state ────────────────────────────────────────────────────────────

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  bool get isSignedIn => firebaseUser != null;

  // ─── Email + Password sign-up ──────────────────────────────────────────────

  /// Creates a new account with an email, password, and optional username.
  /// If [username] is provided it must be unique — an [Exception] is thrown
  /// before account creation if it is already taken.
  Future<void> signUpWithEmail({
    required String name,
    String? email,
    required String password,
    String role = 'parent',
    String? username,
  }) async {
    // Normalize inputs
    final trimmedName = name.trim();
    final normalizedUsername = username?.trim().toLowerCase();

    // Require either email or username
    if ((email == null || email.trim().isEmpty) && (normalizedUsername == null || normalizedUsername.isEmpty)) {
      throw Exception('Provide either email or username');
    }

    // Reject username that looks like an email
    if (normalizedUsername != null && normalizedUsername.contains('@')) {
      throw Exception('Username must not contain @');
    }

    // If username is provided, ensure availability before touching Auth
    if (normalizedUsername != null && normalizedUsername.isNotEmpty) {
      final taken = await _firestore.isUsernameTaken(normalizedUsername);
      if (taken) throw Exception('Username already taken');
    }

    // Decide which email to use for Firebase Auth
    String authEmail;
    final providedEmail = email?.trim();
    if (providedEmail != null && providedEmail.isNotEmpty) {
      authEmail = providedEmail;
    } else {
      // Build a synthetic email for username-only accounts
      final local = normalizedUsername!.replaceAll(RegExp(r'[^a-z0-9_\-]'), '_');
      authEmail = '${local}__user__@app.local';
    }

    // Create the Firebase Auth user
    final cred = await _auth.createUserWithEmailAndPassword(
      email: authEmail,
      password: password,
    );
    final user = cred.user!;

    // Ensure the new user's token is fresh before writing secured Firestore docs.
    // Some platforms return a user object before the client has a valid ID token
    // that Firestore rules will accept. Force a reload and token refresh.
    try {
      await user.reload();
      await user.getIdToken(true);
    } catch (_) {
      // Ignore — we'll still attempt writes and handle permission errors below.
    }

    // Now persist username mapping (if any) and user document.
    try {
      if (normalizedUsername != null && normalizedUsername.isNotEmpty) {
        try {
          await _firestore.saveUsernameMapping(
            username: normalizedUsername,
            email: authEmail,
            uid: user.uid,
          );
        } on Exception catch (e) {
          // If the write failed due to permissions (token race), try refreshing token once and retry.
          try {
            await user.reload();
            await user.getIdToken(true);
            await _firestore.saveUsernameMapping(
              username: normalizedUsername,
              email: authEmail,
              uid: user.uid,
            );
          } catch (e2) {
            rethrow;
          }
        }
      }

      final app = AppUser(
        uid: user.uid,
        name: trimmedName,
        email: authEmail,
        role: role,
        createdAt: Timestamp.now(),
        username: normalizedUsername,
      );
      await _firestore.createUserDoc(app);

      appUser = app;
      notifyListeners();
    } catch (e) {
      // Rollback: delete the Auth user to avoid orphaned auth accounts
      try {
        await user.delete();
      } catch (_) {}
      rethrow;
    }
  }

  // ─── Email sign-in ─────────────────────────────────────────────────────────

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    appUser = await _firestore.getUser(cred.user!.uid);
    notifyListeners();
  }

  // ─── Username OR email sign-in ─────────────────────────────────────────────

  /// Sign in with either an email address or a username.
  ///
  /// - If [identifier] contains '@' it is treated as an email directly.
  /// - Otherwise it is looked up in the /usernames index to retrieve the
  ///   associated email, then sign-in proceeds normally.
  Future<void> signInWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    final id = identifier.trim();

    if (id.isEmpty || password.isEmpty) {
      throw Exception('Please provide identifier and password');
    }

    final String email;
    if (id.contains('@')) {
      // Direct email login — validate basic email shape
      email = id;
      // Note: deeper validation can be added if desired.
    } else {
      // Username login — try usernames index first, then fallback to users collection
      final uname = id.toLowerCase();
      String? found = await _firestore.getEmailByUsername(uname);
      if (found == null) {
        final user = await _firestore.getUserByUsername(uname);
        if (user == null) throw Exception('Username not found');
        found = user.email;
      }
      email = found!;
    }

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      appUser = await _firestore.getUser(cred.user!.uid);
      notifyListeners();
    } on FirebaseAuthException catch (fae) {
      if (fae.code == 'user-not-found') throw Exception('No account found for that email/username');
      if (fae.code == 'wrong-password') throw Exception('Incorrect password');
      if (fae.code == 'invalid-email') throw Exception('Invalid email address');
      rethrow;
    }
  }

  // ─── Google sign-in ────────────────────────────────────────────────────────

  /// Signs in with Google. Creates a /users doc on first sign-in.
  /// Google users won't have a username until they explicitly set one
  /// via [updateUsername].
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // User cancelled.

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    final user = userCred.user!;

    final existing = await _firestore.getUser(user.uid);
    if (existing == null) {
      // First Google sign-in — create the user doc.
      final app = AppUser(
        uid: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        role: 'parent',
        createdAt: Timestamp.now(),
        photoUrl: user.photoURL,
      );
      await _firestore.createUserDoc(app);
      appUser = app;
    } else {
      appUser = existing;
    }

    notifyListeners();
  }

  // ─── Username management ───────────────────────────────────────────────────

  /// Sets or updates the username for the currently signed-in user.
  /// Throws if [newUsername] is already taken.
  Future<void> updateUsername(String newUsername) async {
    if (appUser == null) throw Exception('Not signed in');

    final normalised = newUsername.trim().toLowerCase();

    // Check availability.
    final taken = await _firestore.isUsernameTaken(normalised);
    if (taken) throw Exception('Username already taken');

    // Remove old username mapping if there was one.
    if (appUser!.username != null) {
      await _firestore.deleteUsernameMapping(appUser!.username!);
    }

    // Save new mapping.
    await _firestore.saveUsernameMapping(
      username: normalised,
      email: appUser!.email,
      uid: appUser!.uid,
    );

    // Update the user doc.
    await _firestore.updateUserDoc(appUser!.uid, {'username': normalised});

    appUser = appUser!.copyWith(username: normalised);
    notifyListeners();
  }

  // ─── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await GoogleSignIn().signOut(); // No-op if not signed in via Google.
    await _auth.signOut();
    appUser = null;
    firebaseUser = null;
    notifyListeners();
  }
}