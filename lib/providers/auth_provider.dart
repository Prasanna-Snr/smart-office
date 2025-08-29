import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/auth_user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  AuthUser? _userData;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  User? get user => _user;
  AuthUser? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  
  AuthProvider() {
    // Listen to auth state changes
    AuthService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        _userData = await AuthService.getUserData(user.uid);
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void clearErrorSilently() {
    _errorMessage = null;
    // Don't notify listeners to avoid rebuilding UI
  }
  
  // Sign up method
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await AuthService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      if (!result['success']) {
        _setError(result['message']);
      }
      
      return result;
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }
  
  // Verify OTP and complete registration
  Future<bool> verifyOTPAndRegister({
    required String email,
    required String otp,
    required String password,
    String? displayName,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await AuthService.verifyOTPAndRegister(
        email: email,
        otp: otp,
        password: password,
        displayName: displayName,
      );
      
      if (!result['success']) {
        _setError(result['message']);
        return false;
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Sign in method
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await AuthService.signIn(
        email: email,
        password: password,
      );
      
      if (!result['success']) {
        _setError(result['message']);
        return false;
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Sign out method
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await AuthService.signOut();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final result = await AuthService.resetPassword(email);
      
      if (!result['success']) {
        _setError(result['message']);
        return false;
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}