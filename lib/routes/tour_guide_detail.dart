import 'package:travel_guide_tourist/imports.dart';

class TourGuideDetail extends StatefulWidget {
  const TourGuideDetail({Key? key}) : super(key: key);

  @override
  State<TourGuideDetail> createState() => _TourGuideDetailState();
}

class _TourGuideDetailState extends State<TourGuideDetail> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);

    Widget buildTourPackage(TourPackage tourPackage) => Card(
          child: ListTile(
            onTap: () {
              ///pass arguments to route
              Navigator.pushNamed(context, '/tour_package_detail', arguments: {
                "packageId": tourPackage.packageId,
                "packageTitle": tourPackage.packageTitle,
                "ownerId": tourPackage.ownerId,
                "packageType": tourPackage.packageType,
                "content": tourPackage.content,
                "price": tourPackage.price,
                "duration": tourPackage.duration,
                "stateOfCountry": tourPackage.stateOfCountry,
                "createDate": tourPackage.createDate,
                "lastModifyDate": tourPackage.lastModifyDate,
              });
            },
            // leading: CircleAvatar(child: Text(tourPackage.packageType)),
            title: Text(tourPackage.packageTitle),
            // subtitle: Text(tourPackage.packageType),
          ),
        );

    Stream<List<TourPackage>> readTourPackages() => FirebaseFirestore.instance
        .collection('tourPackages')
        .where('ownerId', isEqualTo: data['uid'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TourPackage.fromJson(doc.data()))
            .toList());

    return Scaffold(
      appBar: AppBar(title: Text("${data['username']}'s Detail")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListTile(
            leading:
                CircleAvatar(child: Image.network(data['photoUrl'].toString())),
            title: Text(data['username']),
            // subtitle: Text(language.toString()),
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tour Guide Info: "),
                    Text("Full Name: ${data['fullname']}"),
                    Text("Email: ${data['email']}"),
                    Text("Phone Number : ${data['phoneNumber']}"),
                    Text("English : ${data['language']['English']}"),
                    Text("Malay : ${data['language']['Malay']}"),
                    Text("Mandarin : ${data['language']['Mandarin']}"),
                    Text("Tamil : ${data['language']['Tamil']}"),
                    Text("Tour Done : ${data['totalDone']}"),
                    Text("Rating: ${data['rating']}"),
                    Text("Rate Number : ${data['rateNumber']}"),
                    Text("Description: ${data['description']}"),
                    const SizedBox(height: 10.0),
                    Text('"${data['description']}"'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          const Text('Tour Package(s): '),
          Flexible(
            ///Display Packages
            child: StreamBuilder<List<TourPackage>>(
              stream: readTourPackages(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong! ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final tourPackages = snapshot.data!;

                  return ListView(
                    children: tourPackages.map(buildTourPackage).toList(),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          )

          // TextFormField(
          //   /// Change username
          //   controller: textController,
          //   decoration: const InputDecoration(
          //     border: UnderlineInputBorder(),
          //     labelText: 'Enter new username',
          //   ),
          // ),
          // const SizedBox(height: 20.0),
          // ElevatedButton(
          //   onPressed: () {
          //     final docTestGuide = FirebaseFirestore.instance
          //         .collection('testGuide')
          //         .doc(data['id']);
          //
          //     docTestGuide.update({
          //       'username': textController.text,
          //       ///delete field -> 'username': FieldValue.delete(),
          //     });
          //     //retrieve latest data
          //     readLatestGuideDetail(id: data['id']);
          //     setState(() {
          //
          //       //retrieve latest data
          //       ///readLatestGuideDetail(id: data['id']);
          //       /// to be fixed, need 2 times to change in display
          //     });
          //   },
          //   child: const Text('Update Info'),
          // ),
        ],
      ),
    );
  }
}
