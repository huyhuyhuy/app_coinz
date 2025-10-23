import '../services/supabase_service.dart';
import '../models/models.dart';

/// Model cho Friend với thông tin đầy đủ
class FriendInfo {
  final UserModel user;
  final WalletModel? wallet;
  final double miningSpeed;
  final bool isOnline;
  final String relationship; // 'referred_by' hoặc 'referral'

  FriendInfo({
    required this.user,
    this.wallet,
    this.miningSpeed = 0.0,
    this.isOnline = false,
    required this.relationship,
  });

  String get formattedBalance => wallet?.formattedBalanceShort ?? '0.00';
  String get formattedSpeed => miningSpeed.toStringAsFixed(8);
}

/// Friends Repository - Quản lý danh sách bạn bè
class FriendsRepository {
  /// Lấy danh sách người mà user đã giới thiệu (referrals)
  Future<List<FriendInfo>> getUserReferrals(String userId) async {
    try {
      print('[FRIENDS_REPO] 👥 Getting referrals for user: $userId');
      
      // Query users mà user này đã giới thiệu (referred_by = userId)
      final response = await SupabaseService.client
          .from('users')
          .select()
          .eq('referred_by', userId)
          .order('created_at', ascending: false);

      final friends = <FriendInfo>[];

      for (var userData in response as List) {
        final friend = UserModel.fromJson(userData as Map<String, dynamic>);
        
        // Lấy wallet info
        WalletModel? wallet;
        try {
          final walletData = await SupabaseService.client
              .from('wallets')
              .select()
              .eq('user_id', friend.userId)
              .single();
          wallet = WalletModel.fromJson(walletData);
        } catch (e) {
          print('[FRIENDS_REPO] ⚠️ Could not load wallet for ${friend.fullName}');
        }

        // TODO: Lấy mining speed từ mining_sessions (tạm thời dùng 0.001)
        final miningSpeed = 0.001; // Base speed

        friends.add(FriendInfo(
          user: friend,
          wallet: wallet,
          miningSpeed: miningSpeed,
          isOnline: false, // TODO: Implement online status
          relationship: 'referral',
        ));
      }

      print('[FRIENDS_REPO] ✅ Found ${friends.length} referrals');
      return friends;
    } catch (e) {
      print('[FRIENDS_REPO] ❌ Error getting referrals: $e');
      return [];
    }
  }

  /// Lấy người đã giới thiệu user này
  Future<FriendInfo?> getUserReferrer(String userId) async {
    try {
      print('[FRIENDS_REPO] 🔍 Getting referrer for user: $userId');
      
      // Lấy current user để biết referred_by
      final currentUserData = await SupabaseService.client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      final currentUser = UserModel.fromJson(currentUserData);
      
      if (currentUser.referredBy == null) {
        print('[FRIENDS_REPO] ℹ️ User has no referrer');
        return null;
      }

      // Lấy thông tin người giới thiệu
      final referrerData = await SupabaseService.client
          .from('users')
          .select()
          .eq('id', currentUser.referredBy!)
          .single();
      
      final referrer = UserModel.fromJson(referrerData);

      // Lấy wallet info
      WalletModel? wallet;
      try {
        final walletData = await SupabaseService.client
            .from('wallets')
            .select()
            .eq('user_id', referrer.userId)
            .single();
        wallet = WalletModel.fromJson(walletData);
      } catch (e) {
        print('[FRIENDS_REPO] ⚠️ Could not load wallet for referrer');
      }

      final miningSpeed = 0.001; // TODO: Get from mining_sessions

      final friendInfo = FriendInfo(
        user: referrer,
        wallet: wallet,
        miningSpeed: miningSpeed,
        isOnline: false,
        relationship: 'referred_by',
      );

      print('[FRIENDS_REPO] ✅ Found referrer: ${referrer.fullName}');
      return friendInfo;
    } catch (e) {
      print('[FRIENDS_REPO] ❌ Error getting referrer: $e');
      return null;
    }
  }

  /// Lấy tất cả bạn bè (referrals + referrer)
  Future<List<FriendInfo>> getAllFriends(String userId) async {
    try {
      print('[FRIENDS_REPO] 👥 Getting all friends for user: $userId');
      
      final friends = <FriendInfo>[];

      // 1. Lấy người đã giới thiệu mình
      final referrer = await getUserReferrer(userId);
      if (referrer != null) {
        friends.add(referrer);
      }

      // 2. Lấy những người mình đã giới thiệu
      final referrals = await getUserReferrals(userId);
      friends.addAll(referrals);

      print('[FRIENDS_REPO] ✅ Total friends: ${friends.length}');
      return friends;
    } catch (e) {
      print('[FRIENDS_REPO] ❌ Error getting all friends: $e');
      return [];
    }
  }

  /// Lấy statistics về referrals
  Future<Map<String, dynamic>> getReferralStats(String userId) async {
    try {
      final referrals = await getUserReferrals(userId);
      final referrer = await getUserReferrer(userId);

      return {
        'totalReferrals': referrals.length,
        'hasReferrer': referrer != null,
        'referrerName': referrer?.user.fullName,
        'speedMultiplier': _calculateSpeedMultiplier(referrals.length),
      };
    } catch (e) {
      print('[FRIENDS_REPO] ❌ Error getting referral stats: $e');
      return {
        'totalReferrals': 0,
        'hasReferrer': false,
        'speedMultiplier': 1.0,
      };
    }
  }

  /// Helper: Calculate speed multiplier
  /// ✅ VẤN ĐỀ 2: Cập nhật milestone mới
  double _calculateSpeedMultiplier(int totalReferrals) {
    if (totalReferrals >= 100) return 4.0;
    if (totalReferrals >= 50) return 3.0;
    if (totalReferrals >= 20) return 2.0;
    return 1.0;
  }
}

