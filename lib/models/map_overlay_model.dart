import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerModel {
  final String id;
  final LatLng position;
  final String title;
  final String snippet;
  final bool isCustom;

  const MapMarkerModel({
    required this.id,
    required this.position,
    required this.title,
    required this.snippet,
    this.isCustom = false,
  });
}

class MapPolylineModel {
  final String id;
  final List<LatLng> points;

  const MapPolylineModel({required this.id, required this.points});
}

class MapPolygonModel {
  final String id;
  final List<LatLng> points;

  const MapPolygonModel({required this.id, required this.points});
}

class MapCircleModel {
  final String id;
  final LatLng center;
  final double radiusMeters;

  const MapCircleModel({
    required this.id,
    required this.center,
    required this.radiusMeters,
  });
}
