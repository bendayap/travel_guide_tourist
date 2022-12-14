import 'package:travel_guide_tourist/imports.dart';

class TouristOrderList extends StatelessWidget {
  const TouristOrderList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);
    Widget buildOrder(OrderRequest order) => Card(
          child: ListTile(
            onTap: () async {
              ///pass arguments to route
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetail(
                    orderId: order.orderId,
                  ),
                ),
              );
            },
            title: Text('ID: ${order.orderId}'),
            subtitle: Text(
                'Date: ${order.startTime.toString()}\nAmount: RM ${order.paymentAmount}\nStatus: ${order.status}'),
          ),
        );

    Stream<List<OrderRequest>> readOrders() => FirebaseFirestore.instance
        .collection('orderRequests')
        .where('touristId', isEqualTo: data['uid'])
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderRequest.fromJson(doc.data())).toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<OrderRequest>>(
          stream: readOrders(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong! ${snapshot.error}');
            } else if (snapshot.hasData) {
              final order = snapshot.data!;

              return ListView(
                children: order.map(buildOrder).toList(),
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
