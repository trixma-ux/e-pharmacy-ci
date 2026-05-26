import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/patient/presentation/screens/home_screen.dart';
import '../../features/patient/presentation/screens/main_layout_screen.dart';
import '../../features/patient/presentation/screens/cart_screen.dart';
import '../../features/patient/presentation/screens/checkout_screen.dart';
import '../../features/patient/presentation/screens/my_orders_screen.dart';
import '../../features/patient/presentation/screens/pharmacy_map_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/pharmacist/presentation/screens/pharmacist_dashboard_screen.dart';

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final refreshListenable = _AuthRefreshListenable(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authAsync = ref.read(authControllerProvider);
      final user = authAsync.valueOrNull;
      final path = state.matchedLocation;

      const publicPaths = {'/splash', '/onboarding', '/auth'};

      if (path == '/splash') return null;

      if (user == null && !publicPaths.contains(path)) {
        return '/auth';
      }

      if (user != null && user.role == 'pharmacist' && path != '/pharmacist_dashboard') {
        if (!publicPaths.contains(path)) {
          return '/pharmacist_dashboard';
        }
      }

      if (user != null && user.role != 'pharmacist' && path == '/pharmacist_dashboard') {
        return '/main';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) => const MainLayoutScreen(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/my_orders',
        name: 'my_orders',
        builder: (context, state) => const MyOrdersScreen(),
      ),
      GoRoute(
        path: '/pharmacist_dashboard',
        name: 'pharmacist_dashboard',
        builder: (context, state) => const PharmacistDashboardScreen(),
      ),
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) => const PharmacyMapScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
    ],
  );
});
