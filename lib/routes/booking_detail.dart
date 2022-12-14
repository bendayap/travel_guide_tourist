// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:travel_guide_tourist/imports.dart';
import 'package:intl/intl.dart';

import '../models/transaction_records.dart';

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
        body: isLoading
            ? LoadingView()
            : SingleChildScrollView(
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
                              Text(
                                  "Tour Guide ID : ${bookingData['tourGuideId']}"),
                              Text("Tourist ID : ${bookingData['touristId']}"),
                              Text("Price: ${bookingData['price']}"),
                              Text(
                                  "Booking Date: ${DateFormat(formatter).format(bookingData['bookingDate'].toDate())}"),
                              Text(
                                  "Tour Date: ${DateFormat(formatter).format(bookingData['tourDate'].toDate())}"),
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
                        if (bookingData['status'] == 'Completed') {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Already Completed'),
                              content: const Text(
                                  'The booking is already completed'),
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
                        } else if (bookingData['status'] == 'Pending') {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Not Started Yet'),
                              content: const Text(
                                  'The booking has not been processed.'),
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
                        } else if (bookingData['status'] == 'Cancelled') {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Booking Has Been Cancelled'),
                              content: const Text('The booking is cancelled'),
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
                                    markAsCompleted(
                                      bookingData['bookingId'],
                                      bookingData['tourGuideId'],
                                      bookingData['price'],
                                    );
                                    Navigator.pop(context);
                                    getData();
                                  },
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text('Mark as Completed'),
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () async {
                        String feedbackId =
                            'feedback_${bookingData['bookingId']}_${bookingData['touristId']}';
                        bool docExists = await checkIfDocExists(feedbackId);
                        if (bookingData['status'] != 'Completed' && bookingData['status'] != 'Rejected' ) {
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
                    ElevatedButton(
                      onPressed: () async {
                        if (bookingData['status'] != 'Pending') {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Booking Has Been Processed'),
                              content: const Text(
                                  'Only booking in pending status can be cancelled'),
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
                        } else if (bookingData['status'] == 'Pending') {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Confirm to Cancel?'),
                              content: const Text(
                                  'Are you confirm to cancel the booking?'
                                      '(Fund will be refunded to your wallet)'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, 'Cancel');
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    cancelOrder(bookingData['orderId']);
                                    Navigator.pop(context);
                                    getData();
                                  },
                                  child: const Text('Confirm'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text('Cancel Booking'),
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

  Future<void> markAsCompleted(
      String bookingId, String tourGuideId, double price) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // try {
    final user = FirebaseAuth.instance.currentUser!;

    ///Update booking status
    final docBooking =
        FirebaseFirestore.instance.collection('bookings').doc(bookingId);
    docBooking.update({
      'status': 'Completed',
      'isPaymentMade': true,
    });

    ///Update transaction status
    final docTransaction = FirebaseFirestore.instance
        .collection('touristTransactions')
        .doc("BookingRequest_$bookingId");
    docTransaction.update({
      'status': 'Successfully',
    });

    ///update tour guide wallet
    final docTourGuideWallet = FirebaseFirestore.instance
        .collection('eWallet')
        .doc('ewallet_$tourGuideId');
    var tourGuideWalletSnap = await docTourGuideWallet.get();
    var tourGuideWalletData = tourGuideWalletSnap.data()!;

    double newTourGuideWalletBalance = tourGuideWalletData['balance'] + price;

    String tourGuideTransactionId = const Uuid().v1();
    TransactionRecord tourGuideTransaction = TransactionRecord(
      transactionId: tourGuideTransactionId,
      transactionAmount: "+RM ${price.toString()}",
      receiveFrom: 'Tour Package Booking',
      ownerId: tourGuideId,
      transactionType: "Booking Completed",
      paymentDetails: "Booking Completed $bookingId",
      paymentMethod: "eWallet Balance",
      newWalletBalance: newTourGuideWalletBalance,
      dateTime: DateTime.now(),
      status: "Successfully",
    );

    docTourGuideWallet.update({
      'balance': newTourGuideWalletBalance,
    });

    await FirebaseFirestore.instance
        .collection("transactions")
        .doc(tourGuideTransactionId)
        .set(tourGuideTransaction.toJson());

    setState(() {});
    navigatorKey.currentState?.pop();
    Utils.showSnackBarSuccess('Marked as Completed');
  }

  Future<void> cancelOrder(String orderId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final user = FirebaseAuth.instance.currentUser!;

    ///update order status
    final docOrder =
    FirebaseFirestore.instance.collection('orderRequests').doc(orderId);
    docOrder.update({
      'status': 'Cancelled',
    });

    ///update wallet balance
    final docWallet = FirebaseFirestore.instance
        .collection('eWallet')
        .doc('ewallet_${user.uid}');
    var eWalletSnap = await docWallet.get();
    var docWalletData = eWalletSnap.data()!;
    double toRefund = bookingData['paymentAmount'];
    double newBalance = docWalletData['balance'] + toRefund;

    docWallet.update({
      'balance': newBalance,
    });

    ///update transaction status
    final docTransaction = FirebaseFirestore.instance
        .collection('touristTransactions')
        .doc('OrderRequest_$orderId');
    docTransaction.update({
      'status': "Refunded",
    });


    String transactionId = "OrderCancelled_$orderId";
    ///add transaction
    TouristTransaction touristTransaction = TouristTransaction(
      transactionId: transactionId,
      transferTo: user.uid,
      transactionAmount: "+RM ${toRefund.toString()}",
      ownerId: user.uid,
      transactionType: "Order Cancelled",
      paymentDetails: "Refund from cancelling order",
      paymentMethod: "eWallet Balance",
      newWalletBalance: docWalletData['balance'] + toRefund,
      dateTime: DateTime.now(),
      status: "Successfully",
    );

    await FirebaseFirestore.instance
        .collection("touristTransactions")
        .doc(transactionId)
        .set(touristTransaction.toJson());

    setState(() {});
    navigatorKey.currentState?.pop();
    Utils.showSnackBarSuccess('Order Cancelled');
  }

}
