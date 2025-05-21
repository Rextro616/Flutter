import 'package:flutter/material.dart';
import '../cart/cart.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;
  late Future<List<Product>> _productsFuture;
  final Map<int, Product> _productsMap = {};

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProductsInfo();
  }

  //Obtiene la info de cada producto en el carrito
  Future<List<Product>> _loadProductsInfo() async {
    final productIds = Cart.items.map((item) => item.productId).toSet().toList();
    List<Product> products = [];
    
    for (var id in productIds) {
      try {
        final product = await ApiService.getProductById(id);
        products.add(product);
        _productsMap[id] = product;
      } catch (e) {
        print('Error al cargar el producto $id: $e');
      }
    }
    
    return products;
  }

  @override
  Widget build(BuildContext context) {
    final items = Cart.items;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito de Compras'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep),
              onPressed: () {
                setState(() {
                  Cart.clear();
                });
              },
              tooltip: 'Vaciar carrito',
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('El carrito está vacío', style: TextStyle(fontSize: 18)),
              ],
            ))
          : FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final product = _productsMap[item.productId];
                          
                          return Dismissible(
                            key: Key('cart_item_${item.productId}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              setState(() {
                                Cart.remove(item.productId);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Producto eliminado del carrito')),
                              );
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: ListTile(
                                leading: product != null 
                                  ? SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.network(
                                        product.image,
                                        fit: BoxFit.contain,
                                        errorBuilder: (ctx, error, _) => Icon(Icons.image_not_supported),
                                      ),
                                    )
                                  : Container(
                                      width: 40,
                                      height: 40,
                                      color: Colors.grey.shade200,
                                      child: Icon(Icons.image_not_supported),
                                    ),
                                title: Text(product?.title ?? 'Producto #${item.productId}'),
                                subtitle: Text('Cantidad: ${item.quantity}'),
                                trailing: Text(
                                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, -2),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${Cart.total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isLoading 
                              ? null 
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  
                                  try {
                                    final cartId = await Cart.saveCart();
                                    
                                    if (cartId > 0) {
                                      if (!mounted) return;
                                      
                                      setState(() {
                                        Cart.clear();
                                      });
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('¡Pedido realizado con éxito! ID: $cartId'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error al procesar el pedido: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: _isLoading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      'REALIZAR PEDIDO',
                                      style: TextStyle(fontSize: 16),
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}