import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';

class ApiService {
  final String baseUrl = 'https://task.itprojects.web.id';
  final storage = const FlutterSecureStorage();

  // ─── Helper: Generator Header ───────────────────
  // Mengurangi repetisi penulisan header dan token di setiap method
  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth) {
      final token = await storage.read(key: 'token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // 1. Login
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: await _getHeaders(withAuth: false),
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'token', value: data['data']['token']);
      await storage.write(key: 'name', value: data['data']['user']['name']);
      return true;
    }
    return false;
  }

  // 2. Get Products (Draft)
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'];

        if (data != null && data['products'] != null) {
          // Parsing List yang lebih ringkas
          return (data['products'] as List)
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        print('=== SERVER ERROR: ${response.statusCode} ===');
        print(response.body);
        return [];
      }
    } catch (e) {
      print('=== ERROR FATAL GET PRODUCTS ===');
      print(e.toString());
      return [];
    }
  }

  // 3. Simpan Draft Produk
  Future<bool> createDraft(String name, int price, String desc) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': desc,
      }),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  // 4. Submit Tugas Akhir
  Future<bool> submitTask(String name, int price, String desc, String githubUrl) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products/submit'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': desc,
        'github_url': githubUrl,
      }),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  // 5. Delete Produk
  Future<bool> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: await _getHeaders(),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  // 6. Ambil nama user
  Future<String?> getName() => storage.read(key: 'name');

  // 7. Logout
  Future<void> logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'name');
  }
}