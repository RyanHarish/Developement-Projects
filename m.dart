import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MosqueLocatorScreen extends StatefulWidget {
  const MosqueLocatorScreen({Key? key}) : super(key: key);

  @override
  _MosqueLocatorScreenState createState() => _MosqueLocatorScreenState();
}

class _MosqueLocatorScreenState extends State<MosqueLocatorScreen> {
  late GoogleMapController mapController;
  Position? _currentPosition;
  String? _currentAddress;
  final Set<Marker> _markers = {};
  final List<LatLng> _mosqueLocations = [
    LatLng(37.7749, -122.4194), // Example location
    LatLng(37.7849, -122.4094), // Example location
  ];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Request the user to enable location services
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Handle the case when the user denies location permission
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied'),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Handle the case when the user permanently denies location permission
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.'),
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      await _getAddressFromLatLng(position);
      _addCurrentLocationMarker(position);
      _addMosqueMarkers();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  void _addCurrentLocationMarker(Position position) {
    _markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow:
            InfoWindow(title: 'Current Location', snippet: _currentAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
    setState(() {});
  }

  void _addMosqueMarkers() {
    for (var mosqueLocation in _mosqueLocations) {
      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        mosqueLocation.latitude,
        mosqueLocation.longitude,
      );

      _markers.add(
        Marker(
          markerId: MarkerId(mosqueLocation.toString()),
          position: mosqueLocation,
          infoWindow: InfoWindow(
            title: 'Mosque',
            snippet:
                'Distance: ${(distanceInMeters / 1000).toStringAsFixed(2)} km',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mosque Locator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'Get Current Location',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition!.latitude,
                        _currentPosition!.longitude),
                    zoom: 15,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    child: const Icon(Icons.my_location),
                    onPressed: () async {
                      await mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude),
                            zoom: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
