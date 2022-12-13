import 'package:travel_guide_tourist/imports.dart';

class HistoryFeedback {
  final String feedbackId;
  final String toId;
  final String fromId;
  final DateTime feedbackDate;
  final String content;
  final num rating;

  const HistoryFeedback({
    this.feedbackId = '',
    required this.toId,
    required this.fromId,
    required this.feedbackDate,
    required this.content,
    required this.rating,
  });

  static HistoryFeedback fromJson(Map<String, dynamic>json) => HistoryFeedback(
    feedbackId: json['feedbackId'],
    toId: json['toId'],
    fromId: json['fromId'],
    feedbackDate: (json['feedbackDate'] as Timestamp).toDate(),
    content: json['content'],
    rating: json['rating'],
  );

  Map<String, dynamic> toJson() => {
    'feedbackId': feedbackId,
    'toId': toId,
    'fromId': fromId,
    'feedbackDate': feedbackDate,
    'content': content,
    'rating': rating,
  };
}
