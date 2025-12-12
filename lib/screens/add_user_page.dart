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

    final autoPassword =
        mobileCtrl.text.substring(6) + "@$role";

    final user = UserModel(
      userId: "",
      name: nameCtrl.text.trim(),
      mobile: mobileCtrl.text.trim(),
      role: role,
      segment: segment,
      password: autoPassword,
    );

    final ok = await userService.addUser(user);

    if (!mounted) return;
    setState(() => loading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User Created\nPassword: $autoPassword")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Create failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add User")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
              validator: (v) => v!.isEmpty ? "Enter name" : null,
            ),
            TextFormField(
              controller: mobileCtrl,
              decoration: const InputDecoration(labelText: "Mobile"),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.length != 10 ? "10 digits" : null,
            ),
            DropdownButtonFormField(
              value: role,
              items: const [
                DropdownMenuItem(value: "master", child: Text("Master")),
                DropdownMenuItem(value: "manager", child: Text("Manager")),
                DropdownMenuItem(value: "salesman", child: Text("Salesman")),
              ],
              onChanged: (v) => role = v.toString(),
            ),
            DropdownButtonFormField(
              value: segment,
              items: const [
                DropdownMenuItem(value: "fmcg", child: Text("FMCG")),
                DropdownMenuItem(value: "pipes", child: Text("PIPES")),
              ],
              onChanged: (v) => segment = v.toString(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : createUser,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Create User"),
            )
          ],
        ),
      ),
    );
  }
}
