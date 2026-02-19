import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'full_network_image_page.dart';

class LogHistoryPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final String segment;
  final String result;
  final DateTime? startDate;
  final DateTime? endDate;

  const LogHistoryPage({
    super.key,
    required this.user,
    required this.segment,
    required this.result,
    this.startDate,
    this.endDate,
  });

  @override
  State<LogHistoryPage> createState() => _LogHistoryPageState();
}

class _LogHistoryPageState extends State<LogHistoryPage> {
  List<dynamic> logs = [];
  bool loading = true;
  String search = "";

  @override
  void initState() {
    super.initState();
    loadLogs();
  }

  // ---------------- LOAD LOGS ---------------- //
  Future<void> loadLogs() async {
    if (!mounted) return;
    setState(() => loading = true);

    final role = widget.user["role"].toString().toLowerCase();
    final userName = widget.user["name"].toString();
    final userSegment = widget.user["segment"].toString();

    // ******** GET FROM VisitLog API ******** //
    List<dynamic> raw = await ApiService.getLogs();

    // ******** MAP TO APP FORMAT (USING VISITLOG) ******** //
    List<dynamic> all = raw.map((l) {
      // 🔥 FIX: dt properly defined
      DateTime dt;

      try {
        if (l["datetime"] != null) {
          dt = DateTime.parse(l["datetime"]);
        } else {
          dt = DateTime.now();
        }
      } catch (e) {
        dt = DateTime.now();
      }

      return {
        "shopName": l["shop_name"] ?? "",
        "salesman": l["salesman_name"] ?? "",
        "photoUrl": l["photo_url"] ?? "",
        "result": l["result"] == "match",
        "distance": double.tryParse(l["distance"].toString()) ?? 0.0,
        "date": DateFormat("dd-MM-yyyy").format(dt),
        "time": DateFormat("HH:mm").format(dt),
        "segment": l["segment"] ?? "",
      };
    }).toList();

    // --------------------------------------------------------------------
    // ROLE BASED FILTERING
    // --------------------------------------------------------------------
    List<dynamic> filtered = all;

    if (role == "salesman") {
      filtered = filtered.where((l) => l["salesman"] == userName).toList();
    }

    if (role == "manager") {
      filtered = filtered
          .where((l) =>
              l["segment"].toString().toUpperCase() ==
              userSegment.toUpperCase())
          .toList();
    }

    // --------------------------------------------------------------------
    // FILTER BY SEGMENT (from filter screen)
    // --------------------------------------------------------------------
    if (widget.segment != "All") {
      filtered = filtered
          .where((l) =>
              l["segment"].toString().toUpperCase() ==
              widget.segment.toUpperCase())
          .toList();
    }

    // --------------------------------------------------------------------
    // FILTER BY RESULT (match/mismatch)
    // --------------------------------------------------------------------
    if (widget.result != "All") {
      bool wantMatch = widget.result.toLowerCase() == "match";
      filtered = filtered.where((l) => l["result"] == wantMatch).toList();
    }

    // --------------------------------------------------------------------
    // FILTER BY DATE RANGE
    // --------------------------------------------------------------------
    if (widget.startDate != null || widget.endDate != null) {
      filtered = filtered.where((l) {
        if (l["date"] == "") return false;

        DateTime dt = DateFormat("dd-MM-yyyy").parse(l["date"]);

        if (widget.startDate != null && dt.isBefore(widget.startDate!)) {
          return false;
        }
        if (widget.endDate != null && dt.isAfter(widget.endDate!)) {
          return false;
        }

        return true;
      }).toList();
    }

    logs = filtered;

    if (!mounted) return;
    setState(() => loading = false);
  }

  // --------------------------------------------------------------------
  // UI STARTS
  // --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final matched = logs.where((l) => l["result"] == true).length;
    final mismatched = logs.where((l) => l["result"] == false).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: Stack(
        children: [
          // ✅ PREMIUM CURVED HEADER
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

                  // ✅ HEADER ROW (BACK + REFRESH)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 26),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Log History",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh,
                            color: Colors.white, size: 26),
                        onPressed: loadLogs,
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Matches & mismatches overview",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ✅ FLOATING WHITE CARD BODY
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
                      child: Column(
                        children: [
                          // 🔍 PREMIUM SEARCH BAR
                          buildSearchBar(),

                          const SizedBox(height: 18),

                          // 📊 PREMIUM PIE CHART
                          buildPieChart(matched, mismatched),

                          const SizedBox(height: 10),

                          // ✅ LOG LIST
                          Expanded(child: buildList()),
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

  Widget buildSearchBar() {
    return TextField(
      onChanged: (v) => setState(() => search = v),
      decoration: InputDecoration(
        hintText: "Search shop...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xFFF4F7FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildPieChart(int match, int mismatch) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.withOpacity(0.10),
        ),
      ),
      child: SizedBox(
        height: 210,
        child: PieChart(
          PieChartData(
            centerSpaceRadius: 50,
            sectionsSpace: 4,
            sections: [
              PieChartSectionData(
                color: Colors.green,
                value: match.toDouble(),
                title: "Match\n$match",
                radius: 65,
                titleStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                color: Colors.red,
                value: mismatch.toDouble(),
                title: "Mismatch\n$mismatch",
                radius: 65,
                titleStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildList() {
    if (loading) return const Center(child: CircularProgressIndicator());

    final result = logs.where((l) {
      return l["shopName"].toLowerCase().contains(search.toLowerCase());
    }).toList();

    if (result.isEmpty) return const Center(child: Text("No logs found"));

    return ListView.builder(
      itemCount: result.length,
      itemBuilder: (_, i) {
        final log = result[i];
        final isMatch = log["result"] == true;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: Colors.blue.withOpacity(0.06),
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,

            // ✅ IMAGE
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullNetworkImagePage(
                      imageUrl: log["photoUrl"],
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFF4F7FC),
                backgroundImage: log["photoUrl"] != ""
                    ? NetworkImage(log["photoUrl"])
                    : null,
                child: log["photoUrl"] == ""
                    ? const Icon(Icons.photo, color: Colors.black54)
                    : null,
              ),
            ),

            // ✅ TITLE
            title: Text(
              "${log["shopName"]} (${isMatch ? "MATCH" : "MISMATCH"})",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isMatch ? Colors.green : Colors.red,
              ),
            ),

            // ✅ SUBTITLE WITH SPACING FIX
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  "${log["date"]} @ ${log["time"]}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  "Salesman: ${log["salesman"]}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            // ✅ DISTANCE BADGE
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7FC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                "${log["distance"].toStringAsFixed(1)} m",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF002D62),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
