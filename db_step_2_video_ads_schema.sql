-- =====================================================
-- VIDEO ADS MANAGEMENT SCHEMA FOR SUPABASE
-- =====================================================

-- 1. Bảng video_ads: Quản lý các video quảng cáo
CREATE TABLE IF NOT EXISTS video_ads (
    ad_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_code VARCHAR(100) UNIQUE NOT NULL,
    video_url TEXT NOT NULL,
    video_title VARCHAR(255),
    video_description TEXT,
    reward_amount DECIMAL(20, 8) DEFAULT 0.001,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'expired')),
    total_views INTEGER DEFAULT 0,
    max_views INTEGER,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng video_views: Lưu lịch sử xem video của user
CREATE TABLE IF NOT EXISTS video_views (
    view_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    ad_id UUID NOT NULL,
    reward_earned DECIMAL(20, 8) DEFAULT 0,
    view_duration INTEGER DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE,
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (ad_id) REFERENCES video_ads(ad_id) ON DELETE CASCADE
);

-- 3. Indexes để tối ưu query
CREATE INDEX IF NOT EXISTS idx_video_ads_status ON video_ads(status);
CREATE INDEX IF NOT EXISTS idx_video_ads_contract ON video_ads(contract_code);
CREATE INDEX IF NOT EXISTS idx_video_views_user ON video_views(user_id);
CREATE INDEX IF NOT EXISTS idx_video_views_ad ON video_views(ad_id);
CREATE INDEX IF NOT EXISTS idx_video_views_date ON video_views(viewed_at);

-- 4. Function để update total_views tự động
CREATE OR REPLACE FUNCTION update_video_total_views()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE video_ads
    SET total_views = total_views + 1,
        updated_at = CURRENT_TIMESTAMP
    WHERE ad_id = NEW.ad_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. Trigger để tự động update total_views khi có view mới
DROP TRIGGER IF EXISTS trigger_update_video_views ON video_views;
CREATE TRIGGER trigger_update_video_views
    AFTER INSERT ON video_views
    FOR EACH ROW
    EXECUTE FUNCTION update_video_total_views();

-- 6. Function để lấy video active ngẫu nhiên
CREATE OR REPLACE FUNCTION get_random_active_video()
RETURNS TABLE (
    ad_id UUID,
    contract_code VARCHAR(100),
    video_url TEXT,
    video_title VARCHAR(255),
    video_description TEXT,
    reward_amount DECIMAL(20, 8)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.ad_id,
        v.contract_code,
        v.video_url,
        v.video_title,
        v.video_description,
        v.reward_amount
    FROM video_ads v
    WHERE v.status = 'active'
        AND (v.end_date IS NULL OR v.end_date > CURRENT_TIMESTAMP)
        AND (v.max_views IS NULL OR v.total_views < v.max_views)
    ORDER BY RANDOM()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- 7. Insert dữ liệu mẫu
INSERT INTO video_ads (contract_code, video_url, video_title, video_description, reward_amount, status, max_views)
VALUES 
    ('AD001', 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 'Sample Video Ad 1', 'Watch this video to earn 0.001 COINZ', 0.001, 'active', 10000),
    ('AD002', 'https://www.youtube.com/watch?v=9bZkp7q19f0', 'Sample Video Ad 2', 'Watch this video to earn 0.002 COINZ', 0.002, 'active', 5000),
    ('AD003', 'https://www.youtube.com/watch?v=kJQP7kiw5Fk', 'Sample Video Ad 3', 'Watch this video to earn 0.001 COINZ', 0.001, 'inactive', NULL)
ON CONFLICT (contract_code) DO NOTHING;

-- 8. Enable Row Level Security (RLS)
ALTER TABLE video_ads ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_views ENABLE ROW LEVEL SECURITY;

-- 9. RLS Policies cho video_ads (public read, admin write)
CREATE POLICY "Anyone can view active video ads"
    ON video_ads FOR SELECT
    USING (status = 'active');

CREATE POLICY "Admins can manage video ads"
    ON video_ads FOR ALL
    USING (true);

-- 10. RLS Policies cho video_views (users can insert their own views)
CREATE POLICY "Users can insert their own video views"
    ON video_views FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Users can view their own video views"
    ON video_views FOR SELECT
    USING (true);

-- =====================================================
-- HƯỚNG DẪN SỬ DỤNG
-- =====================================================

-- Lấy video active ngẫu nhiên:
-- SELECT * FROM get_random_active_video();

-- Thêm video mới:
-- INSERT INTO video_ads (contract_code, video_url, video_title, reward_amount)
-- VALUES ('AD004', 'https://youtube.com/watch?v=xxxxx', 'New Video', 0.001);

-- Lưu lịch sử xem:
-- INSERT INTO video_views (user_id, ad_id, reward_earned, completed)
-- VALUES ('user-uuid', 'ad-uuid', 0.001, true);

-- Xem thống kê video:
-- SELECT ad_id, video_title, total_views, status FROM video_ads ORDER BY total_views DESC;

-- Xem lịch sử xem của user:
-- SELECT * FROM video_views WHERE user_id = 'user-uuid' ORDER BY viewed_at DESC;

