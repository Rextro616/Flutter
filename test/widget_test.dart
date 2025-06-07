import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_list_app/services/auth_service.dart';
import 'package:product_list_app/cart/cart.dart';
import 'package:product_list_app/models/product.dart';
import 'package:product_list_app/models/cart_item.dart';
import 'package:product_list_app/models/rating.dart';

void main() {
  group('DinoStore Core Tests', () {
    late Product testProduct1;
    late Product testProduct2;

    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() {
      Cart.clear();
      testProduct1 = Product(
        id: 1,
        title: 'Fossil de T-Rex',
        price: 999.99,
        description: 'Autentico fossil de Tyrannosaurus Rex',
        category: 'Fossils',
        image: 'https://example.com/trex.jpg',
        rating: Rating(rate: 4.8, count: 15),
      );
      testProduct2 = Product(
        id: 2,
        title: 'Hueso de Triceratops',
        price: 599.50,
        description: 'Fragmento de hueso de Triceratops',
        category: 'Fossils',
        image: 'https://example.com/triceratops.jpg',
        rating: Rating(rate: 4.5, count: 8),
      );
    });

    test('AuthUser creation with valid data', () {
      final authUser = AuthUser(
        email: 'test@dinostore.com',
        name: 'Test User',
        token: 'test_token',
        isFromGoogle: false,
      );

      expect(authUser.email, equals('test@dinostore.com'));
      expect(authUser.name, equals('Test User'));
      expect(authUser.token, equals('test_token'));
      expect(authUser.isFromGoogle, isFalse);
      expect(authUser.displayName, equals('Test User'));
      expect(authUser.uid, equals('test@dinostore.com'));
    });

    test('AuthUser creation for Google user', () {
      final authUser = AuthUser(
        email: 'google@dinostore.com',
        name: 'Google User',
        isFromGoogle: true,
      );

      expect(authUser.email, equals('google@dinostore.com'));
      expect(authUser.name, equals('Google User'));
      expect(authUser.token, isNull);
      expect(authUser.isFromGoogle, isTrue);
    });

    test('Cart add single product', () {
      Cart.add(testProduct1);

      expect(Cart.items.length, equals(1));
      expect(Cart.items.first.productId, equals(1));
      expect(Cart.items.first.quantity, equals(1));
      expect(Cart.items.first.price, equals(999.99));
    });

    test('Cart add same product increments quantity', () {
      Cart.add(testProduct1);
      Cart.add(testProduct1);

      expect(Cart.items.length, equals(1));
      expect(Cart.items.first.quantity, equals(2));
      expect(Cart.items.first.productId, equals(1));
    });

    test('Cart add multiple different products', () {
      Cart.add(testProduct1);
      Cart.add(testProduct2);

      expect(Cart.items.length, equals(2));
      expect(Cart.items.any((item) => item.productId == 1), isTrue);
      expect(Cart.items.any((item) => item.productId == 2), isTrue);
    });

    test('Cart total calculation', () {
      Cart.add(testProduct1);
      Cart.add(testProduct1);
      Cart.add(testProduct2);

      final expectedTotal = (999.99 * 2) + 599.50;
      expect(Cart.total, equals(expectedTotal));
    });

    test('Cart remove product', () {
      Cart.add(testProduct1);
      Cart.add(testProduct2);
      Cart.remove(1);

      expect(Cart.items.length, equals(1));
      expect(Cart.items.any((item) => item.productId == 1), isFalse);
      expect(Cart.items.any((item) => item.productId == 2), isTrue);
    });

    test('Cart clear removes all items', () {
      Cart.add(testProduct1);
      Cart.add(testProduct2);
      Cart.clear();

      expect(Cart.items.length, equals(0));
      expect(Cart.total, equals(0.0));
    });

    test('Product name getter returns title', () {
      expect(testProduct1.name, equals('Fossil de T-Rex'));
      expect(testProduct1.title, equals('Fossil de T-Rex'));
      expect(testProduct1.name, equals(testProduct1.title));
    });

    test('CartItem JSON serialization', () {
      final cartItem = CartItem(
        productId: 1,
        quantity: 2,
        price: 999.99,
      );

      final json = cartItem.toJson();

      expect(json['productId'], equals(1));
      expect(json['quantity'], equals(2));
      expect(json.containsKey('price'), isFalse);
    });
  });
}