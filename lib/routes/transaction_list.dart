import 'package:travel_guide_tourist/imports.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);

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
        title: Text('Date: ${touristTransaction.dateTime}'),
        subtitle: Text('Amount: ${touristTransaction.transactionAmount}'),
      ),
    );

    Stream<List<TouristTransaction>> readTouristTransactions() => FirebaseFirestore.instance
        .collection("touristTransactions")
        .where("ownerId", isEqualTo: data['ownerId'])
        .orderBy("dateTime", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TouristTransaction.fromJson(doc.data()))
        .toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<TouristTransaction>>(
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
