import 'package:cloud_firestore/cloud_firestore.dart';

class TouristTransaction {
  final String transactionId;
  final String transactionAmount;
  final String ownerId;
  final String receiveFrom;
  final String transferTo;
  final String transactionType;
  final String paymentDetails;
  final String paymentMethod;
  final double newWalletBalance;
  final DateTime dateTime;
  final String status;

  const TouristTransaction({
    required this.transactionId,
    required this.transactionAmount,
    required this.ownerId,
    required this.receiveFrom,
    required this.transferTo,
    required this.transactionType,
    required this.paymentDetails,
    required this.paymentMethod,
    required this.newWalletBalance,
    required this.dateTime,
    required this.status,
  });

  static TouristTransaction fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return TouristTransaction(
      transactionId: snapshot["transactionId"],
      transactionAmount: snapshot["transactionAmount"],
      ownerId: snapshot["ownerId"],
      receiveFrom: snapshot["receiveFrom"],
      transferTo: snapshot["transferTo"],
      transactionType: snapshot["transactionType"],
      paymentDetails: snapshot["paymentDetails"],
      paymentMethod: snapshot["paymentMethod"],
      newWalletBalance: snapshot["newWalletBalance"],
      dateTime: snapshot["dateTime"],
      status: snapshot["status"],
    );
  }

  static TouristTransaction fromJson(Map<String, dynamic> json) =>
      TouristTransaction(
        transactionId: json["transactionId"],
        transactionAmount: json["transactionAmount"],
        ownerId: json["ownerId"],
        receiveFrom: json["receiveFrom"],
        transferTo: json["transferTo"],
        transactionType: json["transactionType"],
        paymentDetails: json["paymentDetails"],
        paymentMethod: json["paymentMethod"],
        newWalletBalance: json["newWalletBalance"],
        dateTime: (json["dateTime"] as Timestamp).toDate(),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "transactionId": transactionId,
        "transactionAmount": transactionAmount,
        "ownerId": ownerId,
        "receiveFrom": receiveFrom,
        "transferTo": transferTo,
        "transactionType": transactionType,
        "paymentDetails": paymentDetails,
        "paymentMethod": paymentMethod,
        "newWalletBalance": newWalletBalance,
        "dateTime": dateTime,
        "status": status,
      };
}
