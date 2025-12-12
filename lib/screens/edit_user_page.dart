import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class EditUserPage extends StatefulWidget {
  final UserModel user;
  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  final userService = UserService();

  late TextEditingController nameCtrl;
  late TextEditingController mobileCtrl;

  String? role;
  String? segment;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.user.name);
    mobileCtrl = TextEditingController(text: widget.user.mobile);
    role = widget.user.role;
    segment = widget.user.segment;
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = UserModel(
      id: widget.user.id,
      userId: widget.user.userId,
      name: nameCtrl.text.trim(),
      mobile: mobileCtrl.text.trim(),
      role: role!,
      segment: segment!,
    );

    final ok = await userService.updateUser(updated);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(ok ? "User Updated Successfully" : "Update Failed"),
      ),
    );

    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit User")),
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
                DropdownMenuItem(value: "all", child: Text("ALL")),
                DropdownMenuItem(value: "fmcg", child: Text("FMCG")),
                DropdownMenuItem(value: "pipes", child: Text("PIPES")),
              ],
              onChanged: (v) => segment = v.toString(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: save,
              child: const Text("Save Changes"),
            )
          ],
        ),
      ),
    );
  }
}
