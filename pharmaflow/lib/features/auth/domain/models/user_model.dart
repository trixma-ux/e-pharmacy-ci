class UserModel {
  final String id;
  final String name;
  final String email;
  final String recoveryEmail;
  final String role; // 'patient' ou 'pharmacist'
  final DateTime createdAt;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.recoveryEmail,
    required this.role,
    required this.createdAt,
    this.photoUrl,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? recoveryEmail,
    String? role,
    DateTime? createdAt,
    String? photoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      recoveryEmail: recoveryEmail ?? this.recoveryEmail,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'recoveryEmail': recoveryEmail,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      recoveryEmail: map['recoveryEmail'] ?? '',
      role: map['role'] ?? 'patient',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      photoUrl: map['photoUrl'],
    );
  }
}
