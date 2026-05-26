import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, validated, rejected, delivering, delivered }

class OrderItem {
  final String name;
  final String form;
  final int quantity;
  final int priceValue;
  final bool requiresPrescription;

  const OrderItem({
    required this.name,
    required this.form,
    required this.quantity,
    required this.priceValue,
    required this.requiresPrescription,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] ?? '',
      form: map['form'] ?? '',
      quantity: map['quantity'] ?? 1,
      priceValue: map['priceValue'] ?? 0,
      requiresPrescription: map['requiresPrescription'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'form': form,
    'quantity': quantity,
    'priceValue': priceValue,
    'requiresPrescription': requiresPrescription,
  };
}

class OrderModel {
  final String id;
  final String patientId;
  final String patientName;
  final List<OrderItem> items;
  final int totalValue;
  final int deliveryFee;
  final String paymentMethod;
  final OrderStatus status;
  final String? ordonnanceUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.items,
    required this.totalValue,
    required this.deliveryFee,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.ordonnanceUrl,
    this.updatedAt,
  });

  int get grandTotal => totalValue + deliveryFee;

  bool get hasPrescriptionItems => items.any((i) => i.requiresPrescription);

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending: return 'En attente';
      case OrderStatus.validated: return 'Validée';
      case OrderStatus.rejected: return 'Rejetée';
      case OrderStatus.delivering: return 'En livraison';
      case OrderStatus.delivered: return 'Livrée';
    }
  }

  static OrderStatus _parseStatus(String? s) {
    switch (s) {
      case 'validated': return OrderStatus.validated;
      case 'rejected': return OrderStatus.rejected;
      case 'delivering': return OrderStatus.delivering;
      case 'delivered': return OrderStatus.delivered;
      default: return OrderStatus.pending;
    }
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawItems = data['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? 'Patient',
      items: rawItems.map((e) => OrderItem.fromMap(e as Map<String, dynamic>)).toList(),
      totalValue: data['totalValue'] ?? 0,
      deliveryFee: data['deliveryFee'] ?? 1000,
      paymentMethod: data['paymentMethod'] ?? 'Wave',
      status: _parseStatus(data['status']),
      ordonnanceUrl: data['ordonnanceUrl'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'patientId': patientId,
    'patientName': patientName,
    'items': items.map((i) => i.toMap()).toList(),
    'totalValue': totalValue,
    'deliveryFee': deliveryFee,
    'paymentMethod': paymentMethod,
    'status': status.name,
    'ordonnanceUrl': ordonnanceUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
  };

  String formatPrice(int value) {
    final str = value.toString();
    if (str.length <= 3) return '$str FCFA';
    final groups = <String>[];
    var remaining = str;
    while (remaining.length > 3) {
      groups.insert(0, remaining.substring(remaining.length - 3));
      remaining = remaining.substring(0, remaining.length - 3);
    }
    groups.insert(0, remaining);
    return '${groups.join(' ')} FCFA';
  }
}
