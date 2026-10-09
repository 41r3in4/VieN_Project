import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/local_service.dart';
import '../services/location_service.dart';
import 'main_container_screen.dart';

class MapScreen extends StatefulWidget {
  final LocalService localService;

  const MapScreen({super.key, required this.localService});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
          _markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: const InfoWindow(title: 'Vị trí của bạn'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            ),
          );
        });
        
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15.0,
            ),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _permissionDenied = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _permissionDenied = true;
      });
    }
  }

  void _onConfirmLocation() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainContainerScreen(
          localService: widget.localService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận vị trí'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.deepOrange),
                  SizedBox(height: 16),
                  Text('Đang lấy vị trí của bạn...'),
                ],
              ),
            )
          : _permissionDenied
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Không thể lấy vị trí.\nVui lòng cấp quyền vị trí để tiếp tục.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _fetchLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Thử lại'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _onConfirmLocation,
                        child: const Text('Bỏ qua (Tiếp tục không có vị trí)', style: TextStyle(color: Colors.deepOrange)),
                      )
                    ],
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition != null
                            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                            : const LatLng(16.4637, 107.5909), // Default to Hue
                        zoom: 14.0,
                      ),
                      onMapCreated: (controller) => _mapController = controller,
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                    ),
                    if (kIsWeb)
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.amber.shade100,
                          child: const Text(
                            'Lưu ý: Trên web, Google Maps có thể yêu cầu cấu hình bổ sung (CORS, Billing).',
                            style: TextStyle(color: Colors.orange, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (!_isLoading && !_permissionDenied)
          ? FloatingActionButton.extended(
              onPressed: _onConfirmLocation,
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.check),
              label: const Text('Xác nhận vị trí'),
            )
          : null,
    );
  }
}
