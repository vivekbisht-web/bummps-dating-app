/// Represents the user's wallet balance from GET /api/plans/wallet
class WalletBalance {
  final double balance;
  final String currency;

  WalletBalance({
    required this.balance,
    this.currency = 'INR',
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    // Handle: { balance: 500 } or { wallet: { balance: 500 } } or { data: { balance: 500 } }
    Map<String, dynamic> walletData = json;
    if (json.containsKey('wallet') && json['wallet'] is Map) {
      walletData = json['wallet'] as Map<String, dynamic>;
    } else if (json.containsKey('data') && json['data'] is Map) {
      walletData = json['data'] as Map<String, dynamic>;
    }

    final balanceNum = walletData['walletBalance'] as num? ??
        walletData['balance'] as num? ??
        walletData['amount'] as num? ??
        0.0;

    return WalletBalance(
      balance: balanceNum.toDouble(),
      currency: walletData['currency'] as String? ?? 'INR',
    );
  }
}
