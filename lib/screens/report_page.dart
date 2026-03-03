// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const DashboardPage({
    super.key,
    required this.user,
  });

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

    final result = await ApiService.getDashboardReport(
      startStr,
      endStr,
    );

    if (mounted) {
      setState(() {
        data = result;
        loading = false;
      });
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
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
          // 🔵 HEADER GRADIENT
          Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF002D62),
                  Color(0xFF005BBB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Performance overview",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 📅 DATE RANGE
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: pickStartDate,
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            "${startDate.day}-${startDate.month}-${startDate.year}",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: darkBlue,
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: pickEndDate,
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            "${endDate.day}-${endDate.month}-${endDate.year}",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: darkBlue,
                            elevation: 0,
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

                  // ⚡ QUICK FILTERS
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

                  // 📊 CONTENT CARD
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: loading
                          ? const Center(child: CircularProgressIndicator())
                          : (data == null)
                              ? const Center(child: Text("No data"))
                              : Column(
                                  children: [
                                    buildSummaryCards(),
                                    const SizedBox(height: 20),
                                    Expanded(child: buildSalesmanList()),
                                  ],
                                ),
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
    final totalVisits = data?["totalVisits"] ?? 0;
    final totalMatch = data?["totalMatch"] ?? 0;
    final totalMismatch = data?["totalMismatch"] ?? 0;

    final List reps = List.from(data?["salesmanPerformance"] ?? []);

    final activeReps = reps.length;

    final matchPercent =
        totalVisits == 0 ? 0 : ((totalMatch / totalVisits) * 100).round();

    final avgPerRep =
        activeReps == 0 ? 0 : (totalVisits / activeReps).toStringAsFixed(1);
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        summaryCard("Total Visits", totalVisits.toString()),
        summaryCard("Match %", "$matchPercent%"),
        summaryCard("Active Reps", activeReps.toString()),
        summaryCard("Avg / Rep", avgPerRep.toString()),
      ],
    );
  }

  Widget summaryCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSalesmanList() {
    final list = data!["salesmanPerformance"] as List;

    if (list.isEmpty) {
      return const Center(child: Text("No reps data"));
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) {
        final rep = list[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  rep["name"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text("Visits: ${rep["visits"]}"),
              const SizedBox(width: 10),
              Text("Match: ${rep["match"]}"),
            ],
          ),
        );
      },
    );
  }
}
