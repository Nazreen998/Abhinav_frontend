import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/log_service.dart';
import '../models/log_model.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';
import 'full_network_image_page.dart';   // 🔥 NEW IMPORT FOR PHOTO VIEW

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
  final logService = LogService();
  List<LogModel> logs = [];
  bool loading = true;

  String search = "";

  @override
  void initState() {
    super.initState();
    loadLogs();
  }

  // --------------------------------------------------------------
  // Convert OLD DB date + time → DateTime
  // --------------------------------------------------------------
  DateTime parseOldDate(String date, String time) {
    if (date.isEmpty || time.isEmpty) return DateTime(1900);

    final parts = date.contains("/") ? date.split("/") : date.split("-");
    final d = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final y = int.parse(parts[2]);

    final t = time.split(":");
    final hh = int.parse(t[0]);
    final mm = int.parse(t[1]);
    final ss = int.parse(t[2]);

    return DateTime(y, m, d, hh, mm, ss);
  }

  String prettyDate(String date, String time) {
    final dt = parseOldDate(date, time);
    return DateFormat("dd-MM-yyyy").format(dt);
  }

  String prettyTime(String date, String time) {
    final dt = parseOldDate(date, time);
    return DateFormat("hh:mm a").format(dt);
  }

  // ---------------- LOAD LOGS ---------------- //
  Future<void> loadLogs() async {
    loading = true;
    setState(() {});

    final role = widget.user["role"].toString().toLowerCase();
    final userId = widget.user["user_id"].toString();
    final segment = widget.user["segment"].toString();

    List<dynamic> raw = await logService.getLogs(
      role: role,
      userId: userId,
      segment: segment,
    );

    List<LogModel> all = raw.map((e) => LogModel.fromJson(e)).toList();
    List<LogModel> filtered = all;

    // SALESMAN
    if (role == "salesman") {
      filtered = filtered.where((l) => l.userId == userId).toList();
    }

    // MANAGER
    if (role == "manager") {
      filtered = filtered.where((l) => l.segment == segment.toUpperCase()).toList();
    }

    // FILTER → Segment
    if (widget.segment != "All") {
      filtered = filtered
          .where((l) => l.segment.toUpperCase() == widget.segment.toUpperCase())
          .toList();
    }

    // FILTER → Result
    if (widget.result != "All") {
      filtered = filtered
          .where((l) => l.result.toLowerCase() == widget.result.toLowerCase())
          .toList();
    }

    // DATE FILTER
    filtered = filtered.where((l) {
      final dt = parseOldDate(l.date, l.time);

      if (widget.startDate != null && dt.isBefore(widget.startDate!)) return false;
      if (widget.endDate != null && dt.isAfter(widget.endDate!)) return false;

      return true;
    }).toList();

    logs = filtered;
    loading = false;
    setState(() {});
  }

  // ---------------- UI SECTION ---------------- //

  @override
  Widget build(BuildContext context) {
    final matched = logs.where((l) => l.result == "match").length;
    final mismatched = logs.where((l) => l.result == "mismatch").length;

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

              const SizedBox(height: 10),

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

  // ---------------- LIST ---------------- //
  Widget buildList() {
    if (loading) return const Center(child: CircularProgressIndicator());

    final result = logs.where((l) {
      return l.shopName.toLowerCase().contains(search.toLowerCase());
    }).toList();

    if (result.isEmpty) return const Center(child: Text("No logs found"));

    return ListView.builder(
      itemCount: result.length,
      itemBuilder: (_, i) {
        final log = result[i];

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
                      imageUrl: log.photoUrl,
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    log.photoUrl.isNotEmpty ? NetworkImage(log.photoUrl) : null,
                child: log.photoUrl.isEmpty
                    ? const Icon(Icons.photo, color: Colors.black54)
                    : null,
              ),
            ),

            title: Text(
              log.shopName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            subtitle: Text(
              "${prettyDate(log.date, log.time)} • ${prettyTime(log.date, log.time)}\n"
              "Salesman: ${log.salesman}\n"
              "Result: ${log.result.toUpperCase()}",
            ),

            trailing: Text(
              "${log.distance.toStringAsFixed(1)} m",
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
