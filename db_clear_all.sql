-- ================================================================================
-- DATABASE CLEANUP SCRIPT
-- ================================================================================
-- ⚠️ WARNING: This will DELETE ALL DATA in your database!
-- ⚠️ Only run this if you want to start fresh
-- ⚠️ BACKUP your data first if needed
-- ================================================================================

-- ================================================================================
-- PART 1: DROP ALL TABLES (in correct order - dependencies first)
-- ================================================================================

DROP TABLE IF EXISTS video_views CASCADE;
DROP TABLE IF EXISTS video_ads CASCADE;
DROP TABLE IF EXISTS referral_rewards CASCADE;
DROP TABLE IF EXISTS referrals CASCADE;
DROP TABLE IF EXISTS friends CASCADE;
DROP TABLE IF EXISTS withdrawal_requests CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS wallets CASCADE;
DROP TABLE IF EXISTS mining_stats CASCADE;
DROP TABLE IF EXISTS mining_sessions CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS news CASCADE;
DROP TABLE IF EXISTS app_versions CASCADE;
DROP TABLE IF EXISTS system_settings CASCADE;
DROP TABLE IF EXISTS admin_activity_logs CASCADE;
DROP TABLE IF EXISTS kyc_submissions CASCADE;
DROP TABLE IF EXISTS admins CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ================================================================================
-- PART 2: DROP ALL FUNCTIONS
-- ================================================================================

DROP FUNCTION IF EXISTS update_updated_at_column CASCADE;
DROP FUNCTION IF EXISTS generate_referral_code CASCADE;
DROP FUNCTION IF EXISTS generate_wallet_address CASCADE;
DROP FUNCTION IF EXISTS update_video_total_views CASCADE;
DROP FUNCTION IF EXISTS get_random_active_video CASCADE;

-- ================================================================================
-- PART 3: DROP ALL TRIGGERS (usually dropped with CASCADE, but for safety)
-- ================================================================================

-- Triggers will be dropped automatically with CASCADE above

-- ================================================================================
-- ✅ CLEANUP COMPLETE!
-- ================================================================================
-- All tables, functions, and triggers have been removed.
-- 
-- Next steps:
-- 1. Delete storage buckets manually in Supabase Dashboard:
--    - Go to Storage > avatars > Delete bucket
--    - Go to Storage > video_ads > Delete bucket
--
-- 2. Run PRODUCTION_DATABASE_SETUP.sql to recreate database
-- 3. Run STORAGE_BUCKETS_SETUP.sql to recreate storage
-- ================================================================================

-- Verify cleanup
SELECT tablename FROM pg_tables WHERE schemaname = 'public';
-- Should return empty or only non-app tables

