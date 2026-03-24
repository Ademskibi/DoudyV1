import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryProgressService extends ChangeNotifier {
  static const _prefsKey = 'watched_stories';

  final Set<int> _watchedNumbers = {};

  StoryProgressService();

  bool isWatched(int number) => _watchedNumbers.contains(number);

  // For now `isUnlocked` uses the same logic as `isWatched` per requirements.
  bool isUnlocked(int number) => isWatched(number);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey) ?? '';
    if (raw.isEmpty) return;
    final parts = raw.split(',');
    for (final p in parts) {
      final trimmed = p.trim();
      if (trimmed.isEmpty) continue;
      final n = int.tryParse(trimmed);
      if (n != null) _watchedNumbers.add(n);
    }
    notifyListeners();
  }

  Future<void> markWatched(int number) async {
    if (_watchedNumbers.contains(number)) return;
    _watchedNumbers.add(number);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final raw = _watchedNumbers.toList().join(',');
    await prefs.setString(_prefsKey, raw);
  }
}
