import 'package:travel_guide_tourist/imports.dart';

class TransactionDetail extends StatefulWidget {
  const TransactionDetail({Key? key}) : super(key: key);

  @override
  State<TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {

  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);

    return Scaffold(
      appBar: AppBar(title: const Text("Transaction Detail")),
      body: Column(
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
                    const Text("Transaction Info: "),
                    Text("Id: \n${data['transactionId']}\n"),
                    Text("Amount: ${data['transactionAmount']}"),
                    Text("Receive From : ${data['receiveFrom']}"),
                    Text("Transfer To : ${data['transferTo']}"),
                    Text("Type: ${data['transactionType']}"),
                    Text("Details : ${data['paymentDetails']}"),
                    Text("Payment Method: ${data['paymentMethod']}"),
                    Text("Date: ${data['dateTime']}"),
                    Text("Status: ${data['status']}"),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}
