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

const String appLogo =
    "https://res.cloudinary.com/de46qan00/image/upload/v1765565348/logo_bbvbky.png";

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
  late Animation<Offset> slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> logout() async {
    AuthService.logout();
    Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    final String name = user["name"]?.toString() ?? "User";
    final String mobile = user["mobile"]?.toString() ?? "-";
    final String role =
        user["role"]?.toString().toLowerCase() ?? "";
    final String segment = user["segment"]?.toString() ?? "-";

    final bool isMaster = role == "master";
    final bool isManager = role == "manager";
    final bool isSalesman = role == "salesman";

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,


        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout,
                color: darkBlue, size: 28),
          ),
        ],
      ),

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
              const SizedBox(height: 80),

              // WELCOME CARD
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
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
                    const Text("Welcome",
                        style: TextStyle(
                            color: darkBlue, fontSize: 14)),
                    const SizedBox(height: 5),
                    Text(
                      name,
                      style: const TextStyle(
                          color: darkBlue,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text("Mobile: $mobile",
                        style:
                            const TextStyle(color: darkBlue)),
                    Text("Role: ${role.toUpperCase()}",
                        style:
                            const TextStyle(color: darkBlue)),
                    Text("Segment: $segment",
                        style:
                            const TextStyle(color: darkBlue)),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // GRID
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                children: [
                  _tile(Icons.history, "History Log", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LogHistoryFilterPage(
                                user: widget.user),
                      ),
                    );
                  }),

                  _tile(Icons.storefront, "Shop List", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ShopListPage(user: widget.user),
                      ),
                    );
                  }),

                  if (isMaster || isManager)
                    _tile(Icons.pending_actions,
                        "Pending Shops", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PendingShopsPage(
                                  user: widget.user),
                        ),
                      );
                    }),

                  if (isMaster || isManager)
                    _tile(Icons.list_alt,
                        "Assigned Shops", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AssignedShopsScreen(
                                  user: widget.user),
                        ),
                      );
                    }),

                  if (isMaster || isManager)
                    _tile(Icons.map, "Assign Shops", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AssignShopPage(),
                        ),
                      );
                    }),

                  if (isMaster)
                    _tile(Icons.people_alt, "User List",
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const UserListPage(),
                        ),
                      );
                    }),

                  if (isSalesman)
                    _tile(Icons.add_business, "Add Shop",
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddShopPage(),
                        ),
                      );
                    }),

                  if (isSalesman)
                    _tile(Icons.directions_walk,
                        "Next Shop", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NextShopPage(),
                        ),
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

  Widget _tile(
      IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
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
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
