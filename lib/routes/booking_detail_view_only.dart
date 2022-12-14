// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:travel_guide_tourist/imports.dart';
import 'package:intl/intl.dart';

import '../models/transaction_records.dart';

class BookingDetailViewOnly extends StatefulWidget {
  final String bookingId;

  const BookingDetailViewOnly({super.key, required this.bookingId});

  @override
  State<BookingDetailViewOnly> createState() => _BookingDetailViewOnlyState();
}

class _BookingDetailViewOnlyState extends State<BookingDetailViewOnly> {
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
      receiveFrom: user.uid,
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
