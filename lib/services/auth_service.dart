import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  final String email;
  final String name;
  final String? token;
  final bool isFromGoogle;

  AuthUser({
    required this.email,
    required this.name,
    this.token,
    this.isFromGoogle = false,
  });

  String? get displayName => name;
  String? get uid => email;
}

class AuthService {
  static const String baseUrl = 'http://172.20.10.2:8080/api/auth'; 
  
  final FirebaseAuth _auth = FirebaseAuth.instanceFor(
    app: Firebase.app("flutter"),
  );
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<AuthUser?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        return AuthUser(
          email: user.email ?? '',
          name: user.displayName ?? '',
          isFromGoogle: true,
        );
      }
    } catch (e) {
      print("Error signing in with Google: $e");
    }
    return null;
  }

  Future<AuthUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Guardar token en preferencias
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_email', data['email']);
        await prefs.setString('user_name', data['name']);
        
        return AuthUser(
          email: data['email'],
          name: data['name'],
          token: data['token'],
        );
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Error al iniciar sesión';
      }
    } catch (e) {
      if (e is Exception) {
        throw e.toString().replaceAll('Exception: ', '');
      }
      throw 'Error de conexión. Verifica tu internet.';
    }
  }

  Future<AuthUser?> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'name': displayName.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Guardar token en preferencias
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_email', data['email']);
        await prefs.setString('user_name', data['name']);
        
        return AuthUser(
          email: data['email'],
          name: data['name'],
          token: data['token'],
        );
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Error al registrar usuario';
      }
    } catch (e) {
      if (e is Exception) {
        throw e.toString().replaceAll('Exception: ', '');
      }
      throw 'Error de conexión. Verifica tu internet.';
    }
  }

  // Verificar si hay una sesión guardada
  Future<AuthUser?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final email = prefs.getString('user_email');
      final name = prefs.getString('user_name');
      
      if (token != null && email != null && name != null) {
        return AuthUser(
          email: email,
          name: name,
          token: token,
        );
      }
      
      // Verificar si hay usuario de Google logueado
      final googleUser = _auth.currentUser;
      if (googleUser != null) {
        return AuthUser(
          email: googleUser.email ?? '',
          name: googleUser.displayName ?? '',
          isFromGoogle: true,
        );
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return null;
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    
    // Limpiar datos guardados
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
  }
}