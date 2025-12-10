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
    final userId = widget.user["user_id"];
    final segment = widget.user["segment"];

    // ******** GET FROM REAL API ******** //
    List<dynamic> raw = await ApiService.getLogs(role, segment, userId);

    // ******** MAP TO APP FORMAT ******** //
    List<dynamic> all = raw.map((l) {
      DateTime dt = DateTime.parse(l["created_at"]);

      return {
        "shopName": l["shop_name"] ?? "",
        "salesman": l["salesman_name"] ?? "",
        "photoUrl": l["imageUrl"] ?? "",
        "match": l["match"] == true,
        "distance": (l["distance"] ?? 0).toDouble(),
        "date": DateFormat("dd-MM-yyyy").format(dt),
        "time": DateFormat("hh:mm a").format(dt),
        "segment": l["segment"] ?? "",
      };
    }).toList();

    // --------------------------------------------------------------------
    // ROLE BASED FILTERING
    // --------------------------------------------------------------------
    List<dynamic> filtered = all;

    if (role == "salesman") {
      filtered = filtered.where((l) => l["salesman"] == widget.user["name"]).toList();
    }

    if (role == "manager") {
      filtered = filtered.where((l) =>
          l["segment"].toString().toLowerCase() ==
              segment.toLowerCase()).toList();
    }

    // --------------------------------------------------------------------
    // FILTER BY SEGMENT (from filter screen)
    // --------------------------------------------------------------------
    if (widget.segment != "All") {
      filtered = filtered.where((l) =>
          l["segment"].toString().toUpperCase() ==
              widget.segment.toUpperCase()).toList();
    }

    // --------------------------------------------------------------------
    // FILTER BY RESULT (match/mismatch)
    // --------------------------------------------------------------------
    if (widget.result != "All") {
      bool wantMatch = widget.result.toLowerCase() == "match";
      filtered = filtered.where((l) => l["match"] == wantMatch).toList();
    }

    // --------------------------------------------------------------------
    // FILTER BY DATE RANGE
    // --------------------------------------------------------------------
    if (widget.startDate != null || widget.endDate != null) {
      filtered = filtered.where((l) {
        DateTime dt = DateFormat("dd-MM-yyyy").parse(l["date"]);

        if (widget.startDate != null && dt.isBefore(widget.startDate!)) return false;
        if (widget.endDate != null && dt.isAfter(widget.endDate!)) return false;

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
    final matched = logs.where((l) => l["match"] == true).length;
    final mismatched = logs.where((l) => l["match"] == false).length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007BFF), Color(0xFF66B2FF), Color(0xFFB8E0FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        size: 28, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: loadLogs,
                  ),
                  const Text(
                    "Log History",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      buildSearchBar(),
                      buildPieChart(matched, mismatched),
                      Expanded(child: buildList()),
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

  Widget buildSearchBar() {
    return TextField(
      onChanged: (v) => setState(() => search = v),
      decoration: InputDecoration(
        hintText: "Search shop...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget buildPieChart(int match, int mismatch) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 220,
        child: PieChart(
          PieChartData(
            centerSpaceRadius: 45,
            sections: [
              PieChartSectionData(
                color: Colors.green,
                value: match.toDouble(),
                title: "Match\n$match",
                radius: 60,
              ),
              PieChartSectionData(
                color: Colors.red,
                value: mismatch.toDouble(),
                title: "Mismatch\n$mismatch",
                radius: 60,
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
        final isMatch = log["match"] == true;

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
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
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    log["photoUrl"] != "" ? NetworkImage(log["photoUrl"]) : null,
                child: log["photoUrl"] == ""
                    ? const Icon(Icons.photo, color: Colors.black54)
                    : null,
              ),
            ),

            title: Text(
              "${log["shopName"]} (${isMatch ? "MATCH" : "MISMATCH"})",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMatch ? Colors.green : Colors.red,
              ),
            ),

            subtitle: Text(
              "${log["date"]} @ ${log["time"]}\n"
              "Salesman: ${log["salesman"]}",
            ),

            trailing: Text(
              "${log["distance"].toStringAsFixed(1)} m",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
        );
      },
    );
  }
}
