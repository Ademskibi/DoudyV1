import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreService() {
    // Enable offline persistence where supported; safe to call repeatedly.
    try {
      _db.settings = const Settings(persistenceEnabled: true);
    } catch (_) {}
  }

  // Generic retry wrapper for transient Firestore errors (e.g. 'unavailable').
  Future<T> _withRetry<T>(Future<T> Function() fn, {int maxAttempts = 5, Duration baseDelay = const Duration(milliseconds: 500)}) async {
    var attempt = 0;
    while (true) {
      try {
        return await fn();
      } catch (e) {
        attempt += 1;
        final isTransient = e is FirebaseException && (e.code == 'unavailable' || e.code == 'deadline-exceeded' || e.code == 'resource-exhausted');
        if (!isTransient || attempt >= maxAttempts) rethrow;

        // Exponential backoff with jitter
        final jitterMs = math.Random().nextInt(200);
        final delayMs = (baseDelay.inMilliseconds * math.pow(2, attempt - 1)).toInt() + jitterMs;
        await Future.delayed(Duration(milliseconds: delayMs));
        // retry
      }
    }
  }

  Future<void> createUserDoc(AppUser user) async {
    final ref = _db.collection('users').doc(user.uid);
    await _withRetry(() => ref.set(user.toMap()));
  }

  Future<AppUser?> getUser(String uid) async {
    final snap = await _withRetry(() => _db.collection('users').doc(uid).get());
    if (!snap.exists) return null;
    return AppUser.fromMap(snap.data()!);
  }
}
