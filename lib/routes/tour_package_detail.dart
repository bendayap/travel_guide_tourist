import 'package:travel_guide_tourist/imports.dart';

class TourPackageDetail extends StatefulWidget {
  const TourPackageDetail({Key? key}) : super(key: key);

  @override
  State<TourPackageDetail> createState() => _TourPackageDetailState();
}

class _TourPackageDetailState extends State<TourPackageDetail> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);

    // Future<QuerySnapshot<Map<String, dynamic>>> tourGuide = FirebaseFirestore.instance
    //     .collection('tourGuides')
    //     .where('uid', isEqualTo: data['ownerId'])
    //     .snapshots().
    //     .get();

    // var userSnap = await FirebaseFirestore.instance
    //     .collection('tourGuides')
    //     .doc(FirebaseAuth.instance.currentUser!.uid)
    //     .get();
    //
    // userData = userSnap.data()!;

    // final tourGuide = FirebaseFirestore.instance
    //     .collection('tourGuides')
    //     .where('uid', isEqualTo: data['ownerId']).doc();
    // var tourGuideName = tourGuide.fullname;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Package Title: ${data['packageTitle']}'
            ),
            // const SizedBox(height: 4.0),
            // const Text('Package Type: '),
            // for(int i=0; i<data['packageType'].length; i++)
            //   Text('\n    ${data['packageType'][i]}'),
            const SizedBox(height: 4.0),
            Text(
                'Tour Guide: ${data['ownerId']}'
            ),
            const SizedBox(height: 4.0),
            Text(
                'Duration: ${data['duration']} day(s)'
            ),
            const SizedBox(height: 4.0),
            Text(
                'Price: RM ${data['price']}'
            ),
            const SizedBox(height: 4.0),
            Text(
                '${data['content']}'
            ),
            const SizedBox(height: 20.0),
            const Text('Type: '),
            for(int i=0; i<data['packageType'].length;i++)
              Text("  ${data['packageType'][i]}"),
            const SizedBox(height: 20.0),
            ElevatedButton(
                onPressed: () async {
                  if (FirebaseAuth.instance.currentUser != null) {
                    Navigator.pushNamed(context, '/request_booking', arguments: {
                    'packageId': data['packageId'],
                    'tourGuideId': data['ownerId'],
                    'price': data['price'],
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
                                  Text('Login first in order to make a request.'),
                                  Text('Profile -> Login/Sign Up'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 'Not Now');
                                },
                                child: const Text('Not Now'),
                              ),
                              TextButton(
                                onPressed: () {
                                  navigatorKey.currentState!.popUntil((route) => route.isFirst);
                                  // Navigator.pop(context, 'Go to Home');
                                },
                                child: const Text('Go to Home'),
                              ),
                            ],
                          ),
                    );
                  }
                },
                child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }

  // Future requestBooking() async {
  //   if (FirebaseAuth.instance.currentUser != null) {
  //     final user = FirebaseAuth.instance.currentUser!;
  //
  //     Booking booking = Booking(
  //       bookingId: json['bookingId'],
  //       packageId: json['packageId'],
  //       tourGuideId: json['tourGuideId'],
  //       touristId: json['touristId'],
  //       budget: json['budget'],
  //       bookingDate: (json['bookingDate'] as Timestamp).toDate(),
  //       tourDate: (json['tourDate'] as Timestamp).toDate(),
  //       status: json['status'],
  //       isPaymentMade: json['isPaymentMade'],
  //
  //       uid: cred.user!.uid,
  //       username: username,
  //       fullname: "",
  //       phoneNumber: 0,
  //       email: email,
  //       icNumber: 0,
  //       photoUrl: "",
  //       description: "",
  //       rating: 0,
  //     );
  //
  //     await firestore
  //         .collection("tourists")
  //         .doc(cred.user!.uid)
  //         .set(tourist.toJson());
  //   }
  // }
}
