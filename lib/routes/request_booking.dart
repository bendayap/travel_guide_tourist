// ignore_for_file: use_build_context_synchronously

import 'package:travel_guide_tourist/imports.dart';

class RequestBooking extends StatefulWidget {
  const RequestBooking({
    Key? key,
  }) : super(key: key);

  @override
  State<RequestBooking> createState() => _RequestBookingState();
}

class _RequestBookingState extends State<RequestBooking> {
  final formKey = GlobalKey<FormState>();
  final budgetController = TextEditingController();
  final tourDateController = TextEditingController();
  final usernameController = TextEditingController();
  DateTime selectedDate = DateTime.now().add(const Duration(days: 3));
  final dateController = TextEditingController();

  @override
  void dispose() {
    budgetController.dispose();
    tourDateController.dispose();
    usernameController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    var data = (ModalRoute.of(context)!.settings.arguments as Map);
    dateController.text = selectedDate.toLocal().toString().split(' ')[0];
    final customText = Theme(
      data: ThemeData(
        disabledColor: Colors.blueAccent,
      ),
      child: TextFormField(
        controller: dateController,
        enabled: false,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Select Date',
        ),
      ),
    );

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
        backgroundColor: AppTheme.mainBackground,
        appBar: AppBar(
          title: const Text('Make a Booking Request'),
          backgroundColor: AppTheme.mainAppBar,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                    'Package ID: ${data['packageId']}\nTour Guide ID: ${data['tourGuideId']}'),
                const SizedBox(height: 20),
                Text('Price: ${data['price']}'),
                const SizedBox(height: 20),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: customText,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(Icons.send, size: 32),
                  label: const Text(
                    'Send Request',
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Confirm to Request?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'Cancel');
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              final tourDate = selectedDate;
                              requestBooking(
                                  data['packageId'],
                                  data['tourGuideId'],
                                  data['price'],
                                  today,
                                  tourDate,
                                  data['packageTitle']);
                            },
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future requestBooking(String packageId, String tourGuideId, num price,
      DateTime today, DateTime tourDate, String packageTitle) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final user = currentUser;
      String bookingId = const Uuid().v1();
      // var budget = num.parse(budgetController.text);

      Booking booking = Booking(
        bookingId: bookingId,
        packageId: packageId,
        tourGuideId: tourGuideId,
        touristId: user.uid,
        price: price,
        bookingDate: today,
        tourDate: tourDate,
      );

      await firestore
          .collection("bookings")
          .doc(bookingId)
          .set(booking.toJson());

      ///update balance
      final docWallet = FirebaseFirestore.instance
          .collection('eWallet')
          .doc('ewallet_${currentUser.uid}');
      var eWalletSnap = await docWallet.get();
      var docWalletData = eWalletSnap.data()!;
      double newBalance = docWalletData['balance'] - price;

      docWallet.update({
        'balance': newBalance,
      });

      ///Add Transaction
      String transactionId = "BookingRequest_$bookingId";
      String transactionAmount = "-RM ${price.toString()}";
      String ownerId = user.uid;
      // late String receiveFrom;
      String transferTo = tourGuideId;
      String transactionType = "Booking";
      String paymentDetails = "Book Package: $packageTitle";
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

    Navigator.popUntil(context, ModalRoute.withName('/tour_guide_list'));
    Utils.showSnackBarSuccess('Booking Request Sent');
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: selectedDate,
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

// Future createTourist({required String username, required int age}) async {
//   final docUser = FirebaseFirestore.instance.collection('tourists').doc();
//   final user = FirebaseAuth.instance.currentUser!;
//
//   final tourist = Tourists(
//     uid:
//
//     id: docUser.id,
//     username: username,
//     age: age,
//     birthday: DateTime(2004, 1, 1),
//   );
//   final json = testGuide.toJson();
//
//   await docUser.set(json);
// }
}
