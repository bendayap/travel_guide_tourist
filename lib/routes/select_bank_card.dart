import 'package:travel_guide_tourist/imports.dart';

class SelectBankCard extends StatefulWidget {
  // final String reloadOrWithdraw;
  final String action;
  final String eWalletId;
  final num balance;

  const SelectBankCard({
    super.key,
    required this.action,
    required this.eWalletId,
    required this.balance,
    // required this.reloadOrWithdraw,
  });

  @override
  State<SelectBankCard> createState() => _SelectBankCardState();
}

class _SelectBankCardState extends State<SelectBankCard> {
  CollectionReference bankCardsCollection =
  FirebaseFirestore.instance.collection('bankCards');
  // List<DocumentSnapshot> documents = [];

  @override
  Widget build(BuildContext context) {
    Widget buildBankCard(BankCard bankCard) => Card(
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, '/update_wallet', arguments: {
            "cardId": bankCard.cardId,
            "ownerId": bankCard.ownerId,
            "cardNumber": bankCard.cardNumber,
            "ccv": bankCard.ccv,
            "expiredDate": bankCard.expiredDate,
            'action': widget.action,
            'eWalletId': widget.eWalletId,
            'balance': widget.balance,
          });
        },
        // leading: CircleAvatar(child: Image.network(tourGuide.photoUrl)),
        title: Text(bankCard.cardNumber),
      ),
    );

    Stream<List<BankCard>> readBankCards() => FirebaseFirestore.instance
        .collection('bankCards')
        .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => BankCard.fromJson(doc.data())).toList());

    return Scaffold(
      appBar: AppBar(
          title: const Text("My Bank Cards"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
        backgroundColor: AppTheme.mainAppBar,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.mainBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/add_bank_card');
                },
                child: const Text("Add Card"),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
              child: Divider(
                thickness: 1,
                indent: 0,
                endIndent: 0,
                color: Colors.grey,
              ),
            ),
            const Center(
              child: Text(
                "My Bank Cards",
                style: TextStyle(
                  // color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: StreamBuilder<List<BankCard>>(
                stream: readBankCards(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong! ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final bankCard = snapshot.data!;

                    return ListView(
                      children: bankCard.map(buildBankCard).toList(),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
              child: Divider(
                thickness: 1,
                indent: 0,
                endIndent: 0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
