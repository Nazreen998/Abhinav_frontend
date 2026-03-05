import 'dart:async';
import 'dart:convert';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'call_log_service.dart';
import 'auth_service.dart';

Future<void> initializeBackgroundService() async {

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      autoStartOnBoot: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(),
  );

  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {

  Timer.periodic(const Duration(seconds:20), (timer) async {

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    if(token == null) return;

    AuthService.token = token;

    final raw = prefs.getString("shops_cache");

    if(raw == null) return;

    final shops = jsonDecode(raw);

    await CallLogService.checkCallLogs(shops);

  });

}