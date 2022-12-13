import 'package:travel_guide_tourist/imports.dart';

class AddBankCard extends StatefulWidget {

  const AddBankCard({
    Key? key,
  }) : super(key: key);

  @override
  State<AddBankCard> createState() => _AddBankCardState();
}

class _AddBankCardState extends State<AddBankCard> {
  final formKey = GlobalKey<FormState>();
  final cardNumberController = TextEditingController();
  final ccvController = TextEditingController();
  final expiredDateController = TextEditingController();

  String cardNumber = "";
  String ccvNumber = "";
  String expiredDateNumber = '';

  @override
  void dispose() {
    cardNumberController.dispose();
    ccvController.dispose();
    expiredDateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
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
        title: const Text('Add Bank Card'),
        backgroundColor: AppTheme.mainAppBar,
        // centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // const FlutterLogo(size: 120),
              const SizedBox(height: 20),
              TextFormField(
                ///Card Number Field
                controller: cardNumberController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CardNumberFormatter(),
                ],
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/800px-Mastercard-logo.svg.png',
                      height: 30,
                      width: 30,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                  hintText: 'XXXX XXXX XXXX XXXX',
                  labelText: 'Card Number',
                  counterText: "",
                ),
                maxLength: 19,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length != 19
                    ? "Enter Valid Card Number"
                    : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                ///Expired Date Field
                controller: expiredDateController,
                inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ExpiredDateFormatter(),
                    ],
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'MM/YY',
                      labelText: 'Expired Date',
                      counterText: "",
                    ),
                maxLength: 5,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length != 5
                    ? "Enter Valid Date with format 'MM/YY'"
                    : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                ///CCV Field
                controller: ccvController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'XXX',
                  labelText: 'CCV',
                  counterText: "",
                ),
                maxLength: 3,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value != null && value.length != 3
                    ? "Enter Valid CCV number"
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.add, size: 32),
                label: const Text(
                  'Add Card',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: addBankCard,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ),
  );

  Future addBankCard() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String cardNumber = cardNumberController.text.trim();
    String ccv = ccvController.text.trim();
    String expiredDate = expiredDateController.text.trim();

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final docBankCard = firestore.collection('bankCards').doc();
      final user = FirebaseAuth.instance.currentUser!;

      ///Create tourist document
      BankCard bankCard = BankCard(
          cardId: docBankCard.id,
          ownerId: user.uid,
          cardNumber: cardNumber,
          ccv: ccv,
          expiredDate: expiredDate,
      );

      await firestore
          .collection("bankCards")
          .doc(docBankCard.id)
          .set(bankCard.toJson());

    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    }

    Utils.showSnackBarSuccess('Bank Card Added Successfully');
    navigatorKey.currentState!.pop();
    navigatorKey.currentState!.pop();
  }
}

class ExpiredDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue previousValue,
      TextEditingValue nextValue,
      ) {
    var inputText = nextValue.text;

    if (nextValue.selection.baseOffset == 0) {
      return nextValue;
    }

    var bufferString = new StringBuffer();
    for (int i = 0; i < inputText.length; i++) {
      bufferString.write(inputText[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % 2 == 0 && nonZeroIndexValue != inputText.length) {
        bufferString.write('/');
      }
    }

    var string = bufferString.toString();
    return nextValue.copyWith(
      text: string,
      selection: new TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue previousValue,
      TextEditingValue nextValue,
      ) {
    var inputText = nextValue.text;

    if (nextValue.selection.baseOffset == 0) {
      return nextValue;
    }

    var bufferString = new StringBuffer();
    for (int i = 0; i < inputText.length; i++) {
      bufferString.write(inputText[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % 4 == 0 && nonZeroIndexValue != inputText.length) {
        bufferString.write(' ');
      }
    }

    var string = bufferString.toString();
    return nextValue.copyWith(
      text: string,
      selection: new TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}
