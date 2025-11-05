import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class BatteryOptimizationService {
  static Future<bool> isIgnoringBatteryOptimizations() async {
    return await Permission.ignoreBatteryOptimizations.isGranted;
  }

  static Future<bool> requestIgnoreBatteryOptimizations() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    debugPrint('🔋 Battery Optimization Ignore Permission: $status');
    return status.isGranted;
  }
}
