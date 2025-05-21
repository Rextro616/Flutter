import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../cart/cart.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> futureProduct;

  @override
  void initState() {
    super.initState();
    futureProduct = ApiService.getProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle del Producto')),
      body: FutureBuilder<Product>(
        future: futureProduct,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No se encontró el producto'));
          }

          final product = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 200,
                    padding: EdgeInsets.all(10),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, error, _) => Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  product.title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        Text('${product.rating.rate} (${product.rating.count})')
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Precio: \$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                ),
                SizedBox(height: 16),
                Text(
                  'Descripción:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  product.description,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Cart.add(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.title} agregado al carrito')),
                          );
                        },
                        icon: Icon(Icons.add_shopping_cart),
                        label: Text('Agregar al carrito'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}