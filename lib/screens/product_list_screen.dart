import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
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
        title: Text('Productos'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartScreen()),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay productos disponibles'));
          }

          final products = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                futureProducts = ApiService.getProducts();
              });
            },
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Column(
                    children: [
                      ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.network(
                            product.image,
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, error, _) => Icon(Icons.broken_image),
                            loadingBuilder: (ctx, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                          ),
                        ),
                        title: Text(product.title),
                        subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                        trailing: Icon(Icons.arrow_forward_ios),
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
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(productId: product.id),
                                  ),
                                );
                              },
                              icon: Icon(Icons.info_outline),
                              label: Text('Detalles'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Producto añadido al carrito')),
                                );
                              },
                              icon: Icon(Icons.add_shopping_cart),
                              label: Text('Añadir al carrito'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}