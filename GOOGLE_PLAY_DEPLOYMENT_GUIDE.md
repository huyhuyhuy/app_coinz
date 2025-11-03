# 🚀 Google Play Deployment Guide

## 📋 Mục đích

Guide này hướng dẫn **ĐẦY ĐỦ** các bước để deploy app lên **Google Play Store (CH Play)**.

---

## ✅ CÁC BƯỚC ĐÃ HOÀN THÀNH

### 1. ✅ Application ID
- **Application ID:** `com.dongfi.dfi`
- **Namespace:** `com.dongfi.dfi`
- **Location:** `android/app/build.gradle.kts`

### 2. ✅ MainActivity Package
- **Package:** `com.dongfi.dfi`
- **Location:** `android/app/src/main/kotlin/com/dongfi/dfi/MainActivity.kt`

### 3. ✅ AdMob Configuration
- **App ID:** `ca-app-pub-4969810842586372~7884796278`
- **Location:** `android/app/src/main/AndroidManifest.xml`
- **App Open Ad:** `ca-app-pub-4969810842586372/8233130697`
- **Location:** `lib/services/app_open_ad_manager.dart`
- **Banner Ad:** `ca-app-pub-4969810842586372/8184179176`
- **Location:** `lib/services/ads_helper.dart`

---

## 📝 CÁC BƯỚC CẦN LÀM

### **BƯỚC 1: Tạo Release Keystore** ⚠️ QUAN TRỌNG

#### 1.1. Tạo keystore file

Chạy lệnh trong terminal (ở thư mục `android/app`):

```bash
cd android/app
keytool -genkey -v -keystore dongfi-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias dongfi-key-alias
```

**Thông tin cần điền:**
- **Keystore password:** (Nhập và **LƯU LẠI!**) dongfi1@
- **Re-enter password:** (Nhập lại)
- **First and last name:** DFI: hoang thanh luc
- **Organizational unit:** (Để trống hoặc nhập): dfiteam
- **Organization:** DongFi
- **City:** (Nhập) Ho Chi Minh  
- **State/Province:** (Nhập) Ho Chi Minh
- **Country code:** VN
- **Confirm:** yes
- **Key password:** (Nhập hoặc Enter để dùng cùng password)

**⚠️ QUAN TRỌNG:**
- **LƯU LẠI** keystore file: `dongfi-release-key.jks`
- **LƯU LẠI** passwords (keystore password và key password)
- **BACKUP** keystore file ở nơi an toàn
- **KHÔNG** commit keystore file vào Git!

#### 1.2. Tạo file `key.properties`

Tạo file `android/key.properties` với nội dung:

```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=dongfi-key-alias
storeFile=app/dongfi-release-key.jks
```

**⚠️ QUAN TRỌNG:**
- Thay `<your-keystore-password>` và `<your-key-password>` bằng passwords thật
- **KHÔNG** commit file này vào Git!
- Thêm vào `.gitignore`: `key.properties`, `*.jks`, `*.keystore`

#### 1.3. Cập nhật `build.gradle.kts`

File `android/app/build.gradle.kts` đã được cập nhật với signing config (nếu chưa có, cần thêm):

```kotlin
import java.util.Properties

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use {
        keystoreProperties.load(it)
    }
}

android {
    // ...
    
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

---

### **BƯỚC 2: Build Release APK/AAB**

#### 2.1. Build App Bundle (Recommended)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

#### 2.2. Build APK (Optional - for testing)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

### **BƯỚC 3: Tạo Google Play Console Account**

#### 3.1. Đăng ký Google Play Console

1. Vào https://play.google.com/console
2. Đăng nhập với Google Account
3. Đóng phí $25 (một lần duy nhất)
4. Tạo Developer Account

#### 3.2. Tạo App mới

1. Click **"Create app"**
2. Điền thông tin:
   - **App name:** DFI
   - **Default language:** Tiếng Việt
   - **App type:** App
   - **Free or Paid:** Free
3. Click **"Create"**

---

### **BƯỚC 4: Chuẩn bị Assets**

#### 4.1. App Icon

- **Size:** 512x512 px (PNG)
- **Format:** PNG
- **Location:** `assets/icons/app_icon.png`

#### 4.2. Feature Graphic

- **Size:** 1024x500 px (PNG hoặc JPG)
- **Format:** PNG hoặc JPG

#### 4.3. Screenshots

- **Phone:** 1-8 screenshots (min: 2)
  - **Size:** 16:9 hoặc 9:16
  - **Minimum:** 320 px (shortest side)
  - **Maximum:** 3840 px (longest side)
- **Format:** PNG hoặc JPG

#### 4.4. Description

- **Tiêu đề:** DFI
- **Mô tả ngắn:** (Max 80 ký tự)
- **Mô tả đầy đủ:** (Max 4000 ký tự)

---

### **BƯỚC 5: Tạo Release trên Google Play Console**

#### 5.1. Vào Production (hoặc Internal Testing)

1. Vào Google Play Console
2. Chọn app **DFI**
3. Click **"Production"** (hoặc **"Internal testing"**)
4. Click **"Create new release"**

#### 5.2. Upload AAB

1. Click **"Upload"**
2. Chọn file `app-release.aab` (từ Bước 2.1)
3. Đợi upload xong (có thể mất vài phút)

#### 5.3. Điền Release Notes

- **Release name:** 1.0.0 (hoặc version mới)
- **Release notes:** (Mô tả các thay đổi)

#### 5.4. Review và Roll out

1. Review tất cả thông tin
2. Click **"Save"**
3. Click **"Review release"**
4. Nếu OK, click **"Start rollout to Production"**

---

### **BƯỚC 6: Hoàn tất App Information**

#### 6.1. App Access

- **Restriction:** No restriction (hoặc chọn theo nhu cầu)

#### 6.2. Ads

- **Contains ads:** Yes
- **AdMob App ID:** `ca-app-pub-4969810842586372~7884796278`

#### 6.3. Content Rating

- Điền questionnaire
- Submit để Google review
- Đợi approval (có thể mất vài giờ đến vài ngày)

#### 6.4. Data Safety

- Điền form về data collection
- Khai báo các data mà app thu thập (nếu có)

#### 6.5. Privacy Policy

- **Cần có:** Privacy Policy URL
- Có thể tạo trang Privacy Policy trên website hoặc GitHub Pages

---

### **BƯỚC 7: Review và Publish**

#### 7.1. Review Checklist

- ✅ App Information đầy đủ
- ✅ Assets (icon, screenshots) đã upload
- ✅ Release đã tạo và upload AAB
- ✅ Content Rating đã approved
- ✅ Data Safety đã điền
- ✅ Privacy Policy URL đã cung cấp

#### 7.2. Submit for Review

1. Click **"Submit for review"**
2. Google sẽ review app (có thể mất 1-3 ngày)
3. Nếu có issue, Google sẽ thông báo và yêu cầu fix

#### 7.3. Publish

1. Sau khi review thành công
2. App sẽ tự động publish lên Google Play Store
3. App sẽ xuất hiện trên Google Play trong vài giờ

---

## 🔒 BẢO MẬT

### ⚠️ QUAN TRỌNG

1. **Keystore file:**
   - **BACKUP** ở nơi an toàn
   - **KHÔNG** commit vào Git
   - Nếu mất → **KHÔNG THỂ** update app!

2. **Passwords:**
   - **LƯU LẠI** keystore password và key password
   - Store ở password manager

3. **`.gitignore`:**
   ```
   key.properties
   **/*.jks
   **/*.keystore
   ```

---

## 📊 CHECKLIST

### Code Changes
- ✅ Application ID: `com.dongfi.dfi`
- ✅ MainActivity package: `com.dongfi.dfi`
- ✅ AdMob App ID: `ca-app-pub-4969810842586372~7884796278`
- ✅ App Open Ad ID: `ca-app-pub-4969810842586372/8233130697`
- ✅ Banner Ad ID: `ca-app-pub-4969810842586372/8184179176`

### Build
- ⬜ Release keystore created
- ⬜ `key.properties` created
- ⬜ `build.gradle.kts` updated with signing config
- ⬜ Release AAB built

### Google Play Console
- ⬜ Google Play Console account created
- ⬜ App created in console
- ⬜ App icon uploaded (512x512)
- ⬜ Feature graphic uploaded (1024x500)
- ⬜ Screenshots uploaded (2-8 screenshots)
- ⬜ Description filled
- ⬜ Release AAB uploaded
- ⬜ Content Rating submitted
- ⬜ Data Safety filled
- ⬜ Privacy Policy URL provided
- ⬜ App submitted for review

---

## 🚀 AFTER PUBLISH

### Monitor

1. **Google Play Console:**
   - Check crash reports
   - Check ANR (Application Not Responding)
   - Check user reviews

2. **AdMob:**
   - Check ad revenue
   - Check ad performance
   - Optimize ad placements

### Updates

Khi update app:
1. Tăng `versionCode` và `versionName` trong `pubspec.yaml`
2. Build AAB mới
3. Upload lên Google Play Console
4. Submit for review

---

## ❓ TROUBLESHOOTING

### Build Error

**Lỗi:** "Keystore file not found"
- **Fix:** Kiểm tra `key.properties` có đúng path không
- **Fix:** Đảm bảo keystore file ở đúng location

**Lỗi:** "Invalid keystore format"
- **Fix:** Đảm bảo tạo keystore với `keytool` command đúng

### Upload Error

**Lỗi:** "App bundle validation failed"
- **Fix:** Đảm bảo build AAB với `flutter build appbundle --release`
- **Fix:** Kiểm tra `applicationId` đúng chưa

### Review Rejection

**Lỗi:** "Violates Google Play policies"
- **Fix:** Đọc feedback từ Google
- **Fix:** Fix các issues và resubmit

---

## 📞 SUPPORT

Nếu có vấn đề:
1. Check Google Play Console docs
2. Check Flutter deployment docs
3. Check AdMob integration docs

---

## ✅ HOÀN TẤT!

Sau khi hoàn thành tất cả các bước trên, app sẽ được publish lên Google Play Store! 🎉

**Estimated time:** 1-3 ngày (bao gồm review time)

---

**Created:** 2025-11-03  
**Last Updated:** 2025-11-03

