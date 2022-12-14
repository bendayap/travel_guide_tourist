import 'package:travel_guide_tourist/imports.dart';

class AdminWalletScreen extends StatefulWidget {
  const AdminWalletScreen({super.key});

  @override
  State<AdminWalletScreen> createState() => _AdminWalletScreenState();
}

class _AdminWalletScreenState extends State<AdminWalletScreen> {
  bool isLoading = false;
  bool isAdmin = false;

  Widget buildTouristTransaction(TouristTransaction touristTransaction) => Card(
    child: ListTile(
      onTap: () {
        ///pass arguments to route
        Navigator.pushNamed(context, '/transaction_detail', arguments: {
          "transactionId": touristTransaction.transactionId,
          "transactionAmount": touristTransaction.transactionAmount,
          "ownerId": touristTransaction.ownerId,
          "receiveFrom": touristTransaction.receiveFrom,
          "transferTo": touristTransaction.transferTo,
          "transactionType": touristTransaction.transactionType,
          "paymentDetails": touristTransaction.paymentDetails,
          "paymentMethod": touristTransaction.paymentMethod,
          "newWalletBalance": touristTransaction.newWalletBalance,
          "dateTime": touristTransaction.dateTime,
          "status": touristTransaction.status,
        });
      },
      title: Text('${touristTransaction.transactionId}'),
      subtitle: Text('Tourist ID: ${touristTransaction.ownerId}'
          '\nDate: ${touristTransaction.dateTime}'
          '\nAmount: ${touristTransaction.transactionAmount}'),
    ),
  );

  Stream<List<TouristTransaction>> readTouristTransactions() => FirebaseFirestore.instance
      .collection("touristTransactions")
      .orderBy("ownerId", descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => TouristTransaction.fromJson(doc.data()))
      .toList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Wallet"),
        backgroundColor: AppTheme.mainAppBar,
        centerTitle: true,
      ),
      body: Container(
        child: isLoading ? LoadingView() : StreamBuilder<List<TouristTransaction>>(
          stream: readTouristTransactions(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong! ${snapshot.error}');
            } else if (snapshot.hasData) {
              final touristTransaction = snapshot.data!;

              return ListView(
                children: touristTransaction.map(buildTouristTransaction).toList(),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
