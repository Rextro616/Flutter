class CartItem {
  final int productId;
  final int quantity;
  final double price;

  CartItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      quantity: json['quantity'],
      price: json.containsKey('price') ? double.parse(json['price'].toString()) : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}