
-- Bảng thong_bao: Thông báo cho toàn thể người dùng
CREATE TABLE thong_bao (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    noi_dung TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_thong_bao_created_at ON thong_bao(created_at DESC);

GRANT SELECT ON thong_bao TO anon;
GRANT SELECT ON thong_bao TO authenticated;


