import 'package:travel_guide_tourist/imports.dart';

class Booking {
  final String bookingId;
  final String packageId;
  final String tourGuideId;
  final String touristId;
  final num price;
  final DateTime bookingDate;
  final DateTime tourDate;
  final String status; //Pending, Accepted, Rejected, Completed
  final bool isPaymentMade;

  const Booking({
    this.bookingId = '',
    required this.packageId,
    required this.tourGuideId,
    required this.touristId,
    required this.price,
    required this.bookingDate,
    required this.tourDate,
    this.status = 'Pending',
    this.isPaymentMade = false,
  });

  static Booking fromJson(Map<String, dynamic>json) => Booking(
    bookingId: json['bookingId'],
    packageId: json['packageId'],
    tourGuideId: json['tourGuideId'],
    touristId: json['touristId'],
    price: json['price'],
    bookingDate: (json['bookingDate'] as Timestamp).toDate(),
    tourDate: (json['tourDate'] as Timestamp).toDate(),
    status: json['status'],
    isPaymentMade: json['isPaymentMade'],
  );

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'packageId': packageId,
    'tourGuideId': tourGuideId,
    'touristId': touristId,
    'price': price,
    'bookingDate': bookingDate,
    'tourDate': tourDate,
    'status': status,
    'isPaymentMade': isPaymentMade,
  };
}
