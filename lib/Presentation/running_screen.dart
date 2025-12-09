import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../viewmodels/run_view_model.dart';

class RunScreen extends StatefulWidget {
  final String mode; // <-- add mode here
  const RunScreen({super.key, required this.mode});

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  bool _mapReady = false;
  bool _isMusicPlaying = false;
  String _selectedMusic = "No music selected";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RunViewModel>().initialize();
    });
  }

  void _showMusicPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Choose Music",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMusicOption("Spotify Playlist", Icons.music_note),
            _buildMusicOption("Apple Music", Icons.music_note),
            _buildMusicOption("Local Files", Icons.folder_outlined),
            _buildMusicOption("No Music", Icons.music_off),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00E676)),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        setState(() {
          _selectedMusic = title;
          _isMusicPlaying = title != "No Music";
        });
        Navigator.pop(context);
      },
    );
  }

  Future<void> _moveCamera(LatLng position) async {
    if (!_mapReady) return;
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 17),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    IconData modeIcon = widget.mode == 'running'
        ? Icons.directions_run
        : Icons.directions_walk;
    List<Color> modeGradient = widget.mode == 'running'
        ? [const Color(0xFF00E676), const Color(0xFF00C853)]
        : [const Color(0xFF00B0FF), const Color(0xFF0091EA)];
    String modeTitle = widget.mode == 'running' ? "Running" : "Walking";

    return Scaffold(
      body: Consumer<RunViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.route.isNotEmpty && viewModel.isRunning) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _moveCamera(viewModel.route.last);
            });
          }

          if (viewModel.isInitializing) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1a1a1a), Color(0xFF2d2d2d)],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          }

          final markers = <Marker>{};
          if (viewModel.route.isNotEmpty) {
            markers.add(
              Marker(
                markerId: const MarkerId("start"),
                position: viewModel.route.first,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
              ),
            );
            markers.add(
              Marker(
                markerId: const MarkerId("current"),
                position: viewModel.route.last,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure,
                ),
              ),
            );
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 16,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: markers,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId("route"),
                    color: const Color(0xFF00E676),
                    width: 6,
                    points: viewModel.route,
                  ),
                },
                onMapCreated: (controller) {
                  if (!_controller.isCompleted) {
                    _controller.complete(controller);
                    setState(() => _mapReady = true);
                  }
                },
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            "$modeTitle Tracker",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Mode Icon
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: modeGradient),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: modeGradient[0].withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(modeIcon, color: Colors.white, size: 60),
                      ),
                      const SizedBox(height: 16),

                      // Stats container
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn(
                                "DISTANCE",
                                viewModel.distanceKm,
                                "km",
                              ),
                              _buildStatColumn(
                                "TIME",
                                viewModel.formattedTime,
                                "min",
                              ),
                              _buildStatColumn(
                                "PACE",
                                viewModel.formattedPace,
                                "/km",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSecondaryButton(
                      icon: Icons.stop,
                      label: "Finish",
                      enabled: viewModel.route.isNotEmpty,
                      onTap: () async {
                        final success = await viewModel.finishRun();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? "Run saved successfully!"
                                    : "Failed to save run",
                              ),
                              backgroundColor: success
                                  ? const Color(0xFF00E676)
                                  : Colors.redAccent,
                            ),
                          );
                        }
                      },
                    ),
                    GestureDetector(
                      onTap: viewModel.isRunning
                          ? () => viewModel.pauseRun()
                          : viewModel.route.isEmpty
                          ? () => viewModel.startRun(targetDistance: 0)
                          : () => viewModel.resumeRun(),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: viewModel.isRunning
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B35),
                                    Color(0xFFFF8E53),
                                  ],
                                )
                              : LinearGradient(colors: modeGradient),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (viewModel.isRunning
                                          ? const Color(0xFFFF6B35)
                                          : modeGradient[0])
                                      .withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          viewModel.isRunning ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    _buildSecondaryButton(
                      icon: Icons.my_location,
                      label: "Center",
                      enabled: viewModel.route.isNotEmpty,
                      onTap: () {
                        if (viewModel.route.isNotEmpty)
                          _moveCamera(viewModel.route.last);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, String unit) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
