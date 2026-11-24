import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaflow/core/routing/role_redirect.dart';
import 'package:pharmaflow/features/auth/domain/models/user_model.dart';
import 'package:pharmaflow/features/pharmacist/data/pharmacist_validation_repository.dart';

UserModel _u(String role, {String? status, String id = 'u1'}) => UserModel(
      id: id,
      name: 'Awa',
      email: 'awa@$role.pharmaflow.ci',
      recoveryEmail: 'awa@example.com',
      role: role,
      createdAt: DateTime(2026, 11, 23, 20),
      status: status,
    );

void main() {
  group('UserModel', () {
    test('inscription pharmacien : status pending, aucune clé validated*', () {
      final map = _u('pharmacist').toMap();
      expect(map['status'], 'pending');
      expect(map.containsKey('validatedBy'), isFalse);
      expect(map.containsKey('validatedAt'), isFalse);
    });

    test('inscription pharmacien : pending même si le modèle dit approved', () {
      expect(_u('pharmacist', status: 'approved').toMap()['status'], 'pending');
    });

    test('inscription patient : pas de status ni de clé validated*', () {
      final map = _u('patient').toMap();
      expect(map.containsKey('status'), isFalse);
      expect(map.containsKey('validatedBy'), isFalse);
      expect(map.containsKey('validatedAt'), isFalse);
    });

    test('aller-retour toMap/fromMap', () {
      final back = UserModel.fromMap(_u('pharmacist').toMap(), 'u1');
      expect(back.role, 'pharmacist');
      expect(back.status, 'pending');
      expect(back.isPendingPharmacist, isTrue);
      expect(back.validatedBy, isNull);
      expect(back.validatedAt, isNull);
      expect(back.createdAt, DateTime(2026, 11, 23, 20));
      final patient = UserModel.fromMap(_u('patient').toMap(), 'u2');
      expect(patient.status, isNull);
      expect(patient.isStaff, isFalse);
    });

    test('pharmacien sans status (historique) => pending', () {
      final u = UserModel.fromMap({'name': 'Old', 'role': 'pharmacist'}, 'old');
      expect(u.status, 'pending');
      expect(u.isApprovedPharmacist, isFalse);
    });

    test('validatedAt lu depuis un Timestamp', () {
      final at = DateTime.utc(2026, 11, 23, 20, 30);
      final u = UserModel.fromMap({
        'role': 'pharmacist',
        'status': 'approved',
        'validatedBy': 'admin1',
        'validatedAt': Timestamp.fromDate(at),
      }, 'p');
      expect(u.isApprovedPharmacist, isTrue);
      expect(u.isStaff, isTrue);
      expect(u.validatedBy, 'admin1');
      expect(u.validatedAt!.toUtc(), at);
    });
  });

  group('redirection', () {
    final pending = _u('pharmacist', status: 'pending');
    final approved = _u('pharmacist', status: 'approved');
    final admin = _u('admin');
    final patient = _u('patient');

    test('écran d\'accueil selon rôle et statut', () {
      expect(homePathFor(pending), AppPaths.pendingValidation);
      expect(homePathFor(_u('pharmacist')), AppPaths.pendingValidation);
      expect(homePathFor(approved), AppPaths.pharmacistDashboard);
      expect(homePathFor(admin), AppPaths.pharmacistDashboard);
      expect(homePathFor(patient), AppPaths.main);
    });

    test('déconnecté', () {
      expect(redirectFor(null, '/splash'), isNull);
      expect(redirectFor(null, '/auth'), isNull);
      expect(redirectFor(null, '/main'), AppPaths.auth);
      expect(redirectFor(null, AppPaths.pendingValidation), AppPaths.auth);
      expect(redirectFor(null, AppPaths.pharmacistDashboard), AppPaths.auth);
    });

    test('pharmacien en attente bloqué sur l\'écran d\'attente', () {
      expect(redirectFor(pending, AppPaths.pharmacistDashboard), AppPaths.pendingValidation);
      expect(redirectFor(pending, '/main'), AppPaths.pendingValidation);
      expect(redirectFor(pending, '/my_orders'), AppPaths.pendingValidation);
      expect(redirectFor(pending, AppPaths.pendingValidation), isNull);
      expect(redirectFor(pending, '/auth'), isNull);
    });

    test('pharmacien validé et admin vers le tableau de bord', () {
      expect(redirectFor(approved, AppPaths.pendingValidation), AppPaths.pharmacistDashboard);
      expect(redirectFor(approved, '/main'), AppPaths.pharmacistDashboard);
      expect(redirectFor(approved, AppPaths.pharmacistDashboard), isNull);
      expect(redirectFor(admin, '/main'), AppPaths.pharmacistDashboard);
      expect(redirectFor(admin, AppPaths.pharmacistDashboard), isNull);
    });

    test('patient : ni tableau de bord ni écran d\'attente', () {
      expect(redirectFor(patient, AppPaths.pharmacistDashboard), AppPaths.main);
      expect(redirectFor(patient, AppPaths.pendingValidation), AppPaths.main);
      expect(redirectFor(patient, '/cart'), isNull);
    });
  });

  group('validation', () {
    test('payload : exactement status, validatedBy, validatedAt (serverTimestamp)', () {
      final p = PharmacistValidationRepository.approvalPayload('admin1');
      expect(p.keys.toSet(), {'status', 'validatedBy', 'validatedAt'});
      expect(p['status'], 'approved');
      expect(p['validatedBy'], 'admin1');
      expect(p['validatedAt'], isA<FieldValue>());
      expect(p['validatedAt'], FieldValue.serverTimestamp());
    });
  });
}
