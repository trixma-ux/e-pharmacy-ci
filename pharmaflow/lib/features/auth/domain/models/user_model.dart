import 'package:cloud_firestore/cloud_firestore.dart';

/// Statuts d'un compte pharmacien (règles Firestore bdfb70e).
class PharmacistStatus {
  static const String pending = 'pending';
  static const String approved = 'approved';
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String recoveryEmail;
  final String role; // 'patient', 'pharmacist' ou 'admin' (attribué à la main)
  final DateTime createdAt;
  final String? photoUrl;

  /// 'pending' | 'approved' — pharmaciens uniquement (null pour un patient).
  final String? status;

  /// uid du pharmacien validé / admin qui a validé ce compte.
  final String? validatedBy;

  /// Horodatage serveur de la validation.
  final DateTime? validatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.recoveryEmail,
    required this.role,
    required this.createdAt,
    this.photoUrl,
    this.status,
    this.validatedBy,
    this.validatedAt,
  });

  bool get isPharmacist => role == 'pharmacist';
  bool get isAdmin => role == 'admin';

  /// Pharmacien validé par un pharmacien validé ou un admin.
  bool get isApprovedPharmacist => isPharmacist && status == PharmacistStatus.approved;

  /// Pharmacien pas encore validé (status absent = 'pending').
  bool get isPendingPharmacist => isPharmacist && status != PharmacistStatus.approved;

  /// Personnel habilité (isStaff() dans les règles).
  bool get isStaff => isApprovedPharmacist || isAdmin;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? recoveryEmail,
    String? role,
    DateTime? createdAt,
    String? photoUrl,
    String? status,
    String? validatedBy,
    DateTime? validatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      recoveryEmail: recoveryEmail ?? this.recoveryEmail,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      validatedBy: validatedBy ?? this.validatedBy,
      validatedAt: validatedAt ?? this.validatedAt,
    );
  }

  /// Document écrit à l'INSCRIPTION (`users/{uid}` create).
  ///
  /// Les règles exigent : pharmacien => status 'pending' ; patient => pas de
  /// status ; et JAMAIS les clés validatedBy / validatedAt (même à null).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'recoveryEmail': recoveryEmail,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'photoUrl': photoUrl,
      if (isPharmacist) 'status': PharmacistStatus.pending,
    };
  }

  static DateTime? _toDate(Object? v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    final role = (map['role'] as String?) ?? 'patient';
    final rawStatus = map['status'] as String?;
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      recoveryEmail: map['recoveryEmail'] ?? '',
      role: role,
      createdAt: _toDate(map['createdAt']) ?? DateTime.now(),
      photoUrl: map['photoUrl'],
      // Pharmacien sans status (comptes historiques) => en attente.
      status: rawStatus ?? (role == 'pharmacist' ? PharmacistStatus.pending : null),
      validatedBy: map['validatedBy'] as String?,
      validatedAt: _toDate(map['validatedAt']),
    );
  }
}
