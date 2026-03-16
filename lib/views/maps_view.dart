import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../viewmodels/maps_viewmodel.dart';

class MapsView extends StatelessWidget {
  const MapsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapsViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: const Text(
          'Maps',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        actions: [
          // ── Map-type switcher ──────────────────────────────────────────
          PopupMenuButton<MapType>(
            icon: const Icon(Icons.layers_outlined),
            tooltip: 'Map type',
            onSelected: (type) =>
                context.read<MapsViewModel>().setMapType(type),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: MapType.normal,
                child: _MapTypeItem(Icons.map_outlined, 'Normal'),
              ),
              PopupMenuItem(
                value: MapType.satellite,
                child: _MapTypeItem(Icons.satellite_alt_outlined, 'Satellite'),
              ),
              PopupMenuItem(
                value: MapType.hybrid,
                child: _MapTypeItem(Icons.layers_outlined, 'Hybrid'),
              ),
              PopupMenuItem(
                value: MapType.terrain,
                child: _MapTypeItem(Icons.terrain_outlined, 'Terrain'),
              ),
            ],
          ),
          // ── Map controls toggle panel ──────────────────────────────────
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Map controls',
            onSelected: (action) {
              final vm = context.read<MapsViewModel>();
              if (action == 'zoom') vm.toggleZoomControls();
              if (action == 'compass') vm.toggleCompass();
              if (action == 'location') vm.toggleMyLocationButton();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'zoom',
                child: _ToggleItem('Zoom Controls', vm.showZoomControls),
              ),
              PopupMenuItem(
                value: 'compass',
                child: _ToggleItem('Compass', vm.showCompass),
              ),
              PopupMenuItem(
                value: 'location',
                child: _ToggleItem(
                  'My Location Button',
                  vm.showMyLocationButton,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Google Map ─────────────────────────────────────────────────
          GoogleMap(
            onMapCreated: context.read<MapsViewModel>().onMapCreated,
            initialCameraPosition: vm.initialCameraPosition,
            mapType: vm.mapType,
            markers: vm.markers,
            polylines: vm.polylines,
            polygons: vm.polygons,
            circles: vm.circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: vm.showMyLocationButton,
            zoomControlsEnabled: vm.showZoomControls,
            compassEnabled: vm.showCompass,
            onLongPress: context.read<MapsViewModel>().onMapLongPress,
            onTap: (point) {
              context.read<MapsViewModel>().addTapMarker(point);
            },
          ),

          // ── Loading overlay ────────────────────────────────────────────
          if (vm.isLoadingLocation)
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('Finding your location…'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Long-press hint ────────────────────────────────────────────
          if (vm.dynamicTarget != null)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Card(
                color: colors.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 18,
                        color: colors.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Target set — tap "Dynamic Polyline" FAB to draw route',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Error snack (location) ─────────────────────────────────────
          if (vm.locationError != null)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Card(
                color: colors.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    vm.locationError!,
                    style: TextStyle(
                      color: colors.onErrorContainer,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),

          // ── Camera control bar (bottom) ────────────────────────────────
          Positioned(
            bottom: 100,
            left: 16,
            child: IntrinsicWidth(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CameraButton(
                        icon: Icons.add,
                        tooltip: 'Zoom in',
                        onTap: () => context.read<MapsViewModel>().zoomIn(),
                      ),
                      _CameraButton(
                        icon: Icons.remove,
                        tooltip: 'Zoom out',
                        onTap: () => context.read<MapsViewModel>().zoomOut(),
                      ),
                      _CameraButton(
                        icon: Icons.threed_rotation_outlined,
                        tooltip: 'Tilt & rotate',
                        onTap: () => context.read<MapsViewModel>().tiltCamera(),
                      ),
                      _CameraButton(
                        icon: Icons.center_focus_strong_outlined,
                        tooltip: 'Reset camera',
                        onTap: () =>
                            context.read<MapsViewModel>().resetCamera(),
                      ),
                      _CameraButton(
                        icon: Icons.my_location_outlined,
                        tooltip: 'Go to my location',
                        onTap: () {
                          final loc = context
                              .read<MapsViewModel>()
                              .currentLocation;
                          if (loc != null) {
                            context.read<MapsViewModel>().animateCameraTo(
                              loc,
                              zoom: 15.0,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ), // Card and IntrinsicWidth
          ), // Positioned
          // ── Overlay Buttons ────────────────────────────────────────────
          Positioned(
            bottom: 16,
            right: 16,
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _SpeedDialItem(
                    label: 'Add Marker',
                    icon: Icons.location_pin,
                    color: Colors.red,
                    onTap: () =>
                        context.read<MapsViewModel>().addDefaultMarker(),
                  ),
                  _SpeedDialItem(
                    label: 'Custom Marker',
                    icon: Icons.push_pin_outlined,
                    color: const Color(0xFF6750A4),
                    onTap: () =>
                        context.read<MapsViewModel>().addCustomMarker(),
                  ),
                  _SpeedDialItem(
                    label: 'Remove Selected',
                    icon: Icons.location_off_outlined,
                    color: Colors.deepOrange,
                    onTap: () =>
                        context.read<MapsViewModel>().removeSelectedMarker(),
                  ),
                  _SpeedDialItem(
                    label: 'Static Polyline',
                    icon: Icons.timeline_outlined,
                    color: Colors.blue,
                    onTap: () =>
                        context.read<MapsViewModel>().addStaticPolyline(),
                  ),
                  // _SpeedDialItem(
                  //   label: 'Dynamic Polyline',
                  //   icon: Icons.route_outlined,
                  //   color: Colors.orange,
                  //   onTap: () => context.read<MapsViewModel>().addDynamicPolyline(),
                  // ),
                  _SpeedDialItem(
                    label: 'Add Polygon',
                    icon: Icons.pentagon_outlined,
                    color: Colors.green,
                    onTap: () => context.read<MapsViewModel>().addPolygon(),
                  ),
                  _SpeedDialItem(
                    label: 'Add Circle',
                    icon: Icons.circle_outlined,
                    color: Colors.purple,
                    onTap: () => context.read<MapsViewModel>().addCircle(),
                  ),
                  _SpeedDialItem(
                    label: 'Clear All',
                    icon: Icons.layers_clear_outlined,
                    color: Colors.grey,
                    onTap: () => context.read<MapsViewModel>().clearAll(),
                  ),
                ],
              ), // Column
            ), // IntrinsicWidth
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Private helpers
// ────────────────────────────────────────────────────────────────────────────

class _MapTypeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MapTypeItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Row(
    children: [Icon(icon, size: 18), const SizedBox(width: 10), Text(label)],
  );
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool value;
  const _ToggleItem(this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        value ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
        size: 18,
        color: value ? Theme.of(context).colorScheme.primary : null,
      ),
      const SizedBox(width: 10),
      Text(label),
    ],
  );
}

class _CameraButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _CameraButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(icon, size: 20),
    onPressed: onTap,
    tooltip: tooltip,
    visualDensity: VisualDensity.compact,
  );
}

class _SpeedDialItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SpeedDialItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label chip
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Mini FAB
          SizedBox(
            width: 42,
            height: 42,
            child: FloatingActionButton.small(
              heroTag: label,
              onPressed: onTap,
              backgroundColor: color,
              foregroundColor: Colors.white,
              child: Icon(icon, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
