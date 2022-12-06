import 'package:travel_guide_tourist/imports.dart';

class HistoryFeedback {
  final String feedbackId;
  final String tourGuideId;
  final String touristId;
  final DateTime feedbackDate;
  final String content;
  final num rating;

  const HistoryFeedback({
    this.feedbackId = '',
    required this.tourGuideId,
    required this.touristId,
    required this.feedbackDate,
    required this.content,
    required this.rating,
  });

  static HistoryFeedback fromJson(Map<String, dynamic>json) => HistoryFeedback(
    feedbackId: json['feedbackId'],
    tourGuideId: json['tourGuideId'],
    touristId: json['touristId'],
    feedbackDate: (json['feedbackDate'] as Timestamp).toDate(),
    content: json['content'],
    rating: json['rating'],
  );

  Map<String, dynamic> toJson() => {
    'feedbackId': feedbackId,
    'tourGuideId': tourGuideId,
    'touristId': touristId,
    'feedbackDate': feedbackDate,
    'content': content,
    'rating': rating,
  };
}
