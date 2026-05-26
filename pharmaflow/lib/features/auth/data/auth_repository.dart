import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  String generateLoginEmail(String name, String role) {
    final sanitizedName = name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    return '$sanitizedName@$role.pharmaflow.ci';
  }

  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      String loginEmail = email.trim();

      if (!loginEmail.contains('@')) {
        // Recherche de l'utilisateur par nom pour obtenir son email de connexion
        final querySnapshot = await _firestore
            .collection('users')
            .where('name', isEqualTo: loginEmail)
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          loginEmail = querySnapshot.docs.first.data()['email'] ?? loginEmail;
        } else {
          final sanitized = loginEmail.toLowerCase().replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp(r'[^a-z0-9]'), '');
          loginEmail = '$sanitized@patient.pharmaflow.ci';
        }
      } else if (!loginEmail.endsWith('.pharmaflow.ci')) {
        // Recherche par email de récupération
        final querySnapshot = await _firestore
            .collection('users')
            .where('recoveryEmail', isEqualTo: loginEmail)
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          loginEmail = querySnapshot.docs.first.data()['email'] ?? loginEmail;
        }
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: loginEmail,
        password: password,
      );

      final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (!doc.exists) {
        throw Exception('Donnees utilisateur introuvables.');
      }
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final loginEmail = generateLoginEmail(name, role);
      final credential = await _auth.createUserWithEmailAndPassword(
        email: loginEmail,
        password: password,
      );

      final userModel = UserModel(
        id: credential.user!.uid,
        name: name,
        email: loginEmail,
        recoveryEmail: email.trim(),
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(userModel.id).set(userModel.toMap());

      return userModel;
    } catch (e) {
      throw Exception("Erreur d'inscription: $e");
    }
  }

  Future<void> resetPassword(String email) async {
    var loginEmail = email.trim();
    if (!loginEmail.contains('@')) {
      throw Exception('Veuillez saisir votre email de récupération.');
    }
    if (!loginEmail.endsWith('.pharmaflow.ci')) {
      final querySnapshot = await _firestore
          .collection('users')
          .where('recoveryEmail', isEqualTo: loginEmail)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        throw Exception('Aucun compte associé à cet email.');
      }
      loginEmail = querySnapshot.docs.first.data()['email'] as String;
    }
    await _auth.sendPasswordResetEmail(email: loginEmail);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateProfilePhoto(String uid, String photoUrl) async {
    await _firestore.collection('users').doc(uid).update({
      'photoUrl': photoUrl,
    });
  }
}

// Provider simple sans annotation @riverpod
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
});
