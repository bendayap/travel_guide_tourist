import 'package:travel_guide_tourist/imports.dart';

class ChatroomList extends StatefulWidget {
  const ChatroomList({super.key});

  @override
  State<ChatroomList> createState() => _ChatroomListState();
}

class _ChatroomListState extends State<ChatroomList> {
  bool isLoading = false;
  var user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    // addChat();
  }

  addChat() async {
    try {
      String res = await addChatroom("Tourist 1",
          FirebaseAuth.instance.currentUser!.uid, "Name 1", "[No message]");
      if (res == "success") {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message'),
        backgroundColor: AppTheme.secondaryAppBar,
      ),
      body: isLoading
          ? LoadingView()
          : Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.mainBackground,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("chatrooms")
                          .where("touristId", isEqualTo: user.uid)
                          .orderBy("lastMessageTime", descending: true)
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: LoadingView(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Text('Something went wrong! ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (ctx, index) => ChatroomCard(
                              snap: snapshot.data!.docs[index].data(),
                              index: index,
                            ),
                          );
                        }else {
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

  Future<String> addChatroom(String chatroomTitle, String tourGuideId,
      String touristId, String lastMessage) async {
    final firestore = FirebaseFirestore.instance;
    String res = "Some error occurred";
    String chatroomId = "chatroom_${tourGuideId}_$touristId";

    try {
      var chatroomSnap =
          await firestore.collection('chatrooms').doc(chatroomId).get();

      if (!chatroomSnap.exists) {
        Chatroom chatroom = Chatroom(
          chatroomId: chatroomId,
          chatroomTitle: chatroomTitle,
          tourGuideId: tourGuideId,
          touristId: touristId,
          lastMessage: lastMessage,
          lastMessageTime: DateTime.now(),
        );
        firestore
            .collection('chatrooms')
            .doc(chatroomId)
            .set(chatroom.toJson());
      }

      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
