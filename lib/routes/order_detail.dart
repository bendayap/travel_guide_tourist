// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'package:travel_guide_tourist/imports.dart';
import 'package:intl/intl.dart';

import '../models/transaction_records.dart';

class OrderDetail extends StatefulWidget {
  final String orderId;

  const OrderDetail({super.key, required this.orderId});

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  bool isLoading = false;
  var orderData = {};
  late String paymentStatus;
  String startTime = 'Not Start Yet';
  String endTime = 'Not Completed Yet';
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
      var orderSnap = await FirebaseFirestore.instance
          .collection('orderRequests')
          .doc(widget.orderId)
          .get();

      orderData = orderSnap.data()!;
      if (orderData['isPaymentMade']) {
        paymentStatus = 'Paid';
      } else {
        paymentStatus = 'Not Paid';
      }

      if (orderData['status'] == 'Rejected') {
        startTime = 'Order Rejected';
        endTime = 'Order Rejected';
      } else if (orderData['status'] == 'Cancelled') {
        startTime = 'Order Cancelled';
        endTime = 'Order Cancelled';
      } else if (orderData['startTime'] == orderData['endTime']) {
      } else if (orderData['startTime']
          .toDate()
          .isAfter(orderData['endTime'].toDate())) {
        startTime =
            DateFormat(formatter).format(orderData['startTime'].toDate());
        endTime = 'Not Completed Yet';
      } else {
        startTime =
            DateFormat(formatter).format(orderData['startTime'].toDate());
        endTime = DateFormat(formatter).format(orderData['endTime'].toDate());
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
        appBar: AppBar(title: const Text("Order Detail")),
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
                              const Text("Order Info: "),
                              Text("Order ID: ${orderData['orderId']}"),
                              Text("Location: ${orderData['address']}"),
                              Text(
                                  "Tour Guide ID : ${orderData['tourGuideId']}"),
                              Text("Tourist ID : ${orderData['touristId']}"),
                              Text(
                                  "Payment amount: ${orderData['paymentAmount']}"),
                              // Text("Start Time: ${DateFormat(formatter).format(orderData['startTime'].toDate())}"),
                              // Text("End Time: ${DateFormat(formatter).format(orderData['endTime'].toDate())}"),
                              Text("Start Time: $startTime"),
                              Text("End Time: $endTime"),
                              Text("Status: ${orderData['status']}"),
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
                        if (orderData['status'] == 'Completed') {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Already Completed'),
                              content:
                                  const Text('The order is already completed'),
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
                        } else if (orderData['status'] == 'Pending') {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Not Started Yet'),
                              content:
                                  const Text('The order is not yet started'),
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
                        } else if (orderData['status'] == 'Cancelled') {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Order Has Been Cancelled'),
                              content: const Text('The order is cancelled'),
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
                                  'Are you confirm to mark this order as Completed?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, 'Not Now');
                                  },
                                  child: const Text('Not Now'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await markAsCompleted(
                                        orderData['orderId'],
                                        orderData['tourGuideId'],
                                        orderData['paymentAmount']);
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
                            'feedback_${orderData['orderId']}_${orderData['touristId']}';
                        bool docExists = await checkIfDocExists(feedbackId);
                        if (orderData['status'] != 'Completed') {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Order Not Yet Complete.'),
                              content: const Text(
                                  'You can only rate the tour guide after the order is completed.'),
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
                            (orderData['status'] == 'Completed' ||
                                orderData['status'] == 'Rejected')) {
                          Navigator.pushNamed(context, '/feedback', arguments: {
                            'feedbackId': feedbackId,
                            'tourGuideId': orderData['tourGuideId'],
                            'touristId': orderData['touristId'],
                          });
                        } else {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('You Rated This Order.'),
                              content: const Text(
                                  'You can only rate the tour guide one time for each order.'),
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
                        if (orderData['status'] != 'Pending') {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Order Has Been Processed'),
                              content: const Text(
                                  'Only order in pending status can be cancelled'),
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
                        } else if (orderData['status'] == 'Pending') {
                          await showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Confirm to Cancel?'),
                              content: const Text(
                                  'Are you confirm to cancel the order?'
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
                                    cancelOrder(orderData['orderId']);
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
                      child: const Text('Cancel Order'),
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
      String orderId, String tourGuideId, double fund) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // try {
    final user = FirebaseAuth.instance.currentUser!;
    DateTime end = DateTime.now();
    DateTime start = orderData['startTime'].toDate();
    int duration = end.difference(start).inHours;
    if (end.minute >= 30) {
      duration += 1;
    }

    var instantOrderSnap = await FirebaseFirestore.instance
        .collection('instantOrder')
        .doc("instant_$tourGuideId")
        .get();
    var instantOrderData = instantOrderSnap.data()!;
    int priceInInt = instantOrderData['price'] * duration;
    double price = priceInInt.toDouble();

    ///update balance
    final docWallet = FirebaseFirestore.instance
        .collection('eWallet')
        .doc('ewallet_${user.uid}');
    var eWalletSnap = await docWallet.get();
    var docWalletData = eWalletSnap.data()!;
    double toRefund = fund - price;
    double newBalance = docWalletData['balance'] + toRefund;

    docWallet.update({
      'balance': newBalance,
    });

    ///Add Transaction
    String transactionId = "OrderComplete_$orderId";
    String transactionAmount = "+RM ${toRefund.toString()}";
    String ownerId = user.uid;
    // late String receiveFrom;
    String transferTo = ownerId;
    String transactionType = "Refund";
    String paymentDetails = "Order completed, Returning remaining fund";
    String paymentMethod = "eWallet Balance";
    String status = "Successfully";
    double newWalletBalance = newBalance;
    DateTime dateTime = DateTime.now();

    TouristTransaction transaction = TouristTransaction(
      transactionId: transactionId,
      transactionAmount: transactionAmount,
      ownerId: ownerId,
      // receiveFrom: receiveFrom,
      transferTo: transferTo,
      transactionType: transactionType,
      paymentDetails: paymentDetails,
      paymentMethod: paymentMethod,
      newWalletBalance: newWalletBalance,
      dateTime: dateTime,
      status: status,
    );

    await FirebaseFirestore.instance
        .collection("touristTransactions")
        .doc(transactionId)
        .set(transaction.toJson());

    var startTime = orderData['startTime'].toDate();

    ///update order request
    OrderRequest orderRequest = OrderRequest(
      orderId: orderId,
      tourGuideId: tourGuideId,
      touristId: user.uid,
      address: orderData['address'],
      // startTime: orderData[startTime],
      startTime: startTime,
      endTime: DateTime.now(),
      currentLatitude: orderData['currentLatitude'],
      currentLongitude: orderData['currentLongitude'],
      status: "Completed",
      paymentAmount: price,
      isPaymentMade: true,
    );

    await FirebaseFirestore.instance
        .collection("orderRequests")
        .doc(orderId)
        .set(orderRequest.toJson());

    ///Update transaction status
    final docTransaction = FirebaseFirestore.instance
        .collection('touristTransactions')
        .doc("OrderRequest_$orderId");
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
      receiveFrom: "Instant ORder",
      ownerId: tourGuideId,
      transactionType: "Order Completed",
      paymentDetails: "Order Completed $orderId",
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

    // } on FirebaseAuthException catch (e) {
    //   Utils.showSnackBar(e.toString());
    // }

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
    double toRefund = orderData['paymentAmount'];
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
