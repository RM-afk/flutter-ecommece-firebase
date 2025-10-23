import 'package:cloud_firestore/cloud_firestore.dart';

class ShoeModel {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String description;
  final String imageUrl;
  final String category;
  final List<String> sizes;
  final List<String> colors;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShoeModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.sizes,
    required this.colors,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShoeModel.fromJson(Map<String, dynamic> json) => ShoeModel(
    id: json['id'] as String,
    name: json['name'] as String,
    brand: json['brand'] as String,
    price: (json['price'] as num).toDouble(),
    description: json['description'] as String,
    imageUrl: json['imageUrl'] as String,
    category: json['category'] as String,
    sizes: List<String>.from(json['sizes'] as List),
    colors: List<String>.from(json['colors'] as List),
    createdAt: json['createdAt'] is Timestamp 
      ? (json['createdAt'] as Timestamp).toDate() 
      : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] is Timestamp 
      ? (json['updatedAt'] as Timestamp).toDate() 
      : DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'price': price,
    'description': description,
    'imageUrl': imageUrl,
    'category': category,
    'sizes': sizes,
    'colors': colors,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  ShoeModel copyWith({
    String? id,
    String? name,
    String? brand,
    double? price,
    String? description,
    String? imageUrl,
    String? category,
    List<String>? sizes,
    List<String>? colors,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ShoeModel(
    id: id ?? this.id,
    name: name ?? this.name,
    brand: brand ?? this.brand,
    price: price ?? this.price,
    description: description ?? this.description,
    imageUrl: imageUrl ?? this.imageUrl,
    category: category ?? this.category,
    sizes: sizes ?? this.sizes,
    colors: colors ?? this.colors,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
