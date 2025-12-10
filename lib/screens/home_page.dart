import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'assigned_shops_screen.dart';
import 'shop_list_page.dart';
import 'pending_shops_page.dart';
import 'user_list_page.dart';
import 'assign_shop_page.dart';
import 'next_shop_page.dart';
import 'log_history_filter_page.dart';
import 'add_shop_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const Color darkBlue = Color(0xFF002D62);

  late AnimationController _controller;
  late Animation<double> fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  Future<void> logout() async {
    AuthService.logout(); // ensure token cleared
    Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    final String name = user["name"]?.toString() ?? "User";
    final String mobile = user["mobile"]?.toString() ?? "-";
    final String role = user["role"]?.toString().toLowerCase() ?? "";
    final String segment = user["segment"]?.toString() ?? "-";
    final String userId = user["user_id"]?.toString() ?? "";

    final bool isMaster = role == "master";
    final bool isManager = role == "manager";
    final bool isSalesman = role == "salesman";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout, color: darkBlue, size: 28),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,

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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 70),

              // ---------------- WELCOME CARD ----------------
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.90),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome",
                      style: TextStyle(color: darkBlue, fontSize: 14),
                    ),
                    const SizedBox(height: 5),

                    Text(
                      name,
                      style: const TextStyle(
                        color: darkBlue,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text("Mobile: $mobile",
                        style: const TextStyle(color: darkBlue)),
                    Text("Role: ${role.toUpperCase()}",
                        style: const TextStyle(color: darkBlue)),
                    Text("Segment: $segment",
                        style: const TextStyle(color: darkBlue)),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ---------------- HOME GRID ----------------
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,

                children: [
                  // HISTORY
                  _tile(Icons.history, "History Log", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogHistoryFilterPage(user: widget.user),
                      ),
                    );
                  }),

                  // SHOP LIST
                  _tile(Icons.storefront, "Shop List", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShopListPage(user: widget.user),
                      ),
                    );
                  }),

                  // PENDING SHOPS (Managers + Masters)
                  if (isMaster || isManager)
                    _tile(Icons.pending_actions, "Pending Shops", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PendingShopsPage(user: widget.user),
                        ),
                      );
                    }),

                  // ASSIGNED SHOPS LIST
                  if (isMaster || isManager)
                    _tile(Icons.list_alt, "Assigned Shops", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AssignedShopsScreen(
                           user: widget.user,   // ✅ CORRECT
                          ),
                        ),
                      );
                    }),

                  // ASSIGN SHOPS PAGE
                  if (isMaster || isManager)
                    _tile(Icons.map, "Assign Shops", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AssignShopPage()),
                      );
                    }),

                  // USER LIST (Master Only)
                  if (isMaster)
                    _tile(Icons.people_alt, "User List", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UserListPage()),
                      );
                    }),

                  // ADD SHOP (Salesman Only)
                  if (isSalesman)
                    _tile(Icons.add_business, "Add Shop", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddShopPage()),
                      );
                    }),

                  // NEXT SHOP (Salesman Only)
                  if (isSalesman)
                    _tile(Icons.directions_walk, "Next Shop", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NextShopPage()),
                      );
                    }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------- GRID TILE WIDGET -------------------
  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.90),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.28),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: darkBlue),
            const SizedBox(height: 10),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkBlue,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
