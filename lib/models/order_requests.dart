import 'package:travel_guide_tourist/imports.dart';

class OrderRequest {
  final String orderId;
  final String tourGuideId;
  final String touristId;
  final String address;
  final DateTime startTime;
  final DateTime endTime;
  final String status; //Pending, Accepted, Rejected, Cancelled, Completed
  final num paymentAmount;
  final bool isPaymentMade;

  const OrderRequest({
    this.orderId = '',
    required this.tourGuideId,
    required this.touristId,
    required this.address,
    required this.startTime,
    required this.endTime,
    this.status = 'Pending',
    this.paymentAmount = 0,
    this.isPaymentMade = false,
  });

  static OrderRequest fromJson(Map<String, dynamic>json) => OrderRequest(
    orderId: json['orderId'],
    tourGuideId: json['tourGuideId'],
    touristId: json['touristId'],
    address: json['address'],
    startTime: (json['startTime'] as Timestamp).toDate(),
    endTime: (json['endTime'] as Timestamp).toDate(),
    status: json['status'],
    paymentAmount: json['paymentAmount'],
    isPaymentMade: json['isPaymentMade'],
  );

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'tourGuideId': tourGuideId,
    'touristId': touristId,
    'address': address,
    'startTime': startTime,
    'endTime': endTime,
    'status': status,
    'paymentAmount': paymentAmount,
    'isPaymentMade': isPaymentMade,
  };
}
