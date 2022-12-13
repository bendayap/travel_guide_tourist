// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:travel_guide_tourist/imports.dart';
import 'package:intl/intl.dart';

class BookingDetail extends StatefulWidget {
  final String bookingId;

  const BookingDetail({super.key, required this.bookingId});

  @override
  State<BookingDetail> createState() => _BookingDetailState();
}

class _BookingDetailState extends State<BookingDetail> {
  bool isLoading = false;
  var bookingData = {};
  late String paymentStatus;
  // final DateFormat formatter = DateFormat('dd MMM, H:mm');
  String formatter = "dd MMM yyyy, H:mm";

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      var bookingSnap = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      bookingData = bookingSnap.data()!;
      if (bookingData['isPaymentMade']) {
        paymentStatus = 'Paid';
      } else {
        paymentStatus = 'Not Paid';
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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Booking Detail")),
        body: isLoading ? LoadingView() : SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Booking Info: "),
                        Text("Booking ID: ${bookingData['bookingId']}"),
                        Text("Package: ${bookingData['packageId']}"),
                        Text("Tour Guide ID : ${bookingData['tourGuideId']}"),
                        Text("Tourist ID : ${bookingData['touristId']}"),
                        Text("Price: ${bookingData['price']}"),
                        Text("Booking Date: ${DateFormat(formatter).format(bookingData['bookingDate'].toDate())}"),
                        Text("Tour Date: ${DateFormat(formatter).format(bookingData['tourDate'].toDate())}"),
                        Text("Status: ${bookingData['status']}"),
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
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Confirm To Complete?'),
                      content: const Text(
                          'Are you confirm to mark this booking as Completed?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, 'Not Now');
                          },
                          child: const Text('Not Now'),
                        ),
                        TextButton(
                          onPressed: () {
                            markAsCompleted(bookingData['bookingId']);
                            Navigator.pop(context);
                            getData();
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                  ///TODO: change balance and payment status

                },
                child: const Text('Mark as Completed'),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () async {
                  String feedbackId =
                      'feedback_${bookingData['bookingId']}_${bookingData['touristId']}';
                  bool docExists = await checkIfDocExists(feedbackId);
                  if (bookingData['status'] != 'Completed') {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Booking Not Yet Complete.'),
                        content: const Text(
                            'You can only rate the tour guide after the booking is completed.'),
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
                  } else if (!docExists &&
                      (bookingData['status'] == 'Completed' ||
                          bookingData['status'] == 'Rejected')) {
                    Navigator.pushNamed(context, '/feedback', arguments: {
                      'feedbackId': feedbackId,
                      'tourGuideId': bookingData['tourGuideId'],
                      'touristId': bookingData['touristId'],
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
        ),
      ),
    );
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('feedbacks');
      // int numberOfCollectionRef = await FirebaseFirestore.instance.collection('feedbacks').snapshots().length;

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  void markAsCompleted(String bookingId) {
    final docBooking =
        FirebaseFirestore.instance.collection('bookings').doc(bookingId);
    docBooking.update({
      'status': 'Completed',
    });

    setState(() {});
  }
}
