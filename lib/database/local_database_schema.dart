// ================================================================================
// APP COINZ - LOCAL DATABASE SCHEMA (SQLite)
// Version: 2.0
// Date: 2025-10-06
// ================================================================================

class LocalDatabaseSchema {
  static const String databaseName = 'app_coinz_local.db';
  static const int databaseVersion = 1;

  // ================================================================================
  // TABLE CREATION SCRIPTS
  // ================================================================================

  /// Bảng users: Thông tin người dùng cơ bản
  static const String createUsersTable = '''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT UNIQUE NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      full_name TEXT NOT NULL,
      phone_number TEXT,
      avatar_url TEXT,
      is_verified INTEGER DEFAULT 0,
      is_active INTEGER DEFAULT 1,
      referral_code TEXT UNIQUE NOT NULL,
      referred_by TEXT,
      total_referrals INTEGER DEFAULT 0,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
      last_login TEXT
    )
  ''';

  /// Bảng wallets: Ví coin
  static const String createWalletsTable = '''
    CREATE TABLE wallets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT UNIQUE NOT NULL,
      wallet_address TEXT UNIQUE NOT NULL,
      balance REAL DEFAULT 0,
      pending_balance REAL DEFAULT 0,
      total_earned REAL DEFAULT 0,
      total_spent REAL DEFAULT 0,
      total_withdrawn REAL DEFAULT 0,
      is_active INTEGER DEFAULT 1,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
      synced_to_server INTEGER DEFAULT 0
    )
  ''';

  /// Bảng mining_sessions: Phiên đào coin
  static const String createMiningSessionsTable = '''
    CREATE TABLE mining_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id TEXT UNIQUE NOT NULL,
      user_id TEXT NOT NULL,
      start_time TEXT NOT NULL,
      end_time TEXT,
      duration_seconds INTEGER DEFAULT 0,
      coins_mined REAL DEFAULT 0,
      base_mining_speed REAL DEFAULT 0.001,
      actual_mining_speed REAL DEFAULT 0,
      speed_multiplier REAL DEFAULT 1.0,
      is_active INTEGER DEFAULT 1,
      is_valid INTEGER DEFAULT 1,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      synced_to_server INTEGER DEFAULT 0
    )
  ''';

  /// Bảng mining_stats: Thống kê đào coin theo ngày
  static const String createMiningStatsTable = '''
    CREATE TABLE mining_stats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      date TEXT NOT NULL,
      total_coins_mined REAL DEFAULT 0,
      total_mining_time INTEGER DEFAULT 0,
      sessions_count INTEGER DEFAULT 0,
      avg_mining_speed REAL DEFAULT 0,
      max_mining_speed REAL DEFAULT 0,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      synced_to_server INTEGER DEFAULT 0,
      UNIQUE(user_id, date)
    )
  ''';

  /// Bảng friends: Danh sách bạn bè
  static const String createFriendsTable = '''
    CREATE TABLE friends (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      friend_id TEXT NOT NULL,
      friend_email TEXT NOT NULL,
      friend_name TEXT NOT NULL,
      friend_avatar_url TEXT,
      status TEXT DEFAULT 'accepted',
      is_online INTEGER DEFAULT 0,
      last_seen TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      synced_to_server INTEGER DEFAULT 0,
      UNIQUE(user_id, friend_id)
    )
  ''';

  /// Bảng transactions: Giao dịch
  static const String createTransactionsTable = '''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      transaction_id TEXT UNIQUE NOT NULL,
      user_id TEXT NOT NULL,
      transaction_type TEXT NOT NULL,
      amount REAL NOT NULL,
      fee_amount REAL DEFAULT 0,
      net_amount REAL NOT NULL,
      balance_before REAL NOT NULL,
      balance_after REAL NOT NULL,
      from_user_id TEXT,
      to_user_id TEXT,
      external_wallet_address TEXT,
      description TEXT,
      status TEXT DEFAULT 'pending',
      metadata TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      synced_to_server INTEGER DEFAULT 0
    )
  ''';

  /// Bảng notifications: Thông báo local
  static const String createNotificationsTable = '''
    CREATE TABLE notifications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      notification_id TEXT UNIQUE,
      user_id TEXT NOT NULL,
      title TEXT NOT NULL,
      message TEXT NOT NULL,
      notification_type TEXT NOT NULL,
      related_id TEXT,
      is_read INTEGER DEFAULT 0,
      read_at TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  /// Bảng news_cache: Cache tin tức
  static const String createNewsCacheTable = '''
    CREATE TABLE news_cache (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      news_id TEXT UNIQUE NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      summary TEXT,
      image_url TEXT,
      published_at TEXT,
      cached_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  /// Bảng settings: Cài đặt ứng dụng
  static const String createSettingsTable = '''
    CREATE TABLE settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      setting_key TEXT NOT NULL,
      setting_value TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(user_id, setting_key)
    )
  ''';

  // ================================================================================
  // INDEXES FOR PERFORMANCE
  // ================================================================================

  static const List<String> createIndexes = [
    'CREATE INDEX idx_users_user_id ON users(user_id)',
    'CREATE INDEX idx_users_email ON users(email)',
    'CREATE INDEX idx_users_referral_code ON users(referral_code)',
    
    'CREATE INDEX idx_wallets_user_id ON wallets(user_id)',
    'CREATE INDEX idx_wallets_wallet_address ON wallets(wallet_address)',
    
    'CREATE INDEX idx_mining_sessions_user_id ON mining_sessions(user_id)',
    'CREATE INDEX idx_mining_sessions_session_id ON mining_sessions(session_id)',
    'CREATE INDEX idx_mining_sessions_start_time ON mining_sessions(start_time)',
    'CREATE INDEX idx_mining_sessions_is_active ON mining_sessions(is_active)',
    
    'CREATE INDEX idx_mining_stats_user_id ON mining_stats(user_id)',
    'CREATE INDEX idx_mining_stats_date ON mining_stats(date)',
    
    'CREATE INDEX idx_friends_user_id ON friends(user_id)',
    'CREATE INDEX idx_friends_friend_id ON friends(friend_id)',
    
    'CREATE INDEX idx_transactions_user_id ON transactions(user_id)',
    'CREATE INDEX idx_transactions_transaction_id ON transactions(transaction_id)',
    'CREATE INDEX idx_transactions_type ON transactions(transaction_type)',
    'CREATE INDEX idx_transactions_created_at ON transactions(created_at)',
    
    'CREATE INDEX idx_notifications_user_id ON notifications(user_id)',
    'CREATE INDEX idx_notifications_is_read ON notifications(is_read)',
    
    'CREATE INDEX idx_news_cache_news_id ON news_cache(news_id)',
    
    'CREATE INDEX idx_settings_user_id ON settings(user_id)',
    'CREATE INDEX idx_settings_key ON settings(setting_key)',
  ];

  // ================================================================================
  // ALL TABLES LIST
  // ================================================================================

  static const List<String> allTables = [
    createUsersTable,
    createWalletsTable,
    createMiningSessionsTable,
    createMiningStatsTable,
    createFriendsTable,
    createTransactionsTable,
    createNotificationsTable,
    createNewsCacheTable,
    createSettingsTable,
  ];

  // ================================================================================
  // TABLE NAMES
  // ================================================================================

  static const String tableUsers = 'users';
  static const String tableWallets = 'wallets';
  static const String tableMiningSessions = 'mining_sessions';
  static const String tableMiningStats = 'mining_stats';
  static const String tableFriends = 'friends';
  static const String tableTransactions = 'transactions';
  static const String tableNotifications = 'notifications';
  static const String tableNewsCache = 'news_cache';
  static const String tableSettings = 'settings';

  // ================================================================================
  // DROP TABLES (for migration)
  // ================================================================================

  static const List<String> dropAllTables = [
    'DROP TABLE IF EXISTS users',
    'DROP TABLE IF EXISTS wallets',
    'DROP TABLE IF EXISTS mining_sessions',
    'DROP TABLE IF EXISTS mining_stats',
    'DROP TABLE IF EXISTS friends',
    'DROP TABLE IF EXISTS transactions',
    'DROP TABLE IF EXISTS notifications',
    'DROP TABLE IF EXISTS news_cache',
    'DROP TABLE IF EXISTS settings',
  ];
}

