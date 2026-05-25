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

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AsyncValue.data(null);
  }
}

// Provider manuel sans annotation @riverpod
final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserModel?>(() {
  return AuthController();
});
