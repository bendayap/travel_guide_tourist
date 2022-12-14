// ignore_for_file: use_build_context_synchronously

import 'package:travel_guide_tourist/imports.dart';

class TourGuideNearbyDetail extends StatefulWidget {
  const TourGuideNearbyDetail({Key? key}) : super(key: key);

  @override
  State<TourGuideNearbyDetail> createState() => _TourGuideNearbyDetailState();
}

class _TourGuideNearbyDetailState extends State<TourGuideNearbyDetail> {
  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);
    String currentAddress = data['currentAddress'];
    String tourGuideId = data['uid'];

    return Scaffold(
      appBar: AppBar(
        title: Text("${data['username']}'s Detail"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListTile(
            leading:
                CircleAvatar(child: Image.network(data['photoUrl'].toString())),
            title: Text(data['username']),
          ),
          const SizedBox(height: 10.0),
          const Text('Tour Guide Info: '),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tour Guide Info: "),
                    Text("Full Name: ${data['fullname']}"),
                    Text("Email: ${data['email']}"),
                    Text("Phone Number : ${data['phoneNumber']}"),
                    Text("English : ${data['language']['English']}"),
                    Text("Malay : ${data['language']['Malay']}"),
                    Text("Mandarin : ${data['language']['Mandarin']}"),
                    Text("Tamil : ${data['language']['Tamil']}"),
                    Text("Tour Done : ${data['totalDone']}"),
                    Text("Rating: ${data['rating']}"),
                    Text("Rate Number : ${data['rateNumber']}"),
                    Text("Description: ${data['description']}"),
                    const SizedBox(height: 10.0),
                    Text('"${data['description']}"'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40.0),
          ElevatedButton(
            onPressed: () async {
              var user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                var eWalletSnap = await FirebaseFirestore.instance
                    .collection('eWallet')
                    .doc("ewallet_${FirebaseAuth.instance.currentUser!.uid}")
                    .get();
                var eWalletData = eWalletSnap.data()!;
                double price = double.parse(data['price'].toString()) * 6;

                if (eWalletData['balance'] < data['price'] * 6) {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Insufficient Balance'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            const Text(
                                'Your wallet does not have sufficient balance to order this tour guide.'),
                            const Text(
                                'Due to the policy, your wallet should have sufficient amount to order a tour guide for 6 hours (Fund remaining will be returned to your wallet when the order is completed).'),
                            Text(
                                '\nBalance Needed: ${price.toStringAsFixed(2)}'),
                            Text(
                                'Your Balance: ${eWalletData['balance'].toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, 'Cancel');
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectBankCard(
                                    action: "Reload",
                                    eWalletId: eWalletData["eWalletId"],
                                    balance: eWalletData["balance"]),
                              ),
                            );
                            Navigator.pop(context, 'Reload Balance');
                          },
                          child: const Text('Reload Balance'),
                        ),
                      ],
                    ),
                  );
                } else {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Confirm to Order?'),
                      content: Text(
                          'RM ${price.toStringAsFixed(2)} will be deducted from your wallet.'
                          '\n(Fund remaining will be returned to your wallet when the order is completed)'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, 'Cancel');
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _requestOrder(tourGuideId, currentAddress,
                                data['currentLat'], data['currentLng'], price);
                          },
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  );
                }
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
                          Text('Login first in order to make order.'),
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
                          navigatorKey.currentState!
                              .popUntil((route) => route.isFirst);
                          // Navigator.pop(context, 'Go to Home');
                        },
                        child: const Text('Go to Home'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Order this guide'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestOrder(String tourGuideId, String currentAddress,
      double currentLat, double currentLng, double price) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (FirebaseAuth.instance.currentUser != null) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final docOrder = firestore.collection('orderRequests').doc();
      final user = FirebaseAuth.instance.currentUser!;
      final orderId = docOrder.id;

      OrderRequest orderRequest = OrderRequest(
        orderId: orderId,
        tourGuideId: tourGuideId,
        touristId: user.uid,
        address: currentAddress,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        currentLatitude: currentLat,
        currentLongitude: currentLng,
        paymentAmount: price,
      );

      await firestore
          .collection("orderRequests")
          .doc(orderId)
          .set(orderRequest.toJson());

      ///update balance
      final docWallet = FirebaseFirestore.instance
          .collection('eWallet')
          .doc('ewallet_${user.uid}');
      var eWalletSnap = await docWallet.get();
      var docWalletData = eWalletSnap.data()!;
      double newBalance = docWalletData['balance'] - price;

      docWallet.update({
        'balance': newBalance,
      });

      ///Add Transaction
      String transactionId = "OrderRequest_$orderId";
      String transactionAmount = "-RM ${price.toString()}";
      String ownerId = user.uid;
      // late String receiveFrom;
      String transferTo = tourGuideId;
      String transactionType = "Order Request";
      String paymentDetails = "Order Tour Guide: $orderId";
      String paymentMethod = "eWallet Balance";
      String status = "Pending";
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

      await firestore
          .collection("touristTransactions")
          .doc(transactionId)
          .set(transaction.toJson());
    }

    Navigator.popUntil(context, ModalRoute.withName('/tour_guide_nearby'));
    Utils.showSnackBarSuccess('Order Request Sent');
  }
}
