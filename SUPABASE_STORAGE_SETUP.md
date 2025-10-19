# 📦 HƯỚNG DẪN SETUP SUPABASE STORAGE CHO AVATAR

## 🎯 MỤC TIÊU
Tạo Storage Bucket trên Supabase để lưu trữ ảnh avatar của user.

---

## 📋 BƯỚC 1: TẠO STORAGE BUCKET

### **1.1. Truy cập Supabase Dashboard**
1. Đăng nhập vào https://supabase.com
2. Chọn project: **app-coinz** (hoặc project của bạn)
3. Click **"Storage"** ở sidebar bên trái

### **1.2. Tạo Bucket mới**
1. Click **"New Bucket"**
2. Điền thông tin:
   - **Name:** `avatars` (tên bucket)
   - **Public bucket:** ✅ **CHECK** (để avatar public, ai cũng xem được)
   - **File size limit:** 5 MB (đủ cho avatar)
   - **Allowed MIME types:** `image/jpeg,image/png,image/webp`

3. Click **"Create bucket"**

✅ **Bucket "avatars" đã được tạo!**

---

## 📋 BƯỚC 2: SETUP STORAGE POLICIES (BẢO MẬT)

### **2.1. Policy cho UPLOAD (INSERT)**

Vào tab **Policies** của bucket `avatars`:

1. Click **"New Policy"**
2. Chọn **"For full customization"**
3. Điền:

**Policy Name:**
```
Allow users to upload their own avatar
```

**Target roles:**
```
authenticated
```

**Policy definition (INSERT):**
```sql
-- User chỉ được upload vào folder của mình
-- Path format: avatars/{user_id}/{filename}
((bucket_id = 'avatars'::text) AND 
 ((storage.foldername(name))[1] = (auth.uid())::text))
```

**Using expression:**
```sql
true
```

4. Click **"Review"** → **"Save policy"**

---

### **2.2. Policy cho UPDATE**

1. Click **"New Policy"**
2. Chọn **"For full customization"**
3. Điền:

**Policy Name:**
```
Allow users to update their own avatar
```

**Target roles:**
```
authenticated
```

**Policy definition (UPDATE):**
```sql
((bucket_id = 'avatars'::text) AND 
 ((storage.foldername(name))[1] = (auth.uid())::text))
```

4. Click **"Save policy"**

---

### **2.3. Policy cho DELETE**

1. Click **"New Policy"**
2. Điền tương tự UPDATE:

**Policy Name:**
```
Allow users to delete their own avatar
```

**Policy definition (DELETE):**
```sql
((bucket_id = 'avatars'::text) AND 
 ((storage.foldername(name))[1] = (auth.uid())::text))
```

---

### **2.4. Policy cho SELECT (READ)**

**Không cần tạo!** Vì bucket đã public → ai cũng đọc được.

---

## 📋 BƯỚC 3: TEST BUCKET

### **3.1. Upload thử file**
1. Vào Storage → bucket `avatars`
2. Click **"Upload file"**
3. Chọn 1 ảnh bất kỳ
4. Upload vào folder `test/`
5. Click vào file → Copy URL
6. Paste URL vào browser → Nếu thấy ảnh → ✅ SUCCESS!

### **3.2. URL format**
```
https://fawavpodkrkgmasvuabf.supabase.co/storage/v1/object/public/avatars/test/image.jpg
```

Format:
```
{SUPABASE_URL}/storage/v1/object/public/{BUCKET_NAME}/{PATH}/{FILENAME}
```

---

## 📋 BƯỚC 4: LƯU Ý QUAN TRỌNG

### **File Structure trong bucket:**
```
avatars/
├── {user_id_1}/
│   └── avatar.jpg
├── {user_id_2}/
│   └── avatar.jpg
└── {user_id_3}/
    └── avatar.jpg
```

**Tại sao dùng user_id làm folder?**
- ✅ Mỗi user có folder riêng
- ✅ Security: Policy check folder name = user_id
- ✅ Dễ quản lý
- ✅ Tránh conflict tên file

---

## 📋 BƯỚC 5: TESTING

### **Test 1: Upload ảnh**
```dart
// Trong Flutter app
final file = File('path/to/image.jpg');
final avatarUrl = await storageService.uploadAvatar(
  userId: 'user-123',
  file: file,
);

print('Avatar URL: $avatarUrl');
```

Expected:
```
https://.../storage/v1/object/public/avatars/user-123/avatar.jpg
```

### **Test 2: Delete ảnh cũ**
```dart
await storageService.deleteAvatar(userId: 'user-123');
```

### **Test 3: Access từ browser**
Paste URL vào browser → Nếu thấy ảnh → ✅ SUCCESS!

---

## 🔒 SECURITY CHECKLIST

- ✅ **Public bucket:** Ảnh avatar public, ai cũng xem được
- ✅ **Upload policy:** Chỉ upload vào folder của mình
- ✅ **Update policy:** Chỉ update ảnh của mình
- ✅ **Delete policy:** Chỉ delete ảnh của mình
- ✅ **Size limit:** 5MB (đủ cho avatar)
- ✅ **MIME types:** Chỉ cho phép image/jpeg, png, webp

---

## 📊 STORAGE LIMITS (FREE PLAN)

- **Storage:** 1GB
- **Bandwidth:** 2GB/month
- **File uploads:** Unlimited

**Ước tính:**
- 1 avatar ~200KB
- 1GB = ~5,000 avatars
- 2GB bandwidth = ~10,000 downloads/month

→ **ĐỦ** cho giai đoạn đầu!

---

## ✅ HOÀN TẤT SETUP!

Sau khi làm xong các bước trên:
- ✅ Bucket `avatars` đã tạo
- ✅ Policies đã setup
- ✅ Public access enabled
- ✅ Ready để upload từ Flutter app!

---

## 📱 ANDROID CONFIG (ĐÃ ĐƯỢC TỰ ĐỘNG THÊM)

**File:** `android/app/src/main/AndroidManifest.xml`

### **Permissions:**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### **UCrop Activity:**
```xml
<activity
    android:name="com.yalantis.ucrop.UCropActivity"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar"
    android:exported="false" />
```

✅ **ĐÃ ĐƯỢC TỰ ĐỘNG CONFIG - KHÔNG CẦN LÀM GÌ THÊM!**

---

**Tiếp theo:** Chạy `flutter run` và test tính năng!

---

**Tất cả đã ready!** 🚀

