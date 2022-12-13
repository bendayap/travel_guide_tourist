import 'package:cloud_firestore/cloud_firestore.dart';

class Chatroom {
  final String chatroomId;
  final String chatroomTitle;
  final String tourGuideId;
  final String touristId;
  final String lastMessage;
  final DateTime lastMessageTime;

  const Chatroom(
      {required this.chatroomId,
        required this.chatroomTitle,
        required this.tourGuideId,
        required this.touristId,
        required this.lastMessage,
        required this.lastMessageTime,
      });

  static Chatroom fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Chatroom(
      chatroomId: snapshot["chatroomId"],
      chatroomTitle: snapshot["chatroomTitle"],
      tourGuideId: snapshot["tourGuideId"],
      touristId: snapshot["touristId"],
      lastMessage: snapshot["lastMessage"],
      lastMessageTime: snapshot["lastMessageTime"],
    );
  }

  static Chatroom fromJson(Map<String, dynamic>json) => Chatroom(
    chatroomId: json["chatroomId"],
    chatroomTitle: json["chatroomTitle"],
    tourGuideId: json["tourGuideId"],
    touristId: json["touristId"],
    lastMessage: json["lastMessage"],
    lastMessageTime: json["lastMessageTime"],
  );

  Map<String, dynamic> toJson() => {
    "chatroomId": chatroomId,
    "chatroomTitle": chatroomTitle,
    "tourGuideId": tourGuideId,
    "touristId": touristId,
    "lastMessage": lastMessage,
    "lastMessageTime": lastMessageTime,
  };
}