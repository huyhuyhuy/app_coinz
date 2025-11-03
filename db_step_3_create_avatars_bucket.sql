-- ========================================
-- AVATARS BUCKET SETUP
-- ========================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'avatars',
    'avatars', 
    true,  -- Public bucket
    5242880,  -- 5MB limit
    ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
);

-- ========================================
-- 2. TẠO POLICIES CHO BUCKET
-- ========================================

-- Policy 1: Cho phép SELECT (xem) cho tất cả
CREATE POLICY "Allow public view avatars" ON storage.objects
FOR SELECT USING (bucket_id = 'avatars');

-- Policy 2: Cho phép INSERT (upload) cho tất cả  
CREATE POLICY "Allow public insert avatars" ON storage.objects
FOR INSERT WITH CHECK (bucket_id = 'avatars');

-- Policy 3: Cho phép UPDATE (sửa) cho tất cả
CREATE POLICY "Allow public update avatars" ON storage.objects
FOR UPDATE USING (bucket_id = 'avatars');

-- Policy 4: Cho phép DELETE (xóa) cho tất cả
CREATE POLICY "Allow public delete avatars" ON storage.objects
FOR DELETE USING (bucket_id = 'avatars');

-- ========================================
-- 3. VERIFY SETUP
-- ========================================
-- Kiểm tra bucket đã tạo
SELECT * FROM storage.buckets WHERE id = 'avatars';

-- Kiểm tra policies đã tạo
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'objects' AND schemaname = 'storage';

-- ========================================
-- HOÀN TẤT!
-- ========================================
-- Sau khi chạy script này:
-- ✅ Bucket 'avatars' sẽ được tạo (public)
-- ✅ 4 policies sẽ được tạo cho tất cả operations
-- ✅ Mọi user (kể cả anonymous) có thể upload/sửa/xóa
-- ✅ File size limit: 5MB
-- ✅ Chỉ cho phép file ảnh (jpeg, png, gif, webp)
