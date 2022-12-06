// ignore_for_file: use_build_context_synchronously

import 'package:travel_guide_tourist/imports.dart';

class BookingDetail extends StatefulWidget {
  const BookingDetail({Key? key}) : super(key: key);

  @override
  State<BookingDetail> createState() => _BookingDetailState();
}

class _BookingDetailState extends State<BookingDetail> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);
    String paymentStatus;
    if (data['isPaymentMade']) {
      paymentStatus = 'Paid';
    } else {
      paymentStatus = 'Not Paid';
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Booking Detail")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // ListTile(
          //   leading:
          //   CircleAvatar(child: Image.network(data['photoUrl'].toString())),
          //   title: Text(data['username']),
          //   // subtitle: Text(language.toString()),
          // ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Booking Info: "),
                    Text("Booking ID: ${data['bookingId']}"),
                    Text("Package: ${data['packageId']}"),
                    Text("Tour Guide ID : ${data['tourGuideId']}"),
                    Text("Tourist ID : ${data['touristId']}"),
                    Text("Price: ${data['price']}"),
                    Text("Booking Date : ${data['bookingDate']}"),
                    Text("Tour Date: ${data['tourDate']}"),
                    Text("Status: ${data['status']}"),
                    Text("Payment: $paymentStatus"),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
              onPressed: () async {
                String feedbackId = 'feedback_${data['bookingId']}';
                bool docExists = await checkIfDocExists(feedbackId);
                if (!docExists) {
                  Navigator.pushNamed(context, '/feedback', arguments: {
                  'feedbackId': feedbackId,
                  'tourGuideId': data['tourGuideId'],
                  'touristId': data['touristId'],
                });
                } else {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('You Rated This Booking.'),
                      content: const Text(
                          'You can only rate the tour guide one time for each booking.'),
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
              child: const Text('Feedback to the Tour Guide'),
          ),
        ],
      ),
    );
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('feedbacks');
      // int numberOfCollectionRef = await FirebaseFirestore.instance.collection('feedbacks').snapshots().length;

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }
}
