import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile_model.dart';
import '../repositories/profile_repository.dart';
import 'auth_provider.dart';
import 'firestore_provider.dart';

final profileErrorProvider = StateProvider<String?>((ref) => null);

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfileModel?>(
  ProfileController.new,
);

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ProfileRepository(firestoreService);
});

class ProfileController extends AsyncNotifier<UserProfileModel?> {

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

    final repository = ref.read(profileRepositoryProvider);
    final cachedProfile = await repository.getCachedProfile(userId);

    try {
      final remoteProfile = await repository.getRemoteProfile(userId);

      if (remoteProfile != null) {
        await repository.cacheProfile(userId, remoteProfile);
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
      final repository = ref.read(profileRepositoryProvider);
      await repository.cacheProfile(userId, profile);
      await repository.saveRemoteProfile(userId, profile);
      return profile;
    });

    if (state.hasError) {
      ref.read(profileErrorProvider.notifier).state =
          'No se pudo guardar el perfil. Inténtalo nuevamente.';
      state = AsyncData(profile);
    }
  }

  Future<void> syncProfileOnLogin() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      return;
    }

    ref.read(profileErrorProvider.notifier).state = null;
    final repository = ref.read(profileRepositoryProvider);

    final cachedProfile = await repository.getCachedProfile(userId);

    try {
      final remoteProfile = await repository.getRemoteProfile(userId);

      if (remoteProfile != null) {
        await repository.cacheProfile(userId, remoteProfile);
        state = AsyncData(remoteProfile);
        return;
      }

      if (cachedProfile != null) {
        await repository.saveRemoteProfile(userId, cachedProfile);
        state = AsyncData(cachedProfile);
        return;
      }

      final now = DateTime.now();
      final newProfile = UserProfileModel.empty(userId).copyWith(
        name: 'Usuario',
        createdAt: now,
        updatedAt: now,
      );

      await repository.cacheProfile(userId, newProfile);
      await repository.saveRemoteProfile(userId, newProfile);
      state = AsyncData(newProfile);
    } catch (_) {
      if (cachedProfile != null) {
        state = AsyncData(cachedProfile);
      }
      ref.read(profileErrorProvider.notifier).state =
          'No se pudo sincronizar el perfil al iniciar sesión.';
    }
  }

}
