import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'product_list_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthUser user; 
  final AuthService authService = AuthService();

  HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('🦕'),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Hola ${user.displayName ?? user.name}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Color(0xFF2E7D32).withOpacity(0.5),
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
                child: Icon(Icons.logout, color: Colors.white),
              ),
              onPressed: () async {
                bool shouldLogout = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      title: Row(
                        children: [
                          Text('🦖'),
                          SizedBox(width: 8),
                          Text('Cerrar Sesión'),
                        ],
                      ),
                      content: Text(
                        '¿Estás seguro de que quieres salir de DinoStore?',
                        style: TextStyle(fontSize: 16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Cerrar Sesión',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                ) ?? false;

                if (shouldLogout) {
                  await authService.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                }
              },
              tooltip: 'Cerrar sesión',
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
        child: Column(
          children: [
            // Banner de bienvenida
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF4CAF50),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2E7D32).withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '🦴 ¡Bienvenido a DinoStore! 🦴',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    user.isFromGoogle 
                        ? 'Conectado con Google 🔗' 
                        : 'Sesión con email/contraseña 🔐',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Descubre productos prehistóricamente buenos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido principal (lista de productos)
            Expanded(
              child: ProductListScreen(),
            ),
          ],
        ),
      ),
    );
  }
}