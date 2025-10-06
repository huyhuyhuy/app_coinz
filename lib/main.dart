import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'providers/mining_provider.dart';
import 'providers/wallet_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_localizations.dart';
import 'services/ads_helper.dart';
import 'services/supabase_service.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Google Mobile Ads (nhanh)
  AdsHelper.initialize();

  // Khởi tạo Supabase trước khi chạy app
  await _initializeServices();

  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  // Khởi tạo Supabase
  try {
    await SupabaseService.initialize();
    print('✅ [MAIN] Supabase initialized');
  } catch (e) {
    print('❌ [SUPABASE ERROR] Failed to initialize: $e');
  }

  // Database sẽ tự động khởi tạo khi cần (lazy initialization)
  // Không cần khởi tạo ở đây để tránh chậm khi mở app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MiningProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'App Coinz',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2196F3),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.robotoTextTheme(),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2196F3),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.robotoTextTheme(),
            ),
            locale: languageProvider.currentLocale,
            supportedLocales: const [
              Locale('en', 'US'), // English
              Locale('vi', 'VN'), // Vietnamese
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
