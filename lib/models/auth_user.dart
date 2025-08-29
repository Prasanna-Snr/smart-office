class AuthUser {
  final String uid;
  final String email;
  final String? displayName;
  final bool isEmailVerified;
  final DateTime? createdAt;

  AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    required this.isEmailVerified,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }
}