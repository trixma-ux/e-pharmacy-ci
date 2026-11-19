import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaflow/features/patient/domain/cart_provider.dart';

void main() {
  group('CartNotifier', () {
    test('adds items, parses FCFA prices and merges duplicates', () {
      final cart = CartNotifier();
      cart.addItem(name: 'Doliprane', form: 'Comprimé', price: '1 500 FCFA', requiresPrescription: false);
      cart.addItem(name: 'Doliprane', form: 'Comprimé', price: '1 500 FCFA', requiresPrescription: false);
      cart.addItem(name: 'Amoxicilline', form: 'Gélule', price: '2 000 FCFA', requiresPrescription: true);

      expect(cart.state.length, 2);
      expect(cart.state.first.quantity, 2);
      expect(cart.totalValue, 5000);
      expect(cart.deliveryFee, 1000);
      expect(cart.grandTotal, 6000);
      expect(cart.hasItemsRequiringPrescription, isTrue);
    });

    test('removeItem decrements then deletes; empty cart has no delivery fee', () {
      final cart = CartNotifier();
      cart.addItem(name: 'Vitamine C', form: 'Sachet', price: '800 FCFA', requiresPrescription: false);
      cart.addItem(name: 'Vitamine C', form: 'Sachet', price: '800 FCFA', requiresPrescription: false);
      cart.removeItem('Vitamine C');
      expect(cart.state.single.quantity, 1);
      cart.removeItem('Vitamine C');
      expect(cart.state, isEmpty);
      expect(cart.deliveryFee, 0);
      expect(cart.grandTotal, 0);
    });

    test('formatPrice groups thousands', () {
      final cart = CartNotifier();
      expect(cart.formatPrice(500), '500 FCFA');
      expect(cart.formatPrice(1500), '1 500 FCFA');
      expect(cart.formatPrice(1250000), '1 250 000 FCFA');
    });
  });
}
