import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final items = products.where((p) => app.isFavorite(p.id)).toList();
        return Column(
          children: [
            PageHeader(title: 'Favourites', onBack: () => shellIndex.value = 0),
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Row(
                  children: [
                    Text(
                      '${items.length} saved ${items.length == 1 ? 'item' : 'items'}',
                      style: dm(13, color: Colors.black54),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        for (final p in items) {
                          app.addToCart(p.id);
                        }
                        toast(context, 'Added ${items.length} to your cart');
                      },
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: Text(
                        'Add all to cart',
                        style: dm(13, weight: FontWeight.w700),
                      ),
                      style: TextButton.styleFrom(foregroundColor: kBuyGreen),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: items.isEmpty
                  ? const EmptyState(
                      icon: Icons.favorite_border,
                      message:
                          'No favourites yet.\nTap the heart on a product to save it here.',
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        color: kBeige,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(40),
                        ),
                      ),
                      child: CustomScrollView(
                        slivers: [
                          const SliverToBoxAdapter(child: SizedBox(height: 28)),
                          ProductGrid(items: items),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 130),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
