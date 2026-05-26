import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepository(this._firestore);

  // Stream de toutes les commandes (pour le pharmacien)
  Stream<List<OrderModel>> watchAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  // Stream commandes en attente uniquement
  Stream<List<OrderModel>> watchPendingOrders() {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  // Mettre à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.name,
      'updatedAt': Timestamp.now(),
    });
  }

  // Stream commandes d'un patient
  Stream<List<OrderModel>> watchPatientOrders(String patientId) {
    return _firestore
        .collection('orders')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  // Créer une nouvelle commande (depuis le patient)
  Future<void> createOrder(Map<String, dynamic> data) async {
    await _firestore.collection('orders').add(data);
  }

  // Stats en temps réel pour le pharmacien
  Stream<Map<String, int>> watchStats() {
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snap) {
      final all = snap.docs;
      return {
        'total': all.length,
        'pending': all.where((d) => d.data()['status'] == 'pending').length,
        'validated': all.where((d) => d.data()['status'] == 'validated').length,
        'delivering': all.where((d) => d.data()['status'] == 'delivering').length,
        'delivered': all.where((d) => d.data()['status'] == 'delivered').length,
        'rejected': all.where((d) => d.data()['status'] == 'rejected').length,
      };
    });
  }
}

// Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(FirebaseFirestore.instance);
});

final allOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(orderRepositoryProvider).watchAllOrders();
});

final pendingOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  return ref.watch(orderRepositoryProvider).watchPendingOrders();
});

final orderStatsProvider = StreamProvider<Map<String, int>>((ref) {
  return ref.watch(orderRepositoryProvider).watchStats();
});

final patientOrdersProvider = StreamProvider.family<List<OrderModel>, String>((ref, patientId) {
  return ref.watch(orderRepositoryProvider).watchPatientOrders(patientId);
});
