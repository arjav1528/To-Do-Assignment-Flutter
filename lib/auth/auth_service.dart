import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final _supabase = SupabaseService.client;

  User? get currentUser => _supabase.auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? redirectTo,
  }) async {
    try {
      AppLogger.info('Attempting to sign up user: $email');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        AppLogger.success('User signed up successfully: ${response.user!.email}');
      } else {
        AppLogger.warning('Sign up response received but user is null');
      }
      
      notifyListeners();
      return response;
    } catch (e, stackTrace) {
      AppLogger.error('Sign up failed for email: $email', e, stackTrace);
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Attempting to sign in user: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        AppLogger.success('User signed in successfully: ${response.user!.email}');
      } else {
        AppLogger.warning('Sign in response received but user is null');
      }
      
      notifyListeners();
      return response;
    } catch (e, stackTrace) {
      AppLogger.error('Sign in failed for email: $email', e, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final userEmail = currentUser?.email ?? 'Unknown';
      AppLogger.info('Attempting to sign out user: $userEmail');
      
      await _supabase.auth.signOut();
      AppLogger.success('User signed out successfully');
      
      notifyListeners();
    } catch (e, stackTrace) {
      AppLogger.error('Sign out failed', e, stackTrace);
      rethrow;
    }
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
