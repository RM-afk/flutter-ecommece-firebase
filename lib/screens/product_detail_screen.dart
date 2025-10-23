import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stridebase/models/shoe_model.dart';
import 'package:stridebase/services/auth_service.dart';
import 'package:stridebase/services/cart_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final ShoeModel shoe;

  const ProductDetailScreen({super.key, required this.shoe});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _authService = AuthService();
  final _cartService = CartService();
  String? _selectedSize;
  String? _selectedColor;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    if (widget.shoe.sizes.isNotEmpty) _selectedSize = widget.shoe.sizes.first;
    if (widget.shoe.colors.isNotEmpty) _selectedColor = widget.shoe.colors.first;
  }

  Future<void> _addToCart() async {
    if (_selectedSize == null || _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select size and color')),
      );
      return;
    }

    final user = _authService.currentUser;
    if (user == null) return;

    setState(() => _isAdding = true);

    try {
      await _cartService.addToCart(
        userId: user.uid,
        shoeId: widget.shoe.id,
        size: _selectedSize!,
        color: _selectedColor!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to cart!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            leading: IconButton(
              icon: CircleAvatar(
                backgroundColor: theme.colorScheme.surface,
                child: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget.shoe.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.primaryContainer,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.image_not_supported, size: 64, color: theme.colorScheme.tertiary),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.shoe.brand, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary)),
                              const SizedBox(height: 4),
                              Text(widget.shoe.name, style: theme.textTheme.headlineMedium),
                            ],
                          ),
                        ),
                        Text('\$${widget.shoe.price.toStringAsFixed(2)}', style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.secondary)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Description', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(widget.shoe.description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.tertiary, height: 1.6)),
                    const SizedBox(height: 24),
                    Text('Size', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: widget.shoe.sizes.map((size) {
                        final isSelected = _selectedSize == size;
                        return ChoiceChip(
                          label: Text(size),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedSize = size),
                          backgroundColor: theme.colorScheme.primaryContainer,
                          selectedColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text('Color', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: widget.shoe.colors.map((color) {
                        final isSelected = _selectedColor == color;
                        return ChoiceChip(
                          label: Text(color),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedColor = color),
                          backgroundColor: theme.colorScheme.primaryContainer,
                          selectedColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isAdding ? null : _addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isAdding 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : Text('Add to Cart', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
