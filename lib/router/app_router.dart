import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/profile_edit_screen.dart';
import '../screens/allergen_selection_screen.dart';
import '../screens/manual_entry_screen.dart';
import '../screens/scanner_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!authState.isAuthenticated) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile-edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/allergens',
        builder: (context, state) => const AllergenSelectionScreen(),
      ),
      GoRoute(
        path: '/manual-entry',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ManualEntryScreen(extraData: extra);
        },
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
    ],
  );
});
