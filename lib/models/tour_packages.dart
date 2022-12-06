import 'package:cloud_firestore/cloud_firestore.dart';

class TourPackage {
  final String packageId;
  final String packageTitle;
  final String ownerId;
  final List<dynamic> packageType;
  final String photoUrl;
  final String content;
  final double price;
  final int duration;
  final String stateOfCountry;
  final DateTime createDate;
  final DateTime lastModifyDate;

  const TourPackage(
      {required this.packageId,
        required this.packageTitle,
        required this.ownerId,
        required this.packageType,
        required this.photoUrl,
        required this.content,
        required this.price,
        required this.duration,
        required this.stateOfCountry,
        required this.createDate,
        required this.lastModifyDate,
      });

  static TourPackage fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return TourPackage(
      packageId: snapshot["packageId"],
      packageTitle: snapshot["packageTitle"],
      ownerId: snapshot["ownerId"],
      photoUrl: snapshot["photoUrl"],
      packageType: snapshot["packageType"],
      content: snapshot["content"],
      price: snapshot["price"],
      duration: snapshot["duration"],
      stateOfCountry: snapshot["stateOfCountry"],
      createDate: snapshot["createDate"],
      lastModifyDate: snapshot["lastModifyDate"],
    );
  }

  static TourPackage fromJson(Map<String, dynamic>json) => TourPackage(
    packageId: json["packageId"],
    packageTitle: json["packageTitle"],
    ownerId: json["ownerId"],
    packageType: json["packageType"],
    photoUrl: json["photoUrl"],
    content: json["content"],
    price: json["price"],
    duration: json["duration"],
    stateOfCountry: json["stateOfCountry"],
    createDate: (json["createDate"]  as Timestamp).toDate(),
    lastModifyDate: (json["lastModifyDate"] as Timestamp).toDate(),
  );

  Map<String, dynamic> toJson() => {
    "packageId": packageId,
    "packageTitle": packageTitle,
    "ownerId": ownerId,
    "packageType": packageType.map((i) => i).toList(),
    "photoUrl": photoUrl,
    "content": content,
    "price": price,
    "duration": duration,
    "stateOfCountry": stateOfCountry,
    "createDate": createDate,
    "lastModifyDate": lastModifyDate,
  };
}