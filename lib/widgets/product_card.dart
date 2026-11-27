import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../pages/product_detail_page.dart';
import 'common.dart';

/// Product tile: image on a soft panel, discount + favourite overlays, then
/// name, rating / stock and price. Sizes itself to the grid cell.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final p = product;
    final onSale = p.oldPrice != null;
    final priceColor = onSale ? kBuyGreen : kInk;
    return Semantics(
      button: true,
      label: '${p.name}, ${money(p.price)} per ${p.unit}',
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Rd.lg),
            boxShadow: Elev.card,
          ),
          padding: const EdgeInsets.all(Sp.x2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: kPanel,
                          borderRadius: BorderRadius.circular(Rd.md),
                        ),
                        // Every product fills the panel (see ProductImage.of).
                        child: ProductImage.of(p),
                      ),
                    ),
                    if (p.savingPercent != null)
                      Positioned(
                        left: Sp.x2,
                        top: Sp.x2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Sp.x2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: kAccent,
                            borderRadius: BorderRadius.circular(Rd.pill),
                          ),
                          child: Text(
                            '-${p.savingPercent}%',
                            style: typeStyle(
                              12,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (p.demo)
                      Positioned(
                        left: Sp.x2,
                        bottom: Sp.x2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Sp.x2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(Rd.pill),
                          ),
                          child: Text(
                            'EST. PRICE',
                            style: typeStyle(
                              12,
                              weight: FontWeight.w700,
                              color: kMuted,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: Sp.x1,
                      top: Sp.x1,
                      child: ListenableBuilder(
                        listenable: app,
                        builder: (_, _) {
                          final fav = app.isFavorite(p.id);
                          return Semantics(
                            button: true,
                            label: fav
                                ? 'Remove from favorites'
                                : 'Add to favorites',
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => app.toggleFavorite(p.id),
                              // 44dp touch target around a 32dp visual.
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    transitionBuilder: (c, a) =>
                                        ScaleTransition(scale: a, child: c),
                                    child: Icon(
                                      fav
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      key: ValueKey(fav),
                                      size: 18,
                                      color: fav ? kFavorite : kMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Sp.x1, Sp.x2, Sp.x1, Sp.x1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typeStyle(
                        14,
                        weight: FontWeight.w700,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: Sp.x1),
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/rating.svg'),
                        const Spacer(),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: kGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: Sp.x1),
                        Text(
                          'In stock',
                          style: typeStyle(
                            12,
                            weight: FontWeight.w500,
                            color: kGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sp.x2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            money(p.price).replaceAll('.00', ''),
                            style: typeStyle(
                              18,
                              weight: FontWeight.w800,
                              color: priceColor,
                            ),
                          ),
                          Text(
                            ' /${p.unit}',
                            style: typeStyle(
                              12,
                              weight: FontWeight.w500,
                              color: kMuted,
                            ),
                          ),
                          if (onSale) ...[
                            const SizedBox(width: Sp.x2),
                            Text(
                              '$kTaka${p.oldPrice!.toStringAsFixed(0)}',
                              style: typeStyle(12, color: kSubtle).copyWith(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two-column grid of product cards, used by Home and Favourites.
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.items});
  final List<Product> items;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.page),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: Sp.x4,
          mainAxisSpacing: Sp.x4,
          childAspectRatio: 0.66,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _Reveal(
          index: i,
          child: ProductCard(product: items[i]),
        ),
      ),
    );
  }
}

/// Fades and lifts a card in, staggered by its position in the grid.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + 70 * (index > 5 ? 5 : index)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - v)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
