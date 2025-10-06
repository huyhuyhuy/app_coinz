import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/models.dart';

/// Screen để test database
class TestDatabaseScreen extends StatefulWidget {
  const TestDatabaseScreen({super.key});

  @override
  State<TestDatabaseScreen> createState() => _TestDatabaseScreenState();
}

class _TestDatabaseScreenState extends State<TestDatabaseScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  String _log = '';
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _log += '$message\n';
    });
    print('[TEST] $message');
  }

  Future<void> _testDatabase() async {
    setState(() {
      _isLoading = true;
      _log = '';
    });

    try {
      _addLog('🚀 Starting database test...');

      // Test 1: Get database info
      _addLog('\n📊 Test 1: Get database info');
      await _dbHelper.printDatabaseInfo();
      _addLog('✅ Database info retrieved');

      // Test 2: Insert user
      _addLog('\n👤 Test 2: Insert user');
      final user = UserModel(
        userId: 'test-user-${DateTime.now().millisecondsSinceEpoch}',
        email: 'test@example.com',
        passwordHash: 'hashed_password_123',
        fullName: 'Test User',
        referralCode: 'REF${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _dbHelper.insert('users', user.toMap());
      _addLog('✅ User inserted: ${user.email}');

      // Test 3: Query users
      _addLog('\n📋 Test 3: Query users');
      final users = await _dbHelper.queryAll('users');
      _addLog('✅ Found ${users.length} users');
      for (var u in users) {
        _addLog('   - ${u['email']} (${u['full_name']})');
      }

      // Test 4: Insert wallet
      _addLog('\n💰 Test 4: Insert wallet');
      final wallet = WalletModel(
        userId: user.userId,
        walletAddress: 'COINZ${DateTime.now().millisecondsSinceEpoch}',
        balance: 100.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _dbHelper.insert('wallets', wallet.toMap());
      _addLog('✅ Wallet inserted: ${wallet.walletAddress}');

      // Test 5: Query wallets
      _addLog('\n💼 Test 5: Query wallets');
      final wallets = await _dbHelper.queryAll('wallets');
      _addLog('✅ Found ${wallets.length} wallets');
      for (var w in wallets) {
        _addLog('   - ${w['wallet_address']}: ${w['balance']} coins');
      }

      // Test 6: Count records
      _addLog('\n🔢 Test 6: Count records');
      final userCount = await _dbHelper.count('users');
      final walletCount = await _dbHelper.count('wallets');
      _addLog('✅ Users: $userCount, Wallets: $walletCount');

      _addLog('\n🎉 All tests passed!');
    } catch (e, stackTrace) {
      _addLog('\n❌ Error: $e');
      _addLog('StackTrace: $stackTrace');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearDatabase() async {
    setState(() {
      _isLoading = true;
      _log = '';
    });

    try {
      _addLog('🗑️ Clearing database...');
      await _dbHelper.deleteAll('users');
      await _dbHelper.deleteAll('wallets');
      _addLog('✅ Database cleared');
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Database'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testDatabase,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Run Tests'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _clearDatabase,
                    icon: const Icon(Icons.delete),
                    label: const Text('Clear DB'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _log.isEmpty ? 'Press "Run Tests" to start...' : _log,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

