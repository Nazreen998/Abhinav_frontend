// ignore_for_file: prefer_const_constructors, deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'services/auth_service.dart';
import 'screens/match_page.dart';
import 'services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
   await initializeBackgroundService();
  runApp(const AbhinavApp());
}

class AbhinavApp extends StatefulWidget {
  const AbhinavApp({super.key});

  @override
  State<AbhinavApp> createState() => _AbhinavAppState();
}

class _AbhinavAppState extends State<AbhinavApp> {
  Widget currentPage = const SplashScreen();

  @override
  void initState() {
    super.initState();
    _loadInitialUser();
  }

  Future<void> _loadInitialUser() async {
    await Future.delayed(const Duration(seconds: 2));

    if (AuthService.token != null && AuthService.currentUser != null) {
      setState(() {
        currentPage = HomePage(user: AuthService.currentUser!);
      });
    } else {
      setState(() {
        currentPage = const LoginPage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Abhinav Tracking",
      debugShowCheckedModeBanner: false,
      home: currentPage,
      routes: {
        "/login": (_) => const LoginPage(),
        "/home": (_) {
          if (AuthService.currentUser == null) {
            return const LoginPage();
          }
          return HomePage(user: AuthService.currentUser!);
        },
        "/match": (context) => MatchPage(
              shop: ModalRoute.of(context)!.settings.arguments,
            ),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF002D62),
              Color(0xFF005BBB),
              Color(0xFF1A73E8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔵 App Logo (Replace with your asset if needed)
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "ABHINAV TRACKING",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Smart Field Monitoring",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
