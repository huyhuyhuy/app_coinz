# 📱 HƯỚNG DẪN BUILD VÀ XUẤT BẢN APP LÊN APP STORE (Mac Mini)

Hướng dẫn chi tiết từng bước cho người chưa từng dùng Mac Mini, từ cài đặt đến xuất bản app lên App Store.

---

## 📋 MỤC LỤC

1. [Chuẩn bị](#1-chuẩn-bị)
2. [Cài đặt Xcode](#2-cài-đặt-xcode)
3. [Cài đặt Flutter](#3-cài-đặt-flutter)
4. [Cài đặt CocoaPods](#4-cài-đặt-cocoapods)
5. [Clone code từ Git](#5-clone-code-từ-git)
6. [Cài đặt Dependencies](#6-cài-đặt-dependencies)
7. [Cấu hình Signing trong Xcode](#7-cấu-hình-signing-trong-xcode)
8. [Build App](#8-build-app)
9. [Archive và Upload lên App Store Connect](#9-archive-và-upload-lên-app-store-connect)
10. [Submit để Review](#10-submit-để-review)
11. [Xử lý Lỗi Thường Gặp](#11-xử-lý-lỗi-thường-gặp)

---

## 1. CHUẨN BỊ

### 1.1. Kiểm tra tài khoản Apple Developer

✅ **Bạn đã có:**
- Tài khoản Apple Developer ($99/năm)
- Đã đăng ký và thanh toán thành công

### 1.2. Thông tin cần chuẩn bị

- **Bundle ID**: `com.dongfi.dfi` (đã cấu hình sẵn trong code)
- **App Name**: `DongFi`
- **Apple ID**: Email đăng nhập Apple Developer của bạn
- **Git Repository URL**: URL của repository chứa code (GitHub, GitLab, Bitbucket, etc.)

---

## 2. CÀI ĐẶT XCODE

### Bước 2.1: Mở App Store trên Mac Mini

1. Click vào biểu tượng **App Store** trên Dock (thanh dưới cùng màn hình)
2. Hoặc tìm "App Store" trong Spotlight (nhấn `Cmd + Space`, gõ "App Store")

### Bước 2.2: Tìm và cài đặt Xcode

1. Trong App Store, tìm kiếm: **"Xcode"**
2. Click vào **"Get"** hoặc **"Install"** (miễn phí, nhưng cần đăng nhập Apple ID)
3. **Lưu ý**: Xcode rất lớn (~15-20GB), cài đặt sẽ mất 30-60 phút tùy tốc độ mạng
4. Đợi Xcode tải và cài đặt xong

### Bước 2.3: Mở Xcode lần đầu và chấp nhận license

1. Mở **Finder** (biểu tượng mặt cười trên Dock)
2. Vào **Applications** (Ứng dụng)
3. Tìm và mở **Xcode**
4. Lần đầu mở sẽ có popup yêu cầu chấp nhận license:
   - Click **"Agree"** (Đồng ý)
   - Nhập mật khẩu Mac của bạn
5. Xcode sẽ tự động cài đặt thêm các components cần thiết (mất 5-10 phút)

### Bước 2.4: Cài đặt Command Line Tools

1. Mở **Terminal** (tìm trong Spotlight: `Cmd + Space`, gõ "Terminal")
2. Chạy lệnh:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   ```
3. Nhập mật khẩu Mac của bạn (khi gõ sẽ không hiện ký tự, cứ gõ bình thường và Enter)
4. Chạy tiếp:
   ```bash
   sudo xcodebuild -license accept
   ```
5. Nhập mật khẩu lần nữa

### Bước 2.5: Kiểm tra Xcode đã cài đặt đúng

Trong Terminal, chạy:
```bash
xcodebuild -version
```

Kết quả sẽ hiển thị phiên bản Xcode (ví dụ: `Xcode 15.0` hoặc `Xcode 16.0`)

---

## 3. CÀI ĐẶT FLUTTER

### Bước 3.1: Tải Flutter SDK

1. Mở trình duyệt Safari (hoặc Chrome) trên Mac Mini
2. Truy cập: https://docs.flutter.dev/get-started/install/macos
3. Tải Flutter SDK cho macOS:
   - Click vào link **"Download Flutter SDK"**
   - Chọn file `.zip` (không chọn `git clone`)
   - File sẽ tự động tải về thư mục **Downloads**

### Bước 3.2: Giải nén và di chuyển Flutter

1. Mở **Finder**
2. Vào thư mục **Downloads**
3. Tìm file `flutter_macos_xxx.zip` (xxx là số phiên bản)
4. Double-click để giải nén (sẽ tạo thư mục `flutter`)
5. Di chuyển thư mục `flutter` vào thư mục chính:
   - Kéo thả thư mục `flutter` từ Downloads vào **Home** (biểu tượng ngôi nhà trên sidebar)
   - Hoặc copy vào: `/Users/[tên-user-của-bạn]/flutter`

### Bước 3.3: Thêm Flutter vào PATH

1. Mở **Terminal**
2. Chạy lệnh để mở file cấu hình:
   ```bash
   nano ~/.zshrc
   ```
   (Nếu dùng bash thay vì zsh, dùng: `nano ~/.bash_profile`)

3. Thêm dòng này vào cuối file:
   ```bash
   export PATH="$PATH:$HOME/flutter/bin"
   ```

4. Lưu file:
   - Nhấn `Ctrl + O` (chữ O, không phải số 0)
   - Nhấn `Enter` để xác nhận
   - Nhấn `Ctrl + X` để thoát

5. Áp dụng cấu hình:
   ```bash
   source ~/.zshrc
   ```
   (Hoặc `source ~/.bash_profile` nếu dùng bash)

### Bước 3.4: Kiểm tra Flutter đã cài đặt đúng

Chạy lệnh:
```bash
flutter --version
```

Kết quả sẽ hiển thị phiên bản Flutter (ví dụ: `Flutter 3.24.0`)

### Bước 3.5: Chạy Flutter Doctor để kiểm tra môi trường

Chạy lệnh:
```bash
flutter doctor
```

Kết quả sẽ hiển thị các thành phần đã cài đặt. Bạn sẽ thấy:
- ✅ Flutter (installed)
- ✅ Android toolchain (nếu cần, nhưng không bắt buộc cho iOS)
- ✅ Xcode (installed)
- ⚠️ CocoaPods (chưa cài - sẽ cài ở bước tiếp theo)

---

## 4. CÀI ĐẶT COCOAPODS

CocoaPods là công cụ quản lý dependencies cho iOS.

### Bước 4.1: Cài đặt CocoaPods

Trong Terminal, chạy:
```bash
sudo gem install cocoapods
```

Nhập mật khẩu Mac của bạn khi được hỏi.

**Lưu ý**: Nếu gặp lỗi về quyền, có thể cần cài đặt Homebrew trước (xem phần Xử lý Lỗi).

### Bước 4.2: Kiểm tra CocoaPods đã cài đặt

Chạy:
```bash
pod --version
```

Kết quả sẽ hiển thị phiên bản (ví dụ: `1.15.0`)

---

## 5. CLONE CODE TỪ GIT

### Bước 5.1: Mở Terminal và chuyển đến thư mục làm việc

1. Mở **Terminal**
2. Chuyển đến thư mục bạn muốn lưu code (ví dụ: Desktop hoặc Documents):
   ```bash
   cd ~/Desktop
   ```
   (Hoặc `cd ~/Documents` nếu muốn lưu trong Documents)

### Bước 5.2: Clone repository

Chạy lệnh clone (thay `[URL-REPOSITORY]` bằng URL thật của bạn):
```bash
git clone [URL-REPOSITORY]
```

**Ví dụ:**
- GitHub: git clone https://github.com/huyhuyhuy/app_coinz.git


### Bước 5.3: Chuyển vào thư mục project
Sau khi clone xong, chuyển vào thư mục:
```bash
cd app_coinz/app_coinz
```

(Lưu ý: có thể cần `cd app_coinz` hoặc `cd app_coinz/app_coinz` tùy cấu trúc repository của bạn)

### Bước 5.4: Kiểm tra code đã clone đúng

Chạy:
```bash
ls -la
```

Bạn sẽ thấy các file như `pubspec.yaml`, `lib/`, `ios/`, `android/`, etc.

---

## 6. CÀI ĐẶT DEPENDENCIES

### Bước 6.1: Cài đặt Flutter dependencies

Trong Terminal, đảm bảo đang ở thư mục `app_coinz/app_coinz`, chạy:
```bash
flutter pub get
```

Lệnh này sẽ tải và cài đặt tất cả packages trong `pubspec.yaml`.

### Bước 6.2: Cài đặt iOS dependencies (CocoaPods)

1. Chuyển vào thư mục iOS:
   ```bash
   cd ios
   ```

2. Cài đặt pods:
   ```bash
   pod install
   ```

   **Lưu ý**: Lần đầu chạy sẽ mất 5-10 phút để tải các dependencies.

3. Sau khi xong, quay lại thư mục gốc:
   ```bash
   cd ..
   ```

### Bước 6.3: Kiểm tra Flutter Doctor một lần nữa

Chạy:
```bash
flutter doctor
```

Tất cả các mục nên hiển thị ✅ (hoặc ít nhất Xcode và CocoaPods phải ✅)

---

## 7. CẤU HÌNH SIGNING TRONG XCODE

Đây là bước quan trọng để app có thể build và upload lên App Store.

### Bước 7.1: Mở project trong Xcode

1. Trong Terminal, đảm bảo đang ở thư mục `app_coinz/app_coinz`
2. Mở project iOS trong Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
   
   **LƯU Ý**: Phải mở `.xcworkspace`, KHÔNG phải `.xcodeproj`!

3. Xcode sẽ mở và hiển thị project

### Bước 7.2: Chọn target Runner

1. Ở sidebar bên trái, click vào **"Runner"** (biểu tượng màu xanh ở trên cùng)
2. Ở giữa màn hình, chọn tab **"Signing & Capabilities"**

### Bước 7.3: Cấu hình Team và Bundle Identifier

1. **Team**: 
   - Click dropdown "Team"
   - Chọn team Apple Developer của bạn (sẽ hiển thị tên hoặc email)
   - Nếu chưa thấy, click **"Add Account..."** và đăng nhập Apple ID của bạn

2. **Bundle Identifier**:
   - Đảm bảo là: `com.dongfi.dfi`
   - Nếu khác, sửa lại cho đúng

3. **Automatically manage signing**:
   - ✅ Đảm bảo checkbox này được BẬT (checked)

4. Xcode sẽ tự động tạo **Provisioning Profile** và **Signing Certificate**
   - Nếu thành công, bạn sẽ thấy dấu ✅ xanh
   - Nếu có lỗi, xem phần Xử lý Lỗi

### Bước 7.4: Chọn scheme và device

1. Ở thanh trên cùng Xcode, bên trái có dropdown hiển thị:
   - **Scheme**: Chọn **"Runner"**
   - **Device**: Chọn **"Any iOS Device (arm64)"** (KHÔNG chọn simulator)

---

## 8. BUILD APP

### Bước 8.1: Build bằng Flutter (Khuyến nghị)

Trong Terminal, đảm bảo đang ở thư mục `app_coinz/app_coinz`, chạy:
```bash
flutter build ios --release
```

Lệnh này sẽ:
- Build app ở chế độ release
- Tạo file `.app` trong `build/ios/iphoneos/`

**Lưu ý**: Build lần đầu sẽ mất 5-10 phút.

### Bước 8.2: Kiểm tra build thành công

Sau khi build xong, bạn sẽ thấy:
```
✓ Built build/ios/iphoneos/Runner.app
```

---

## 9. ARCHIVE VÀ UPLOAD LÊN APP STORE CONNECT

### Bước 9.1: Mở Xcode và chọn Product > Archive

1. Mở Xcode (đã mở từ bước 7.1)
2. Trên thanh menu, chọn: **Product** → **Archive**
3. Xcode sẽ build lại và tạo Archive
4. Quá trình này mất 3-5 phút

### Bước 9.2: Kiểm tra Archive thành công

Sau khi Archive xong, cửa sổ **Organizer** sẽ tự động mở:
- Bạn sẽ thấy Archive vừa tạo với ngày giờ hiện tại
- Status sẽ hiển thị **"Ready to Submit"** hoặc **"Ready to Distribute"**

### Bước 9.3: Upload lên App Store Connect

1. Trong cửa sổ Organizer, chọn Archive vừa tạo
2. Click nút **"Distribute App"** (màu xanh, ở bên phải)
3. Chọn **"App Store Connect"** → Click **"Next"**
4. Chọn **"Upload"** → Click **"Next"**
5. Chọn **"Automatically manage signing"** → Click **"Next"**
6. Xem lại thông tin → Click **"Upload"**
7. Xcode sẽ upload app lên App Store Connect
   - Quá trình này mất 5-15 phút tùy tốc độ mạng
   - Bạn sẽ thấy progress bar

### Bước 9.4: Kiểm tra upload thành công

1. Sau khi upload xong, bạn sẽ thấy thông báo **"Upload Successful"**
2. Mở trình duyệt, truy cập: https://appstoreconnect.apple.com
3. Đăng nhập bằng Apple ID Developer của bạn
4. Vào **"My Apps"** → Tìm app **"DongFi"** (hoặc tạo mới nếu chưa có)
5. Vào tab **"TestFlight"** hoặc **"App Store"**
6. Bạn sẽ thấy build vừa upload (có thể đang ở trạng thái "Processing")

---

## 10. SUBMIT ĐỂ REVIEW

### Bước 10.1: Tạo App trong App Store Connect (nếu chưa có)

1. Truy cập: https://appstoreconnect.apple.com
2. Click **"My Apps"** → **"+"** → **"New App"**
3. Điền thông tin:
   - **Platform**: iOS
   - **Name**: DongFi
   - **Primary Language**: Vietnamese hoặc English
   - **Bundle ID**: Chọn `com.dongfi.dfi` (phải match với Bundle ID trong Xcode)
   - **SKU**: `dongfi-ios` (hoặc bất kỳ mã nào bạn muốn)
4. Click **"Create"**

### Bước 10.2: Đợi build được process xong

- Build vừa upload sẽ ở trạng thái **"Processing"** trong 10-30 phút
- Sau khi xong, status sẽ đổi thành **"Ready to Submit"**

### Bước 10.3: Điền thông tin App Store Listing

1. Vào tab **"App Store"** trong App Store Connect
2. Điền các thông tin bắt buộc:
   - **App Name**: DongFi
   - **Subtitle**: (tùy chọn)
   - **Description**: Mô tả app của bạn
   - **Keywords**: Từ khóa tìm kiếm
   - **Support URL**: URL hỗ trợ
   - **Marketing URL**: (tùy chọn)
   - **Privacy Policy URL**: URL chính sách bảo mật (BẮT BUỘC)
   - **Category**: Chọn danh mục phù hợp
   - **App Icon**: Upload icon 1024x1024px
   - **Screenshots**: Upload ít nhất 1 screenshot cho iPhone

### Bước 10.4: Chọn build và Submit

1. Scroll xuống phần **"Build"**
2. Click **"+ Version or Platform"** → Chọn build vừa upload
3. Điền thông tin **"Version Information"**:
   - **Version**: `1.0.3` (hoặc version hiện tại trong `pubspec.yaml`)
   - **What's New in This Version**: Mô tả các thay đổi
4. Trả lời các câu hỏi **"App Review Information"**:
   - **Contact Information**: Email và số điện thoại
   - **Demo Account**: (nếu cần)
   - **Notes**: Ghi chú cho reviewer (nếu cần)
5. Click **"Add for Review"**
6. Xác nhận và click **"Submit for Review"**

### Bước 10.5: Theo dõi trạng thái Review

- App sẽ ở trạng thái **"Waiting for Review"**
- Apple sẽ review trong 1-3 ngày làm việc
- Bạn sẽ nhận email khi có kết quả

---

## 11. XỬ LÝ LỖI THƯỜNG GẶP

### Lỗi 11.1: "Command Line Tools not found"

**Nguyên nhân**: Chưa cài đặt Command Line Tools

**Giải pháp**:
```bash
sudo xcode-select --install
```

Sau đó làm lại bước 2.4.

---

### Lỗi 11.2: "CocoaPods installation failed"

**Nguyên nhân**: Quyền truy cập hoặc Ruby version

**Giải pháp 1**: Cài đặt Homebrew trước:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Sau đó cài CocoaPods:
```bash
brew install cocoapods
```

**Giải pháp 2**: Dùng rbenv để quản lý Ruby version (nâng cao)

---

### Lỗi 11.3: "No signing certificate found"

**Nguyên nhân**: Chưa đăng nhập Apple ID trong Xcode hoặc Team chưa được chọn

**Giải pháp**:
1. Mở Xcode → **Preferences** (hoặc `Cmd + ,`)
2. Vào tab **"Accounts"**
3. Click **"+"** → Chọn **"Apple ID"**
4. Đăng nhập bằng Apple ID Developer của bạn
5. Quay lại bước 7.3 và chọn Team

---

### Lỗi 11.4: "Bundle identifier is already in use"

**Nguyên nhân**: Bundle ID `com.dongfi.dfi` đã được sử dụng bởi app khác

**Giải pháp**:
1. Kiểm tra trong App Store Connect xem Bundle ID đã được đăng ký chưa
2. Nếu chưa, tạo App mới trong App Store Connect với Bundle ID này
3. Nếu đã có app khác dùng, cần đổi Bundle ID (không khuyến nghị)

---

### Lỗi 11.5: "Pod install failed"

**Nguyên nhân**: Lỗi khi cài đặt CocoaPods dependencies

**Giải pháp**:
1. Xóa cache:
   ```bash
   cd ios
   rm -rf Pods Podfile.lock
   pod cache clean --all
   ```

2. Cài lại:
   ```bash
   pod install --repo-update
   ```

---

### Lỗi 11.6: "Flutter doctor shows issues"

**Nguyên nhân**: Một số components chưa được cài đặt đầy đủ

**Giải pháp**:
Chạy:
```bash
flutter doctor -v
```

Xem chi tiết lỗi và làm theo hướng dẫn. Thường thì:
- Xcode: Đã cài ở bước 2
- CocoaPods: Đã cài ở bước 4
- Android toolchain: Không cần thiết cho iOS (có thể bỏ qua)

---

### Lỗi 11.7: "Archive failed" hoặc "Build failed"

**Nguyên nhân**: Lỗi trong code hoặc cấu hình

**Giải pháp**:
1. Xem chi tiết lỗi trong Xcode (ở tab "Issue Navigator" - `Cmd + 5`)
2. Thử build bằng Flutter trước:
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   flutter build ios --release
   ```
3. Nếu vẫn lỗi, kiểm tra:
   - Bundle ID đúng chưa
   - Signing đã cấu hình chưa
   - Dependencies đã cài đầy đủ chưa

---

### Lỗi 11.8: "Upload failed" - Invalid Bundle

**Nguyên nhân**: Thiếu thông tin trong Info.plist hoặc cấu hình sai

**Giải pháp**:
1. Kiểm tra `ios/Runner/Info.plist` có đầy đủ:
   - `NSCameraUsageDescription`
   - `NSPhotoLibraryUsageDescription`
   - `NSPhotoLibraryAddUsageDescription`
   - `GADApplicationIdentifier`
2. Đảm bảo version trong `pubspec.yaml` đúng format: `1.0.3+4`

---

## 📝 CHECKLIST TRƯỚC KHI SUBMIT

Trước khi submit app lên App Store, đảm bảo:

- ✅ Xcode đã cài đặt và cấu hình đúng
- ✅ Flutter đã cài đặt và trong PATH
- ✅ CocoaPods đã cài đặt
- ✅ Code đã clone từ Git về Mac Mini
- ✅ Dependencies đã cài đặt (`flutter pub get` và `pod install`)
- ✅ Signing đã cấu hình trong Xcode (Team và Bundle ID)
- ✅ App đã build thành công (`flutter build ios --release`)
- ✅ Archive đã tạo thành công trong Xcode
- ✅ Upload lên App Store Connect thành công
- ✅ Thông tin App Store Listing đã điền đầy đủ
- ✅ Privacy Policy URL đã có (BẮT BUỘC)
- ✅ App Icon 1024x1024px đã upload
- ✅ Screenshots đã upload (ít nhất 1 cái)

---

## 🎉 HOÀN THÀNH!

Sau khi submit, bạn chỉ cần đợi Apple review. Thường mất 1-3 ngày làm việc.

**Lưu ý quan trọng:**
- Kiểm tra email thường xuyên để nhận thông báo từ Apple
- Nếu bị reject, đọc kỹ lý do và sửa lại
- Sau khi được approve, app sẽ tự động xuất hiện trên App Store

---

## 📞 HỖ TRỢ

Nếu gặp vấn đề không giải quyết được:
1. Kiểm tra lại từng bước trong hướng dẫn này
2. Xem phần "Xử lý Lỗi Thường Gặp"
3. Tìm kiếm lỗi trên Google với từ khóa cụ thể
4. Tham khảo tài liệu chính thức:
   - Flutter: https://docs.flutter.dev
   - Apple Developer: https://developer.apple.com/documentation

---

**Chúc bạn thành công! 🚀**

