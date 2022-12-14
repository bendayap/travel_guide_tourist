import 'package:travel_guide_tourist/imports.dart';

import 'admin_booking_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool isAdmin = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
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
      return const AdminBookingScreen();
    } else {
      return isLoading
          ? LoadingView()
          : Scaffold(
              backgroundColor: AppTheme.mainBackground,
              appBar: AppBar(
                title: const Text('Booking'),
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
                                // content: const Text(
                                //     'Login first in order to make a request.'),
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
                padding: const EdgeInsets.fromLTRB(0.0, 140.0, 0.0, 0.0),
                child: Column(
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/tour_guide_list');
                        },
                        child: const Text('Start Booking'),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text('Lazy to prepare a tour plan? \nBook a tour guide for your tour!'),
                    const SizedBox(height: 60),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final docUser = FirebaseAuth.instance.currentUser;
                          if (docUser != null) {
                            Navigator.pushNamed(
                                context, '/tourist_booking_list',
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
                                      Text('Login first to view your booking.'),
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
                        child: const Text('My Booking'),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text('View the booking you placed.'),
                  ],
                ),
              ),
            );
    }
  }
}
