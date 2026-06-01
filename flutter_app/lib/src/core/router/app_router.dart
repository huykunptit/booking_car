import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_provider.dart';
import 'go_router_refresh.dart';
import '../../features/auth/forgot_password/forgot_password_screen.dart';
import '../../features/auth/login/login_screen.dart';
import '../../features/auth/register/register_screen.dart';
import '../../features/auth/reset_password/reset_password_screen.dart';
import '../../features/bookings/booking_create_screen.dart';
import '../../features/bookings/booking_detail_screen.dart';
import '../../features/bookings/booking_history_screen.dart';
import '../../features/booking/booking_pickup_dropoff_screen.dart';
import '../../features/cars/car_detail_screen.dart';
import '../../features/cars/car_list_screen.dart';
import '../../features/cars/car_tracking_screen.dart';
import '../../features/home/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  final refresh = GoRouterRefreshNotifier(auth);
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = auth.isAuthenticated;
      final inAuthFlow = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';
      if (!loggedIn && !inAuthFlow) return '/login';
      if (loggedIn && inAuthFlow) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/cars', builder: (context, state) => const CarListScreen()),
      GoRoute(
        path: '/cars/:id',
        builder: (context, state) => CarDetailScreen(carId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/cars/:id/book',
        builder: (context, state) => BookingCreateScreen(carId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/cars/:id/tracking',
        builder: (context, state) => CarTrackingScreen(carId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/bookings', builder: (context, state) => const BookingHistoryScreen()),
      GoRoute(
        path: '/bookings/:id',
        builder: (context, state) => BookingDetailScreen(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/bookings/:id/pickup-dropoff',
        builder: (context, state) => BookingPickupDropoffScreen(bookingId: state.pathParameters['id']!),
      ),
    ],
  );
});
