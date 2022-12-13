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
                    Text("transactionId: \n${data['transactionId']}\n"),
                    Text("transactionAmount: ${data['transactionAmount']}"),
                    Text("receiveFrom : ${data['receiveFrom']}"),
                    Text("transferTo : ${data['transferTo']}"),
                    Text("transactionType: ${data['transactionType']}"),
                    Text("paymentDetails : ${data['paymentDetails']}"),
                    Text("paymentMethod: ${data['paymentMethod']}"),
                    Text("dateTime: ${data['dateTime']}"),
                    Text("status: ${data['status']}"),
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
