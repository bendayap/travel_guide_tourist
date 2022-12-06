// ignore_for_file: use_build_context_synchronously

import 'package:travel_guide_tourist/imports.dart';

class TourGuideNearbyDetail extends StatefulWidget {
  const TourGuideNearbyDetail({Key? key}) : super(key: key);

  @override
  State<TourGuideNearbyDetail> createState() => _TourGuideNearbyDetailState();
}

class _TourGuideNearbyDetailState extends State<TourGuideNearbyDetail> {
  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);
    String currentAddress = data['currentAddress'];
    String tourGuideId = data['uid'];

    return Scaffold(
      appBar: AppBar(
        title: Text("${data['username']}'s Detail"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListTile(
            leading:
                CircleAvatar(child: Image.network(data['photoUrl'].toString())),
            title: Text(data['username']),
          ),
          const SizedBox(height: 10.0),
          const Text('Tour Guide Info: '),
          ///TODO: display tour guide info
          const SizedBox(height: 40.0),
          ElevatedButton(
            onPressed: () {
              _requestOrder(tourGuideId, currentAddress);
            },
            child: const Text('Order this guide'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestOrder(String tourGuideId, String currentAddress)
  async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (FirebaseAuth.instance.currentUser != null) {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final docOrder = firestore.collection('orderRequests').doc();
      final user = FirebaseAuth.instance.currentUser!;

      OrderRequest orderRequest = OrderRequest(
        orderId: docOrder.id,
        tourGuideId: tourGuideId,
        touristId: user.uid,
        address: currentAddress,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );

      await firestore
          .collection("orderRequests")
          .doc(docOrder.id)
          .set(orderRequest.toJson());
    }

    Navigator.popUntil(context, ModalRoute.withName('/tour_guide_nearby'));
    Utils.showSnackBarSuccess('Order Request Sent');
  }
}
