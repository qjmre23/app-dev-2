class User {
  final String id;
  final String username;
  final String email;
  final String passwordHash;
  final String department;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.department,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'department': department,
        'created_at': createdAt.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        passwordHash: json['password_hash'],
        department: json['department'],
        createdAt: DateTime.parse(json['created_at']),
      );
}

class Order {
  final String id;
  final String toyId;
  final String toyName;
  final String category;
  final String rfidUid;
  final String assignedPerson;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String department;
  final double totalAmount;

  Order({
    required this.id,
    required this.toyId,
    required this.toyName,
    required this.category,
    required this.rfidUid,
    required this.assignedPerson,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.department,
    required this.totalAmount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'toy_id': toyId,
        'toy_name': toyName,
        'category': category,
        'rfid_uid': rfidUid,
        'assigned_person': assignedPerson,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'department': department,
        'total_amount': totalAmount,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        toyId: json['toy_id'],
        toyName: json['toy_name'],
        category: json['category'],
        rfidUid: json['rfid_uid'],
        assignedPerson: json['assigned_person'],
        status: json['status'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
        department: json['department'],
        totalAmount: json['total_amount'].toDouble(),
      );

  Order copyWith({
    String? id,
    String? toyId,
    String? toyName,
    String? category,
    String? rfidUid,
    String? assignedPerson,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? department,
    double? totalAmount,
  }) {
    return Order(
      id: id ?? this.id,
      toyId: toyId ?? this.toyId,
      toyName: toyName ?? this.toyName,
      category: category ?? this.category,
      rfidUid: rfidUid ?? this.rfidUid,
      assignedPerson: assignedPerson ?? this.assignedPerson,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      department: department ?? this.department,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
