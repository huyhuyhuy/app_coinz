app open ad
ca-app-pub-4969810842586372/8233130697


banner ad:
ca-app-pub-4969810842586372/8184179176


# App Open Ads - Hướng dẫn sử dụng

## 📱 Tổng quan

App Open Ads được implement với các đặc điểm:
- ✅ **Frequency:** Show 1 lần mỗi **4 giờ**
- ✅ **Smart Loading:** Đợi thực sự cho ad load xong (timeout 8s)
- ✅ **Flexible Splash:** Splash tối thiểu 2s, nhưng đợi ad load nếu cần (tối đa 8s)
- ✅ **Smart Skip:** Skip nếu ad không ready sau timeout
- ✅ **User-friendly:** Có nút Skip sau 5 giây (AdMob built-in)
- ✅ **Test Ads:** Sử dụng Google AdMob Test ID

---

## 🎯 Flow hoạt động

```
User mở app
    ↓
[AppInitScreen - Splash]
    ↓
Parallel loading (đợi cả 3):
  - AuthProvider init (~100-500ms)
  - Splash animation (min 2s)
  - Ad load (đợi thực sự, timeout 8s)
    ↓
Thời gian thực tế = max(2s, ad_load_time)
  - Nếu ad load < 2s → đợi 2s (splash)
  - Nếu ad load 2-8s → đợi ad load xong
  - Nếu ad load > 8s → timeout, skip ad
    ↓
Check: Đã qua 4 giờ? + Ad ready?
    ├─ YES → [Show App Open Ad]
    │            ↓ (Ad duration + Skip button)
    │            ↓
    └─ NO  → Skip
                 ↓
    Check đã đăng nhập?
    ├─ YES → [MainScreen]
    └─ NO  → [LoginScreen]
```

---

## 📁 Files đã tạo/sửa

### 1. **app_open_ad_manager.dart** (Mới)
- Location: `lib/services/app_open_ad_manager.dart`
- Chức năng: Quản lý App Open Ads
- Methods:
  - `loadAd()` - Load ad và **đợi thực sự** cho đến khi load xong (timeout 8s)
  - `showAdIfReady()` - Show nếu ready
  - `_canShowAd()` - Check 4 giờ frequency
  - `resetLastShownTime()` - Reset để test
- **Important:** 
  - Dùng `Completer` để đợi ad load callback thay vì return ngay
  - Timeout 8s (thay vì 5s) vì main thread có thể bận khi khởi động app

### 2. **app_init_screen.dart** (Mới)
- Location: `lib/screens/app_init_screen.dart`
- Chức năng: Splash + Load ad + Check auth
- Flow:
  1. Parallel loading:
     - AuthProvider init (~100-500ms)
     - Splash animation (min 2s)
     - Ad load (đợi thực sự, timeout 8s)
  2. Đợi cả 3 xong: `max(2s, ad_load_time)` với `ad_load_time ≤ 8s`
  3. Show ad nếu ready
  4. Navigate to MainScreen/LoginScreen
- **Flexible Splash:** Nếu ad load nhanh thì vào app sớm, nếu chậm thì đợi đủ

### 3. **main.dart** (Đã sửa)
- Location: `lib/main.dart`
- Thay đổi:
  - Import `AppInitScreen` thay vì `LoginScreen`
  - Home widget: `AppInitScreen()` thay vì `LoginScreen()`

---

## ⏱️ Timing & Performance

### Splash Time (Flexible)

```
Thời gian splash = max(2s, ad_load_time)
với ad_load_time ≤ 8s
```

### Các Kịch Bản:

| Tình huống | Ad Load Time | Splash Time | Ad Show | Tổng Thời Gian |
|------------|--------------|-------------|---------|-----------------|
| **Mạng tốt** | 1s | 2s | ✅ Yes | ~2s + ad duration |
| **Mạng bình thường** | 3s | 3s | ✅ Yes | ~3s + ad duration |
| **Mạng chậm** | 6s | 6s | ✅ Yes | ~6s + ad duration |
| **Mạng rất chậm** | 10s | 8s (timeout) | ❌ Skip | ~8s |
| **Offline/Fail** | ∞ | 8s (timeout) | ❌ Skip | ~8s |

### Tại sao timeout 8s?

Dựa trên testing logs:
- Main thread bận khi khởi động (Skipped 425+ frames)
- Nhiều initialization đồng thời (WebView, Camera, Firebase, AdMob)
- Test ad thực tế load trong ~6-8s trên thiết bị thật
- 8s là đủ cho ad load nhưng không quá lâu cho UX

### Best & Worst Case:

```
✅ Best case (mạng nhanh):
   Splash 2s → Ad show → Total ~2s + ad

⚠️ Worst case (mạng chậm/offline):
   Splash 8s → Skip ad → Total ~8s
```

---

## 🔧 Test Ad ID

```dart
Ad Unit ID (Test): ca-app-pub-3940256099942544/9257395921
Type: App Open Ad
Provider: Google AdMob Test Ads
```

**Note:** Đây là Test ID của Google, sẽ luôn load thành công khi test.

---

## 🧪 Testing

### Test 1: Lần đầu mở app (Mạng tốt)
```
1. Mở app lần đầu
   → Splash ~2-3s (đợi ad load)
   → Show App Open Ad (vì chưa show lần nào)
   → Skip sau 5s hoặc tap X
   → Navigate to Login/MainScreen
```

### Test 2: Lần đầu mở app (Mạng chậm)
```
1. Mở app lần đầu với mạng chậm
   → Splash ~6-8s (đợi ad load timeout)
   → Show App Open Ad (nếu load kịp)
   → Hoặc skip nếu timeout
   → Navigate to Login/MainScreen
```

### Test 3: Mở lại trong vòng 4 giờ
```
1. Mở app lại (trong vòng 4 giờ)
   → Splash 2s (không load ad)
   → Skip ad (chưa đủ 4 giờ)
   → Navigate to Login/MainScreen ngay
```

### Test 4: Mở lại sau 4 giờ
```
1. Đợi 4 giờ (hoặc reset - xem bên dưới)
2. Mở app
   → Splash 2-8s (đợi ad load)
   → Show App Open Ad (đã đủ 4 giờ)
   → Navigate to Login/MainScreen
```

### Test 4: Ad không load được
```
1. Tắt internet
2. Mở app
   → Show splash 2s
   → Skip ad (not ready)
   → Navigate to Login ngay
```

---

## 🔄 Reset Last Shown Time (Để test)

Nếu muốn test mà không đợi 4 giờ, có thể reset thời gian:

### Option 1: Code
```dart
// Thêm vào đâu đó trong app (ví dụ: một button test)
await AppOpenAdManager.resetLastShownTime();
```

### Option 2: Clear App Data
```bash
# Android
adb shell pm clear com.your.package.name

# iOS
Xóa app và cài lại
```

### Option 3: SharedPreferences
Xóa key: `app_open_ad_last_shown` trong SharedPreferences

---

## 📊 Logs để debug

```
[APP_OPEN_AD] 📱 Loading app open ad...
[APP_OPEN_AD] ✅ Ad loaded successfully
[APP_OPEN_AD] ✅ Đã qua X giờ - OK
[APP_OPEN_AD] 🎬 Showing app open ad...
[APP_OPEN_AD] 📺 Ad showed full screen
[APP_OPEN_AD] ✅ Ad dismissed
[APP_OPEN_AD] 💾 Saved last shown time
```

Hoặc nếu skip:
```
[APP_OPEN_AD] ⏰ Chưa đủ 4 giờ - skip loading
[APP_OPEN_AD] ⚠️ Ad not ready - skip
[APP_OPEN_AD] ⏰ Còn X phút nữa
```

---

## ⚙️ Cấu hình

### Thay đổi Frequency
```dart
// Trong app_open_ad_manager.dart
static const Duration _minTimeBetweenAds = Duration(hours: 4); // Đổi số giờ ở đây
```

### Thay đổi Splash Duration
```dart
// Trong app_init_screen.dart
final splashFuture = Future.delayed(const Duration(seconds: 2)); // Đổi số giây
```

---

## 🚀 Production

Khi deploy lên production, cần:

### 1. Đổi Test Ad ID thành Real Ad ID
```dart
// Trong app_open_ad_manager.dart
static String get appOpenAdUnitId {
  // TODO: Thay bằng Real Ad Unit ID từ AdMob Console
  return 'ca-app-pub-YOUR_REAL_ID/APP_OPEN_AD_ID';
}
```

### 2. Kiểm tra AdMob Console
- Tạo Ad Unit mới loại "App Open Ad"
- Copy Ad Unit ID
- Paste vào code

### 3. Test với Real Ads
- Build release APK
- Test trên thiết bị thật
- Đợi vài phút để ads cache

---

## ❓ Troubleshooting

### Ad không hiển thị
1. Check logs: `[APP_OPEN_AD]`
2. Check internet connection
3. Check đã đủ 4 giờ chưa
4. Reset last shown time để test

### Ad load chậm
- Đây là bình thường, ad sẽ cache sau lần đầu
- Smart loading sẽ skip nếu quá chậm

### App bị crash
- Check linter errors
- Check logs để xem lỗi ở đâu
- Ensure Google Mobile Ads initialized

---

## 📞 Support

Nếu có vấn đề, check:
1. Logs console
2. AdMob dashboard
3. Google Mobile Ads SDK documentation

---

**Created:** 2025
**Version:** 1.0.0
**Test Ads:** ✅ Active

