import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile_model.dart';
import '../services/firestore_service.dart';

class ProfileRepository {
  static const _cachePrefix = 'profile_cache_';

  final FirestoreService _firestoreService;

  ProfileRepository(this._firestoreService);

  Future<UserProfileModel?> getCachedProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_cachePrefix$userId');

    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return UserProfileModel.fromMap(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<UserProfileModel?> getRemoteProfile(String userId) {
    return _firestoreService.getProfile(userId);
  }

  Future<void> saveRemoteProfile(String userId, UserProfileModel profile) {
    return _firestoreService.saveProfile(userId, profile);
  }

  Future<void> cacheProfile(String userId, UserProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_cachePrefix$userId', jsonEncode(profile.toMap()));
  }
}
