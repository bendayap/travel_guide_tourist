import 'package:travel_guide_tourist/imports.dart';

class TourGuideList extends StatelessWidget {
  const TourGuideList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget buildTourGuide(TourGuide tourGuide) => Card(
          child: ListTile(
            onTap: () {
              ///pass arguments to route
              Navigator.pushNamed(context, '/tour_guide_detail', arguments: {
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
              });
            },
            leading: CircleAvatar(child: Image.network(tourGuide.photoUrl)),
            title: Text(tourGuide.username),
          ),
        );

    Stream<List<TourGuide>> readTourGuides() => FirebaseFirestore.instance
        .collection('tourGuides')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TourGuide.fromJson(doc.data()))
            .toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Tour Guide List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<TourGuide>>(
          stream: readTourGuides(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong! ${snapshot.error}');
            } else if (snapshot.hasData) {
              final tourGuides = snapshot.data!;
              // if (tourGuides.isEmpty) {
              //   return const Padding(
              //     padding: EdgeInsets.all(5),
              //       child: Text('The tour guide currently has no providing any tour package.'),
              //   );
              // }
              return ListView(
                children: tourGuides.map(buildTourGuide).toList(),
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
