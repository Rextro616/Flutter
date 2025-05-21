import 'package:product_list_app/models/cart_item.dart';

class CartModel {
  final int id;
  final int userId;
  final String date;
  final List<CartItem> products;

  CartModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.products,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    List<CartItem> cartItems = (json['products'] as List)
        .map((item) => CartItem.fromJson(item))
        .toList();

    return CartModel(
      id: json['id'],
      userId: json['userId'],
      date: json['date'],
      products: cartItems,
    );
  }

  double get total {
    return products.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}

