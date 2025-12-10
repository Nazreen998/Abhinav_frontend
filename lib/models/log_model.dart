class LogModel {
  final String userId;
  final String shopId;
  final String shopName;
  final String salesman;
  final String date;
  final String time;
  final String datetime;

  LogModel({
    required this.userId,
    required this.shopId,
    required this.shopName,
    required this.salesman,
    required this.date,
    required this.time,
    required this.datetime,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "shop_id": shopId,
      "shop_name": shopName,
      "salesman": salesman,
      "date": date,
      "time": time,
      "datetime": datetime,
    };
  }
}
