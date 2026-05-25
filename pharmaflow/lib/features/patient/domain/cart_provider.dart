import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final String name;
  final String form;
  final String price;
  final int priceValue;
  final bool requiresPrescription;
  int quantity;

  CartItem({
    required this.name,
    required this.form,
    required this.price,
    required this.priceValue,
    required this.requiresPrescription,
    this.quantity = 1,
  });

  int get totalValue => priceValue * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      name: name,
      form: form,
      price: price,
      priceValue: priceValue,
      requiresPrescription: requiresPrescription,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem({
    required String name,
    required String form,
    required String price,
    required bool requiresPrescription,
  }) {
    // Parse the price from "1 500 FCFA" → 1500
    final priceValue = int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    
    final existing = state.indexWhere((item) => item.name == name);
    if (existing >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existing) state[i].copyWith(quantity: state[i].quantity + 1)
          else state[i],
      ];
    } else {
      state = [...state, CartItem(
        name: name,
        form: form,
        price: price,
        priceValue: priceValue,
        requiresPrescription: requiresPrescription,
      )];
    }
  }

  void removeItem(String name) {
    final existing = state.indexWhere((item) => item.name == name);
    if (existing >= 0) {
      if (state[existing].quantity > 1) {
        state = [
          for (int i = 0; i < state.length; i++)
            if (i == existing) state[i].copyWith(quantity: state[i].quantity - 1)
            else state[i],
        ];
      } else {
        state = state.where((item) => item.name != name).toList();
      }
    }
  }

  void deleteItem(String name) {
    state = state.where((item) => item.name != name).toList();
  }

  void clear() {
    state = [];
  }

  int get totalValue =>
      state.fold(0, (sum, item) => sum + item.totalValue);

  int get deliveryFee => state.isEmpty ? 0 : 1000;

  int get grandTotal => totalValue + deliveryFee;

  bool get hasItemsRequiringPrescription =>
      state.any((item) => item.requiresPrescription);

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

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
