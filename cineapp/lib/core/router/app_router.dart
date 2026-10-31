import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/movies/presentation/screens/home_screen.dart';
import '../../features/movies/presentation/screens/movie_detail_screen.dart';
import '../../features/movies/presentation/screens/search_screen.dart';
import '../../features/booking/presentation/screens/choose_session_screen.dart';
import '../../features/booking/presentation/screens/choose_tickets_screen.dart';
import '../../features/booking/presentation/screens/booking_summary_screen.dart';
import '../../features/booking/presentation/screens/payment_screen.dart';
import '../../features/booking/presentation/screens/booking_confirmation_screen.dart';
import '../../features/tickets/presentation/screens/tickets_screen.dart';
import '../../features/tickets/presentation/screens/ticket_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../widgets/main_scaffold.dart';

class AppRoutes {
  // Auth
  static const login = '/login';
  static const register = '/register';
  // Main flow
  static const home = '/home';
  static const movieDetail = '/movie/:id';
  static const chooseSession = '/book/session';
  static const chooseTickets = '/book/tickets';
  static const bookingSummary = '/book/summary';
  static const payment = '/book/payment';
  static const bookingConfirmation = '/book/confirmation';
  // Tabs
  static const search = '/search';
  static const tickets = '/tickets';
  static const ticketDetail = '/tickets/:ticketId';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
}

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    refreshListenable: notifier,
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoggedIn = ref.read(authProvider).isAuthenticated;
      final isOnAuthRoute = state.uri.path.startsWith('/login') ||
          state.uri.path.startsWith('/register');
      if (!isLoggedIn && !isOnAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isOnAuthRoute) return AppRoutes.home;
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterScreen(),
      ),

      // Main app — com BottomNav via ShellRoute
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, _) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.search,
            builder: (_, _) => const SearchScreen(),
          ),
          GoRoute(
            path: AppRoutes.tickets,
            builder: (_, _) => const TicketsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, _) => const ProfileScreen(),
          ),
        ],
      ),

      // Fora do ShellRoute (sem bottom nav)
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (_, _) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.movieDetail,
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MovieDetailScreen(movieId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.chooseSession,
        builder: (_, _) => const ChooseSessionScreen(),
      ),
      GoRoute(
        path: AppRoutes.chooseTickets,
        builder: (_, _) => const ChooseTicketsScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookingSummary,
        builder: (_, _) => const BookingSummaryScreen(),
      ),
      GoRoute(
        path: AppRoutes.payment,
        builder: (_, _) => const PaymentScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookingConfirmation,
        builder: (_, _) => const BookingConfirmationScreen(),
      ),
      GoRoute(
        path: AppRoutes.ticketDetail,
        builder: (_, state) {
          final ticketId = state.pathParameters['ticketId']!;
          return TicketDetailScreen(ticketId: ticketId);
        },
      ),
    ],
  );
});
