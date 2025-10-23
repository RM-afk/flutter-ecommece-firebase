import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemData {
  final String shoeId;
  final String shoeName;
  final String brand;
  final double price;
  final String size;
  final String color;
  final int quantity;
  final String imageUrl;

  OrderItemData({
    required this.shoeId,
    required this.shoeName,
    required this.brand,
    required this.price,
    required this.size,
    required this.color,
    required this.quantity,
    required this.imageUrl,
  });

  factory OrderItemData.fromJson(Map<String, dynamic> json) => OrderItemData(
    shoeId: json['shoeId'] as String,
    shoeName: json['shoeName'] as String,
    brand: json['brand'] as String,
    price: (json['price'] as num).toDouble(),
    size: json['size'] as String,
    color: json['color'] as String,
    quantity: json['quantity'] as int,
    imageUrl: json['imageUrl'] as String,
  );

  Map<String, dynamic> toJson() => {
    'shoeId': shoeId,
    'shoeName': shoeName,
    'brand': brand,
    'price': price,
    'size': size,
    'color': color,
    'quantity': quantity,
    'imageUrl': imageUrl,
  };
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemData> items;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] as String,
    userId: json['userId'] as String,
    items: (json['items'] as List).map((item) => OrderItemData.fromJson(item as Map<String, dynamic>)).toList(),
    totalAmount: (json['totalAmount'] as num).toDouble(),
    status: json['status'] as String,
    orderDate: json['orderDate'] is Timestamp 
      ? (json['orderDate'] as Timestamp).toDate() 
      : DateTime.parse(json['orderDate'] as String),
    createdAt: json['createdAt'] is Timestamp 
      ? (json['createdAt'] as Timestamp).toDate() 
      : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] is Timestamp 
      ? (json['updatedAt'] as Timestamp).toDate() 
      : DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'items': items.map((item) => item.toJson()).toList(),
    'totalAmount': totalAmount,
    'status': status,
    'orderDate': Timestamp.fromDate(orderDate),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderItemData>? items,
    double? totalAmount,
    String? status,
    DateTime? orderDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => OrderModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    items: items ?? this.items,
    totalAmount: totalAmount ?? this.totalAmount,
    status: status ?? this.status,
    orderDate: orderDate ?? this.orderDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
