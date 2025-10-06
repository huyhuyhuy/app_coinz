# 📱 CÁCH XEM LOGS KHI CHẠY TRÊN THIẾT BỊ ANDROID

## 🔍 VẤN ĐỀ
Khi chạy app trên thiết bị Android (Samsung A107F), bạn không thấy logs database trong console.

## ✅ GIẢI PHÁP

### Cách 1: Xem logs trong VS Code / Android Studio

#### Nếu dùng VS Code:
1. Mở Terminal trong VS Code
2. Chạy lệnh:
```bash
flutter run --verbose
```

3. Hoặc sau khi app đã chạy, xem logs bằng:
```bash
flutter logs
```

4. Filter logs để chỉ xem database logs:
```bash
flutter logs | findstr "DATABASE"
```

#### Nếu dùng Android Studio:
1. Mở tab **"Run"** ở dưới cùng
2. Click vào **"Logcat"**
3. Trong ô filter, gõ: `DATABASE`
4. Hoặc gõ: `flutter`

### Cách 2: Dùng ADB (Android Debug Bridge)

```bash
# Xem tất cả logs
adb logcat

# Filter chỉ xem Flutter logs
adb logcat | findstr "flutter"

# Filter chỉ xem DATABASE logs
adb logcat | findstr "DATABASE"

# Clear logs cũ trước khi xem
adb logcat -c
adb logcat | findstr "DATABASE"
```

### Cách 3: Xem logs trong App (KHUYẾN NGHỊ)

Tôi đã tạo một **Test Database Screen** trong app:

1. Chạy app trên thiết bị
2. Vào tab **Profile** (icon người dùng)
3. Click vào **"Test Database"**
4. Click button **"Run Tests"**
5. Xem logs trực tiếp trên màn hình điện thoại!

**Ưu điểm**:
- ✅ Không cần console
- ✅ Xem logs trực tiếp trên điện thoại
- ✅ Test database ngay trong app
- ✅ Dễ debug

---

## 🔧 KIỂM TRA DATABASE

### Bước 1: Chạy app
```bash
cd app_coinz
flutter run
```

### Bước 2: Xem logs khởi tạo
Trong console, bạn sẽ thấy:
```
[DATABASE] 🚀 Starting initialization...
[DATABASE] 📂 Database path: /data/user/0/com.example.app_coinz/databases/app_coinz_local.db
[DATABASE] 🔨 Creating database version 1...
[DATABASE] ✅ Table 1/9 created
[DATABASE] ✅ Table 2/9 created
...
[DATABASE] ✅ Created 26 indexes
[DATABASE] ✅ Database created successfully!
[DATABASE] 📖 Database opened: /data/user/0/...
[DATABASE] ✅ Database opened successfully
[DATABASE] 📊 ========== DATABASE INFO ==========
[DATABASE] 📂 Path: /data/user/0/...
[DATABASE] 🔢 Version: 1
[DATABASE] 🔓 Is Open: true
[DATABASE] 📋 Tables (9):
[DATABASE]    - users
[DATABASE]    - wallets
[DATABASE]    - mining_sessions
[DATABASE]    - mining_stats
[DATABASE]    - friends
[DATABASE]    - transactions
[DATABASE]    - notifications
[DATABASE]    - news_cache
[DATABASE]    - settings
[DATABASE] 📊 ================================
✅ [DATABASE] Database initialized successfully!
```

### Bước 3: Test trong app
1. Vào **Profile** tab
2. Click **"Test Database"**
3. Click **"Run Tests"**
4. Xem kết quả trên màn hình

---

## ❌ NẾU VẪN KHÔNG THẤY LOGS

### Kiểm tra 1: App có chạy được không?
```bash
flutter devices
```
Phải thấy thiết bị Samsung A107F trong danh sách.

### Kiểm tra 2: Có lỗi compile không?
```bash
flutter analyze
```

### Kiểm tra 3: Build lại app
```bash
flutter clean
flutter pub get
flutter run
```

### Kiểm tra 4: Xem logs chi tiết
```bash
flutter run --verbose
```

### Kiểm tra 5: Dùng Test Database Screen
- Vào Profile tab
- Click "Test Database"
- Xem logs trực tiếp trên màn hình

---

## 🎯 LOGS QUAN TRỌNG CẦN TÌM

Tìm các dòng log này:

1. **Khởi tạo database**:
```
[DATABASE] 🚀 Starting initialization...
```

2. **Đường dẫn database**:
```
[DATABASE] 📂 Database path: ...
```

3. **Tạo tables**:
```
[DATABASE] ✅ Table 1/9 created
```

4. **Database info**:
```
[DATABASE] 📊 ========== DATABASE INFO ==========
```

5. **Lỗi (nếu có)**:
```
[DATABASE] ❌ Error: ...
```

---

## 💡 TIPS

### Tip 1: Filter logs hiệu quả
```bash
# Windows PowerShell
flutter logs | Select-String "DATABASE"

# Windows CMD
flutter logs | findstr "DATABASE"

# Linux/Mac
flutter logs | grep "DATABASE"
```

### Tip 2: Save logs ra file
```bash
flutter logs > logs.txt
```

Sau đó mở file `logs.txt` để xem.

### Tip 3: Xem logs real-time
```bash
flutter logs --clear
```

### Tip 4: Dùng Test Database Screen
Đây là cách **DỄ NHẤT** và **NHANH NHẤT**!
- Không cần console
- Xem logs trực tiếp trên điện thoại
- Test database ngay lập tức

---

## 📞 NẾU VẪN GẶP VẤN ĐỀ

1. Chụp màn hình console
2. Chụp màn hình Test Database Screen
3. Copy logs và gửi cho tôi
4. Cho biết:
   - Thiết bị: Samsung A107F
   - Android version: ?
   - Flutter version: `flutter --version`
   - Có lỗi gì không?

---

## ✅ CHECKLIST

- [ ] Đã chạy `flutter pub get`
- [ ] Đã chạy `flutter run`
- [ ] Đã thử xem logs bằng `flutter logs`
- [ ] Đã thử filter logs: `flutter logs | findstr "DATABASE"`
- [ ] Đã vào Profile tab → Test Database
- [ ] Đã click "Run Tests"
- [ ] Đã xem logs trên màn hình điện thoại

---

**Chúc bạn thành công! 🚀**

