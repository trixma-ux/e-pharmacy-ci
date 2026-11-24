import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, validated, rejected, delivering, delivered, cancelled }

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
  final DateTime? cancelledAt;

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
    this.cancelledAt,
  });

  int get grandTotal => totalValue + deliveryFee;

  bool get hasPrescriptionItems => items.any((i) => i.requiresPrescription);

  /// A patient may cancel only while the order is still pending.
  bool get canBeCancelled => status == OrderStatus.pending;

  String get statusLabel => status.label;

  static OrderStatus parseStatus(String? s) {
    switch (s) {
      case 'validated': return OrderStatus.validated;
      case 'rejected': return OrderStatus.rejected;
      case 'delivering': return OrderStatus.delivering;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
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
      status: parseStatus(data['status']),
      ordonnanceUrl: data['ordonnanceUrl'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      cancelledAt: data['cancelledAt'] != null
          ? (data['cancelledAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
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
    if (cancelledAt != null) {
      map['cancelledAt'] = Timestamp.fromDate(cancelledAt!);
    }
    return map;
  }

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

/// Exact Firestore update a patient must send to cancel a pending order.
/// Keys and values are constrained by firestore.rules (cbcc8d1):
/// pending -> cancelled, only status / updatedAt / cancelledAt, timestamps = request.time.
Map<String, dynamic> patientCancelUpdate() => {
  'status': 'cancelled',
  'updatedAt': FieldValue.serverTimestamp(),
  'cancelledAt': FieldValue.serverTimestamp(),
};

/// Dashboard counters. Revenue is the sum of [OrderModel.grandTotal] for
/// delivered orders only — cancelled, rejected and in-flight orders are excluded.
Map<String, int> computeOrderStats(Iterable<OrderModel> orders) {
  var pending = 0;
  var validated = 0;
  var delivering = 0;
  var delivered = 0;
  var rejected = 0;
  var cancelled = 0;
  var revenue = 0;
  var count = 0;
  for (final o in orders) {
    count++;
    switch (o.status) {
      case OrderStatus.pending:
        pending++;
        break;
      case OrderStatus.validated:
        validated++;
        break;
      case OrderStatus.delivering:
        delivering++;
        break;
      case OrderStatus.delivered:
        delivered++;
        revenue += o.grandTotal;
        break;
      case OrderStatus.rejected:
        rejected++;
        break;
      case OrderStatus.cancelled:
        cancelled++;
        break;
    }
  }
  return {
    'total': count,
    'pending': pending,
    'validated': validated,
    'delivering': delivering,
    'delivered': delivered,
    'rejected': rejected,
    'cancelled': cancelled,
    'revenue': revenue,
  };
}


extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending: return 'En attente';
      case OrderStatus.validated: return 'Validée';
      case OrderStatus.rejected: return 'Rejetée';
      case OrderStatus.delivering: return 'En livraison';
      case OrderStatus.delivered: return 'Livrée';
      case OrderStatus.cancelled: return 'Annulée';
    }
  }
}
