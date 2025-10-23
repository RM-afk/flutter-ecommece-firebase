import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stridebase/models/cart_item_model.dart';
import 'package:stridebase/services/auth_service.dart';
import 'package:stridebase/services/cart_service.dart';
import 'package:stridebase/services/order_service.dart';
import 'package:stridebase/screens/auth_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _authService = AuthService();
  final _cartService = CartService();
  final _orderService = OrderService();
  bool _isPlacingOrder = false;

  Future<void> _placeOrder(List<CartItemModel> items) async {
    if (items.isEmpty) return;

    setState(() => _isPlacingOrder = true);

    try {
      final user = _authService.currentUser;
      if (user == null) return;

      await _orderService.createOrder(userId: user.uid, cartItems: items);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authService.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          title: Text('Shopping Cart', style: theme.textTheme.titleLarge),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.tertiary),
                const SizedBox(height: 16),
                Text(
                  'Please sign in to view your cart',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.login, color: theme.colorScheme.primary),
                    label: Text('Sign in', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text('Shopping Cart', style: theme.textTheme.titleLarge),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<CartItemModel>>(
        stream: _cartService.watchCartItems(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final items = snapshot.data ?? [];
          
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: theme.colorScheme.tertiary),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.tertiary)),
                ],
              ),
            );
          }

          final total = items.fold(0.0, (sum, item) => sum + item.totalPrice);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final shoe = item.shoe;
                    if (shoe == null) return const SizedBox();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                            child: CachedNetworkImage(
                              imageUrl: shoe.imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 100,
                                height: 100,
                                color: theme.colorScheme.surface,
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 100,
                                height: 100,
                                color: theme.colorScheme.surface,
                                child: Icon(Icons.image_not_supported, color: theme.colorScheme.tertiary),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(shoe.name, style: theme.textTheme.titleSmall),
                                  const SizedBox(height: 4),
                                  Text('${item.size} | ${item.color}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.tertiary)),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('\$${shoe.price.toStringAsFixed(2)}', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.secondary)),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline),
                                            iconSize: 20,
                                            onPressed: () async {
                                              if (item.quantity > 1) {
                                                await _cartService.updateQuantity(item.id, item.quantity - 1);
                                              }
                                            },
                                          ),
                                          Text('${item.quantity}', style: theme.textTheme.titleSmall),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline),
                                            iconSize: 20,
                                            onPressed: () async {
                                              await _cartService.updateQuantity(item.id, item.quantity + 1);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                            onPressed: () async {
                              await _cartService.removeFromCart(item.id);
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: theme.textTheme.titleLarge),
                          Text('\$${total.toStringAsFixed(2)}', style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.secondary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isPlacingOrder ? null : () => _placeOrder(items),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isPlacingOrder 
                            ? const CircularProgressIndicator(color: Colors.white) 
                            : Text('Place Order', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
