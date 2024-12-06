import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String token;
  final String address;
  String prediction;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.token,
    required this.address,
    this.prediction = "Unknown", // Default value
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'token': token,
      'address': address,
      'prediction': prediction, // Include prediction in map
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      token: map['token'] ?? '',
      address: map['address'] ?? '',
      prediction: map['prediction'] ?? "Unknown", // Initialize prediction
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? token,
    String? address,
    String? prediction, // Add prediction to copyWith
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      token: token ?? this.token,
      address: address ?? this.address,
      prediction: prediction ?? this.prediction, // Update prediction
    );
  }
}
