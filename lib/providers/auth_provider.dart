import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Initial state is false. We can trigger an async check afterwards.
    checkAuthStatus();
    return false;
  }

  Future<void> checkAuthStatus() async {
    final isAuth = await authService.isAuthenticated();
    state = isAuth;
  }

  Future<void> login(String email, String password) async {
    final success = await authService.login(email, password);
    if (success) {
      state = true;
    }
  }

  Future<void> register(String email, String password) async {
    await authService.register(email, password);
  }

  Future<void> logout() async {
    await authService.logout();
    state = false;
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});
