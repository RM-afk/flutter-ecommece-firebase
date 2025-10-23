import 'package:flutter/material.dart';
import 'package:stridebase/models/shoe_model.dart';
import 'package:stridebase/services/shoe_service.dart';
import 'package:stridebase/screens/product_detail_screen.dart';
import 'package:stridebase/screens/cart_screen.dart';
import 'package:stridebase/screens/profile_screen.dart';
import 'package:stridebase/widgets/shoe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _shoeService = ShoeService();
  String _selectedCategory = 'All';
  final _categories = ['All', 'Running', 'Casual', 'Formal', 'Sports'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text('STRIDEBASE',
            style: theme.textTheme.titleLarge?.copyWith(
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_bag_outlined,
                color: theme.colorScheme.primary),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: theme.colorScheme.primary),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Discover Your', style: theme.textTheme.headlineMedium),
                Text('Perfect Pair',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(color: theme.colorScheme.secondary)),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = category),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<ShoeModel>>(
              stream: _shoeService.watchAllShoes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: theme.colorScheme.tertiary),
                        const SizedBox(height: 16),
                        Text('No shoes available',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: theme.colorScheme.tertiary)),
                        const SizedBox(height: 8),
                        Text('Please connect Firebase and add products',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: theme.colorScheme.tertiary)),
                      ],
                    ),
                  );
                }

                final shoes = _selectedCategory == 'All'
                    ? snapshot.data!
                    : snapshot.data!
                        .where((s) => s.category == _selectedCategory)
                        .toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: shoes.length,
                  itemBuilder: (context, index) {
                    final shoe = shoes[index];
                    return ShoeCard(
                      shoe: shoe,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(shoe: shoe))),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
