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

  // Collection publique minimale pour retrouver l'email de connexion AVANT login,
  // sans rendre la collection `users` lisible publiquement.
  // Doc IDs : `name_<nom normalisé>` et `recovery_<email de récupération>`.
  // Contenu : { uid, loginEmail } uniquement. Lecture par ID seulement (pas de listing).
  static const String _lookupCollection = 'login_lookup';

  String _sanitizeName(String name) => name
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'[^a-z0-9]'), '');

  String _nameKey(String name) => 'name_${_sanitizeName(name)}';
  String _recoveryKey(String email) => 'recovery_${email.trim().toLowerCase()}';

  Future<String?> _lookupLoginEmail(String key) async {
    try {
      final doc = await _firestore.collection(_lookupCollection).doc(key).get();
      return doc.data()?['loginEmail'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Crée/actualise les entrées de recherche de l'utilisateur connecté (best effort).
  Future<void> _upsertLoginLookup(UserModel user) async {
    final entries = <String>[
      if (_sanitizeName(user.name).isNotEmpty) _nameKey(user.name),
      if (user.recoveryEmail.trim().isNotEmpty) _recoveryKey(user.recoveryEmail),
    ];
    for (final key in entries) {
      try {
        await _firestore.collection(_lookupCollection).doc(key).set({
          'uid': user.id,
          'loginEmail': user.email,
        });
      } catch (_) {
        // Clé déjà prise par un autre compte (homonyme) : on ignore.
      }
    }
  }

  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final input = email.trim();
      final candidates = <String>[];

      if (!input.contains('@')) {
        // Connexion par nom : email de connexion via login_lookup, sinon domaines générés
        final found = await _lookupLoginEmail(_nameKey(input));
        if (found != null) candidates.add(found);
        final sanitized = _sanitizeName(input);
        for (final role in ['patient', 'pharmacist']) {
          final generated = '$sanitized@$role.pharmaflow.ci';
          if (!candidates.contains(generated)) candidates.add(generated);
        }
      } else if (!input.endsWith('.pharmaflow.ci')) {
        // Connexion par email de récupération
        final found = await _lookupLoginEmail(_recoveryKey(input));
        candidates.add(found ?? input);
      } else {
        candidates.add(input);
      }

      UserCredential? credential;
      FirebaseAuthException? lastError;
      for (final candidate in candidates) {
        try {
          credential = await _auth.signInWithEmailAndPassword(
            email: candidate,
            password: password,
          );
          break;
        } on FirebaseAuthException catch (e) {
          lastError = e;
        }
      }
      if (credential == null) {
        throw lastError ?? Exception('Identifiants invalides.');
      }

      final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (!doc.exists) {
        throw Exception('Donnees utilisateur introuvables.');
      }
      final user = UserModel.fromMap(doc.data()!, doc.id);
      // Migration douce des comptes existants vers login_lookup
      await _upsertLoginLookup(user);
      return user;
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
        // Un pharmacien inscrit démarre « en attente » : il doit être validé
        // par un pharmacien validé ou un admin (règles Firestore).
        status: role == 'pharmacist' ? PharmacistStatus.pending : null,
      );

      // toMap() écrit status 'pending' pour un pharmacien, rien pour un
      // patient, et jamais validatedBy / validatedAt (refusés par les règles).
      await _firestore.collection('users').doc(userModel.id).set(userModel.toMap());
      await _upsertLoginLookup(userModel);

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
      final found = await _lookupLoginEmail(_recoveryKey(loginEmail));
      if (found == null) {
        throw Exception('Aucun compte associé à cet email.');
      }
      loginEmail = found;
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
