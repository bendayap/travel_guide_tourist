class Tourist {
  late String uid;
  final String username;
  final String fullname;
  final String phoneNumber;
  final String email;
  final String icNumber;
  final String photoUrl;
  final String description;
  final double rating;
  final bool icVerified;

  Tourist({
    this.uid = '',
    required this.username,
    required this.fullname,
    required this.phoneNumber,
    required this.email,
    required this.icNumber,
    this.photoUrl =
        'https://firebasestorage.googleapis.com/v0/b/fyp-travel-guide-6b527.appspot.com/o/default-avatar.jpg?alt=media', //default profile pic
    required this.description,
    required this.rating,
    required this.icVerified,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'username': username,
        'fullname': fullname,
        'phoneNumber': phoneNumber,
        'email': email,
        'icNumber': icNumber,
        'photoUrl': photoUrl,
        'description': description,
        'rating': rating,
        'icVerified': icVerified,
      };

  static Tourist fromJson(Map<String, dynamic> json) => Tourist(
        uid: json['uid'],
        username: json['username'],
        fullname: json['fullname'],
        phoneNumber: json['phoneNumber'],
        email: json['email'],
        icNumber: json['icNumber'],
        photoUrl: json['photoUrl'],
        description: json['description'],
        rating: json['rating'],
        icVerified: json['icVerified'],
      );
}
