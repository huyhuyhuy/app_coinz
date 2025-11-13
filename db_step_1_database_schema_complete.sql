-- ================================================================================
-- ALL DATABASE 
-- ================================================================================

-- ================================================================================
-- PART 1: USER & AUTHENTICATION
-- ================================================================================

-- Bảng users: Thông tin người dùng cơ bản
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) UNIQUE,
    avatar_url TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    referral_code VARCHAR(20) UNIQUE NOT NULL,
    referred_by UUID REFERENCES users(id) ON DELETE SET NULL,
    total_referrals INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Bảng user_profiles: Hồ sơ chi tiết người dùng
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    date_of_birth DATE,
    gender VARCHAR(10),
    country VARCHAR(100),
    city VARCHAR(100),
    address TEXT,
    kyc_status VARCHAR(20) DEFAULT 'pending',
    mining_level INTEGER DEFAULT 1,
    total_coins_mined DECIMAL(18,8) DEFAULT 0,
    total_mining_time INTEGER DEFAULT 0,
    mining_speed_multiplier DECIMAL(5,2) DEFAULT 1.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng admins: Quản trị viên
CREATE TABLE admins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL DEFAULT 'moderator',
    permissions JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES admins(id)
);

-- Bảng admin_activity_logs: Lịch sử hoạt động admin
CREATE TABLE admin_activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID REFERENCES admins(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(50),
    target_id UUID,
    details JSONB,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================================
-- PART 2: KYC SYSTEM
-- ================================================================================

-- Bảng kyc_submissions: Yêu cầu xác minh danh tính
CREATE TABLE kyc_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    submission_number INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'pending',
    id_card_number VARCHAR(50),
    id_card_front_url TEXT,
    id_card_back_url TEXT,
    selfie_url TEXT,
    bank_name VARCHAR(100),
    bank_account_number VARCHAR(50),
    bank_account_name VARCHAR(255),
    rejection_reason TEXT,
    reviewed_by UUID REFERENCES admins(id),
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================================
-- PART 3: MINING SYSTEM
-- ================================================================================

-- Bảng mining_sessions: Phiên đào coin
CREATE TABLE mining_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    duration_seconds INTEGER DEFAULT 0,
    coins_mined DECIMAL(18,8) DEFAULT 0,
    base_mining_speed DECIMAL(10,4) DEFAULT 0.001,
    actual_mining_speed DECIMAL(10,4) DEFAULT 0,
    speed_multiplier DECIMAL(5,2) DEFAULT 1.0,
    is_active BOOLEAN DEFAULT TRUE,
    is_valid BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_duration CHECK (duration_seconds >= 0 AND duration_seconds <= 86400)
);

-- Bảng mining_stats: Thống kê đào coin theo ngày
CREATE TABLE mining_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    total_coins_mined DECIMAL(18,8) DEFAULT 0,
    total_mining_time INTEGER DEFAULT 0,
    sessions_count INTEGER DEFAULT 0,
    avg_mining_speed DECIMAL(10,4) DEFAULT 0,
    max_mining_speed DECIMAL(10,4) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, date)
);

-- ================================================================================
-- PART 4: WALLET & TRANSACTIONS
-- ================================================================================

-- Bảng wallets: Ví coin
CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    wallet_address VARCHAR(255) UNIQUE NOT NULL,
    balance DECIMAL(18,8) DEFAULT 0,
    pending_balance DECIMAL(18,8) DEFAULT 0,
    total_earned DECIMAL(18,8) DEFAULT 0,
    total_spent DECIMAL(18,8) DEFAULT 0,
    total_withdrawn DECIMAL(18,8) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT positive_balance CHECK (balance >= 0)
);

-- Bảng transactions: Giao dịch
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    transaction_type VARCHAR(20) NOT NULL,
    amount DECIMAL(18,8) NOT NULL,
    fee_amount DECIMAL(18,8) DEFAULT 0,
    net_amount DECIMAL(18,8) NOT NULL,
    balance_before DECIMAL(18,8) NOT NULL,
    balance_after DECIMAL(18,8) NOT NULL,
    from_user_id UUID REFERENCES users(id),
    to_user_id UUID REFERENCES users(id),
    external_wallet_address VARCHAR(255),
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng withdrawal_requests: Yêu cầu rút coin
CREATE TABLE withdrawal_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(18,8) NOT NULL,
    fee_amount DECIMAL(18,8) NOT NULL,
    net_amount DECIMAL(18,8) NOT NULL,
    external_wallet_address VARCHAR(255) NOT NULL,
    wallet_type VARCHAR(50),
    status VARCHAR(20) DEFAULT 'pending',
    rejection_reason TEXT,
    transaction_id UUID REFERENCES transactions(id),
    reviewed_by UUID REFERENCES admins(id),
    reviewed_at TIMESTAMP,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================================
-- PART 5: SOCIAL & REFERRAL
-- ================================================================================

-- Bảng friends: Danh sách bạn bè
CREATE TABLE friends (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    friend_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'accepted',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, friend_id),
    CONSTRAINT no_self_friend CHECK (user_id != friend_id)
);

-- Bảng referrals: Hệ thống giới thiệu
CREATE TABLE referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    referred_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    referral_code VARCHAR(20) NOT NULL,
    bonus_percentage DECIMAL(5,2) DEFAULT 5.0,
    total_bonus_earned DECIMAL(18,8) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng referral_rewards: Lịch sử thưởng giới thiệu
CREATE TABLE referral_rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referral_id UUID REFERENCES referrals(id) ON DELETE CASCADE,
    referrer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    referred_id UUID REFERENCES users(id) ON DELETE CASCADE,
    reward_type VARCHAR(50) NOT NULL,
    amount DECIMAL(18,8) NOT NULL,
    source_transaction_id UUID REFERENCES transactions(id),
    milestone INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================================
-- PART 6: SYSTEM & NOTIFICATIONS
-- ================================================================================

-- Bảng system_settings: Cấu hình hệ thống
CREATE TABLE system_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    data_type VARCHAR(20) DEFAULT 'string',
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    updated_by UUID REFERENCES admins(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng notifications: Thông báo
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    related_id UUID,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng news: Tin tức
CREATE TABLE news (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    summary TEXT,
    image_url TEXT,
    author_id UUID REFERENCES admins(id),
    is_published BOOLEAN DEFAULT FALSE,
    published_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng app_versions: Quản lý phiên bản app
CREATE TABLE app_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version_number VARCHAR(20) UNIQUE NOT NULL,
    platform VARCHAR(20) NOT NULL,
    build_number INTEGER NOT NULL,
    is_force_update BOOLEAN DEFAULT FALSE,
    min_supported_version VARCHAR(20),
    release_notes TEXT,
    download_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================================
-- PART 7: INDEXES FOR PERFORMANCE
-- ================================================================================

-- Users indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_referral_code ON users(referral_code);
CREATE INDEX idx_users_referred_by ON users(referred_by);
CREATE INDEX idx_users_created_at ON users(created_at);

-- User profiles indexes
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_kyc_status ON user_profiles(kyc_status);

-- Admins indexes
CREATE INDEX idx_admins_user_id ON admins(user_id);
CREATE INDEX idx_admins_role ON admins(role);

-- KYC submissions indexes
CREATE INDEX idx_kyc_submissions_user_id ON kyc_submissions(user_id);
CREATE INDEX idx_kyc_submissions_status ON kyc_submissions(status);
CREATE INDEX idx_kyc_submissions_created_at ON kyc_submissions(created_at);

-- Mining sessions indexes
CREATE INDEX idx_mining_sessions_user_id ON mining_sessions(user_id);
CREATE INDEX idx_mining_sessions_start_time ON mining_sessions(start_time);
CREATE INDEX idx_mining_sessions_is_active ON mining_sessions(is_active);

-- Mining stats indexes
CREATE INDEX idx_mining_stats_user_id ON mining_stats(user_id);
CREATE INDEX idx_mining_stats_date ON mining_stats(date);

-- Wallets indexes
CREATE INDEX idx_wallets_user_id ON wallets(user_id);
CREATE INDEX idx_wallets_wallet_address ON wallets(wallet_address);

-- Transactions indexes
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_type ON transactions(transaction_type);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_transactions_from_user ON transactions(from_user_id);
CREATE INDEX idx_transactions_to_user ON transactions(to_user_id);

-- Withdrawal requests indexes
CREATE INDEX idx_withdrawal_requests_user_id ON withdrawal_requests(user_id);
CREATE INDEX idx_withdrawal_requests_status ON withdrawal_requests(status);
CREATE INDEX idx_withdrawal_requests_created_at ON withdrawal_requests(created_at);

-- Friends indexes
CREATE INDEX idx_friends_user_id ON friends(user_id);
CREATE INDEX idx_friends_friend_id ON friends(friend_id);
CREATE INDEX idx_friends_status ON friends(status);

-- Referrals indexes
CREATE INDEX idx_referrals_referrer_id ON referrals(referrer_id);
CREATE INDEX idx_referrals_referred_id ON referrals(referred_id);
CREATE INDEX idx_referrals_code ON referrals(referral_code);

-- Notifications indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- News indexes
CREATE INDEX idx_news_is_published ON news(is_published);
CREATE INDEX idx_news_published_at ON news(published_at);

-- ================================================================================
-- PART 8: TRIGGERS & FUNCTIONS
-- ================================================================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_kyc_submissions_updated_at BEFORE UPDATE ON kyc_submissions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mining_sessions_updated_at BEFORE UPDATE ON mining_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mining_stats_updated_at BEFORE UPDATE ON mining_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_wallets_updated_at BEFORE UPDATE ON wallets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_withdrawal_requests_updated_at BEFORE UPDATE ON withdrawal_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_friends_updated_at BEFORE UPDATE ON friends
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_referrals_updated_at BEFORE UPDATE ON referrals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_system_settings_updated_at BEFORE UPDATE ON system_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_news_updated_at BEFORE UPDATE ON news
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function: Generate referral code
CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.referral_code IS NULL OR NEW.referral_code = '' THEN
        NEW.referral_code := 'REF' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 8));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_user_referral_code BEFORE INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION generate_referral_code();

-- Function: Generate wallet address
CREATE OR REPLACE FUNCTION generate_wallet_address()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.wallet_address IS NULL OR NEW.wallet_address = '' THEN
        NEW.wallet_address := 'COINZ' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 32));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_wallet_address_trigger BEFORE INSERT ON wallets
    FOR EACH ROW EXECUTE FUNCTION generate_wallet_address();

-- ================================================================================
-- PART 9: INITIAL SYSTEM SETTINGS
-- ================================================================================

INSERT INTO system_settings (setting_key, setting_value, data_type, description, is_public) VALUES
('base_mining_speed', '0.001', 'decimal', 'Tốc độ đào cơ bản (coins/giây)', true),
('withdrawal_fee_percentage', '11.0', 'decimal', 'Phí rút coin (%)', true),
('min_withdrawal_amount', '10.0', 'decimal', 'Số coin tối thiểu để rút', true),
('referral_bonus_percentage', '5.0', 'decimal', 'Phần trăm bonus từ người được giới thiệu', true),
('referral_milestone_20', '0.5', 'decimal', 'Bonus khi đạt 20 referrals', true),
('referral_milestone_50', '2.0', 'decimal', 'Bonus khi đạt 50 referrals', true),
('referral_milestone_100', '5.0', 'decimal', 'Bonus khi đạt 100 referrals', true),
('max_mining_session_hours', '24', 'integer', 'Thời gian đào tối đa mỗi phiên (giờ)', false),
('kyc_required_for_withdrawal', 'true', 'boolean', 'Yêu cầu KYC để rút coin', true),
('app_maintenance_mode', 'false', 'boolean', 'Chế độ bảo trì', true),
('min_app_version_android', '1.0.0', 'string', 'Phiên bản Android tối thiểu', true),
('min_app_version_ios', '1.0.0', 'string', 'Phiên bản iOS tối thiểu', true);

-- ================================================================================
-- END OF SCHEMA
-- ================================================================================

