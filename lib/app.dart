import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'src/core/theme.dart';
import 'src/providers/app_providers.dart';
import 'src/services/auth_service.dart';
import 'src/screens/splash_screen.dart';
import 'src/screens/auth_screen.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/carbon_tracker_screen.dart';
import 'src/screens/products_screen.dart';
import 'src/screens/challenges_screen.dart';
import 'src/screens/forum_screen.dart';
import 'src/screens/profile_screen.dart';
import 'utils/navigation_helper.dart';


class GreenStepsApp extends StatelessWidget {
  const GreenStepsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: const _AppWithRouter(),
    );
  }
}

class ExitConfirmationWrapper extends StatefulWidget {
  final Widget child;

  const ExitConfirmationWrapper({super.key, required this.child});

  @override
  State<ExitConfirmationWrapper> createState() => _ExitConfirmationWrapperState();
}

class _ExitConfirmationWrapperState extends State<ExitConfirmationWrapper> {
  DateTime? lastBackPressedTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (disposition, result) {
        // Only intercept system back if we are on the home screen
        final now = DateTime.now();
        final shouldExit = lastBackPressedTime == null ||
            now.difference(lastBackPressedTime!) > const Duration(seconds: 2);

        if (shouldExit) {
          lastBackPressedTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // allow pop → exit app
          Navigator.of(context).maybePop();
        }

        // Return void, not Future
      },
      child: widget.child,
    );
  }
}



class _AppWithRouter extends StatelessWidget {
  const _AppWithRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final router = _createRouter(context);
        return MaterialApp.router(
          title: 'GreenSteps - Sustainable Living Guide',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: router,
        );
      },
    );
  }

  GoRouter _createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final authService = context.read<AuthService>();
        final isAuthenticated = authService.isAuthenticated;
        final isSplash = state.matchedLocation == '/splash';

        if (isSplash) return null;
        if (!isAuthenticated && state.matchedLocation != '/auth') return '/auth';
        if (isAuthenticated && state.matchedLocation == '/auth') return '/home';

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => ExitConfirmationWrapper(child: const HomeScreen()),
        ),
        GoRoute(
          path: '/carbon-tracker',
          builder: (context, state) => const CarbonTrackerScreen(),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductsScreen(),
        ),
        GoRoute(
          path: '/challenges',
          builder: (context, state) => const ChallengesScreen(),
        ),
        GoRoute(
          path: '/forum',
          builder: (context, state) => const ForumScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    );
  }
}