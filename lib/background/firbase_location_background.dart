import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notif_analytics/firebase_options.dart';
import 'dart:async';

Future<void> initBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundServiceStart,
      isForegroundMode: true,
      autoStart: false,
      initialNotificationTitle: 'Tracking Location ......',
      initialNotificationContent:
          'Your real-time location data is being sent to Firebase.',
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onBackgroundServiceStart,
      onBackground: onIosBackground,
      autoStart: false,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onBackgroundServiceStart(ServiceInstance service) async {
  final deviceId = 'notif_analytics_device';
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref(
    'locations/$deviceId',
  );

  DateTime? lastWriteAt;
  Future<void> onPosition(Position position) async {
    final now = DateTime.now();
    if (lastWriteAt != null &&
        now.difference(lastWriteAt!) < const Duration(seconds: 2)) {
      return;
    }

    await dbRef.set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'timestamp': DateTime.now().toIso8601String(),
    });
    lastWriteAt = now;
  }

  StreamSubscription<Position>? positionSubscription =
      Geolocator.getPositionStream(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      ).listen((Position position) {
        (onPosition(position));
      });

  service.on('stop').listen((_) async {
    await positionSubscription.cancel();
    service.stopSelf();
  });
}
