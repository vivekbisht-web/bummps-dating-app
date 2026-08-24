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

/// Represents a Razorpay order created by the backend
/// POST /api/plans/wallet/create-order or POST /api/plans/subscribe
class RazorpayOrder {
  final String orderId;
  final int amount; // in paise
  final String currency;
  final String keyId;

  RazorpayOrder({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
  });

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> root = json;
    if (json.containsKey('data') && json['data'] is Map) {
      root = json['data'] as Map<String, dynamic>;
    }

    final order = root['order'] is Map<String, dynamic>
        ? root['order'] as Map<String, dynamic>
        : (root['order'] is Map ? Map<String, dynamic>.from(root['order'] as Map) : root);

    return RazorpayOrder(
      orderId: order['id']?.toString() ??
          order['orderId']?.toString() ??
          order['order_id']?.toString() ??
          root['orderId']?.toString() ??
          root['order_id']?.toString() ??
          root['id']?.toString() ??
          '',
      amount: (order['amount'] as num? ?? root['amount'] as num? ?? 0).toInt(),
      currency: order['currency']?.toString() ?? root['currency']?.toString() ?? 'INR',
      keyId: root['key']?.toString() ??
          root['keyId']?.toString() ??
          root['key_id']?.toString() ??
          order['key']?.toString() ??
          order['keyId']?.toString() ??
          order['key_id']?.toString() ??
          '',
    );
  }
}
