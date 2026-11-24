import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/models/user_model.dart';

/// Validation des comptes pharmaciens en attente (pharmacien validé ou admin).
class PharmacistValidationRepository {
  PharmacistValidationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Requête autorisée par les règles (list réservé au personnel habilité).
  /// Pas d'orderBy : le tri se fait côté client.
  Query<Map<String, dynamic>> pendingQuery() => _firestore
      .collection('users')
      .where('role', isEqualTo: 'pharmacist')
      .where('status', isEqualTo: PharmacistStatus.pending);

  /// Pharmaciens en attente, du plus ancien au plus récent.
  Stream<List<UserModel>> watchPending() => pendingQuery().snapshots().map((s) {
        final list = s.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return list;
      });

  /// Exactement les 3 champs attendus par la règle de validation.
  static Map<String, dynamic> approvalPayload(String validatorUid) => {
        'status': PharmacistStatus.approved,
        'validatedBy': validatorUid,
        'validatedAt': FieldValue.serverTimestamp(),
      };

  Future<void> approve({required String pharmacistUid, required String validatorUid}) async {
    if (pharmacistUid == validatorUid) {
      throw StateError('Vous ne pouvez pas valider votre propre compte.');
    }
    await _firestore.collection('users').doc(pharmacistUid).update(approvalPayload(validatorUid));
  }
}

final pharmacistValidationRepositoryProvider = Provider<PharmacistValidationRepository>((ref) {
  return PharmacistValidationRepository(FirebaseFirestore.instance);
});

/// À n'écouter que pour un pharmacien validé ou un admin.
final pendingPharmacistsProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(pharmacistValidationRepositoryProvider).watchPending();
});
