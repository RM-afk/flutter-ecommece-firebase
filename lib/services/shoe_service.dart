import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stridebase/models/shoe_model.dart';
import 'package:stridebase/services/backend_status.dart';

class ShoeService {
  FirebaseFirestore get _firestore {
    return FirebaseFirestore.instance;
  }

  // Sample catalog for offline mode
  static final List<ShoeModel> _sample = [
    ShoeModel(
      id: 'sample-1',
      name: 'AirStride Runner',
      brand: 'StrideBase',
      price: 129.99,
      description: 'Lightweight running shoe with breathable mesh and responsive cushioning.',
      imageUrl: 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?q=80&w=800&auto=format&fit=crop',
      category: 'Running',
      sizes: ['7', '8', '9', '10', '11'],
      colors: ['Black', 'White'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ShoeModel(
      id: 'sample-2',
      name: 'CityFlex Casual',
      brand: 'StrideBase',
      price: 89.50,
      description: 'Everyday casual sneakers with minimalist styling and comfort.',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=800&auto=format&fit=crop',
      category: 'Casual',
      sizes: ['6', '7', '8', '9', '10'],
      colors: ['Gray', 'Navy'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ShoeModel(
      id: 'sample-3',
      name: 'Executive Derby',
      brand: 'StrideBase',
      price: 159.00,
      description: 'Polished leather formal shoes for a sharp, professional look.',
      imageUrl: 'https://images.unsplash.com/photo-1614252369377-830c6be9e6ad?q=80&w=800&auto=format&fit=crop',
      category: 'Formal',
      sizes: ['8', '9', '10', '11', '12'],
      colors: ['Brown', 'Black'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  Future<List<ShoeModel>> getAllShoes() async {
    if (!BackendStatus.isFirebaseAvailable) return _sample;
    final snapshot = await _firestore.collection('shoes').orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => ShoeModel.fromJson(doc.data())).toList();
  }

  Future<List<ShoeModel>> getShoesByCategory(String category) async {
    if (!BackendStatus.isFirebaseAvailable) {
      return _sample.where((s) => s.category == category).toList();
    }
    final snapshot = await _firestore.collection('shoes').where('category', isEqualTo: category).get();
    return snapshot.docs.map((doc) => ShoeModel.fromJson(doc.data())).toList();
  }

  Future<ShoeModel?> getShoeById(String id) async {
    if (!BackendStatus.isFirebaseAvailable) {
      try {
        return _sample.firstWhere((s) => s.id == id);
      } catch (_) {
        return null;
      }
    }
    final doc = await _firestore.collection('shoes').doc(id).get();
    if (doc.exists) {
      return ShoeModel.fromJson(doc.data()!);
    }
    return null;
  }

  Stream<List<ShoeModel>> watchAllShoes() {
    if (!BackendStatus.isFirebaseAvailable) {
      return Stream<List<ShoeModel>>.value(_sample);
    }
    return _firestore
        .collection('shoes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ShoeModel.fromJson(doc.data())).toList());
  }
}
