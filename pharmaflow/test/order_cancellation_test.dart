import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pharmaflow/features/auth/domain/models/user_model.dart';
import 'package:pharmaflow/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pharmaflow/features/patient/presentation/screens/my_orders_screen.dart';
import 'package:pharmaflow/features/pharmacist/data/order_repository.dart';
import 'package:pharmaflow/features/pharmacist/domain/order_model.dart';

OrderModel _order({
  String id = 'o1',
  String patientId = 'cust',
  OrderStatus status = OrderStatus.pending,
  int totalValue = 3000,
  int deliveryFee = 1000,
  DateTime? cancelledAt,
}) {
  return OrderModel(
    id: id,
    patientId: patientId,
    patientName: 'Awa',
    items: const [
      OrderItem(
        name: 'Doliprane',
        form: 'Comprimé',
        quantity: 2,
        priceValue: 1500,
        requiresPrescription: false,
      ),
    ],
    totalValue: totalValue,
    deliveryFee: deliveryFee,
    paymentMethod: 'Wave',
    status: status,
    createdAt: DateTime(2026, 11, 23, 10, 30),
    cancelledAt: cancelledAt,
  );
}

class _FakeAuth extends AuthController {
  _FakeAuth(this.user);
  final UserModel user;

  @override
  Future<UserModel?> build() async => user;
}

final _patient = UserModel(
  id: 'cust',
  name: 'Awa',
  email: 'awa@patient.pharmaflow.ci',
  recoveryEmail: 'awa@example.com',
  role: 'patient',
  createdAt: DateTime(2026, 11, 23),
);

void main() {
  group('OrderStatus.cancelled', () {
    test('parseStatus et libellé français Annulée', () {
      expect(OrderModel.parseStatus('cancelled'), OrderStatus.cancelled);
      expect(OrderStatus.cancelled.label, 'Annulée');
      expect(_order(status: OrderStatus.cancelled).statusLabel, 'Annulée');
      expect(_order(status: OrderStatus.pending).statusLabel, 'En attente');
      expect(OrderModel.parseStatus('pending'), OrderStatus.pending);
      expect(OrderModel.parseStatus(null), OrderStatus.pending);
      expect(OrderModel.parseStatus('inconnu'), OrderStatus.pending);
    });

    test('toMap conserve le statut cancelled et cancelledAt', () {
      final at = DateTime.utc(2026, 11, 24, 8, 15);
      final map = _order(status: OrderStatus.cancelled, cancelledAt: at).toMap();
      expect(map['status'], 'cancelled');
      expect(map['cancelledAt'], isA<Timestamp>());
      expect((map['cancelledAt'] as Timestamp).toDate().toUtc(), at);
    });

    test('canBeCancelled seulement pour une commande en attente', () {
      expect(_order(status: OrderStatus.pending).canBeCancelled, isTrue);
      for (final s in OrderStatus.values.where((s) => s != OrderStatus.pending)) {
        expect(_order(status: s).canBeCancelled, isFalse, reason: s.name);
      }
    });
  });

  group('computeOrderStats', () {
    test('les commandes annulées sont comptées à part et exclues du CA', () {
      final stats = computeOrderStats([
        _order(id: 'p', status: OrderStatus.pending, totalValue: 2000, deliveryFee: 1000),
        _order(id: 'v', status: OrderStatus.validated, totalValue: 4000, deliveryFee: 1000),
        _order(id: 'g', status: OrderStatus.delivering, totalValue: 5000, deliveryFee: 1000),
        _order(id: 'd1', status: OrderStatus.delivered, totalValue: 3000, deliveryFee: 1000),
        _order(id: 'd2', status: OrderStatus.delivered, totalValue: 7000, deliveryFee: 1000),
        _order(id: 'r', status: OrderStatus.rejected, totalValue: 9000, deliveryFee: 1000),
        _order(id: 'c1', status: OrderStatus.cancelled, totalValue: 8000, deliveryFee: 1000),
        _order(id: 'c2', status: OrderStatus.cancelled, totalValue: 1500, deliveryFee: 1000),
      ]);
      expect(stats['total'], 8);
      expect(stats['pending'], 1);
      expect(stats['validated'], 1);
      expect(stats['delivering'], 1);
      expect(stats['delivered'], 2);
      expect(stats['rejected'], 1);
      expect(stats['cancelled'], 2);
      // 3000+1000 + 7000+1000 = 12000 ; annulées (9000) et rejetées (10000) exclues
      expect(stats['revenue'], 12000);
    });

    test('liste vide : tout à zéro', () {
      final stats = computeOrderStats(const []);
      expect(stats, {
        'total': 0,
        'pending': 0,
        'validated': 0,
        'delivering': 0,
        'delivered': 0,
        'rejected': 0,
        'cancelled': 0,
        'revenue': 0,
      });
    });
  });

  group('patientCancelUpdate', () {
    test('clés et valeurs exactes attendues par les règles Firestore', () {
      final map = patientCancelUpdate();
      expect(map.keys.toSet(), {'status', 'updatedAt', 'cancelledAt'});
      expect(map.length, 3);
      expect(map['status'], 'cancelled');
      expect(map['updatedAt'], isA<FieldValue>());
      expect(map['cancelledAt'], isA<FieldValue>());
    });
  });

  group('MyOrdersScreen bouton Annuler', () {
    setUpAll(() async {
      await initializeDateFormatting('fr_FR');
    });

    Future<void> pumpOrders(WidgetTester tester, List<OrderModel> orders) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(() => _FakeAuth(_patient)),
          patientOrdersProvider('cust').overrideWith((ref) => Stream.value(orders)),
        ],
        child: const MaterialApp(
          locale: Locale('fr', 'FR'),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('fr', 'FR')],
          home: MyOrdersScreen(),
        ),
      ));
      await tester.pump();
      await tester.pumpAndSettle();
    }

    testWidgets('visible uniquement sur une commande en attente', (tester) async {
      await pumpOrders(tester, [
        _order(id: 'pending1', status: OrderStatus.pending),
        _order(id: 'validated1', status: OrderStatus.validated),
        _order(id: 'rejected1', status: OrderStatus.rejected),
        _order(id: 'delivering1', status: OrderStatus.delivering),
        _order(id: 'delivered1', status: OrderStatus.delivered),
        _order(id: 'cancelled1', status: OrderStatus.cancelled),
      ]);

      expect(find.text('En attente'), findsOneWidget);
      expect(find.text('Validée'), findsOneWidget);
      expect(find.text('Rejetée'), findsOneWidget);
      expect(find.text('En livraison'), findsOneWidget);
      expect(find.text('Livrée'), findsOneWidget);
      expect(find.text('Annulée'), findsOneWidget);
      expect(find.text('Annuler la commande'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('absent quand aucune commande n\'est en attente', (tester) async {
      await pumpOrders(tester, [
        _order(id: 'validated1', status: OrderStatus.validated),
        _order(id: 'cancelled1', status: OrderStatus.cancelled),
        _order(id: 'delivered1', status: OrderStatus.delivered),
      ]);
      expect(find.text('Annuler la commande'), findsNothing);
      expect(find.text('Annulée'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('le dialogue de confirmation s\'affiche en français', (tester) async {
      await pumpOrders(tester, [_order(id: 'pending1', status: OrderStatus.pending)]);
      await tester.tap(find.text('Annuler la commande'));
      await tester.pumpAndSettle();
      expect(find.text('Annuler la commande ?'), findsOneWidget);
      expect(find.textContaining('Cette action est définitive'), findsOneWidget);
      expect(find.text('Retour'), findsOneWidget);
      expect(find.text('Confirmer l\'annulation'), findsOneWidget);
      await tester.tap(find.text('Retour'));
      await tester.pumpAndSettle();
      expect(find.text('Annuler la commande ?'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
