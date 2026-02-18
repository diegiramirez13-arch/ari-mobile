import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile_model.dart';
import 'auth_provider.dart';
import 'firestore_provider.dart';

final profileErrorProvider = StateProvider<String?>((ref) => null);

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfileModel?>(
  ProfileController.new,
);

class ProfileController extends AsyncNotifier<UserProfileModel?> {
  static const _cachePrefix = 'profile_cache_';

  @override
  Future<UserProfileModel?> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      return null;
    }

    return _loadProfile(userId);
  }

  Future<UserProfileModel?> _loadProfile(String userId) async {
    ref.read(profileErrorProvider.notifier).state = null;

    final cachedProfile = await _getCachedProfile(userId);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final remoteProfile = await firestoreService.getProfile(userId);

      if (remoteProfile != null) {
        await _cacheProfile(userId, remoteProfile);
        return remoteProfile;
      }

      return cachedProfile;
    } catch (e) {
      ref.read(profileErrorProvider.notifier).state =
          'No se pudo cargar el perfil desde Firebase.';
      return cachedProfile;
    }
  }

  Future<void> refreshProfile() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadProfile(userId));
  }

  Future<void> saveProfile({
    required String name,
    String? bio,
    String? occupation,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = AsyncError(Exception('Usuario no autenticado'), StackTrace.current);
      return;
    }

    final previous = state.value;
    final now = DateTime.now();
    final profile = (previous ?? UserProfileModel.empty(userId)).copyWith(
      name: name.trim(),
      bio: bio?.trim().isEmpty == true ? null : bio?.trim(),
      occupation:
          occupation?.trim().isEmpty == true ? null : occupation?.trim(),
      createdAt: previous?.createdAt ?? now,
      updatedAt: now,
    );

    state = const AsyncLoading();
    ref.read(profileErrorProvider.notifier).state = null;

    state = await AsyncValue.guard(() async {
      await _cacheProfile(userId, profile);
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.saveProfile(userId, profile);
      return profile;
    });

    if (state.hasError) {
      ref.read(profileErrorProvider.notifier).state =
          'No se pudo guardar el perfil. Inténtalo nuevamente.';
      state = AsyncData(profile);
    }
  }

  Future<UserProfileModel?> _getCachedProfile(String userId) async {
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

  Future<void> _cacheProfile(String userId, UserProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_cachePrefix$userId', jsonEncode(profile.toMap()));
  }
}
