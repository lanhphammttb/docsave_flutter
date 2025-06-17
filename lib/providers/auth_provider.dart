import 'package:flutter/foundation.dart';
import '../models/user.dart' as app_user;
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  app_user.User? _userData;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  app_user.User? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _init();
  }

  void _init() async {
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    _userData = await ApiService.getUserData();
    _isAuthenticated = _userData != null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await ApiService.login(email, password);

      debugPrint('AuthProvider: Login result: $result');

      if (result != null) {
        debugPrint('AuthProvider: Login successful, getting user data');
        _userData = await ApiService.getUserData();
        debugPrint('AuthProvider: User data: $_userData');
        _isAuthenticated = true;
        _setLoading(false);
        notifyListeners();
        debugPrint('AuthProvider: Sign in completed successfully');
        return true;
      } else {
        debugPrint('AuthProvider: Login result is null');
        _setError('Đăng nhập thất bại. Vui lòng kiểm tra email và mật khẩu.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      debugPrint('AuthProvider: Sign in error: $e');
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await ApiService.register(email, password, name);

      if (result != null) {
        _userData = await ApiService.getUserData();
        _isAuthenticated = true;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Đăng ký thất bại. Vui lòng thử lại.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await ApiService.clearToken();
      _userData = null;
      _isAuthenticated = false;
    } catch (e) {
      _setError('Có lỗi xảy ra khi đăng xuất: $e');
    }
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
