import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../services/location_service.dart';
import '../../services/location_background_service.dart';

class HomeLocationTrackingViewModel extends ChangeNotifier {
  HomeLocationTrackingViewModel({required LocationRealtimeService service})
    : _service = service;

  final LocationRealtimeService _service;
  StreamSubscription<Position>? _positionSubscription;
  DateTime? _lastWriteAt;

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  String? _error;
  String? get lastError => _error;

  bool allowTracking = false;

  AppLifecycleState _state = AppLifecycleState.resumed;

  void onAppLifecycleChanged(AppLifecycleState state) async {
    _state = state;
    if (state == AppLifecycleState.resumed) {
      await stopBackgroundTracking();
    } else if (state == AppLifecycleState.inactive && allowTracking) {
      await startBackgroundTracking();
    } else if (state == AppLifecycleState.paused && allowTracking) {
      await startBackgroundTracking();
    } else if (state == AppLifecycleState.detached && allowTracking) {
      await startBackgroundTracking();
    }
  }

  Future<void> toggleBackgroundTracking(bool value) async {
    allowTracking = value;
    notifyListeners();
  }

  Future<void> toggleTracking() async {
    if (_isTracking) {
      await stopTracking();
      return;
    }
    await startTracking();
  }

  Future<void> startTracking() async {
    _error = null;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location service is disabled.';
        notifyListeners();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _error = 'Location permission denied.';
        notifyListeners();
        return;
      }

      await _positionSubscription?.cancel();
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).listen(_onPosition);

      _isTracking = true;
      notifyListeners();
    } catch (_) {
      _error = 'Could not start location tracking.';
      _isTracking = false;
      notifyListeners();
    }
  }

  Future<void> stopTracking() async {
    if (!_isTracking) return;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    FlutterBackgroundService().invoke('stop');
    _isTracking = false;
    notifyListeners();
  }

  Future<void> _onPosition(Position position) async {
    final now = DateTime.now();
    if (_lastWriteAt != null &&
        now.difference(_lastWriteAt!) < const Duration(seconds: 2)) {
      return;
    }

    try {
      await _service.writeLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        state: _state,
      );
      _lastWriteAt = now;
      _error = null;
      notifyListeners();
    } catch (_) {
      _error = 'Failed to send realtime location.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_isTracking) {
      stopTracking();
    }
    _positionSubscription?.cancel();
    super.dispose();
  }
}
