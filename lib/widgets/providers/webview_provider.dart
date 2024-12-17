import 'package:flutter/material.dart';
import 'package:webview_application/models/platform.dart';

class WebViewProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  GamePlatform? _selectedPlatform;
  final List<GamePlatform> _platforms;

  WebViewProvider(this._platforms) {
    if (_platforms.isNotEmpty) {
      _selectedPlatform = _platforms.first;
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  GamePlatform? get selectedPlatform => _selectedPlatform;
  List<GamePlatform> get platforms => _platforms;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void setSelectedPlatform(GamePlatform platform) {
    _selectedPlatform = platform;
    notifyListeners();
  }
}