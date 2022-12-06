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

  @override
  void dispose() {
    budgetController.dispose();
    tourDateController.dispose();
    usernameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    var data = (ModalRoute.of(context)!.settings.arguments as Map);

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
                Text('${data['packageId']}, ${data['tourGuideId']}'),
                const SizedBox(height: 20),
                // TextFormField(
                //   ///Budget Field
                //   controller: budgetController,
                //   keyboardType: TextInputType.number,
                //   inputFormatters: <TextInputFormatter>[
                //     FilteringTextInputFormatter.digitsOnly
                //   ],
                //   textInputAction: TextInputAction.next,
                //   decoration: const InputDecoration(labelText: 'Budget'),
                //   autovalidateMode: AutovalidateMode.onUserInteraction,
                //   validator: (value) => value != null && value.isEmpty
                //       ? 'Enter a number'
                //       : null,
                // ),
                const SizedBox(height: 4),
                // TextFormField(
                //   ///Username Field
                //   controller: usernameController,
                //   textInputAction: TextInputAction.next,
                //   decoration: const InputDecoration(labelText: 'Username'),
                //   autovalidateMode: AutovalidateMode.onUserInteraction,
                //   validator: (value) => value != null && value.isEmpty
                //       ? 'Enter a username'
                //       : null,
                // ),
                const SizedBox(height: 4),
                InputDatePickerFormField(
                    initialDate: today,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
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
                  onPressed: () {
                    ///TODO: select date
                    final tourDate = today;
                    requestBooking(data['packageId'], data['tourGuideId'], data['price'], today, tourDate);
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

  Future requestBooking(String packageId, String tourGuideId, num price, DateTime today, DateTime tourDate)
  async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (FirebaseAuth.instance.currentUser != null) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser!;
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
    }

    // navigatorKey.currentState!.popUntil((route) => route.isFirst);
    // navigatorKey.currentState!.pop();
    Navigator.popUntil(context, ModalRoute.withName('/tour_guide_list'));
    Utils.showSnackBarSuccess('Booking Request Sent');
  }

  Future<DateTime?> pickDate(DateTime today) => showDatePicker(
    context: context,
    initialDate: today,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

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
