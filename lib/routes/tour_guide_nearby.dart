import 'package:travel_guide_tourist/imports.dart';

class TourGuideNearby extends StatefulWidget {
  const TourGuideNearby({Key? key}) : super(key: key);

  @override
  State<TourGuideNearby> createState() => _TourGuideNearbyState();
}

class _TourGuideNearbyState extends State<TourGuideNearby> {

  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);
    String currentAddress = data['currentAddress'];
    num currentLat = data['currentLat'];
    num currentLng = data['currentLng'];

    var onDutyList = data['onDutyList'];

    Widget buildTourGuide(TourGuide tourGuide) => Card(
          child: ListTile(
            onTap: () {
              ///pass arguments to route
              Navigator.pushNamed(context, '/tour_guide_nearby_detail',
                  arguments: {
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
                    'currentLat': currentLat,
                    'currentLng': currentLng,
                  });
            },
            leading: CircleAvatar(child: Image.network(tourGuide.photoUrl)),
            title: Text(tourGuide.username),
            // trailing: Padding(
            //   padding: EdgeInsets.all(3.0),
            //   child: ,
            // ),
          ),
        );

    Stream<List<TourGuide>> readTourGuides() => FirebaseFirestore.instance
        .collection('tourGuides')
        .where('uid', whereIn: onDutyList) //filter where in
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
            Text('${onDutyList.length}'),
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

  // getInstant() async {
  //   InstantOrder instantOrder;
  //   await FirebaseFirestore.instance
  //   .collection('instantOrder')
  //   // .where('onDuty', isEqualTo: true)
  //       .get()
  //       .then((value) => {
  //     value.docs.forEach((doc) {
  //       // instantOrder = InstantOrder.fromJson(doc.data());
  //       // onDutyList.add(instantOrder.ownerID);
  //       // onDutyList.add(doc.data()['ownerID'].toString());
  //       onDutyList.add(doc.data()['ownerID']);
  //       // onDutyList.add('pp123');
  //     })
  //   });
  //   // onDutyList.add('ww');
  // }
}
