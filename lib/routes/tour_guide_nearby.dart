import 'package:travel_guide_tourist/imports.dart';

class TourGuideNearby extends StatefulWidget {
  const TourGuideNearby({Key? key}) : super(key: key);

  @override
  State<TourGuideNearby> createState() => _TourGuideNearbyState();
}

class _TourGuideNearbyState extends State<TourGuideNearby> {

  @override
  void initState() {
    ///TODO: Implement statement
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);
    String currentAddress = data['currentAddress'];
    num currentLat = data['currentLat'];
    num currentLng = data['currentLng'];

    Widget buildTourGuide(TourGuide tourGuide) => Card(
          child: ListTile(
            onTap: () {
              ///pass arguments to route
              Navigator.pushNamed(context, '/tour_guide_nearby_detail', arguments: {
                'uid': tourGuide.uid,
                'username': tourGuide.username,
                'fullname': tourGuide.fullname,
                'phoneNumber': tourGuide.phoneNumber,
                'email': tourGuide.email,
                'isEmailVerified': tourGuide.isEmailVerified,
                'icNumber': tourGuide.icNumber,
                'isIcVerified': tourGuide.isIcVerified,
                'photoUrl': tourGuide.photoUrl,
                'description': tourGuide.description,
                'language': tourGuide.language,
                'rating': tourGuide.rating,
                'rateNumber': tourGuide.rateNumber,
                'totalDone': tourGuide.totalDone,
                'grade': tourGuide.grade,
                'currentAddress': currentAddress,
              });
            },
            leading: CircleAvatar(child: Image.network(tourGuide.photoUrl)),
            title: Text(tourGuide.username),
          ),
        );


    // List<String> strList;
    // FirebaseFirestore.instance.collection('instantOrder')
    //     .where('onDuty', isEqualTo: true).get().then((snapshot) => {
    //       snapshot.docs.forEach((doc){
    //         strList.add(doc.data['ownerId']);
    //       })
    // });

    Stream<List<TourGuide>> readInstantOrder = FirebaseFirestore.instance.collection('instantOrder')
         .where('onDuty', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TourGuide.fromJson(doc.data()))
        .toList());

    Stream<List<TourGuide>> readTourGuides() => FirebaseFirestore.instance
        .collection('tourGuides')
        // .where('isIcVerified', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TourGuide.fromJson(doc.data()))
            .toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Guide Nearby'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 10.0),
            Text('Your Location: \n$currentAddress'),
            const SizedBox(height: 10.0),
            const Text('Tour Guide Near You'),
            // Text('$instantOrder'),
            const SizedBox(height: 10.0),
            Expanded(
              child: StreamBuilder<List<TourGuide>>(
                stream: readTourGuides(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong! ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    ///TODO: this
                    // return ListView(children: snapshot.data!.map((doc){
                    //
                    // }).toList());

                      // return StreamBuilder<List<InstantOrder>> (
                      //   stream: readInstantOrder,
                      //   builder: (context, snapshot){
                      //
                      //   },
                      // );
                    ///Ori code
                    final tourGuides = snapshot.data!;

                    return ListView(
                      children: tourGuides.map(buildTourGuide).toList(),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _calculateDistance(double lat1, double lng1, lat2, lng2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    var distanceInKiloMeters = 12742 * asin(sqrt(a));

    /// return as distance in Meters
    return distanceInKiloMeters * 1000;
  }
}
