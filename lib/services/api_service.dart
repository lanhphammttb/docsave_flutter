import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_user;
import '../models/document.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Thay đổi base URL theo backend của bạn
  static const String baseUrl = 'https://docsave.vercel.app/api/mobile'; // hoặc URL thực tế

  // Local storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Clear token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Save user data
  static Future<void> saveUserData(app_user.User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Get user data
  static Future<app_user.User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return app_user.User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Check if token is valid
  static Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Token validation response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Token validation error: $e');
      return false;
    }
  }

  // Logout and clear data
  static Future<void> logout() async {
    debugPrint('Logging out and clearing data');
    await clearToken();
  }

  // Auth methods
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Kiểm tra xem có token và user không
        if (data['data']['token'] == null) {
          debugPrint('No token in response');
          throw Exception('Token không hợp lệ');
        }

        if (data['data']['user'] == null) {
          debugPrint('No user data in response');
          throw Exception('Thông tin người dùng không hợp lệ');
        }

        debugPrint('User data from API: ${data['data']['user']}');

        await saveToken(data['data']['token']);

        try {
          await saveUserData(app_user.User.fromJson(data['data']['user']));
        } catch (e) {
          debugPrint('Error parsing user data: $e');
        }

        return data;
      } else {
        // Trả về error message từ API
        final errorData = jsonDecode(response.body);
        debugPrint('Login failed with error: $errorData');
        throw Exception(errorData['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      if (e is Exception) {
        debugPrint('Login exception: $e');
        rethrow; // Re-throw để AuthProvider có thể bắt được
      }
      debugPrint('Login error: $e');
      throw Exception('Không thể kết nối đến server');
    }
  }

  static Future<Map<String, dynamic>?> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await saveToken(data['data']['token']);
        await saveUserData(app_user.User.fromJson(data['data']['user']));
        return data;
      } else {
        // Trả về error message từ API
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow; // Re-throw để AuthProvider có thể bắt được
      }
      debugPrint('Register error: $e');
      throw Exception('Không thể kết nối đến server');
    }
  }

  // Document methods
  static Future<List<Document>> getDocuments() async {
    try {
      final token = await getToken();
      debugPrint('Token for getDocuments: $token');

      if (token == null) {
        debugPrint('No token found, returning empty list');
        return [];
      }

      debugPrint('Making request to: $baseUrl/documents');
      final response = await http.get(
        Uri.parse('$baseUrl/documents'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final List<dynamic> data = responseData['data']['documents'] ?? [];
        debugPrint('Documents data: $data');

        if (data.isEmpty) {
          debugPrint('No documents found, returning empty list');
          return [];
        }

        return data.map((json) => Document.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        debugPrint('Unauthorized - token might be invalid or expired');
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else {
        // Trả về error message từ API
        final errorData = jsonDecode(response.body);
        debugPrint('API error: $errorData');
        throw Exception(errorData['message'] ?? 'Không thể tải danh sách tài liệu');
      }
    } catch (e) {
      if (e is Exception) {
        debugPrint('Get documents exception: $e');
        rethrow;
      }
      debugPrint('Get documents error: $e');
      throw Exception('Không thể kết nối đến server');
    }
  }

  static Future<Document?> createDocument({
    required String title,
    String? description,
    required String fileName,
    required String fileUrl,
    required String fileType,
    required int fileSize,
    required List<String> tags,
    bool isPublic = false,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/documents'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'fileName': fileName,
          'fileUrl': fileUrl,
          'fileType': fileType,
          'fileSize': fileSize,
          'tags': tags,
          'isPublic': isPublic,
        }),
      );

      if (response.statusCode == 201) {
        return Document.fromJson(jsonDecode(response.body));
      } else {
        // Trả về error message từ API
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Không thể tạo tài liệu');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      debugPrint('Create document error: $e');
      throw Exception('Không thể kết nối đến server');
    }
  }

  static Future<bool> deleteDocument(String documentId) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('$baseUrl/documents/$documentId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Trả về error message từ API
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Không thể xóa tài liệu');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      debugPrint('Delete document error: $e');
      throw Exception('Không thể kết nối đến server');
    }
  }

  // File upload (giả lập - thực tế sẽ upload lên server)
  static Future<String?> uploadFile(String filePath, String fileName) async {
    try {
      // Giả lập upload thành công
      await Future.delayed(const Duration(seconds: 2));
      return 'https://example.com/files/$fileName';
    } catch (e) {
      debugPrint('Upload file error: $e');
      return null;
    }
  }
}
