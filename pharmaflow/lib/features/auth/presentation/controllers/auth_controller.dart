import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_model.dart';
import '../../data/auth_repository.dart';

class AuthController extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final repo = ref.read(authRepositoryProvider);
    return await repo.getCurrentUserData();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<UserModel?>(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.signInWithEmail(email, password);
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard<UserModel?>(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.signUpWithEmail(
        email: email,
        password: password,
        name: name,
        role: role,
      );
    });
  }

  Future<void> resetPassword(String email) async {
    final previous = state.value;
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(email);
      state = AsyncValue.data(previous);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    final currentUser = state.value;
    if (currentUser == null) return;
    final repo = ref.read(authRepositoryProvider);
    await repo.updateProfilePhoto(currentUser.id, photoUrl);
    state = AsyncValue.data(currentUser.copyWith(photoUrl: photoUrl));
  }
}

// Provider manuel sans annotation @riverpod
final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserModel?>(() {
  return AuthController();
});
