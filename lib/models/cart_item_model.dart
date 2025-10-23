import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stridebase/models/shoe_model.dart';

class CartItemModel {
  final String id;
  final String userId;
  final String shoeId;
  final String size;
  final String color;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  ShoeModel? shoe;

  CartItemModel({
    required this.id,
    required this.userId,
    required this.shoeId,
    required this.size,
    required this.color,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.shoe,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json['id'] as String,
    userId: json['userId'] as String,
    shoeId: json['shoeId'] as String,
    size: json['size'] as String,
    color: json['color'] as String,
    quantity: json['quantity'] as int,
    createdAt: json['createdAt'] is Timestamp 
      ? (json['createdAt'] as Timestamp).toDate() 
      : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] is Timestamp 
      ? (json['updatedAt'] as Timestamp).toDate() 
      : DateTime.parse(json['updatedAt'] as String),
    shoe: json['shoe'] != null ? ShoeModel.fromJson(json['shoe'] as Map<String, dynamic>) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'shoeId': shoeId,
    'size': size,
    'color': color,
    'quantity': quantity,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  CartItemModel copyWith({
    String? id,
    String? userId,
    String? shoeId,
    String? size,
    String? color,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    ShoeModel? shoe,
  }) => CartItemModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    shoeId: shoeId ?? this.shoeId,
    size: size ?? this.size,
    color: color ?? this.color,
    quantity: quantity ?? this.quantity,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    shoe: shoe ?? this.shoe,
  );

  double get totalPrice => (shoe?.price ?? 0) * quantity;
}
