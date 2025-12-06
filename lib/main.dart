import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'services/auth_service.dart';
import 'screens/match_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
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
              Color(0xFF6BA7FF),
              Color(0xFF007FFF),
              Color(0xFFFF6EC7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.location_on, size: 90, color: Colors.white),
              SizedBox(height: 25),
              Text(
                "ABHINAV TRACKING",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
