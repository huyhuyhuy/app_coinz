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
 `pubspec.yaml`:
```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.3
  path_provider: ^2.1.1
```

**DatabaseHelper:**
```dart
import 'package:app_coinz/database/database_helper.dart';


## SETUP SERVER DATABASE (Supabase)

### Bước 1: Tạo Supabase Account

1. Truy cập: https://supabase.com
2. Click **"Start your project"**
3. Sign up với GitHub hoặc Email
4. Xác nhận email

### Bước 2: Tạo Project Mới

1. Click **"New Project"**
2. Điền thông tin:
   - **Name**: `app-coinz`
   - **Database Password**: Tạo password mạnh (LƯU LẠI!) app_coinz123@ app_coinz123@
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
   - **Project URL**: https://otncsmyfaaomszzmfkxt.supabase.co
   - **anon public key**: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90bmNzbXlmYWFvbXN6em1ma3h0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3MzkzNTksImV4cCI6MjA3NTMxNTM1OX0.fLQtLqHiJJLLFENKk5w1TazKD4Q22Aca4TP23CcVMK0
   - **service_role key**: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90bmNzbXlmYWFvbXN6em1ma3h0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTczOTM1OSwiZXhwIjoyMDc1MzE1MzU5fQ.7Qlz63y77PksG_fqxqPcyAodmdBJ-w9NdIBsPSIN_ls

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
