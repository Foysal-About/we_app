import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'reviews_page.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product _p = widget.product;
  int _qty = 1;
  final _scroll = ScrollController();

  List<Product> get _siblings =>
      products.where((p) => p.brandId == _p.brandId).toList();

  void _select(Product p) {
    setState(() {
      _p = p;
      _qty = 1;
    });
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _step(int d) {
    final list = _siblings;
    final i = (list.indexOf(_p) + d) % list.length;
    _select(list[i < 0 ? i + list.length : i]);
  }

  void _addToCart() {
    app.addToCart(_p.id, _qty);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$_qty × ${_p.name} added to cart'),
          duration: const Duration(milliseconds: 1600),
          // Keep the message clear of the action bar.
          margin: EdgeInsets.fromLTRB(
            Sp.page,
            0,
            Sp.page,
            MediaQuery.paddingOf(context).bottom + 150,
          ),
        ),
      );
  }

  void _buyNow() {
    app.addToCart(_p.id, _qty);
    shellIndex.value = 2;
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void _zoom() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: _p.tint,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Sp.x6),
                    child: ProductImage.of(
                      _p,
                      background: _p.tint,
                      contain: true,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(ctx).top + Sp.x2,
              right: Sp.x3,
              child: IconButton.filled(
                tooltip: 'Close',
                onPressed: () => Navigator.of(ctx).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: kInk,
                ),
                icon: const Icon(Icons.close),
              ),
            ),
            Positioned(
              bottom: MediaQuery.paddingOf(ctx).bottom + Sp.x4,
              left: 0,
              right: 0,
              child: Center(
                child: Text('Pinch to zoom', style: dm(12, color: kMuted)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String _brandName(Product p) => brands
      .firstWhere((b) => b.id == p.brandId)
      .title
      .replaceAll(' Products', '');

  @override
  Widget build(BuildContext context) {
    final p = _p;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: p.tint,
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final reviews = app.reviews
              .where((r) => r.productId == p.id)
              .toList();
          final avg = reviews.isEmpty
              ? 0.0
              : reviews.fold<int>(0, (a, r) => a + r.rating) / reviews.length;
          return Stack(
            children: [
              ListView(
                controller: _scroll,
                padding: EdgeInsets.zero,
                children: [_hero(p, top), _panel(p, reviews, avg, bottom)],
              ),
              Positioned(
                top: top + Sp.x2,
                left: Sp.page,
                right: Sp.page,
                child: _topBar(p),
              ),
              Positioned(
                left: Sp.x4,
                right: Sp.x4,
                bottom: bottom < 12 ? 12 : bottom,
                child: _actionBar(p),
              ),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------------ hero

  Widget _hero(Product p, double top) {
    final sibs = _siblings;
    return SizedBox(
      height: top + 380,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft stage behind cut-out products (photos fill the hero instead).
          if (!p.photo)
            Container(
              width: 300,
              height: 300,
              margin: EdgeInsets.only(top: top + 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          // The picture drifts up and fades a little as the page scrolls.
          AnimatedBuilder(
            animation: _scroll,
            builder: (context, child) {
              final off = _scroll.hasClients
                  ? _scroll.offset.clamp(0.0, 320.0)
                  : 0.0;
              return Transform.translate(
                offset: Offset(0, off * 0.35),
                child: Opacity(opacity: 1 - off / 480, child: child),
              );
            },
            child: GestureDetector(
              onTap: _zoom,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Padding(
                  key: ValueKey(p.id),
                  padding: p.photo
                      ? EdgeInsets.fromLTRB(Sp.page, top + 72, Sp.page, 64)
                      : EdgeInsets.fromLTRB(
                          Sp.x8 + Sp.x1,
                          top + 64,
                          Sp.x8 + Sp.x1,
                          56,
                        ),
                  child: p.photo
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Rd.xl),
                            boxShadow: Elev.raised,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Rd.xl),
                            child: SizedBox.expand(
                              child: ProductImage(
                                p.image,
                                background: p.tint,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : ProductImage.of(p, background: p.tint, contain: true),
                ),
              ),
            ),
          ),
          if (sibs.length > 1) ...[
            Positioned(
              left: Sp.x2,
              child: _Arrow(Icons.chevron_left, () => _step(-1)),
            ),
            Positioned(
              right: Sp.x2,
              child: _Arrow(Icons.chevron_right, () => _step(1)),
            ),
            Positioned(
              bottom: 48,
              child: Row(
                children: [
                  for (final s in sibs)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: s.id == p.id ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: s.id == p.id
                            ? kInk
                            : kInk.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(Rd.pill),
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (p.savingPercent != null)
            Positioned(
              left: Sp.page,
              bottom: 44,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sp.x3,
                  vertical: Sp.x1,
                ),
                decoration: BoxDecoration(
                  color: kBuyGreen,
                  borderRadius: BorderRadius.circular(Rd.pill),
                ),
                child: Text(
                  '${p.savingPercent}% OFF',
                  style: dm(12, weight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
          Positioned(
            right: Sp.page,
            bottom: 44,
            child: Row(
              children: [
                const Icon(Icons.zoom_in, size: 18, color: kMuted),
                const SizedBox(width: Sp.x1),
                Text('Tap to zoom', style: dm(12, color: kMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(Product p) {
    return Row(
      children: [
        _GlassButton(
          icon: Icons.arrow_back,
          label: 'Back',
          onTap: () => Navigator.of(context).pop(),
        ),
        const Spacer(),
        _GlassButton(
          icon: app.isFavorite(p.id) ? Icons.favorite : Icons.favorite_border,
          iconColor: app.isFavorite(p.id) ? kFavorite : kInk,
          label: 'Favourite',
          onTap: () => app.toggleFavorite(p.id),
        ),
        const SizedBox(width: Sp.x2),
        _GlassButton(
          icon: Icons.shopping_bag_outlined,
          label: 'Cart',
          badge: app.cartCount,
          onTap: () {
            shellIndex.value = 2;
            Navigator.of(context).popUntil((r) => r.isFirst);
          },
        ),
      ],
    );
  }

  // ----------------------------------------------------------------- panel

  Widget _panel(Product p, List<Review> reviews, double avg, double bottom) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(Sp.page, Sp.x6, Sp.page, 190 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Rd.xxl)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: Sp.x2,
            runSpacing: Sp.x2,
            children: [
              _Tag(Icons.verified_outlined, _brandName(p), kBeige, kInk),
              const _Tag(
                Icons.check_circle_outline,
                'In stock',
                kSoftGreen,
                kBuyGreen,
              ),
            ],
          ),
          const SizedBox(height: Sp.x3),
          Text(
            p.name,
            style: urbanist(26, weight: FontWeight.w800, color: kInk),
          ),
          const SizedBox(height: Sp.x2),
          Row(
            children: [
              StarRating(value: avg == 0 ? 4 : avg.round(), size: 18),
              const SizedBox(width: Sp.x2),
              Text(
                reviews.isEmpty
                    ? 'No reviews yet'
                    : '${avg.toStringAsFixed(1)} · ${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'}',
                style: dm(12, color: kMuted),
              ),
            ],
          ),
          const SizedBox(height: Sp.x4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money(p.price),
                style: urbanist(
                  26,
                  weight: FontWeight.w800,
                  color: p.oldPrice != null ? kBuyGreen : kInk,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: Sp.x1, bottom: 3),
                child: Text('/ ${p.unit}', style: dm(14, color: kMuted)),
              ),
              if (p.oldPrice != null) ...[
                const SizedBox(width: Sp.x3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    money(p.oldPrice!),
                    style: dm(
                      14,
                      color: kSubtle,
                    ).copyWith(decoration: TextDecoration.lineThrough),
                  ),
                ),
              ],
            ],
          ),
          if (p.demo) ...[
            const SizedBox(height: Sp.x2),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: kSubtle),
                const SizedBox(width: Sp.x1),
                Expanded(
                  child: Text(
                    'Estimated price. The final price is confirmed on order.',
                    style: dm(12, color: kSubtle),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: Sp.x5),
          _deliveryCard(),
          const SizedBox(height: Sp.x6),
          _title('Features'),
          for (final f in p.features)
            Padding(
              padding: const EdgeInsets.only(bottom: Sp.x2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3, right: Sp.x3),
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: kBrandGreen,
                    ),
                  ),
                  Expanded(
                    child: Text(f, style: dm(14, color: kInk)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: Sp.x6),
          _title('Specifications'),
          LayoutBuilder(
            builder: (context, c) {
              final w = (c.maxWidth - Sp.x3) / 2;
              final specs = <(String, String)>[
                ('Brand', _brandName(p)),
                ('Category', p.category),
                if (p.size != null) ('Size', p.size!),
                ('Sold per', p.unit),
              ];
              return Wrap(
                spacing: Sp.x3,
                runSpacing: Sp.x3,
                children: [
                  for (final s in specs)
                    _Spec(width: w, label: s.$1, value: s.$2),
                ],
              );
            },
          ),
          const SizedBox(height: Sp.x6),
          _reviews(p, reviews, avg),
          const SizedBox(height: Sp.x6),
          _title('You may also like'),
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                for (final o in products.where((x) => x.id != p.id))
                  _Related(product: o, onTap: () => _select(o)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryCard() {
    return Container(
      padding: const EdgeInsets.all(Sp.x4),
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(Rd.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: kSoftGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: kBrandGreen,
            ),
          ),
          const SizedBox(width: Sp.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Free delivery', style: dm(14, weight: FontWeight.w700)),
                Text(
                  'Estimated by ${deliveryEta()}',
                  style: dm(12, color: kMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviews(Product p, List<Review> reviews, double avg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _title('Reviews', bottom: 0)),
            TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ReviewsPage())),
              child: Text(
                'Write a review',
                style: dm(12, weight: FontWeight.w700, color: kBrandGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: Sp.x2),
        if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Sp.x4),
            decoration: BoxDecoration(
              color: kPanel,
              borderRadius: BorderRadius.circular(Rd.lg),
            ),
            child: Text(
              'No reviews yet. Be the first to share what you think.',
              style: dm(14, color: kMuted),
            ),
          )
        else ...[
          Row(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: urbanist(34, weight: FontWeight.w800),
              ),
              const SizedBox(width: Sp.x3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StarRating(value: avg.round(), size: 18),
                  Text(
                    '${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'}',
                    style: dm(12, color: kMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Sp.x3),
          for (final r in reviews)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: Sp.x3),
              padding: const EdgeInsets.all(Sp.x4),
              decoration: BoxDecoration(
                color: kPanel,
                borderRadius: BorderRadius.circular(Rd.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StarRating(value: r.rating, size: 16),
                      const Spacer(),
                      Text(r.date, style: dm(12, color: kSubtle)),
                    ],
                  ),
                  if (r.text.isNotEmpty) ...[
                    const SizedBox(height: Sp.x2),
                    Text(r.text, style: dm(14, color: kInk)),
                  ],
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _title(String t, {double bottom = Sp.x3}) => Padding(
    padding: EdgeInsets.only(bottom: bottom),
    child: Text(
      t,
      style: urbanist(18, weight: FontWeight.w800, color: kInk),
    ),
  );

  // ------------------------------------------------------------ action bar

  Widget _actionBar(Product p) {
    return GlassPanel(
      radius: Rd.xl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Sp.x4, Sp.x3, Sp.x4, Sp.x3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _QtyPill(
                  value: _qty,
                  onChanged: (v) => setState(() => _qty = v),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total', style: dm(12, color: kMuted)),
                    Text(
                      money(p.price * _qty),
                      style: urbanist(18, weight: FontWeight.w800, color: kInk),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Sp.x3),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    color: kBrown,
                    onTap: _addToCart,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: Sp.x2),
                        Flexible(
                          child: Text(
                            'Add to cart',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: dm(
                              14,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: Sp.x3),
                Expanded(
                  child: _ActionButton(
                    color: kBuyGreen,
                    onTap: _buyNow,
                    child: Center(
                      child: Text(
                        'Buy Now',
                        style: dm(
                          14,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- widgets

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = kInk,
    this.badge = 0,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Tappable(
        onTap: onTap,
        child: SizedBox(
          width: Sp.control,
          height: Sp.control,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GlassPanel(
                radius: Rd.pill,
                blur: 12,
                opacity: 0.6,
                child: SizedBox(
                  width: Sp.control,
                  height: Sp.control,
                  child: Icon(icon, size: 22, color: iconColor),
                ),
              ),
              if (badge > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    height: 18,
                    constraints: const BoxConstraints(minWidth: 18),
                    padding: const EdgeInsets.symmetric(horizontal: Sp.x1),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kAccent,
                      borderRadius: BorderRadius.circular(Rd.pill),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      style: dm(
                        12,
                        weight: FontWeight.w700,
                        color: Colors.white,
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

class _Tag extends StatelessWidget {
  const _Tag(this.icon, this.label, this.bg, this.fg);
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: Sp.x3, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(Rd.pill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: fg),
        const SizedBox(width: Sp.x1),
        Text(
          label,
          style: dm(12, weight: FontWeight.w700, color: fg),
        ),
      ],
    ),
  );
}

class _Spec extends StatelessWidget {
  const _Spec({required this.width, required this.label, required this.value});
  final double width;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: const EdgeInsets.all(Sp.x4),
    decoration: BoxDecoration(
      color: kPanel,
      borderRadius: BorderRadius.circular(Rd.lg),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: dm(12, color: kMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: dm(14, weight: FontWeight.w700, color: kInk),
        ),
      ],
    ),
  );
}

class _QtyPill extends StatelessWidget {
  const _QtyPill({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData i, String tip, VoidCallback f) => IconButton(
      tooltip: tip,
      onPressed: f,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(
        minWidth: Sp.control,
        minHeight: Sp.control,
      ),
      icon: Icon(i, size: 20, color: kInk),
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(Rd.pill),
        border: Border.all(color: kBarGrey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(
            Icons.remove,
            'Decrease',
            () => value > 1 ? onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 36,
            child: Center(
              child: Text(
                '$value',
                style: dm(16, weight: FontWeight.w800, color: kInk),
              ),
            ),
          ),
          btn(Icons.add, 'Increase', () => onChanged(value + 1)),
        ],
      ),
    );
  }
}

class _Related extends StatelessWidget {
  const _Related({required this.product, required this.onTap});
  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: Sp.x3),
    child: Tappable(
      onTap: onTap,
      child: Container(
        width: 128,
        padding: const EdgeInsets.all(Sp.x3),
        decoration: BoxDecoration(
          color: kPanel,
          borderRadius: BorderRadius.circular(Rd.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Rd.md),
                child: ProductImage.of(product),
              ),
            ),
            const SizedBox(height: Sp.x2),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: dm(12, weight: FontWeight.w700, color: kInk),
            ),
            Text(
              money(product.price),
              style: dm(12, weight: FontWeight.w800, color: kInk),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Arrow extends StatelessWidget {
  const _Arrow(this.icon, this.onTap);
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      width: Sp.control,
      height: Sp.control,
      child: Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: Elev.card,
          ),
          child: Icon(icon, size: 24, color: kInk),
        ),
      ),
    ),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.color,
    required this.onTap,
    required this.child,
  });
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Tappable(
    onTap: onTap,
    child: Container(
      height: Sp.control,
      padding: const EdgeInsets.symmetric(horizontal: Sp.x3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Rd.pill),
      ),
      child: child,
    ),
  );
}
