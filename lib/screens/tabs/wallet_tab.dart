import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/app_localizations.dart';
import '../../repositories/transaction_repository.dart';
import '../../models/models.dart';

/// Filter type cho transactions
enum TransactionFilter {
  all,      // Tất cả
  incoming, // Chỉ giao dịch đến (+)
  outgoing, // Chỉ giao dịch đi (-)
}

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  bool _isInitialized = false;
  TransactionFilter _currentFilter = TransactionFilter.all;
  final TransactionRepository _transactionRepo = TransactionRepository();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      _initializeProviders();
      _isInitialized = true;
    }
  }

  Future<void> _initializeProviders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    if (authProvider.userId != null) {
      // Use addPostFrameCallback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        walletProvider.initialize(authProvider.userId!);
      });
    }
  }

  void _copyWalletAddress(BuildContext context, String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).locale.languageCode == 'vi'
              ? 'Đã sao chép địa chỉ ví'
              : 'Wallet address copied',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInternalTransferDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    
    final recipientController = TextEditingController();
    final amountController = TextEditingController();
    final passwordController = TextEditingController();
    bool showPasswordField = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(localizations.transferInternal),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: recipientController,
                    decoration: InputDecoration(
                      labelText: localizations.recipientWalletAddress,
                      hintText: 'DFI...',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                    ),
                    enabled: !showPasswordField,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: localizations.amount,
                      hintText: '0.00',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.monetization_on),
                      suffixText: 'DFI',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: !showPasswordField,
                  ),
                  if (showPasswordField) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: localizations.password,
                        hintText: localizations.pleaseEnterPassword,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text(localizations.cancel),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!showPasswordField) {
                    // First step: Validate input
                    final recipient = recipientController.text.trim();
                    final amountText = amountController.text.trim();

                    if (recipient.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations.pleaseEnterWalletAddress)),
                      );
                      return;
                    }

                    if (amountText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations.pleaseEnterAmount)),
                      );
                      return;
                    }

                    final amount = double.tryParse(amountText);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations.pleaseEnterAmount)),
                      );
                      return;
                    }

                    if (amount > walletProvider.balance) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations.insufficientBalance)),
                      );
                      return;
                    }

                    // Show password field
                    setState(() {
                      showPasswordField = true;
                    });
                  } else {
                    // Second step: Verify password and transfer
                    final password = passwordController.text;
                    
                    if (password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations.pleaseEnterPassword)),
                      );
                      return;
                    }

                    // Verify password (simple check for now)
                    // In production, this should verify against stored password hash
                    // For now, we'll just check if it's not empty
                    
                    final amount = double.parse(amountController.text);
                    final recipient = recipientController.text.trim();

                    // Perform internal transfer
                    final success = await walletProvider.transferInternal(
                      fromUserId: authProvider.userId!,
                      toWalletAddress: recipient,
                      amount: amount,
                    );

                    Navigator.pop(dialogContext);

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.transferSuccessful),
                          backgroundColor: Colors.green,
                        ),
                      );
                      await walletProvider.refresh(authProvider.userId!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.transferFailed),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(showPasswordField ? localizations.confirm : localizations.locale.languageCode == 'vi' ? 'Tiếp tục' : 'Continue'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Consumer2<AuthProvider, WalletProvider>(
      builder: (context, authProvider, walletProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card - Compact version (like home tab, but without navigation)
              Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row with icon and title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                localizations.totalBalance,
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Balance amount
                      Text(
                        '${walletProvider.formattedBalanceShort} DFI',
                        style: GoogleFonts.roboto(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Wallet address with copy button
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              walletProvider.shortWalletAddress,
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                            onPressed: () {
                              _copyWalletAddress(
                                context,
                                walletProvider.wallet?.walletAddress ?? '',
                              );
                            },
                            tooltip: localizations.locale.languageCode == 'vi'
                                ? 'Sao chép địa chỉ'
                                : 'Copy address',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Transfer Buttons
              Row(
                children: [
                  // Internal Transfer Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showInternalTransferDialog(context),
                      icon: const Icon(Icons.swap_horiz, size: 20),
                      label: Text(
                        localizations.transferInternal,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // BNB Transfer Button (Coming Soon)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.currency_bitcoin, size: 20),
                      label: Text(
                        '${localizations.transferToBNB}\n(${localizations.comingSoon} + KYC)',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Transaction History Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.locale.languageCode == 'vi'
                        ? 'Lịch sử giao dịch'
                        : 'Transaction History',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Filter chips
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFilterChip(
                        TransactionFilter.all,
                        '',
                        icon: Icons.format_list_bulleted,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        TransactionFilter.incoming,
                        '',
                        icon: Icons.keyboard_arrow_down,
                        iconColor: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        TransactionFilter.outgoing,
                        '',
                        icon: Icons.keyboard_arrow_up,
                        iconColor: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Transactions List
              FutureBuilder<List<TransactionModel>>(
                future: _loadTransactions(authProvider.userId ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.roboto(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  final allTransactions = snapshot.data ?? [];
                  
                  // ✅ Remove duplicate transactions (same description + amount + time)
                  final deduplicatedTransactions = _removeDuplicateTransactions(allTransactions);
                  
                  // Filter transactions theo _currentFilter
                  final filteredTransactions = _filterTransactions(deduplicatedTransactions);

                  if (filteredTransactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              localizations.locale.languageCode == 'vi'
                                  ? 'Chưa có giao dịch'
                                  : 'No transactions yet',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: filteredTransactions
                        .map((transaction) => _buildTransactionCard(
                              context,
                              transaction,
                              localizations,
                            ))
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// Load transactions từ database
  Future<List<TransactionModel>> _loadTransactions(String userId) async {
    if (userId.isEmpty) return [];
    
    try {
      // ✅ Sync từ server trước (để restore lại data nếu bị mất)
      await _transactionRepo.syncTransactionsFromServer(userId);
      
      // ⚠️ KHÔNG gọi cleanup ở đây nữa - để UI tự handle deduplication
      // Lý do: Cleanup có thể xóa nhầm transactions hợp lệ
      // UI deduplication an toàn hơn vì chỉ ẩn, không xóa
      
      // Load từ local (tăng limit lên để load nhiều transactions hơn)
      final transactions = await _transactionRepo.getUserTransactions(userId, limit: 500);
      
      print('[WALLET_TAB] 📥 Loaded ${transactions.length} transactions from local database');
      
      return transactions;
    } catch (e) {
      print('[WALLET_TAB] ❌ Error loading transactions: $e');
      return [];
    }
  }

  /// Remove duplicate transactions (ONLY real duplicates - same timestamp to the minute)
  List<TransactionModel> _removeDuplicateTransactions(List<TransactionModel> transactions) {
    final Map<String, TransactionModel> uniqueTransactions = {};
    
    for (final transaction in transactions) {
      // ✅ Create unique key: type + description + amount + timestamp (to the MINUTE)
      // This ensures we only hide REAL duplicates (same transaction at same time)
      final timestampToMinute = transaction.createdAt.toIso8601String().substring(0, 16); // YYYY-MM-DDTHH:MM
      final uniqueKey = '${transaction.transactionType}_${transaction.description}_${transaction.amount}_$timestampToMinute';
      
      // Keep the first occurrence (or could keep latest based on ID)
      if (!uniqueTransactions.containsKey(uniqueKey)) {
        uniqueTransactions[uniqueKey] = transaction;
      } else {
        print('[WALLET_TAB] ⚠️ UI: Found duplicate transaction: ${transaction.transactionId} - ${transaction.description} - $timestampToMinute');
      }
    }
    
    final deduplicatedList = uniqueTransactions.values.toList();
    
    if (transactions.length != deduplicatedList.length) {
      print('[WALLET_TAB] 🔄 UI: Filtered ${transactions.length - deduplicatedList.length} duplicate transactions');
    }
    
    return deduplicatedList;
  }

  /// Filter transactions theo loại
  List<TransactionModel> _filterTransactions(List<TransactionModel> transactions) {
    switch (_currentFilter) {
      case TransactionFilter.all:
        return transactions;
      
      case TransactionFilter.incoming:
        // Giao dịch làm TĂNG số dư (+)
        return transactions.where((t) => _isIncomingTransaction(t)).toList();
      
      case TransactionFilter.outgoing:
        // Giao dịch làm GIẢM số dư (-)
        return transactions.where((t) => !_isIncomingTransaction(t)).toList();
    }
  }

  /// Check xem transaction có phải là incoming (tăng số dư) không
  bool _isIncomingTransaction(TransactionModel transaction) {
    // Các loại giao dịch làm TĂNG số dư
    const incomingTypes = [
      'mining',           // Đào coin
      'referral',         // Bonus giới thiệu
      'transfer_receive', // Nhận chuyển khoản
      'video_reward',     // Xem video
    ];
    
    return incomingTypes.contains(transaction.transactionType);
  }

  /// Build filter chip button
  Widget _buildFilterChip(TransactionFilter filter, String label, {IconData? icon, Color? iconColor}) {
    final isSelected = _currentFilter == filter;
    
    Color getColor() {
      if (filter == TransactionFilter.incoming) return Colors.green;
      if (filter == TransactionFilter.outgoing) return Colors.red;
      return Theme.of(context).colorScheme.primary;
    }
    
    Color getIconColor() {
      if (isSelected) return Colors.white;
      if (iconColor != null) return iconColor;
      return Colors.grey.shade700;
    }
    
    return InkWell(
      onTap: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? getColor() : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? getColor() : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: getIconColor(),
              ),
              if (label.isNotEmpty) const SizedBox(width: 4),
            ],
            if (label.isNotEmpty)
              Text(
                label,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build transaction card
  Widget _buildTransactionCard(
    BuildContext context,
    TransactionModel transaction,
    AppLocalizations localizations,
  ) {
    final isIncoming = _isIncomingTransaction(transaction);
    final color = isIncoming ? Colors.green : Colors.red;
    final icon = _getTransactionIcon(transaction.transactionType);
    final amountPrefix = isIncoming ? '+' : '-';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    _getTransactionDescription(transaction, localizations),
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Time
                  Text(
                    _formatTransactionTime(transaction.createdAt, localizations),
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Amount
            Text(
              '$amountPrefix${transaction.amount.toStringAsFixed(8)}',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get icon cho từng loại transaction
  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'mining':
        return Icons.landscape; // Icon đào
      case 'referral':
        return Icons.people; // Icon giới thiệu
      case 'transfer_receive':
        return Icons.call_received; // Nhận chuyển khoản
      case 'transfer_send':
        return Icons.call_made; // Gửi chuyển khoản
      case 'video_reward':
        return Icons.video_library; // Xem video
      case 'withdrawal':
        return Icons.account_balance; // Rút tiền
      default:
        return Icons.swap_horiz; // Mặc định
    }
  }

  /// Get description cho transaction (đa ngôn ngữ)
  String _getTransactionDescription(TransactionModel transaction, AppLocalizations localizations) {
    final isVi = localizations.locale.languageCode == 'vi';
    
    switch (transaction.transactionType) {
      case 'mining':
        return isVi ? 'Phần thưởng khai thác' : 'Mining Reward';
      
      case 'referral':
        return isVi ? 'Thưởng giới thiệu bạn bè' : 'Referral Bonus';
      
      case 'transfer_receive':
        return transaction.description.isNotEmpty
            ? transaction.description
            : (isVi ? 'Nhận chuyển khoản' : 'Received Transfer');
      
      case 'transfer_send':
        return transaction.description.isNotEmpty
            ? transaction.description
            : (isVi ? 'Gửi chuyển khoản' : 'Sent Transfer');
      
      case 'video_reward':
        return isVi ? 'Thưởng xem video' : 'Video Reward';
      
      case 'withdrawal':
        return isVi ? 'Rút tiền' : 'Withdrawal';
      
      default:
        return transaction.description.isNotEmpty
            ? transaction.description
            : transaction.transactionType;
    }
  }

  /// Format transaction time
  String _formatTransactionTime(DateTime time, AppLocalizations localizations) {
    final now = DateTime.now();
    final diff = now.difference(time);
    final isVi = localizations.locale.languageCode == 'vi';
    
    // Nếu trong ngày hôm nay
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return isVi ? 'Vừa xong' : 'Just now';
        }
        return isVi ? '${diff.inMinutes} phút trước' : '${diff.inMinutes}m ago';
      }
      return isVi ? '${diff.inHours} giờ trước' : '${diff.inHours}h ago';
    }
    
    // Nếu hôm qua
    if (diff.inDays == 1) {
      return isVi ? 'Hôm qua' : 'Yesterday';
    }
    
    // Nếu trong tuần (< 7 ngày)
    if (diff.inDays < 7) {
      return isVi ? '${diff.inDays} ngày trước' : '${diff.inDays}d ago';
    }
    
    // Ngày cụ thể
    return DateFormat('dd/MM/yyyy HH:mm').format(time);
  }
}

