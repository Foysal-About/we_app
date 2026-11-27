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
        return GlassHeaderColumn(
          children: [
            PageHeader(title: 'Favourites', onBack: () => shellIndex.value = 0),
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(Sp.page, 0, Sp.page, Sp.x3),
                child: Row(
                  children: [
                    Text(
                      '${items.length} saved ${items.length == 1 ? 'item' : 'items'}',
                      style: dm(13, color: kMuted),
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
                  ? Builder(
                      builder: (ctx) => Padding(
                        padding: EdgeInsets.only(top: GlassTopInset.of(ctx)),
                        child: EmptyHero(
                          icon: Icons.favorite_border,
                          title: 'No favourites yet',
                          message:
                              'Tap the heart on any product to save it here.',
                          actionLabel: 'Browse products',
                          onAction: () => shellIndex.value = 0,
                          iconColor: kFavorite,
                        ),
                      ),
                    )
                  : Container(
                      // Full-bleed so the glass bar frosts the beige.
                      color: kBeige,
                      child: CustomScrollView(
                        slivers: [
                          const SliverToBoxAdapter(child: GlassInsetSpacer()),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: Sp.x4),
                          ),
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
