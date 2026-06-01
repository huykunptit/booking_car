import 'package:flutter/foundation.dart';

import 'auth_repository.dart';
import 'auth_tokens.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repo) {
    _restore();
  }

  final AuthRepository _repo;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> _restore() async {
    final refreshToken = await _repo.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      _isAuthenticated = true;
      try {
        await refreshIfNeeded();
      } catch (_) {
        await logout();
      }
    }
    notifyListeners();
  }

  Future<void> login(String phone, String password) async {
    await _setLoading(true);
    try {
      final tokens = await _repo.login(phone: phone, password: password);
      await _repo.saveTokens(tokens);
      _isAuthenticated = true;
    } finally {
      await _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> register(String phone, String password, String otp) async {
    await _setLoading(true);
    try {
      final tokens = await _repo.register(phone: phone, password: password, otp: otp);
      await _repo.saveTokens(tokens);
      _isAuthenticated = true;
    } finally {
      await _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> forgotPassword(String email) async {
    await _setLoading(true);
    try {
      await _repo.forgotPassword(email: email);
    } finally {
      await _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> resetPassword({required String email, required String otp, required String newPassword}) async {
    await _setLoading(true);
    try {
      await _repo.resetPassword(email: email, otp: otp, newPassword: newPassword);
    } finally {
      await _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repo.clearTokens();
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> refreshIfNeeded() async {
    final refreshToken = await _repo.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return;
    final tokens = await _repo.refresh(refreshToken: refreshToken);
    await _repo.saveTokens(tokens);
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> _setLoading(bool value) async {
    _isLoading = value;
    notifyListeners();
  }
}
