// 📌 login_page.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool loading = false;
  bool showPass = false;

  static const Color darkBlue = Color(0xFF002D62);

  late AnimationController _anim;
  late Animation<double> fadeAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    fadeAnim = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _anim.forward();
  }

  Future<void> loginUser() async {
    if (mobileCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      _msg("Enter all fields");
      return;
    }

    setState(() => loading = true);

    final ok = await AuthService.login(
      mobileCtrl.text.trim(),
      passCtrl.text.trim(),
    );

    setState(() => loading = false);

    if (!ok) {
      _msg("Invalid credentials");
      return;
    }

    if (AuthService.currentUser == null) {
      _msg("Something went wrong. Try again.");
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(user: AuthService.currentUser!),
      ),
    );
  }

  void _msg(String txt) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(txt)));
  }

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

        child: FadeTransition(
          opacity: fadeAnim,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on,
                    size: 100, color: darkBlue),
                const SizedBox(height: 25),

                const Text(
                  "ABHINAV TRACKING APP",
                  style: TextStyle(
                    color: darkBlue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                _inputBox("Mobile Number", mobileCtrl),
                const SizedBox(height: 20),

                _passwordBox(),
                const SizedBox(height: 35),

                loading
                    ? const CircularProgressIndicator(color: darkBlue)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: darkBlue,
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: loginUser,
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputBox(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: darkBlue),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.90),
        labelText: label,
        labelStyle: const TextStyle(color: darkBlue),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: darkBlue),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _passwordBox() {
    return TextField(
      controller: passCtrl,
      obscureText: !showPass,
      style: const TextStyle(color: darkBlue),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.90),
        labelText: "Password",
        labelStyle: const TextStyle(color: darkBlue),
        suffixIcon: IconButton(
          onPressed: () => setState(() => showPass = !showPass),
          icon: Icon(
            showPass ? Icons.visibility : Icons.visibility_off,
            color: darkBlue,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: darkBlue),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
