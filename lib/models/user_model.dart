class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;
  final bool isActive;
  final String? imageBase64; // Base64 encoded image

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.isActive = true,
    this.imageBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'imageBase64': imageBase64,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      imageBase64: json['imageBase64'],
    );
  }
}