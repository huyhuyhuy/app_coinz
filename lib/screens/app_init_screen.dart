import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/app_open_ad_manager.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'main_screen.dart';

/// Screen khởi tạo app
/// - Show splash
/// - Load App Open Ad trong background
/// - Check auth status
/// - Show ad nếu ready và đủ điều kiện (4 giờ)
/// - Navigate to MainScreen (nếu đã đăng nhập) hoặc LoginScreen
class AppInitScreen extends StatefulWidget {
  const AppInitScreen({super.key});

  @override
  State<AppInitScreen> createState() => _AppInitScreenState();
}

class _AppInitScreenState extends State<AppInitScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// ✅ Initialize app: Load ad + Check auth + Show ad (if ready)
  Future<void> _initializeApp() async {
    print('[APP_INIT] 🚀 Starting app initialization...');
    
    // ✅ Step 1: Đợi AuthProvider khởi tạo xong
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authWaitFuture = authProvider.waitForInitialization();
    
    // ✅ Step 2: Load App Open Ad
    // Đợi thực sự cho đến khi ad load xong (tối đa 8 giây)
    final adLoadFuture = AppOpenAdManager.loadAd();
    
    // ✅ Step 3: Đợi splash screen tối thiểu 2 giây (để hiển thị logo)
    final splashFuture = Future.delayed(const Duration(seconds: 2));
    
    // ✅ Step 4: Đợi cả 3 hoàn thành
    // - AuthProvider init (nhanh, ~100-500ms)
    // - Splash animation (2s cố định)
    // - Ad load (đợi thực sự, timeout 8s)
    // → Thời gian thực tế: max(2s, ad_load_time) với ad_load_time ≤ 8s
    // → Nếu ad load nhanh (< 2s): đợi 2s (splash)
    // → Nếu ad load chậm (> 2s): đợi ad load xong (tối đa 8s)
    await Future.wait([
      authWaitFuture,
      splashFuture,
      adLoadFuture,
    ]);
    
    if (!mounted) return;
    
    setState(() {
      _isInitialized = true;
    });
    
    print('[APP_INIT] ✅ App initialized. isAuthenticated=${authProvider.isAuthenticated}');
    
    // ✅ Step 5: Show App Open Ad (nếu ready)
    // Sau đó navigate to appropriate screen
    _showAdAndNavigate();
  }

  /// ✅ Show ad (nếu ready) và navigate to appropriate screen
  void _showAdAndNavigate() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    AppOpenAdManager.showAdIfReady(
      onAdDismissed: () {
        // ✅ Ad dismissed (hoặc skip) → Navigate to appropriate screen
        if (mounted) {
          if (authProvider.isAuthenticated) {
            // ✅ Đã đăng nhập → MainScreen
            print('[APP_INIT] ✅ User authenticated → Navigate to MainScreen');
            _navigateToMainScreen();
          } else {
            // ✅ Chưa đăng nhập → LoginScreen
            print('[APP_INIT] ℹ️ User not authenticated → Navigate to LoginScreen');
            _navigateToLoginScreen();
          }
        }
      },
    );
  }

  /// ✅ Navigate to MainScreen (đã đăng nhập)
  void _navigateToMainScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }

  /// ✅ Navigate to LoginScreen (chưa đăng nhập)
  void _navigateToLoginScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFE0), // Match app background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'assets/icons/app_logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            
            const SizedBox(height: 32),
            
            // App Name
            Text(
              'DFI',
              style: GoogleFonts.roboto(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD4AF37), // Gold color to match logo
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Tagline
            Text(
              '',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Loading indicator
            if (!_isInitialized)
              Column(
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFD4AF37), // Gold color to match logo
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

