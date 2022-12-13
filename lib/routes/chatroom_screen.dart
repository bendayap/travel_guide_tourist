// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:travel_guide_tourist/imports.dart';

class ChatroomScreen extends StatefulWidget {
  final chatroomId;
  // final packageTitle;

  const ChatroomScreen({
    super.key,
    required this.chatroomId,
    // required this.packageTitle
  });

  @override
  State<ChatroomScreen> createState() => _ChatroomScreenState();
}

class _ChatroomScreenState extends State<ChatroomScreen> {
  TextEditingController contentController = TextEditingController();
  bool isLoading = false;
  String tourGuideName = '';
  String touristName = '';
  String chatroomTitle = '';

  @override
  void initState() {
    super.initState();
    // sendMessage();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      ///TODO: when come back same packageTitle will have error message
      var chatroomDetailSnap = await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatroomId)
          .get();

      var tourGuideSnap = await FirebaseFirestore.instance
          .collection('tourGuides')
          .doc(chatroomDetailSnap.data()!["tourGuideId"])
          .get();

      var touristSnap = await FirebaseFirestore.instance
          .collection('tourists')
          .doc(chatroomDetailSnap.data()!["touristId"])
          .get();

      setState(() {
        tourGuideName = tourGuideSnap.data()!["username"];
        touristName = touristSnap.data()!["username"];
        // chatroomTitle = widget.packageTitle;
        chatroomTitle = chatroomDetailSnap.data()!['chatroomTitle'];
      });
    } catch (e) {
      // Utils.showSnackBar(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  sendMessage() async {
    if (contentController.text != "") {
      try {
        String res = await firebaseSendMessage(
          widget.chatroomId,
          FirebaseAuth.instance.currentUser!.uid,
          // "Hello world",
          contentController.text,
          "text",
        );
        if (res == "success") {
          contentController.text = "";

          setState(() {
            isLoading = false;
          });
        } else {
          Utils.showSnackBar(res);
        }
      } catch (err) {
        setState(() {
          isLoading = false;
        });
        Utils.showSnackBar(err.toString());
      }
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('messages');
  List<DocumentSnapshot> documents = [];

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(chatroomTitle),
            ),
            body: Container(
              // width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.mainBackground,
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Divider(),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: StreamBuilder(
                          stream: messagesCollection
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, streamSnapshot) {
                            if (streamSnapshot.hasData) {
                              documents = streamSnapshot.data!.docs;

                              documents = documents.where((element) {
                                return element.get('chatroomId').contains(
                                    widget.chatroomId);
                              }).toList();
                            }
                            return ListView.builder(
                              reverse: true,
                              itemCount: documents.length,
                              itemBuilder: (ctx, index) => MessageCard(
                                snap: documents[index].data(),
                                touristName: touristName,
                                tourGuideName: tourGuideName,
                              ),
                            );
                          }),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                    decoration: const BoxDecoration(
                        // color: Theme.of(context).colorScheme.secondary,
                        ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 15,
                          child: TextFormField(
                            // inputFormatters: [
                            //   FilteringTextInputFormatter.digitsOnly,
                            // ],
                            controller: contentController,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Write something ...',
                            ),
                            // maxLength: null,
                            maxLines: null,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: IconButton(
                            color: Theme.of(context).colorScheme.primary,
                            icon: const Icon(Icons.send),
                            onPressed: sendMessage,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Future<String> firebaseSendMessage(
      String chatroomId, String fromId, String content, String type) async {
    final firestore = FirebaseFirestore.instance;
    String res = "Some error occurred";
    String messageId = const Uuid().v1();
    try {
      Message message = Message(
        messageId: messageId,
        chatroomId: chatroomId,
        fromId: fromId,
        content: content,
        type: type,
        timestamp: DateTime.now(),
      );
      firestore.collection('messages').doc(messageId).set(message.toJson());

      if (type == "text") {
        firestore.collection('chatrooms').doc(chatroomId).update(
            {"lastMessage": content, "lastMessageTime": DateTime.now()});
      } else if (type == "package") {
        firestore.collection('chatrooms').doc(chatroomId).update({
          "lastMessage": "Sent you a tour package",
          "lastMessageTime": DateTime.now()
        });
      }

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
