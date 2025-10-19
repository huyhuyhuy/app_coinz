import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'local_database_schema.dart';

/// DatabaseHelper - Singleton class để quản lý SQLite database
/// 
/// Chức năng:
/// - Khởi tạo database
/// - Tạo tables và indexes
/// - Cung cấp database instance cho toàn app
/// - Hỗ trợ migration khi upgrade version
class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  // Private constructor
  DatabaseHelper._internal();

  /// Factory constructor trả về singleton instance
  factory DatabaseHelper() {
    return instance;
  }

  /// Getter để lấy database instance
  /// Tự động khởi tạo nếu chưa có
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Khởi tạo database
  Future<Database> _initDatabase() async {
    try {
      // Lấy đường dẫn database
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, LocalDatabaseSchema.databaseName);

      // Mở database (sẽ tự động tạo nếu chưa có)
      final db = await openDatabase(
        path,
        version: LocalDatabaseSchema.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );

      return db;
    } catch (e) {
      print('[DATABASE] ❌ Error initializing database: $e');
      rethrow;
    }
  }

  /// Callback khi tạo database lần đầu
  Future<void> _onCreate(Database db, int version) async {
    print('[DATABASE] 🔨 Creating new database version $version...');

    try {
      // Tạo tất cả các bảng
      for (String createTableSql in LocalDatabaseSchema.allTables) {
        await db.execute(createTableSql);
      }

      // Tạo indexes
      for (String createIndexSql in LocalDatabaseSchema.createIndexes) {
        await db.execute(createIndexSql);
      }

      print('[DATABASE] ✅ Database created successfully with ${LocalDatabaseSchema.allTables.length} tables');
    } catch (e) {
      print('[DATABASE] ❌ Error creating database: $e');
      rethrow;
    }
  }

  /// Callback khi upgrade database version
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('[DATABASE] ⬆️ Upgrading database from version $oldVersion to $newVersion...');

    try {
      // Migration từ version 1 lên 2: Thêm cột updated_at vào bảng transactions
      if (oldVersion < 2) {
        print('[DATABASE] 🔧 Adding updated_at column to transactions table...');
        await db.execute('ALTER TABLE transactions ADD COLUMN updated_at TEXT DEFAULT CURRENT_TIMESTAMP');
        print('[DATABASE] ✅ Migration to version 2 completed');
      }

      print('[DATABASE] ✅ Database upgraded successfully!');
    } catch (e) {
      print('[DATABASE] ❌ Error during migration: $e');
      // Nếu migration fail, có thể cần reset database
      print('[DATABASE] ⚠️ Consider calling resetDatabase() if issues persist');
      rethrow;
    }
  }

  /// Callback khi mở database
  Future<void> _onOpen(Database db) async {
    // Database đã mở - không cần log để tránh spam
  }

  /// Đóng database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    print('🔒 Database closed');
  }

  /// Xóa database (dùng cho testing hoặc reset app)
  Future<void> deleteDatabase() async {
    String path = join(
      await getDatabasesPath(),
      LocalDatabaseSchema.databaseName,
    );
    await databaseFactory.deleteDatabase(path);
    _database = null;
    print('🗑️ Database deleted');
  }

  /// Reset database (xóa và tạo lại)
  Future<void> resetDatabase() async {
    await deleteDatabase();
    _database = await _initDatabase();
    print('🔄 Database reset');
  }

  // ============================================================================
  // GENERIC CRUD OPERATIONS
  // ============================================================================

  /// Insert một record vào bảng
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert nhiều records vào bảng (batch)
  Future<void> insertBatch(String table, List<Map<String, dynamic>> dataList) async {
    final db = await database;
    Batch batch = db.batch();
    for (var data in dataList) {
      batch.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Query tất cả records từ bảng
  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  /// Query records với điều kiện where
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Query một record duy nhất
  Future<Map<String, dynamic>?> queryOne(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Update records
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Delete records
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// Delete tất cả records từ bảng
  Future<int> deleteAll(String table) async {
    final db = await database;
    return await db.delete(table);
  }

  /// Đếm số lượng records
  Future<int> count(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    var result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table ${where != null ? 'WHERE $where' : ''}',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Execute raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Execute raw SQL (INSERT, UPDATE, DELETE)
  Future<int> rawExecute(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawInsert(sql, arguments);
  }

  // ============================================================================
  // TRANSACTION SUPPORT
  // ============================================================================

  /// Execute multiple operations in a transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Check if table exists
  Future<bool> tableExists(String tableName) async {
    final db = await database;
    var result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  /// Get database info
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    
    // Get all tables
    var tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
    );
    
    // Get database size
    String path = join(
      await getDatabasesPath(),
      LocalDatabaseSchema.databaseName,
    );
    
    return {
      'path': path,
      'version': await db.getVersion(),
      'tables': tables.map((t) => t['name']).toList(),
      'isOpen': db.isOpen,
    };
  }

  /// Print database info (for debugging)
  Future<void> printDatabaseInfo() async {
    try {
      var info = await getDatabaseInfo();
      print('[DATABASE] 📊 ========== DATABASE INFO ==========');
      print('[DATABASE] 📂 Path: ${info['path']}');
      print('[DATABASE] 🔢 Version: ${info['version']}');
      print('[DATABASE] 🔓 Is Open: ${info['isOpen']}');
      print('[DATABASE] 📋 Tables (${(info['tables'] as List).length}):');
      for (var table in info['tables']) {
        print('[DATABASE]    - $table');
      }
      print('[DATABASE] 📊 ================================');
    } catch (e) {
      print('[DATABASE] ❌ Error getting database info: $e');
    }
  }
}

