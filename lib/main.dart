import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'services/task_service.dart';
import 'services/theme_service.dart';
import 'auth/auth_service.dart';
import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'app/theme.dart';
import 'utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    AppLogger.info('Initializing Supabase...');
    await SupabaseService.initialize();
    AppLogger.success('Supabase initialized successfully');

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        AppLogger.success('User signed in via email verification');
      } else if (event == AuthChangeEvent.signedOut) {
        AppLogger.info('User signed out');
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        AppLogger.debug('Auth token refreshed');
      }
    });
  } catch (e, stackTrace) {
    AppLogger.error('Error initializing Supabase', e, stackTrace);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TaskService()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return Consumer<ThemeService>(
            builder: (context, themeService, _) {
              return MaterialApp(
                title: 'Todo App',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeService.themeMode,
                home: const AuthWrapper(),
              );
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          AppLogger.debug('Checking authentication state...');
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isAuthenticated = authService.isAuthenticated;
        final userEmail = authService.currentUser?.email ?? 'Unknown';
        
        if (isAuthenticated) {
          AppLogger.info('User is authenticated: $userEmail - Redirecting to dashboard');
          return const DashboardScreen();
        } else {
          AppLogger.info('User is not authenticated - Showing login screen');
          return const LoginScreen();
        }
      },
    );
  }
}
