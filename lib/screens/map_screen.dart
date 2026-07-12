import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/walk_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final walk = context.watch<WalkService>();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  (walk.currentPosition != null &&
                      walk.currentPosition!.latitude.isFinite &&
                      walk.currentPosition!.longitude.isFinite)
                  ? walk.currentPosition!
                  : const LatLng(35.6762, 139.6503),
              initialZoom: 17,
              minZoom: 3,
              maxZoom: 19,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.anet.flower_walk',
              ),
              if (walk.route.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: walk.route
                          .where(
                            (p) => p.latitude.isFinite && p.longitude.isFinite,
                          )
                          .toList(),
                      strokeWidth: 4,
                      color: const Color(0xFFFF8FAB),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  ...walk.currentFlowers
                      .where((f) => f.latitude.isFinite && f.longitude.isFinite)
                      .map(
                        (f) => Marker(
                          point: LatLng(f.latitude, f.longitude),
                          width: 30,
                          height: 30,
                          child: Text(
                            f.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                  if (walk.currentPosition != null &&
                      walk.currentPosition!.latitude.isFinite &&
                      walk.currentPosition!.longitude.isFinite)
                    Marker(
                      point: walk.currentPosition!,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // top stats bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('👟', '${walk.stepCount}', 'steps'),
                  _divider(),
                  _stat('🌸', '${walk.flowerCount}', 'flowers'),
                  _divider(),
                  _stat('📍', walk.distanceKm.toStringAsFixed(2), 'km'),
                ],
              ),
            ),
          ),

          // center map on user button
          if (walk.currentPosition != null &&
              walk.currentPosition!.latitude.isFinite &&
              walk.currentPosition!.longitude.isFinite)
            Positioned(
              bottom: 120,
              right: 16,
              child: FloatingActionButton.small(
                heroTag: 'center',
                backgroundColor: Colors.white,
                onPressed: () {
                  final pos = walk.currentPosition!;
                  if (pos.latitude.isFinite && pos.longitude.isFinite) {
                    _mapController.move(pos, 17);
                  }
                },
                child: const Icon(Icons.my_location, color: Color(0xFF4CAF50)),
              ),
            ),

          // start / stop button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  if (walk.isWalking) {
                    final finished = await walk.stopWalk();
                    if (finished != null && context.mounted) {
                      _showSummary(context, finished);
                    }
                  } else {
                    await walk.startWalk();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: walk.isWalking
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF4CAF50),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (walk.isWalking
                                    ? const Color(0xFFFF6B6B)
                                    : const Color(0xFF4CAF50))
                                .withValues(alpha: 0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    walk.isWalking ? Icons.stop_rounded : Icons.directions_walk,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String icon, String value, String label) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ],
  );

  Widget _divider() =>
      Container(height: 36, width: 1, color: Colors.grey.shade200);

  void _showSummary(BuildContext context, walk) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🌸 walk complete!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryTile('👟', '${walk.stepCount}', 'steps'),
                _summaryTile('🌸', '${walk.flowerCount}', 'flowers'),
                _summaryTile(
                  '📍',
                  '${walk.distanceKm.toStringAsFixed(2)} km',
                  'distance',
                ),
                _summaryTile('⏱️', walk.duration, 'time'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'back to garden 🌷',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryTile(String icon, String value, String label) => Column(
    children: [
      Text(icon, style: const TextStyle(fontSize: 24)),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
    ],
  );
}
