import 'package:flutter/foundation.dart';
import '../models/document.dart';
import '../services/api_service.dart';

class DocumentProvider with ChangeNotifier {
  List<Document> _documents = [];
  bool _isLoading = false;
  String? _error;

  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDocuments() async {
    _setLoading(true);
    _clearError();

    try {
      // Kiểm tra token trước khi gọi API
      final isTokenValid = await ApiService.isTokenValid();
      if (!isTokenValid) {
        debugPrint('Token is invalid, logging out');
        await ApiService.logout();
        _setError('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
        _setLoading(false);
        return;
      }

      _documents = await ApiService.getDocuments();
      _setLoading(false);
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Load documents error: $errorMessage');

      // Nếu lỗi là unauthorized, logout và yêu cầu đăng nhập lại
      if (errorMessage.contains('hết hạn') || errorMessage.contains('Unauthorized')) {
        await ApiService.logout();
        _setError('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else {
        _setError(errorMessage);
      }
      _setLoading(false);
    }
  }

  Future<bool> createDocument({
    required String title,
    String? description,
    required String fileName,
    required String fileUrl,
    required String fileType,
    required int fileSize,
    required List<String> tags,
    bool isPublic = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      Document? newDocument = await ApiService.createDocument(
        title: title,
        description: description,
        fileName: fileName,
        fileUrl: fileUrl,
        fileType: fileType,
        fileSize: fileSize,
        tags: tags,
        isPublic: isPublic,
      );

      if (newDocument != null) {
        _documents.insert(0, newDocument);
        _setLoading(false);
        return true;
      } else {
        _setError('Không thể tạo tài liệu mới');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteDocument(String documentId) async {
    _setLoading(true);
    _clearError();

    try {
      bool success = await ApiService.deleteDocument(documentId);
      if (success) {
        _documents.removeWhere((doc) => doc.id == documentId);
        _setLoading(false);
        return true;
      } else {
        _setError('Không thể xóa tài liệu');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  List<Document> searchDocuments(String query) {
    if (query.isEmpty) return _documents;

    return _documents.where((doc) {
      return doc.title.toLowerCase().contains(query.toLowerCase()) ||
          doc.topic.toLowerCase().contains(query.toLowerCase()) ||
          doc.category.toLowerCase().contains(query.toLowerCase()) ||
          (doc.content?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (doc.fileName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          (doc.link?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  List<Document> getDocumentsByType(String type) {
    return _documents.where((doc) => doc.type.toLowerCase() == type.toLowerCase()).toList();
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
