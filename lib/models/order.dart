import 'package:hive/hive.dart';

part 'order.g.dart';

enum OrderStatus {
  PENDING,
  PROCESSING,
  ON_THE_WAY,
  DELIVERED,
}

@HiveType(typeId: 2)
class Order extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String toyId;

  @HiveField(2)
  final String toyName;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String rfidUid;

  @HiveField(5)
  final String assignedPerson;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? updatedAt;

  @HiveField(9)
  final String department;

  @HiveField(10)
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

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      toyId: json['toy_id'] ?? '',
      toyName: json['toy_name'] ?? '',
      category: json['category'] ?? '',
      rfidUid: json['rfid_uid'] ?? '',
      assignedPerson: json['assigned_person'] ?? '',
      status: json['status'] ?? 'PENDING',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      department: json['department'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
  }

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

  bool get isPending => status == 'PENDING';
  bool get isProcessing => status == 'PROCESSING';
  bool get isOnTheWay => status == 'ON_THE_WAY';
  bool get isDelivered => status == 'DELIVERED';
}
