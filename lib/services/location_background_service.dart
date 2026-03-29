import 'package:flutter_background_service/flutter_background_service.dart';

Future<void> startBackgroundTracking() async {
  if (!await FlutterBackgroundService().isRunning()) {
    FlutterBackgroundService().startService();
  }
}

Future<void> stopBackgroundTracking() async {
  if (await FlutterBackgroundService().isRunning()) {
    FlutterBackgroundService().invoke('stop');
  }
}
