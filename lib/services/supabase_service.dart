import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service class to initialize and manage Supabase client
class SupabaseService {
  static Future<void> initialize() async {
    // Load environment variables
    await dotenv.load(fileName: '.env');

    // Get Supabase credentials from environment
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    // Validate that credentials are provided
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'Supabase credentials are missing. Please check your .env file.\n'
        'Required: SUPABASE_URL and SUPABASE_ANON_KEY',
      );
    }

    // Initialize Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false, // Set to true for development debugging
    );
  }

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the current authenticated user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}
