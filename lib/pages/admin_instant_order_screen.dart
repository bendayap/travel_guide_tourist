import 'package:travel_guide_tourist/imports.dart';
import 'package:travel_guide_tourist/routes/order_detail_view_only.dart';

import '../routes/booking_detail_view_only.dart';

class AdminInstantOrderScreen extends StatefulWidget {
  const AdminInstantOrderScreen({super.key});

  @override
  State<AdminInstantOrderScreen> createState() =>
      _AdminInstantOrderScreenState();
}

class _AdminInstantOrderScreenState extends State<AdminInstantOrderScreen> {
  bool isLoading = false;
  bool isAdmin = false;

  Widget buildOrder(OrderRequest order) => Card(
        child: ListTile(
          onTap: () async {
            ///pass arguments to route
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailViewOnly(
                  orderId: order.orderId,
                ),
              ),
            );
          },
          title: Text('ID: ${order.orderId}'),
          subtitle: Text('Tourist ID: ${order.touristId}'
              '\nDate: ${order.startTime.toString()}\nPrice: ${order.paymentAmount}'),
        ),
      );

  Stream<List<OrderRequest>> readOrders() => FirebaseFirestore.instance
      .collection('orderRequests')
      .orderBy('touristId', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => OrderRequest.fromJson(doc.data()))
          .toList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Order"),
        backgroundColor: AppTheme.mainAppBar,
        centerTitle: true,
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
