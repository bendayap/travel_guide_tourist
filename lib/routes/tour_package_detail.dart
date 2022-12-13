// ignore_for_file: use_build_context_synchronously

import 'package:travel_guide_tourist/imports.dart';

class TourPackageDetail extends StatefulWidget {
  const TourPackageDetail({Key? key}) : super(key: key);

  @override
  State<TourPackageDetail> createState() => _TourPackageDetailState();
}

class _TourPackageDetailState extends State<TourPackageDetail> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);
    var user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Package Title: ${data['packageTitle']}'
            ),
            // const SizedBox(height: 4.0),
            // const Text('Package Type: '),
            // for(int i=0; i<data['packageType'].length; i++)
            //   Text('\n    ${data['packageType'][i]}'),
            const SizedBox(height: 4.0),
            Text(
                'Tour Guide: ${data['ownerId']}'
            ),
            const SizedBox(height: 4.0),
            Text(
                'Duration: ${data['duration']} day(s)'
            ),
            const SizedBox(height: 4.0),
            Text(
                'Price: RM ${data['price']}'
            ),
            const SizedBox(height: 4.0),
            Text(
                'About the package: \n${data['content']}'
            ),
            const SizedBox(height: 20.0),
            const Text('Type: '),
            for(int i=0; i<data['packageType'].length;i++)
              Text("  ${data['packageType'][i]}"),
            const SizedBox(height: 20.0),
            ElevatedButton(
                onPressed: () async {
                  if (user != null) {
                    Navigator.pushNamed(context, '/request_booking', arguments: {
                    'packageId': data['packageId'],
                    'tourGuideId': data['ownerId'],
                    'price': data['price'],
                  });
                  } else {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          AlertDialog(
                            title: const Text(
                                'No User Logged'),
                            // content: const Text(
                            //     'Login first in order to make a request.'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: const <Widget>[
                                  Text('Login first in order to make a request.'),
                                  Text('Profile -> Login/Sign Up'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 'Not Now');
                                },
                                child: const Text('Not Now'),
                              ),
                              TextButton(
                                onPressed: () {
                                  navigatorKey.currentState!.popUntil((route) => route.isFirst);
                                  // Navigator.pop(context, 'Go to Home');
                                },
                                child: const Text('Go to Home'),
                              ),
                            ],
                          ),
                    );
                  }
                },
                child: const Text('Book Now'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (user != null) {
                  String chatroomId = "chatroom_${data['ownerId']}_${user.uid}";
                  bool chatroomExists = await checkIfDocExists(chatroomId);
                  if (!chatroomExists) {
                    await addChatroom(chatroomId, data['packageTitle'],
                        data['ownerId'], user.uid);
                  }
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatroomScreen(
                              chatroomId: chatroomId,
                            // packageTitle: data['packageTitle'],
                          ),
                    ),
                  );
                } else {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        AlertDialog(
                          title: const Text(
                              'No User Logged'),
                          // content: const Text(
                          //     'Login first in order to make a request.'),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: const <Widget>[
                                Text('Login first in order to start chatting.'),
                                Text('Go to Profile -> Login/Sign Up'),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, 'Not Now');
                              },
                              child: const Text('Not Now'),
                            ),
                            TextButton(
                              onPressed: () {
                                navigatorKey.currentState!.popUntil((route) => route.isFirst);
                                // Navigator.pop(context, 'Go to Home');
                              },
                              child: const Text('Go to Home'),
                            ),
                          ],
                        ),
                  );
                }
              },
              child: const Text('Chat with Tour Guide'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> addChatroom(String chatroomId, String chatroomTitle,
      String tourGuideId, String touristId) async {

    final firestore = FirebaseFirestore.instance;
    String res = "Some error occurred";

    try {
      var chatroomSnap = await firestore.collection('chatrooms')
          .doc(chatroomId).get();

      if(!chatroomSnap.exists) {
        Chatroom chatroom = Chatroom(
          chatroomId: chatroomId,
          chatroomTitle: chatroomTitle,
          tourGuideId: tourGuideId,
          touristId: touristId,
          lastMessage: "Hi.",
          lastMessageTime: DateTime.now(),
        );
        firestore.collection('chatrooms').doc(chatroomId).set(chatroom.toJson());
      }

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('chatrooms');
      // int numberOfCollectionRef = await FirebaseFirestore.instance.collection('feedbacks').snapshots().length;

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }
}
