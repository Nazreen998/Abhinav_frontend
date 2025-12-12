import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../utils/date_utils.dart';


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
  late TextEditingController passwordCtrl;

  String role = "salesman";
  String segment = "fmcg";

  @override
  void initState() {
    super.initState();

    nameCtrl = TextEditingController(text: widget.user.name);
    mobileCtrl = TextEditingController(text: widget.user.mobile);

    // ⭐ password auto-fill (last 4 digits logic fallback)
    passwordCtrl = TextEditingController(
      text: widget.user.password ??
          widget.user.mobile.substring(widget.user.mobile.length - 4),
    );

    role = widget.user.role;
    segment = widget.user.segment;
  }

  Future<void> save() async {
  print("SAVE CLICKED");

  if (!_formKey.currentState!.validate()) {
    print("FORM INVALID");
    return;
  }

  print("FORM VALID");

    final updated = UserModel(
      id: widget.user.id,
      userId: widget.user.userId,
      name: nameCtrl.text.trim(),
      mobile: mobileCtrl.text.trim(),
      role: role,
      segment: segment,
      password: passwordCtrl.text.trim(), // ✅ INCLUDE PASSWORD
    );

    bool ok = await userService.updateUser(updated);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "User Updated Successfully" : "Update Failed"),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );

    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit User"),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field(nameCtrl, "Name"),
            _field(mobileCtrl, "Mobile", keyboard: TextInputType.phone),
            _field(passwordCtrl, "Password"),

            const SizedBox(height: 16),

            DropdownButtonFormField(
              value: role,
              decoration: _decor("Role"),
              items: const [
                DropdownMenuItem(value: "master", child: Text("Master")),
                DropdownMenuItem(value: "manager", child: Text("Manager")),
                DropdownMenuItem(value: "salesman", child: Text("Salesman")),
              ],
              onChanged: (v) => setState(() => role = v.toString()),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField(
              value: segment,
              decoration: _decor("Segment"),
              items: const [
                DropdownMenuItem(value: "all", child: Text("ALL")),
                DropdownMenuItem(value: "fmcg", child: Text("FMCG")),
                DropdownMenuItem(value: "pipes", child: Text("PIPES")),
              ],
              onChanged: (v) => setState(() => segment = v.toString()),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: save,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        decoration: _decor(label),
        validator: (v) => v!.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  InputDecoration _decor(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
