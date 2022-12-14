// ignore_for_file: use_build_context_synchronously, avoid_function_literals_in_foreach_calls
import 'package:travel_guide_tourist/imports.dart';

import 'admin_instant_order_screen.dart';

class InstantOrderScreen extends StatefulWidget {
  const InstantOrderScreen({super.key});

  @override
  State<InstantOrderScreen> createState() => _InstantOrderScreenState();
}

class _InstantOrderScreenState extends State<InstantOrderScreen> {
  bool isAdmin = false;
  late Position currentPosition;
  String currentAddress = 'Location not detected yet';
  List<String> onDutyList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    _getInstant();
    getData();
  }

  Future getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        var collectionRef = FirebaseFirestore.instance.collection('admins');
        var doc = await collectionRef.doc(currentUser.uid).get();
        if (doc.exists) {
          isAdmin = true;
        }
      }
      setState(() {
        isLoading = false;
      });
      setState(() {});
    } catch (e) {
      Utils.showSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isAdmin) {
      return const AdminInstantOrderScreen();
    } else {
      return isLoading ? LoadingView() : Scaffold(
      backgroundColor: AppTheme.mainBackground,
      appBar: AppBar(
        title: const Text('Instant Order'),
        backgroundColor: AppTheme.mainAppBar,
        centerTitle: true,
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () async {
                  if (FirebaseAuth.instance.currentUser == null) {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('No User Logged'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: const <Widget>[
                              Text('Please login first.'),
                              Text('Profile -> Login/Sign Up'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'OK');
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.pushNamed(context, '/chatroom_list');
                  }
                },
                child: const Icon(Icons.message),
              )),
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
                        'onDutyList': onDutyList,
                      });
                },
                child: const Text('Start Order'),
              ),
            ),
            const SizedBox(height: 5),
            const Text('Order a tour guide to guide your tour now!'),
            const SizedBox(height: 40.0),
            Container(
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent)
              ),
              child: Text(
              'Your Current Location:'
              '\n\n$currentAddress',
              style: const TextStyle(fontSize: 20),
            ),),
            const SizedBox(height: 30.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final docUser = FirebaseAuth.instance.currentUser;
                  if (docUser != null) {
                    Navigator.pushNamed(context, '/tourist_order_list',
                        arguments: {
                          'uid': docUser.uid,
                        });
                  } else {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('No User Logged'),
                        // content: const Text(
                        //     'Login first in order to make a request.'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: const <Widget>[
                              Text('Login first to view your order.'),
                              Text('Profile -> Login/Sign Up'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'OK');
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('My Order'),
              ),
            ),
            const SizedBox(height: 5),
            const Text('View the order you placed.'),
          ],
        ),
      ),
    );
    }
  }

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
            '\n${place.subAdministrativeArea}, ${place.postalCode}';
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

  _getInstant() async {
    await FirebaseFirestore.instance
        .collection('instantOrder')
        .where('onDuty', isEqualTo: true)
        .get()
        .then((value) => {
              value.docs.forEach((doc) {
                onDutyList.add(doc.data()['ownerID']);
              })
            });
  }
}
