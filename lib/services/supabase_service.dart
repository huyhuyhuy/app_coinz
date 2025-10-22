import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Supabase Service - Singleton để quản lý Supabase client
class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitializing = false;
  
  /// Initialize Supabase
  static Future<void> initialize() async {
    // Tránh khởi tạo nhiều lần
    if (_isInitializing || _client != null) {
      print('[SUPABASE] ⏳ Already initializing or initialized');
      return;
    }
    
    _isInitializing = true;
    
    try {
      print('[SUPABASE] 🚀 Initializing Supabase...');
      
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      
      _client = Supabase.instance.client;
      print('[SUPABASE] ✅ Supabase initialized successfully');
      print('[SUPABASE] 🌐 URL: ${SupabaseConfig.supabaseUrl}');
    } catch (e) {
      print('[SUPABASE] ❌ Error initializing Supabase: $e');
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }
  
  /// Get Supabase client instance
  static SupabaseClient get client {
    if (_client == null) {
      // Nếu chưa khởi tạo, thử khởi tạo đồng bộ
      print('[SUPABASE] ⚠️ Client not initialized, attempting sync initialization...');
      throw Exception('Supabase not initialized. Call SupabaseService.initialize() first.');
    }
    return _client!;
  }
  
  /// Get Supabase client instance (async version)
  static Future<SupabaseClient> getClientAsync() async {
    if (_client == null) {
      print('[SUPABASE] 🔄 Client not initialized, initializing now...');
      await initialize();
    }
    return _client!;
  }
  
  /// Check if Supabase is initialized
  static bool get isInitialized => _client != null;
  
  /// Test connection to Supabase
  static Future<bool> testConnection() async {
    try {
      print('[SUPABASE] 🔍 Testing connection...');
      
      // Try to query system_settings table
      final response = await client
          .from('system_settings')
          .select('setting_key')
          .limit(1);
      
      print('[SUPABASE] ✅ Connection test successful');
      print('[SUPABASE] 📊 Response: $response');
      return true;
    } catch (e) {
      print('[SUPABASE] ❌ Connection test failed: $e');
      return false;
    }
  }
}

