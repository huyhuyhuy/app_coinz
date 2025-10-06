import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_localizations.dart';
import 'services/ads_helper.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Google Mobile Ads
  await AdsHelper.initialize();

  // Khởi tạo Local Database
  try {
    print('🚀 [DATABASE] Starting initialization...');
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database; // Trigger database initialization
    print('✅ [DATABASE] Database instance created: ${db.path}');

    await dbHelper.printDatabaseInfo();
    print('✅ [DATABASE] Database initialized successfully!');
  } catch (e, stackTrace) {
    print('❌ [DATABASE ERROR] Failed to initialize database:');
    print('Error: $e');
    print('StackTrace: $stackTrace');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
