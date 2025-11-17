import '../models/user_model.dart';
import 'api_service.dart';

/// Authentication service handling user signup, login, and logout
/// Uses REST API for authentication
class AuthService {
  final ApiService _apiService = ApiService();
  UserModel? _currentUser;
  String? _token;

  // Allow profile screen to update current user
  set currentUser(UserModel? user) => _currentUser = user;

  /// Get current authenticated user
  UserModel? get currentUser => _currentUser;

  /// Stream of authentication state changes (simplified - returns current user)
  Stream<UserModel?> get authStateChanges => Stream.value(_currentUser);

  /// Sign up a new user with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiService.post('/auth/signup', {
        'email': email,
        'password': password,
        'name': name,
      });

      if (response['success'] == true) {
        _token = response['token'];
        await _apiService.setToken(_token!);
        
        _currentUser = UserModel.fromJson(response['user']);
        return _currentUser;
      } else {
        throw Exception(response['message'] ?? 'Sign up failed');
      }
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign in existing user with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        _token = response['token'];
        await _apiService.setToken(_token!);
        
        _currentUser = UserModel.fromJson(response['user']);
        return _currentUser;
      } else {
        throw Exception(response['message'] ?? 'Sign in failed');
      }
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _apiService.post('/auth/logout', {});
      await _apiService.clearToken();
      _currentUser = null;
      _token = null;
    } catch (e) {
      // Clear local state even if API call fails
      await _apiService.clearToken();
      _currentUser = null;
      _token = null;
    }
  }

  /// Reset password via email
  Future<void> resetPassword(String email) async {
    try {
      final response = await _apiService.post('/auth/reset-password', {
        'email': email,
      });

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Load current user from token (call on app start)
  Future<void> loadCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      if (response['success'] == true) {
        _currentUser = UserModel.fromJson(response['user']);
      }
    } catch (e) {
      // Token invalid or expired
      _currentUser = null;
      _token = null;
      await _apiService.clearToken();
    }
  }

  /// Handle authentication exceptions with user-friendly messages
  String _handleAuthException(dynamic e) {
    final errorMessage = e.toString().toLowerCase();
    
    if (errorMessage.contains('email-already-in-use') || 
        errorMessage.contains('already exists')) {
      return 'An account already exists with this email.';
    } else if (errorMessage.contains('user-not-found') || 
               errorMessage.contains('no user found')) {
      return 'No user found with this email.';
    } else if (errorMessage.contains('wrong-password') || 
               errorMessage.contains('incorrect password')) {
      return 'Incorrect password. Please try again.';
    } else if (errorMessage.contains('invalid-email') || 
               errorMessage.contains('invalid email')) {
      return 'Invalid email address format.';
    } else if (errorMessage.contains('weak-password') || 
               errorMessage.contains('password is too weak')) {
      return 'Password is too weak. Please use at least 6 characters.';
    } else if (errorMessage.contains('user-disabled')) {
      return 'This account has been disabled.';
    } else {
      return e.toString().replaceAll('Exception: ', '');
    }
  }
}
