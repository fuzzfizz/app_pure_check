import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Listen to Supabase auth state changes natively
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      state = session != null;
    });

    // Initial state
    return Supabase.instance.client.auth.currentSession != null;
  }

  Future<void> login(String email, String password) async {
    await authService.login(email, password);
  }

  Future<void> register(String email, String password) async {
    await authService.register(email, password);
  }

  Future<void> logout() async {
    await authService.logout();
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});
