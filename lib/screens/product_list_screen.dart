import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../cart/cart.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = ApiService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('🦴'),
            SizedBox(width: 8),
            Text('Catálogo Prehistórico'),
          ],
        ),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.shopping_cart, color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CartScreen()),
                );
              },
              tooltip: 'Ver carrito de fósiles',
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: FutureBuilder<List<Product>>(
          future: futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🦖', style: TextStyle(fontSize: 50)),
                    SizedBox(height: 16),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Excavando productos...',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🦴', style: TextStyle(fontSize: 50)),
                    SizedBox(height: 16),
                    Text(
                      'Error al cargar productos',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🦕', style: TextStyle(fontSize: 50)),
                    SizedBox(height: 16),
                    Text(
                      'No hay productos disponibles',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Los dinosaurios se llevaron todo 🦖',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final products = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  futureProducts = ApiService.getProducts();
                });
              },
              color: Color(0xFF4CAF50),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 6,
                    shadowColor: Color(0xFF4CAF50).withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Color(0xFF4CAF50).withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              width: 60,
                              height: 60,
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFF4CAF50).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.image,
                                  fit: BoxFit.contain,
                                  errorBuilder: (ctx, error, _) => Container(
                                    color: Color(0xFF4CAF50).withOpacity(0.1),
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                  loadingBuilder: (ctx, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF4CAF50),
                                        ),
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            title: Text(
                              product.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Container(
                              margin: EdgeInsets.only(top: 4),
                              child: Text(
                                '\${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ),
                            trailing: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF2E7D32),
                                size: 16,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(productId: product.id),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailScreen(productId: product.id),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.info_outline, size: 18),
                                    label: Text('Ver Detalles'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF2E7D32),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Cart.add(product);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Text('🦴'),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '${product.title} agregado al carrito',
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Color(0xFF4CAF50),
                                          duration: Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.add_shopping_cart, size: 18),
                                    label: Text('Añadir'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4CAF50),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}