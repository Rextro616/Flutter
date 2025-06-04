import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:product_list_app/models/cart.dart';
import 'package:product_list_app/models/cart_item.dart';
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  // Obtener todos los productos
  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    
    if (response.statusCode == 200) {
      List<dynamic> productsJson = jsonDecode(response.body);
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar productos: ${response.statusCode}');
    }
  }

  // Obtener un producto por su ID
  static Future<Product> getProductById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));
    
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar el producto: ${response.statusCode}');
    }
  }

  // Crear un carrito
  static Future<Map<String, dynamic>> createCart(List<CartItem> items) async {
    final Map<String, dynamic> cartData = {
      'userId': 1,
      'date': DateTime.now().toIso8601String(),
      'products': items.map((item) => item.toJson()).toList(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/carts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cartData),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear el carrito: ${response.statusCode}');
    }
  }

  // Obtener carrito por ID
  static Future<CartModel> getCartById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/carts/$id'));
    
    if (response.statusCode == 200) {
      Map<String, dynamic> cartJson = jsonDecode(response.body);
      
      // Para cada producto en el carrito obtenemos los detalles completos
      CartModel cart = CartModel.fromJson(cartJson);
      
      // la API no devuelve el precio del producto en el carrito, así que obtener los precios individuales
      for (var i = 0; i < cart.products.length; i++) {
        final product = await getProductById(cart.products[i].productId);
        cart.products[i] = CartItem(
          productId: cart.products[i].productId,
          quantity: cart.products[i].quantity,
          price: product.price,
        );
      }
      
      return cart;
    } else {
      throw Exception('Error al cargar el carrito: ${response.statusCode}');
    }
  }
}