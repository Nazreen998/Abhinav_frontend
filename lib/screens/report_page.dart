// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool loading = true;
  Map<String, dynamic>? data;

  DateTime startDate = DateTime.now().subtract(const Duration(days: 7)); 

  DateTime endDate = DateTime.now();

  static const Color darkBlue = Color(0xFF002D62);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);

    final startStr =
        "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";

    final endStr =
        "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    final result = await ApiService.getDashboardReport(startStr, endStr);

    if (mounted) {
      setState(() {
        data = result;
        loading = false;
      });
    }
  }

  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else if (minutes > 0) {
      return "${minutes}m ${secs}s";
    } else {
      return "${secs}s";
    }
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  Widget quickChip(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF0F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: Stack(
        children: [
          Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF002D62), Color(0xFF005BBB)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Dashboard",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Performance overview",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: pickStartDate,
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                              "${startDate.day}-${startDate.month}-${startDate.year}"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: darkBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: pickEndDate,
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                              "${endDate.day}-${endDate.month}-${endDate.year}"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: darkBlue,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: loadData,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      quickChip("Today", () {
                        setState(() {
                          startDate = DateTime.now();
                          endDate = DateTime.now();
                        });
                        loadData();
                      }),
                      const SizedBox(width: 8),
                      quickChip("7 Days", () {
                        setState(() {
                          startDate =
                              DateTime.now().subtract(const Duration(days: 7));
                          endDate = DateTime.now();
                        });
                        loadData();
                      }),
                      const SizedBox(width: 8),
                      quickChip("This Month", () {
                        final now = DateTime.now();
                        setState(() {
                          startDate = DateTime(now.year, now.month, 1);
                          endDate = now;
                        });
                        loadData();
                      }),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              buildSummaryCards(),
                              const SizedBox(height: 12),
                              Expanded(child: buildSalesmanList())
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummaryCards() {
    final visits = data?["totalVisits"] ?? 0;
    final calls = data?["totalCalls"] ?? 0;
    final match = data?["totalMatch"] ?? 0;
    final mismatch = data?["totalMismatch"] ?? 0;

    return Row(
      children: [
        Expanded(
            child: summaryMini(Icons.store, "Visits", visits, Colors.blue)),
        const SizedBox(width: 6),
        Expanded(
            child: summaryMini(Icons.phone, "Calls", calls, Colors.orange)),
        const SizedBox(width: 6),
        Expanded(
            child:
                summaryMini(Icons.check_circle, "Match", match, Colors.green)),
        const SizedBox(width: 6),
        Expanded(
            child: summaryMini(Icons.cancel, "Mismatch", mismatch, Colors.red)),
      ],
    );
  }

  Widget summaryMini(IconData icon, String title, int value, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryItem(IconData icon, String title, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value.toString(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ],
    );
  }

  Widget buildSalesmanList() {
    final list = data?["salesmanPerformance"] ?? [];

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final rep = list[i];
        final int duration = rep["callDuration"] ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: darkBlue,
                    child: Text(rep["name"][0],
                        style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Text(rep["name"],
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: stat("Visits", rep["visits"], Colors.blue)),
                  Expanded(child: stat("Calls", rep["calls"], Colors.orange)),
                  Expanded(child: stat("Match", rep["match"], Colors.green)),
                  Expanded(
                      child: stat("Mismatch", rep["mismatch"], Colors.red)),
                  Expanded(child: stat("Duration", duration, Colors.purple)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget stat(String title, int value, Color color) {
    String displayValue;

    if (title == "Duration") {
      displayValue = formatDuration(value);
    } else {
      displayValue = value.toString();
    }

    return Column(
      children: [
        Text(displayValue,
            style: TextStyle(
                fontSize: title == "Duration" ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: color)),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }
}
