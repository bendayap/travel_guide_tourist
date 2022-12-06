// ignore_for_file: use_build_context_synchronously
import 'package:travel_guide_tourist/imports.dart';

class InstantOrderPage extends StatefulWidget {
  const InstantOrderPage({super.key});

  @override
  State<InstantOrderPage> createState() => _InstantOrderPageState();
}

class _InstantOrderPageState extends State<InstantOrderPage> {
  late Position currentPosition;
  String currentAddress = 'Location not detected yet';

  var lat2 = 38.4219983;
  var lng2 = -121.084;
  num distance = 0.0;

  @override
  void initState() {
    _getCurrentPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.mainBackground,
        appBar: AppBar(
          title: const Text('Instant Order'),
          backgroundColor: AppTheme.mainAppBar,
          centerTitle: true,
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    ///TODO: Implement chatroom
                  },
                  child: const Icon(
                      Icons.message
                  ),
                )
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
          child: Column(
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (currentAddress == 'Location not detected yet') {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Current Location Not Detected'),
                          content: const Text(
                              'Get your current location before using instant order.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                _getCurrentPosition();
                                Navigator.pop(context, 'OK');
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                    Navigator.pushNamed(context, '/tour_guide_nearby',
                        arguments: {
                          'currentAddress': currentAddress,
                          'currentLat': currentPosition.latitude,
                          'currentLng': currentPosition.longitude,
                        });
                  },
                  child: const Text('Start Order'),
                ),
              ),
              const SizedBox(height: 40.0),
              Center(
                child: ElevatedButton(
                  onPressed: _getCurrentPosition,
                  child: const Text('Get Current Location'),
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                currentAddress,
                style: const TextStyle(fontSize: 20),
              ),
              // Text('LAT: ${currentPosition?.latitude}'),
              // Text('LNG: ${currentPosition?.longitude}'),
              // Text('LAT2: $lat2'),
              // Text('LNG2: $lng2'),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    distance = _calculateDistance(currentPosition.latitude,
                        currentPosition.longitude, lat2, lng2);
                  });
                },
                child: const Text('Get Distance'),
              ),
              Text('Distance: $distance meters'),

              // Text('ADDRESS: ${currentAddress ?? ""}'),
            ],
          ),
        ),
      );

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => currentPosition = position);
      _getAddressFromLatLng(currentPosition);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            currentPosition.latitude, currentPosition.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        currentAddress = '${place.street}, ${place.subLocality}, '
            '${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  _calculateDistance(double lat1, double lng1, lat2, lng2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    var distanceInKiloMeters = 12742 * asin(sqrt(a));

    /// return as distance in Meters
    return distanceInKiloMeters * 1000;
  }
}
