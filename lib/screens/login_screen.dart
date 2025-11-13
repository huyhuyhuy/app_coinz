import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_localizations.dart';
import '../widgets/language_selector.dart';
import 'register_screen.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _identifierController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // ✅ FIX: Clear toàn bộ navigation stack khi login thành công
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false, // Remove all previous routes
        );
      } else if (mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _resolveErrorMessage(authProvider.errorCode, localizations),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _resolveErrorMessage(String? code, AppLocalizations localizations) {
    switch (code) {
      case 'identifier_not_found':
        return localizations.accountNotFound;
      case 'invalid_password':
        return localizations.incorrectPassword;
      default:
        return localizations.loginFailed;
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Language Selector
                Align(
                  alignment: Alignment.topRight,
                  child: const LanguageSelector(),
                ),

                const SizedBox(height: 40),

                // App Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Image.asset(
                      'assets/icons/app_logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Title
                Text(
                  localizations.welcomeMessage,
                  style: GoogleFonts.roboto(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Identifier Field (Email or Phone)
                TextFormField(
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: localizations.emailOrPhone,
                    prefixIcon: const Icon(Icons.alternate_email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.pleaseEnterEmailOrPhone;
                    }
                    final trimmed = value.trim();
                    if (trimmed.contains('@')) {
                      if (!trimmed.contains('.') || trimmed.startsWith('@')) {
                        return localizations.pleaseEnterValidEmail;
                      }
                    } else {
                      final sanitized = trimmed.replaceAll(RegExp(r'\s+'), '');
                      if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(sanitized)) {
                        return localizations.pleaseEnterValidEmailOrPhone;
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: localizations.password,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.pleaseEnterPassword;
                    }
                    if (value.length < 6) {
                      return localizations.passwordTooShort;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Login Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              localizations.login,
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Forgot Password
                TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password
                  },
                  child: Text(
                    localizations.forgotPassword,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      localizations.dontHaveAccount,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        localizations.register,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
