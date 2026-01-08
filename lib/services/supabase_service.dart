import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_logger.dart';

class SupabaseService {
  static Future<void> initialize() async {
    AppLogger.info('Loading environment variables...');
    await dotenv.load(fileName: '.env');
    AppLogger.success('Environment variables loaded');

    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      AppLogger.error('Supabase credentials are missing in .env file');
      throw Exception(
        'Supabase credentials are missing. Please check your .env file.\n'
        'Required: SUPABASE_URL and SUPABASE_ANON_KEY',
      );
    }

    AppLogger.info('Initializing Supabase client...');
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
    AppLogger.success('Supabase client initialized');
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static bool get isAuthenticated => currentUser != null;
}
