# 📚 HƯỚNG DẪN SETUP DATABASE CHO APP COINZ

## 📋 MỤC LỤC
1. [Tổng quan](#tổng-quan)
2. [Setup Local Database (SQLite)](#setup-local-database-sqlite)
3. [Setup Server Database (Supabase)](#setup-server-database-supabase)
4. [Testing Database](#testing-database)
5. [Troubleshooting](#troubleshooting)

---

## 🎯 TỔNG QUAN

### Kiến trúc Database
App Coinz sử dụng kiến trúc **Offline-First** với 2 tầng database:

1. **Local Database (SQLite)**
   - Lưu trữ dữ liệu trên thiết bị
   - Hoạt động offline
   - Sync với server khi có internet

2. **Server Database (Supabase PostgreSQL)**
   - Lưu trữ tập trung
   - Real-time sync
   - Backup và recovery

### Files đã tạo
```
app_coinz/
├── lib/
│   ├── database/
│   │   ├── local_database_schema.dart  ✅ Schema cho SQLite
│   │   └── database_helper.dart        ✅ Helper class
│   └── models/
│       ├── user_model.dart             ✅ User model
│       ├── wallet_model.dart           ✅ Wallet model
│       ├── mining_session_model.dart   ✅ Mining session model
│       └── models.dart                 ✅ Export file
├── database_schema_complete.sql        ✅ SQL cho Supabase
└── DATABASE_SETUP_GUIDE.md            ✅ File này

```

---

## 📱 SETUP LOCAL DATABASE (SQLite)

### Bước 1: Cài đặt Dependencies

Đã thêm vào `pubspec.yaml`:
```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.3
  path_provider: ^2.1.1
```

**Chạy lệnh:**
```bash
cd app_coinz
flutter pub get
```

### Bước 2: Khởi tạo Database

Database sẽ tự động được khởi tạo khi app chạy lần đầu.

**Sử dụng DatabaseHelper:**
```dart
import 'package:app_coinz/database/database_helper.dart';

// Lấy database instance
final db = await DatabaseHelper.instance.database;

// Hoặc sử dụng helper methods
final dbHelper = DatabaseHelper.instance;
```

### Bước 3: Test Database

Tạo file test: `lib/test_database.dart`
```dart
import 'package:app_coinz/database/database_helper.dart';
import 'package:app_coinz/models/models.dart';
import 'package:uuid/uuid.dart';

Future<void> testDatabase() async {
  final dbHelper = DatabaseHelper.instance;
  
  // Print database info
  await dbHelper.printDatabaseInfo();
  
  // Test insert user
  final user = UserModel(
    userId: Uuid().v4(),
    email: 'test@example.com',
    passwordHash: 'hashed_password',
    fullName: 'Test User',
    referralCode: 'REF12345',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  
  await dbHelper.insert('users', user.toMap());
  print('✅ User inserted');
  
  // Test query
  final users = await dbHelper.queryAll('users');
  print('📊 Users: $users');
}
```

### Bước 4: Integrate vào App

Khởi tạo database trong `main.dart`:
```dart
import 'package:app_coinz/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseHelper.instance.database;
  print('✅ Database initialized');
  
  runApp(MyApp());
}
```

---

## 🌐 SETUP SERVER DATABASE (Supabase)

### Bước 1: Tạo Supabase Account

1. Truy cập: https://supabase.com
2. Click **"Start your project"**
3. Sign up với GitHub hoặc Email
4. Xác nhận email

### Bước 2: Tạo Project Mới

1. Click **"New Project"**
2. Điền thông tin:
   - **Name**: `app-coinz`
   - **Database Password**: Tạo password mạnh (LƯU LẠI!)
   - **Region**: Chọn gần nhất (Singapore cho VN)
   - **Pricing Plan**: Free
3. Click **"Create new project"**
4. Đợi 2-3 phút để setup

### Bước 3: Chạy SQL Schema

1. Vào project dashboard
2. Click **"SQL Editor"** ở sidebar
3. Click **"New query"**
4. Copy toàn bộ nội dung file `database_schema_complete.sql`
5. Paste vào editor
6. Click **"Run"** (hoặc Ctrl+Enter)
7. Kiểm tra kết quả: "Success. No rows returned"

### Bước 4: Verify Tables

1. Click **"Table Editor"** ở sidebar
2. Kiểm tra các bảng đã tạo:
   - ✅ users
   - ✅ user_profiles
   - ✅ admins
   - ✅ kyc_submissions
   - ✅ mining_sessions
   - ✅ mining_stats
   - ✅ wallets
   - ✅ transactions
   - ✅ withdrawal_requests
   - ✅ friends
   - ✅ referrals
   - ✅ referral_rewards
   - ✅ system_settings
   - ✅ notifications
   - ✅ news
   - ✅ app_versions

### Bước 5: Lấy API Keys

1. Click **"Settings"** (icon bánh răng)
2. Click **"API"**
3. Copy các thông tin:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGc...`
   - **service_role key**: `eyJhbGc...` (GIỮ BÍ MẬT!)

### Bước 6: Setup Row Level Security (RLS)

Supabase tự động enable RLS. Để test, tạm thời disable:

```sql
-- Disable RLS cho testing (CHỈ DÙNG KHI DEVELOPMENT)
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE wallets DISABLE ROW LEVEL SECURITY;
ALTER TABLE mining_sessions DISABLE ROW LEVEL SECURITY;
-- ... (các bảng khác)
```

**LƯU Ý**: Sau khi test xong, phải enable lại và tạo policies!

### Bước 7: Cài đặt Supabase Flutter Package

Thêm vào `pubspec.yaml`:
```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

Chạy:
```bash
flutter pub get
```

### Bước 8: Initialize Supabase trong App

Tạo file `lib/services/supabase_service.dart`:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'YOUR_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
}
```

Update `main.dart`:
```dart
import 'package:app_coinz/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  print('✅ Supabase initialized');
  
  // Initialize local database
  await DatabaseHelper.instance.database;
  print('✅ Local database initialized');
  
  runApp(MyApp());
}
```

---

## 🧪 TESTING DATABASE

### Test Local Database

```dart
// Test insert
final user = UserModel(...);
await DatabaseHelper.instance.insert('users', user.toMap());

// Test query
final users = await DatabaseHelper.instance.queryAll('users');
print('Users: ${users.length}');

// Test update
await DatabaseHelper.instance.update(
  'users',
  {'full_name': 'Updated Name'},
  where: 'user_id = ?',
  whereArgs: [userId],
);

// Test delete
await DatabaseHelper.instance.delete(
  'users',
  where: 'user_id = ?',
  whereArgs: [userId],
);
```

### Test Supabase

```dart
import 'package:app_coinz/services/supabase_service.dart';

// Test insert
final response = await SupabaseService.client
    .from('users')
    .insert({
      'email': 'test@example.com',
      'password_hash': 'hashed',
      'full_name': 'Test User',
    })
    .select();

print('Inserted: $response');

// Test query
final users = await SupabaseService.client
    .from('users')
    .select();

print('Users: $users');
```

---

## 🔧 TROUBLESHOOTING

### Lỗi: "Database is locked"
**Giải pháp**: Đóng tất cả connections trước khi thao tác
```dart
await DatabaseHelper.instance.close();
```

### Lỗi: "Table already exists"
**Giải pháp**: Reset database
```dart
await DatabaseHelper.instance.resetDatabase();
```

### Lỗi: Supabase "Invalid API key"
**Giải pháp**: 
1. Kiểm tra lại API key
2. Đảm bảo không có khoảng trắng thừa
3. Kiểm tra project URL đúng

### Lỗi: "Row Level Security"
**Giải pháp**: Tạm disable RLS hoặc tạo policies
```sql
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
```

---

## 📝 NEXT STEPS

Sau khi setup xong database:

1. ✅ Test local database
2. ✅ Test Supabase connection
3. ⏭️ Tạo Repository classes
4. ⏭️ Implement sync logic
5. ⏭️ Tạo mining engine
6. ⏭️ Implement wallet features

---

## 📞 HỖ TRỢ

Nếu gặp vấn đề:
1. Kiểm tra logs trong console
2. Xem file `troubleshooting.md`
3. Hỏi AI assistant

---

**Chúc bạn setup thành công! 🎉**

