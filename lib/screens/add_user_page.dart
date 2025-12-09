import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();

  String role = "salesman";
  String segment = "fmcg";

  final userService = UserService();
  bool loading = false;

  Future<void> createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    // AUTO PASSWORD
    final autoPassword =
        mobileCtrl.text.substring(mobileCtrl.text.length - 4) +
            "@${role.toLowerCase()}";

    UserModel u = UserModel(
      id: null,
      userId: "",
      name: nameCtrl.text.trim(),
      mobile: mobileCtrl.text.trim(),
      role: role.toLowerCase(),
      password: autoPassword,
      createdAt: "",
      segment: segment.toLowerCase(),

    );

    bool ok = await userService.addUser(u);

    setState(() => loading = false);

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User Created!\nPassword: $autoPassword")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create user")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF007BFF),
              Color(0xFF66B2FF),
              Color(0xFFB8E0FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                "Add User",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: customInput("Name"),
                        validator: (v) => v!.isEmpty ? "Enter name" : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: mobileCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: customInput("Mobile"),
                        validator: (v) =>
                            v!.length != 10 ? "Enter 10 digit mobile" : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField(
                        value: role,
                        decoration: customInput("Role"),
                        items: const [
                          DropdownMenuItem(
                              value: "master", child: Text("Master")),
                          DropdownMenuItem(
                              value: "manager", child: Text("Manager")),
                          DropdownMenuItem(
                              value: "salesman", child: Text("Salesman")),
                        ],
                        onChanged: (v) => setState(() => role = v.toString()),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField(
                        value: segment,
                        decoration: customInput("Segment"),
                        items: const [
                          DropdownMenuItem(
                              value: "fmcg", child: Text("FMCG")),
                          DropdownMenuItem(
                              value: "pipes", child: Text("PIPES")),
                        ],
                        onChanged: (v) =>
                            setState(() => segment = v.toString()),
                      ),
                      const SizedBox(height: 28),
                      loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: createUser,
                                child: const Text(
                                  "Create User",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration customInput(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
