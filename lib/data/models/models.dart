/// ---------------------------------------------------------------------------
/// USER MODEL
/// ---------------------------------------------------------------------------
class UserModel {
  final String id;
  final String userId;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;

  UserModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.role = 'user',
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'],
      avatarUrl: map['avatarUrl'],
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'role': role,
    };
  }
}

/// ---------------------------------------------------------------------------
/// WALLET MODEL
/// ---------------------------------------------------------------------------
class WalletModel {
  final String id;
  final String userId;
  final String accountNumber;
  final double balance;
  final String accountType;

  WalletModel({
    required this.id,
    required this.userId,
    required this.accountNumber,
    required this.balance,
    required this.accountType,
  });

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      accountNumber: map['accountNumber'] ?? '',
      balance: (map['balance'] is int)
          ? (map['balance'] as int).toDouble()
          : (map['balance'] ?? 0.0),
      accountType: map['accountType'] ?? 'checking',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'accountNumber': accountNumber,
      'balance': balance,
      'accountType': accountType,
    };
  }
}

/// ---------------------------------------------------------------------------
/// CARD MODEL  (updated: isActive getter + last4 + maskedNumber)
/// ---------------------------------------------------------------------------
class CardModel {
  final String id;
  final String userId;
  final String? cardName;
  final String cardNumber;
  final String cardType;
  final String status;
  final String? expiryDate;

  CardModel({
    required this.id,
    required this.userId,
    this.cardName,
    required this.cardNumber,
    required this.cardType,
    this.status = 'active',
    this.expiryDate,
  });

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      cardName: map['cardName'],
      cardNumber: map['cardNumber'] ?? '',
      cardType: map['cardType'] ?? 'local',
      status: map['status'] ?? 'active',
      expiryDate: map['expiryDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cardName': cardName,
      'cardNumber': cardNumber,
      'cardType': cardType,
      'status': status,
      'expiryDate': expiryDate,
    };
  }

  // ── Helpers dùng trong UI ──────────────────────────────────────────────
  bool get isActive => status.toLowerCase() == 'active';

  String get last4 {
    final n = cardNumber.replaceAll(' ', '').replaceAll('-', '');
    return n.length >= 4 ? n.substring(n.length - 4) : n;
  }

  String get maskedNumber => '•••• •••• •••• $last4';
}

/// ---------------------------------------------------------------------------
/// TRANSACTION MODEL
/// ---------------------------------------------------------------------------
class TransactionModel {
  final String id;
  final String? senderId;
  final String receiverId;
  final double amount;
  final double balanceAfter;
  final String type;
  final String? description;
  final String category;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    this.senderId,
    required this.receiverId,
    required this.amount,
    required this.balanceAfter,
    required this.type,
    this.description,
    required this.category,
    required this.createdAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['\$id'] ?? '',
      senderId: map['senderId'],
      receiverId: map['receiverId'] ?? '',
      amount: (map['amount'] as num? ?? 0).toDouble(),
      balanceAfter: (map['balanceAfter'] as num? ?? 0).toDouble(),
      type: map['type'] ?? 'transfer',
      description: map['description'],
      category: map['category'] ?? 'other',
      createdAt:
          map['\$createdAt'] !=
              null // Appwrite dùng $createdAt làm mặc định
          ? DateTime.parse(map['\$createdAt'].toString())
                .toLocal() // Thêm .toLocal()
          : (map['createdAt'] != null
                ? DateTime.parse(map['createdAt'].toString()).toLocal()
                : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'type': type,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// ---------------------------------------------------------------------------
/// NOTIFICATION MODEL
/// ---------------------------------------------------------------------------
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String?
  params; // JSON tham số thô — dùng để render đa ngôn ngữ ở client
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.params, // nullable — doc cũ không có thì null, fallback về content
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      params: map['params'] as String?, // null nếu doc cũ chưa có field này
      type: map['type'] ?? 'system',
      isRead: map['isRead'] ?? false,
      createdAt: map['\$createdAt'] != null
          ? DateTime.parse(map['\$createdAt'].toString()).toLocal()
          : (map['createdAt'] != null
                ? DateTime.parse(map['createdAt'].toString()).toLocal()
                : DateTime.now()),
    );
  }
}
