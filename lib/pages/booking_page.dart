import 'package:travel_guide_tourist/imports.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.mainBackground,
    appBar: AppBar(
      title: const Text('Booking'),
      backgroundColor: AppTheme.mainAppBar,
      centerTitle: true,
      actions: <Widget>[
        Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/chatroom_list');
              },
              child: const Icon(
                  Icons.message
              ),
            )
        ),
      ],
    ),
    body: Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/tour_guide_list');
            },
            child: const Text('Start Booking'),
          ),
          ElevatedButton(
            onPressed: () async {
              final docUser = FirebaseAuth.instance.currentUser;
              if (docUser != null) {
                Navigator.pushNamed(context, '/tourist_booking_list', arguments: {
                  'uid': docUser.uid,
                });
              } else {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      AlertDialog(
                        title: const Text(
                            'No User Logged'),
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
                          // TextButton(
                          //   onPressed: () {
                          //     navigatorKey.currentState!.popUntil((route) => route.isFirst);
                          //     // Navigator.pop(context, 'Go to Home');
                          //   },
                          //   child: const Text('Go to Home'),
                          // ),
                        ],
                      ),
                );
              }
            },
            child: const Text('My Booking'),
          ),
        ],
      ),
    ),
  );
}
