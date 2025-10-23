import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stridebase/models/order_model.dart';
import 'package:stridebase/models/cart_item_model.dart';
import 'package:stridebase/services/cart_service.dart';
import 'package:stridebase/services/backend_status.dart';

class OrderService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final CartService _cartService = CartService();

  Future<OrderModel> createOrder(
      {required String userId, required List<CartItemModel> cartItems}) async {
    final now = DateTime.now();
    final items = cartItems
        .map((item) => OrderItemData(
              shoeId: item.shoeId,
              shoeName: item.shoe!.name,
              brand: item.shoe!.brand,
              price: item.shoe!.price,
              size: item.size,
              color: item.color,
              quantity: item.quantity,
              imageUrl: item.shoe!.imageUrl,
            ))
        .toList();

    final totalAmount =
        cartItems.fold(0.0, (total, item) => total + item.totalPrice);

    if (!BackendStatus.isFirebaseAvailable) {
      // Simulate an order locally with a random id prefix when offline
      final order = OrderModel(
        id: 'local-${now.microsecondsSinceEpoch}',
        userId: userId,
        items: items,
        totalAmount: totalAmount,
        status: 'pending',
        orderDate: now,
        createdAt: now,
        updatedAt: now,
      );
      await _cartService.clearCart(userId);
      return order;
    }

    final order = OrderModel(
      id: _firestore.collection('orders').doc().id,
      userId: userId,
      items: items,
      totalAmount: totalAmount,
      status: 'pending',
      orderDate: now,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('orders').doc(order.id).set(order.toJson());
    await _cartService.clearCart(userId);
    return order;
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    if (!BackendStatus.isFirebaseAvailable) return [];
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .get();
    return snapshot.docs.map((doc) => OrderModel.fromJson(doc.data())).toList();
  }

  Stream<List<OrderModel>> watchUserOrders(String userId) {
    if (!BackendStatus.isFirebaseAvailable) return Stream.value([]);
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data()))
            .toList());
  }
}
