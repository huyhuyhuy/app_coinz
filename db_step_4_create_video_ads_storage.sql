-- ==========================================
-- Supabase Storage Setup for Video Ads
-- ==========================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'video_ads',
  'video_ads',
  true,  -- Public bucket
  104857600,  -- 100MB max file size (100 * 1024 * 1024)
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


-- ==========================================
-- BƯỚC 2: Xóa tất cả RLS policies cũ (nếu có)
-- ==========================================

DROP POLICY IF EXISTS "Allow public SELECT access to video_ads bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow public INSERT access to video_ads bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow public UPDATE access to video_ads bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow public DELETE access to video_ads bucket" ON storage.objects;

DROP POLICY IF EXISTS "Allow authenticated SELECT access to video_ads bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated INSERT access to video_ads bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated UPDATE access to video_ads bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated DELETE access to video_ads bucket" ON storage.objects;

DROP POLICY IF EXISTS "Allow anon SELECT access to video_ads bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow anon INSERT access to video_ads bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow anon UPDATE access to video_ads bucket" ON storage.objects;
DROP POLICY IF EXISTS "Allow anon DELETE access to video_ads bucket" ON storage.objects;


-- ==========================================
-- BƯỚC 3: Tạo RLS Policies cho Public Access
-- ==========================================

-- 1. SELECT (Xem/Tải video) - Cho phép tất cả mọi người
CREATE POLICY "Allow public SELECT access to video_ads bucket"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'video_ads');

-- 2. INSERT (Upload video) - Cho phép tất cả mọi người
CREATE POLICY "Allow public INSERT access to video_ads bucket"
ON storage.objects FOR INSERT
TO public
WITH CHECK (
  bucket_id = 'video_ads'
  AND (storage.foldername(name))[1] = 'videos'  -- Bắt buộc upload vào folder 'videos/'
  AND (
    -- Chỉ cho phép video files
    lower(storage.extension(name)) IN ('mp4', 'mpeg', 'mov', 'avi', 'mkv', 'webm')
  )
);

-- 3. UPDATE (Cập nhật metadata) - Cho phép tất cả mọi người
CREATE POLICY "Allow public UPDATE access to video_ads bucket"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'video_ads')
WITH CHECK (bucket_id = 'video_ads');

-- 4. DELETE (Xóa video) - Cho phép tất cả mọi người
CREATE POLICY "Allow public DELETE access to video_ads bucket"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'video_ads');


-- ==========================================
-- BƯỚC 4: Tạo RLS Policies cho Authenticated Users
-- ==========================================

-- 1. SELECT - Authenticated users
CREATE POLICY "Allow authenticated SELECT access to video_ads bucket"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'video_ads');

-- 2. INSERT - Authenticated users
CREATE POLICY "Allow authenticated INSERT access to video_ads bucket"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'video_ads'
  AND (storage.foldername(name))[1] = 'videos'
  AND (
    lower(storage.extension(name)) IN ('mp4', 'mpeg', 'mov', 'avi', 'mkv', 'webm')
  )
);

-- 3. UPDATE - Authenticated users
CREATE POLICY "Allow authenticated UPDATE access to video_ads bucket"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'video_ads')
WITH CHECK (bucket_id = 'video_ads');

-- 4. DELETE - Authenticated users
CREATE POLICY "Allow authenticated DELETE access to video_ads bucket"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'video_ads');


-- ==========================================
-- BƯỚC 5: Tạo RLS Policies cho Anonymous Users
-- ==========================================

-- 1. SELECT - Anon users
CREATE POLICY "Allow anon SELECT access to video_ads bucket"
ON storage.objects FOR SELECT
TO anon
USING (bucket_id = 'video_ads');

-- 2. INSERT - Anon users
CREATE POLICY "Allow anon INSERT access to video_ads bucket"
ON storage.objects FOR INSERT
TO anon
WITH CHECK (
  bucket_id = 'video_ads'
  AND (storage.foldername(name))[1] = 'videos'
  AND (
    lower(storage.extension(name)) IN ('mp4', 'mpeg', 'mov', 'avi', 'mkv', 'webm')
  )
);

-- 3. UPDATE - Anon users
CREATE POLICY "Allow anon UPDATE access to video_ads bucket"
ON storage.objects FOR UPDATE
TO anon
USING (bucket_id = 'video_ads')
WITH CHECK (bucket_id = 'video_ads');

-- 4. DELETE - Anon users
CREATE POLICY "Allow anon DELETE access to video_ads bucket"
ON storage.objects FOR DELETE
TO anon
USING (bucket_id = 'video_ads');


-- ==========================================
-- HOÀN TẤT!
-- ==========================================
-- Bạn có thể upload video bằng cách:
-- 1. Supabase Dashboard → Storage → video_ads → Upload
-- 2. Folder structure: video_ads/videos/your_video.mp4
-- 3. Sau khi upload, lấy public URL:
--    https://[your-project-ref].supabase.co/storage/v1/object/public/video_ads/videos/your_video.mp4
-- 4. Thêm URL vào bảng video_ads (video_url column)
-- ==========================================

-- ==========================================
-- KIỂM TRA BUCKET ĐÃ TẠO THÀNH CÔNG
-- ==========================================
SELECT * FROM storage.buckets WHERE id = 'video_ads';

-- ==========================================
-- KIỂM TRA POLICIES ĐÃ TẠO THÀNH CÔNG
-- ==========================================
SELECT 
  schemaname, 
  tablename, 
  policyname, 
  permissive, 
  roles, 
  cmd, 
  qual, 
  with_check
FROM pg_policies 
WHERE tablename = 'objects' 
AND policyname LIKE '%video_ads%'
ORDER BY policyname;

