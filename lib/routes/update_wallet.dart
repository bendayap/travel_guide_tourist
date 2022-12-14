import 'package:travel_guide_tourist/imports.dart';

class UpdateWallet extends StatefulWidget {
  const UpdateWallet({
    Key? key,
  }) : super(key: key);

  @override
  State<UpdateWallet> createState() => _UpdateWalletState();
}

class _UpdateWalletState extends State<UpdateWallet> {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);
    String action = data['action'];
    String eWalletId = data['eWalletId'];
    late double balance;
    if (data['balance'] is int) {
      balance = data['balance'].toDouble();
    } else if (data['balance'] is double) {
      balance = data['balance'];
    }

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
          title: Text('${data['action']}'),
          backgroundColor: AppTheme.mainAppBar,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Text.rich(TextSpan(
                  text: '${data['action']} with Card ',
                  style: const TextStyle(fontSize: 20),
                  children: <TextSpan>[
                    TextSpan(
                        text: '${data['cardNumber']}',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        )),
                    // can add more TextSpans here...
                  ],
                )),
                const SizedBox(height: 10),
                Text('Current Balance: ${data['balance']}'),
                const SizedBox(height: 30),
                TextFormField(
                  ///TODO: null check and 2 decimal
                  controller: amountController,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textInputAction: TextInputAction.done,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    // hintText: '00.00',
                    labelText: 'Amount (RM)',
                    counterText: "",
                  ),
                  // maxLength: 3,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) =>
                      value != null && (double.parse(value) < 10)
                          ? "Minimum amount is 10"
                          : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(
                    'Confirm to ${data['action']}',
                    style: const TextStyle(fontSize: 24),
                  ),
                  onPressed: () async {
                    // updateEWallet(data['action'], data['eWalletId'], data['balance']);
                    updateEWallet(action, eWalletId, data['cardNumber'], balance);
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future updateEWallet(String action, String eWalletId, String cardNumber, double balance) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    var eWalletSnap = await firestore
        .collection('eWallet')
        .doc("ewallet_${FirebaseAuth.instance.currentUser!.uid}")
        .get();
    var eWalletData = eWalletSnap.data()!;

    final user = FirebaseAuth.instance.currentUser!;
    double amount = double.parse(amountController.text);
    // double amount = 30;
    late String transactionId;
    late String transactionAmount;
    late String ownerId;
    late String receiveFrom;
    late String transferTo;
    late String transactionType;
    late String paymentDetails;
    late String paymentMethod;
    late String status;
    late double newWalletBalance;
    late DateTime dateTime;

    if (action == 'Withdraw' && eWalletData['balance'] < amount) {
      Utils.showSnackBar('Insufficient Fund');
      navigatorKey.currentState!.pop();
      return;
    }

    // try {
    transactionId = "${action}_${const Uuid().v1()}";
    ownerId = user.uid;
    if (action == 'Reload') {
      transactionAmount = "+RM ${amount.toString()}";
      receiveFrom = "Bank Card $cardNumber";
      transferTo = ownerId;
      transactionType = "Reload";
      paymentDetails = "Reload eWallet balance from bank";
      paymentMethod = "Bank Card";
      newWalletBalance = eWalletData['balance'] + amount;
    } else if (action == 'Withdraw') {
      transactionAmount = "-RM ${amount.toString()}";
      receiveFrom = ownerId;
      transferTo = "Bank Card $cardNumber";
      transactionType = "Withdraw";
      paymentDetails = "Withdraw from eWallet balance to bank";
      paymentMethod = "eWallet Balance";
      newWalletBalance = eWalletData['balance'] - amount;
    }
    dateTime = DateTime.now();
    status = "Successfully";

    ///create tourist transaction
    TouristTransaction transaction = TouristTransaction(
      transactionId: transactionId,
      transactionAmount: transactionAmount,
      ownerId: ownerId,
      receiveFrom: receiveFrom,
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

    ///update ewallet
    EWallet eWallet = EWallet(
      eWalletId: eWalletId,
      ownerId: ownerId,
      balance: newWalletBalance,
    );

    await firestore.collection("eWallet").doc(eWalletId).set(eWallet.toJson());
    // } on FirebaseAuthException catch (e) {
    //   Utils.showSnackBar(e.message);
    // }

    Utils.showSnackBarSuccess('Transferred Successfully');
    navigatorKey.currentState!.pop();
    navigatorKey.currentState!.pop();
  }
}

// keyboardType: TextInputType.numberWithOptions(decimal: true),
// inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9.,]+')),],
// onChanged: (value) => doubleVar = double.parse(value),
