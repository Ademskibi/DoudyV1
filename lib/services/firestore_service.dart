import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── User document ────────────────────────────────────────────────────────

  Future<void> createUserDoc(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return AppUser.fromMap(snap.data()!);
  }

  Future<void> updateUserDoc(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // ─── Username index ────────────────────────────────────────────────────────

  /// Returns the email mapped to [username], or null if not found.
  Future<String?> getEmailByUsername(String username) async {
    final docId = username.toLowerCase();
    final snap = await _db.collection('usernames').doc(docId).get();
    if (!snap.exists || snap.data() == null) return null;
    final data = snap.data()!;
    return data['email'] as String?;
  }

  /// Returns true if [username] is already taken.
  Future<bool> isUsernameTaken(String username) async {
    final email = await getEmailByUsername(username);
    return email != null;
  }

  /// Finds a user document by `username` field in the `users` collection.
  /// This acts as a fallback in case the `usernames` index is missing.
  Future<AppUser?> getUserByUsername(String username) async {
    final q = await _db
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return AppUser.fromMap(q.docs.first.data());
  }

  /// Saves a username → {email, uid} mapping in the /usernames index.
  Future<void> saveUsernameMapping({
    required String username,
    required String email,
    required String uid,
  }) async {
    final docId = username.toLowerCase();
    await _db.collection('usernames').doc(docId).set({
      'email': email,
      'uid': uid,
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a username mapping (useful if the user changes their username).
  Future<void> deleteUsernameMapping(String username) async {
    await _db.collection('usernames').doc(username.toLowerCase()).delete();
  }
}