
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

  Tourist({
    this.uid = '',
    required this.username,
    required this.fullname,
    required this.phoneNumber,
    required this.email,
    required this.icNumber,
    required this.photoUrl,
    required this.description,
    required this.rating,
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
  };

  static Tourist fromJson(Map<String, dynamic>json) => Tourist(
    uid: json['uid'],
    username: json['username'],
    fullname: json['fullname'],
    phoneNumber: json['phoneNumber'],
    email: json['email'],
    icNumber: json['icNumber'],
    photoUrl: json['photoUrl'],
    description: json['description'],
    rating: json['rating'],
  );
}
