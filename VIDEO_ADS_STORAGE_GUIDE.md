# 🎬 Hướng Dẫn Setup Video Ads Storage trên Supabase

## 📋 Tổng quan

File này hướng dẫn cách tạo và cấu hình Storage bucket `video_ads` trên Supabase để lưu trữ video quảng cáo cho tính năng "Xem video nhận thưởng".

---

## 🚀 BƯỚC 1: Chạy SQL Script

### Cách 1: Sử dụng SQL Editor trên Supabase Dashboard

1. Đăng nhập vào **Supabase Dashboard**: https://app.supabase.com
2. Chọn project của bạn
3. Vào **SQL Editor** (menu bên trái)
4. Click **New Query**
5. Copy toàn bộ nội dung file `create_video_ads_storage.sql`
6. Paste vào SQL Editor
7. Click **Run** để thực thi

### Cách 2: Chạy từng phần (Recommended cho người mới)

Chạy lần lượt từng BƯỚC trong file SQL:

#### BƯỚC 1: Tạo Bucket
```sql
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'video_ads',
  'video_ads',
  true,
  104857600,  -- 100MB
  ARRAY[
    'video/mp4',
    'video/mpeg',
    'video/quicktime',
    'video/x-msvideo',
    'video/x-matroska',
    'video/webm'
  ]
)
ON CONFLICT (id) DO NOTHING;
```

#### BƯỚC 2-5: Tạo Policies
(Copy từng phần trong file SQL và chạy)

---

## 📤 BƯỚC 2: Upload Video

### Option 1: Upload qua Supabase Dashboard

1. Vào **Storage** → Chọn bucket **video_ads**
2. Tạo folder `videos` (nếu chưa có)
3. Click **Upload file**
4. Chọn video file (.mp4, .webm, etc.)
5. Upload (max 100MB mỗi file)

### Option 2: Upload qua API

```bash
curl -X POST \
  'https://[YOUR-PROJECT-REF].supabase.co/storage/v1/object/video_ads/videos/my_video.mp4' \
  -H 'Authorization: Bearer [YOUR-ANON-KEY]' \
  -H 'Content-Type: video/mp4' \
  --data-binary '@/path/to/your/video.mp4'
```

---

## 🔗 BƯỚC 3: Lấy Public URL

Sau khi upload thành công, video sẽ có public URL theo format:

```
https://[YOUR-PROJECT-REF].supabase.co/storage/v1/object/public/video_ads/videos/[VIDEO-NAME].mp4
```

**Ví dụ:**
```
https://abcdefghijk.supabase.co/storage/v1/object/public/video_ads/videos/product_demo.mp4
```

---

## 📝 BƯỚC 4: Thêm Video vào Database

Sau khi có URL, thêm video vào bảng `video_ads`:

```sql
INSERT INTO video_ads (
  video_id,
  title,
  description,
  video_url,
  thumbnail_url,
  duration_seconds,
  reward_amount,
  max_views_per_user_per_day,
  total_views,
  is_active,
  created_at,
  updated_at
)
VALUES (
  gen_random_uuid(),
  'Product Demo Video',                    -- Tên video
  'Watch and earn 0.01 COINZ',            -- Mô tả
  'https://abcdefghijk.supabase.co/storage/v1/object/public/video_ads/videos/product_demo.mp4',  -- URL từ bước 3
  'https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',  -- Thumbnail (optional)
  45,                                      -- Độ dài video (giây)
  0.01,                                    -- Thưởng cho mỗi lượt xem
  1,                                       -- Số lần xem tối đa/ngày/user
  0,                                       -- Tổng lượt xem hiện tại
  true,                                    -- Active = true
  NOW(),
  NOW()
);
```

---

## ✅ Kiểm Tra Setup Thành Công

### 1. Kiểm tra Bucket đã tạo

```sql
SELECT * FROM storage.buckets WHERE id = 'video_ads';
```

**Kết quả mong đợi:**
- `id`: video_ads
- `name`: video_ads
- `public`: true
- `file_size_limit`: 104857600 (100MB)

### 2. Kiểm tra Policies

```sql
SELECT policyname 
FROM pg_policies 
WHERE tablename = 'objects' 
AND policyname LIKE '%video_ads%';
```

**Kết quả mong đợi:** 12 policies (4 cho public, 4 cho authenticated, 4 cho anon)

### 3. Test Upload

1. Upload 1 video test qua Dashboard
2. Lấy public URL
3. Mở URL trong browser → Video phải play được

---

## 🎯 Cấu Hình Storage

### File Size Limit
- **Mặc định:** 100MB (104857600 bytes)
- **Để thay đổi:**
```sql
UPDATE storage.buckets 
SET file_size_limit = 209715200  -- 200MB
WHERE id = 'video_ads';
```

### Allowed MIME Types
- video/mp4 ✅
- video/mpeg ✅
- video/quicktime (.mov) ✅
- video/x-msvideo (.avi) ✅
- video/x-matroska (.mkv) ✅
- video/webm ✅

### Folder Structure
```
video_ads/
└── videos/
    ├── product_demo.mp4
    ├── tutorial_01.mp4
    ├── tutorial_02.webm
    └── ...
```

---

## 🔒 Security & Permissions

### Public Access
- ✅ **SELECT:** Mọi người có thể xem/tải video
- ✅ **INSERT:** Mọi người có thể upload video
- ✅ **UPDATE:** Mọi người có thể cập nhật metadata
- ✅ **DELETE:** Mọi người có thể xóa video

### Restrictions
- 📁 **Folder:** Bắt buộc upload vào folder `videos/`
- 📹 **File Type:** Chỉ cho phép video files (mp4, webm, mov, etc.)
- 📏 **File Size:** Max 100MB mỗi file

---

## 🎬 Workflow Hoàn Chỉnh

```
1. Chuẩn bị video (.mp4, >30 giây)
   ↓
2. Upload lên Supabase Storage (bucket: video_ads, folder: videos/)
   ↓
3. Lấy public URL
   ↓
4. Thêm record vào bảng video_ads (với URL từ bước 3)
   ↓
5. App tự động load video từ database
   ↓
6. User xem video → Nhận thưởng!
```

---

## 🐛 Troubleshooting

### Lỗi: "new row violates row-level security policy"

**Nguyên nhân:** RLS policies chưa được tạo đúng

**Giải pháp:**
1. Xóa tất cả policies cũ (BƯỚC 2 trong SQL)
2. Tạo lại policies (BƯỚC 3-5 trong SQL)

### Lỗi: "File size exceeds limit"

**Nguyên nhân:** Video > 100MB

**Giải pháp:**
- Nén video xuống < 100MB
- Hoặc tăng `file_size_limit` trong bucket config

### Lỗi: "Invalid MIME type"

**Nguyên nhân:** File không phải video format được cho phép

**Giải pháp:**
- Chuyển đổi sang .mp4 hoặc .webm
- Hoặc thêm MIME type vào `allowed_mime_types`

---

## 📚 Tài Liệu Tham Khảo

- [Supabase Storage Documentation](https://supabase.com/docs/guides/storage)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage Policies](https://supabase.com/docs/guides/storage/security/access-control)

---

## ✅ Checklist

- [ ] Đã chạy SQL script `create_video_ads_storage.sql`
- [ ] Đã kiểm tra bucket `video_ads` đã tạo thành công
- [ ] Đã kiểm tra 12 RLS policies đã tạo thành công
- [ ] Đã upload video test
- [ ] Đã lấy được public URL
- [ ] Đã test URL (video play được trong browser)
- [ ] Đã thêm record vào bảng `video_ads`
- [ ] Đã test trong app (video hiển thị và play được)

---

**🎉 Hoàn thành! Bạn đã setup xong Video Ads Storage!**

