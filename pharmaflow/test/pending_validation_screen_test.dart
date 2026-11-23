import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaflow/features/auth/domain/models/user_model.dart';
import 'package:pharmaflow/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pharmaflow/features/auth/presentation/screens/pending_validation_screen.dart';

class _FakeAuth extends AuthController {
  @override
  Future<UserModel?> build() async => UserModel(
        id: 'p1',
        name: 'Awa',
        email: 'awa@pharmacist.pharmaflow.ci',
        recoveryEmail: 'awa@example.com',
        role: 'pharmacist',
        createdAt: DateTime(2026, 11, 23),
        status: 'pending',
      );
}

void main() {
  for (final size in const [Size(390, 844), Size(1280, 800)]) {
    testWidgets('écran d\'attente en français (${size.width.toInt()} px)', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [authControllerProvider.overrideWith(_FakeAuth.new)],
        child: const MaterialApp(home: PendingValidationScreen()),
      ));
      await tester.pump();
      expect(find.text('Compte en attente de validation'), findsOneWidget);
      expect(find.textContaining('Bonjour Awa'), findsOneWidget);
      expect(find.text('Vérifier à nouveau'), findsOneWidget);
      expect(find.text('Se déconnecter'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
