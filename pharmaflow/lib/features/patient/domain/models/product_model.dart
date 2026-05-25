class ProductModel {
  final String id;
  final String name;
  final String form;
  final double price;
  final bool requiresPrescription;
  final String imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.form,
    required this.price,
    required this.requiresPrescription,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'form': form,
      'price': price,
      'requiresPrescription': requiresPrescription,
      'imageUrl': imageUrl,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      name: map['name'] ?? '',
      form: map['form'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      requiresPrescription: map['requiresPrescription'] ?? false,
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
