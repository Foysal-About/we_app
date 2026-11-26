import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../pages/product_detail_page.dart';

/// 178x223 card from the design, scaled to whatever width the grid gives it.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final p = product;
    return GestureDetector(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: p))),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          width: 178,
          height: 223,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 20,
                top: 22,
                width: 138,
                height: 120,
                child: Image.asset(p.image, fit: BoxFit.contain),
              ),
              Positioned(
                left: 10,
                top: 154,
                child: Text(
                  p.name,
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ),
              Positioned(
                left: 11,
                top: 165,
                child: SvgPicture.asset('assets/icons/rating.svg'),
              ),
              Positioned(
                left: 11,
                top: 182,
                child: SvgPicture.asset(
                  'assets/icons/in_stock.svg',
                  width: 7,
                  height: 7,
                ),
              ),
              Positioned(
                left: 20,
                top: 179,
                child: Text(
                  'In stock',
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.w500,
                    fontSize: 9,
                    height: 11 / 9,
                    color: kGreen,
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 200,
                child: SvgPicture.asset(
                  'assets/icons/taka.svg',
                  width: 7.4,
                  height: 9.35,
                ),
              ),
              Positioned(
                left: 21,
                top: 200,
                child: Text(
                  p.price.toStringAsFixed(2),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    height: 12 / 10,
                  ),
                ),
              ),
              Positioned(
                left: 142,
                top: 7,
                child: ListenableBuilder(
                  listenable: app,
                  builder: (_, _) => GestureDetector(
                    onTap: () => app.toggleFavorite(p.id),
                    child: SvgPicture.asset(
                      app.isFavorite(p.id)
                          ? 'assets/icons/heart_circle_red.svg'
                          : 'assets/icons/heart_circle_grey.svg',
                    ),
                  ),
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
      padding: const EdgeInsets.fromLTRB(19, 0, 24, 0),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 31,
          mainAxisSpacing: 34,
          childAspectRatio: 178 / 223,
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
