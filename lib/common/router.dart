
import 'package:chenbin_app/screens/login_page.dart';
import 'package:go_router/go_router.dart';

import '../screens/about_page.dart';
import '../screens/home_page.dart';

final GoRouter getRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutPage(),
    ),
  ],
);