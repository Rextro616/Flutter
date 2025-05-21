import 'package:product_list_app/models/cart.dart';
import 'package:product_list_app/models/cart_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class Cart {
  static final List<CartItem> _items = [];
  static int _nextCartId = 1;
  
  // Agregar un producto al carrito local
  static void add(Product product) {
    // Buscar si el producto ya está en el carrito
    int existingIndex = _items.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex >= 0) {
      // Incrementar la cantidad si ya existe
      final existingItem = _items[existingIndex];
      _items[existingIndex] = CartItem(
        productId: existingItem.productId,
        quantity: existingItem.quantity + 1,
        price: product.price,
      );
    } else {
      // Agregar nuevo item si no existe
      _items.add(CartItem(
        productId: product.id,
        quantity: 1,
        price: product.price,
      ));
    }
  }
  
  // Eliminar un producto del carrito
  static void remove(int productId) {
    _items.removeWhere((item) => item.productId == productId);
  }
  
  // Guardar el carrito en la API
  static Future<int> saveCart() async {
    if (_items.isEmpty) return 0;
    
    final result = await ApiService.createCart(_items);
    _nextCartId = result['id'] ?? _nextCartId + 1;
    return _nextCartId;
  }
  
  // Cargar un carrito desde la API
  static Future<CartModel> loadCart(int cartId) async {
    return await ApiService.getCartById(cartId);
  }
  
  // Obtener los items actuales
  static List<CartItem> get items => _items;
  
  // Calcular el total del carrito
  static double get total => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  
  // Limpiar el carrito
  static void clear() {
    _items.clear();
  }
}