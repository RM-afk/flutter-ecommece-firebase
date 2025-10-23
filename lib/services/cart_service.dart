import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stridebase/models/cart_item_model.dart';
import 'package:stridebase/services/shoe_service.dart';
import 'package:stridebase/services/backend_status.dart';

class CartService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final ShoeService _shoeService = ShoeService();

  Future<void> addToCart({
    required String userId,
    required String shoeId,
    required String size,
    required String color,
    int quantity = 1,
  }) async {
    if (!BackendStatus.isFirebaseAvailable) {
      // No-op in offline mode
      return;
    }
    final now = DateTime.now();
    final cartItem = CartItemModel(
      id: _firestore.collection('cart').doc().id,
      userId: userId,
      shoeId: shoeId,
      size: size,
      color: color,
      quantity: quantity,
      createdAt: now,
      updatedAt: now,
    );
    await _firestore.collection('cart').doc(cartItem.id).set(cartItem.toJson());
  }

  Future<List<CartItemModel>> getCartItems(String userId) async {
    if (!BackendStatus.isFirebaseAvailable) return [];
    final snapshot = await _firestore.collection('cart').where('userId', isEqualTo: userId).get();
    final items = snapshot.docs.map((doc) => CartItemModel.fromJson(doc.data())).toList();
    for (var item in items) {
      item.shoe = await _shoeService.getShoeById(item.shoeId);
    }
    return items;
  }

  Stream<List<CartItemModel>> watchCartItems(String userId) {
    if (!BackendStatus.isFirebaseAvailable) return Stream.value([]);
    return _firestore.collection('cart').where('userId', isEqualTo: userId).snapshots().asyncMap((snapshot) async {
      final items = snapshot.docs.map((doc) => CartItemModel.fromJson(doc.data())).toList();
      for (var item in items) {
        item.shoe = await _shoeService.getShoeById(item.shoeId);
      }
      return items;
    });
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (!BackendStatus.isFirebaseAvailable) return;
    await _firestore.collection('cart').doc(cartItemId).update({
      'quantity': quantity,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> removeFromCart(String cartItemId) async {
    if (!BackendStatus.isFirebaseAvailable) return;
    await _firestore.collection('cart').doc(cartItemId).delete();
  }

  Future<void> clearCart(String userId) async {
    if (!BackendStatus.isFirebaseAvailable) return;
    final snapshot = await _firestore.collection('cart').where('userId', isEqualTo: userId).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
