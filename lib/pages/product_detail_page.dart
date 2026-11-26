import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => app.markViewed(_p.id));
  }

  List<Product> get _siblings =>
      products.where((p) => p.brandId == _p.brandId).toList();

  void _select(Product p) {
    setState(() {
      _p = p;
      _qty = 1;
    });
    app.markViewed(p.id);
    if (_scroll.hasClients) _scroll.jumpTo(0);
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
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1600),
          // Keep the message clear of the Add to cart / Buy Now buttons.
          margin: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            MediaQuery.paddingOf(context).bottom + 96,
          ),
        ),
      );
  }

  void _buyNow() {
    app.addToCart(_p.id, _qty);
    shellIndex.value = 2;
    Navigator.of(context).popUntil((r) => r.isFirst);
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
              ? 4.0
              : reviews.fold<int>(0, (a, r) => a + r.rating) / reviews.length;
          return Column(
            children: [
              PageHeader(
                showLogo: true,
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Padding(
                          key: ValueKey(p.id),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 70,
                            vertical: 8,
                          ),
                          child: InteractiveViewer(
                            minScale: 1,
                            maxScale: 3,
                            child: Image.asset(p.image, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    ),
                    if (_siblings.length > 1) ...[
                      Positioned(
                        left: 14,
                        top: 0,
                        bottom: 0,
                        child: _Arrow(Icons.chevron_left, () => _step(-1)),
                      ),
                      Positioned(
                        right: 14,
                        top: 0,
                        bottom: 0,
                        child: _Arrow(Icons.chevron_right, () => _step(1)),
                      ),
                    ],
                    Positioned(
                      right: 12,
                      top: 0,
                      child: IconButton(
                        tooltip: 'Favourite',
                        onPressed: () => app.toggleFavorite(p.id),
                        icon: Icon(
                          app.isFavorite(p.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: app.isFavorite(p.id)
                              ? const Color(0xFFFB0000)
                              : kInk,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StarRating(value: avg.round(), size: 15),
                  const SizedBox(width: 6),
                  Text(
                    reviews.isEmpty
                        ? 'No reviews yet'
                        : '${avg.toStringAsFixed(1)} (${reviews.length})',
                    style: dm(12, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(p.name, style: urbanist(22, weight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(
                '${money(p.price)} / ${p.unit}',
                style: dm(16, weight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: kPanel,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ListView(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(24, 22, 24, 190),
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _Chip(Icons.verified_outlined, _brandName(p)),
                                const _Chip(
                                  Icons.inventory_2_outlined,
                                  'In stock',
                                ),
                                const _Chip(
                                  Icons.local_shipping_outlined,
                                  'Free delivery',
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _title('Features'),
                            for (final f in p.features)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        top: 3,
                                        right: 10,
                                      ),
                                      child: Icon(
                                        Icons.check_circle,
                                        size: 14,
                                        color: kBrandGreen,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        f,
                                        style: dm(13, height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),
                            _title('Specifications'),
                            _spec('Brand', _brandName(p)),
                            _spec('Category', p.category),
                            if (p.size != null) _spec('Size', p.size!),
                            _spec('Sold per', p.unit),
                            _spec('Availability', 'In stock'),
                            const SizedBox(height: 16),
                            _title('Reviews'),
                            if (reviews.isEmpty)
                              Text(
                                'Be the first to review this product from Profile → My reviews.',
                                style: dm(
                                  12.5,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              )
                            else
                              for (final r in reviews)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          StarRating(value: r.rating, size: 14),
                                          const Spacer(),
                                          Text(
                                            r.date,
                                            style: dm(
                                              11,
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (r.text.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 3,
                                          ),
                                          child: Text(
                                            r.text,
                                            style: dm(13, height: 1.4),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            const SizedBox(height: 16),
                            _title('You may also like'),
                            SizedBox(
                              height: 132,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  for (final o in products.where(
                                    (x) => x.id != p.id,
                                  ))
                                    _Related(
                                      product: o,
                                      onTap: () => _select(o),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: bottom < 12 ? 12 : bottom,
                        child: GlassPanel(
                          radius: 28,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    QtyStepper(
                                      value: _qty,
                                      onChanged: (v) =>
                                          setState(() => _qty = v),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Total ${money(p.price * _qty)}',
                                      style: dm(14, weight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _ActionButton(
                                        color: kBrown,
                                        onTap: _addToCart,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.add_shopping_cart,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Add to cart',
                                              style: dm(
                                                15,
                                                weight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: _ActionButton(
                                        color: kBuyGreen,
                                        onTap: _buyNow,
                                        child: Center(
                                          child: Text(
                                            'Buy Now',
                                            style: dm(
                                              15,
                                              weight: FontWeight.w600,
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

  Widget _title(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: urbanist(16, weight: FontWeight.w800)),
  );

  Widget _spec(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(k, style: dm(12.5, color: Colors.black54)),
        ),
        Expanded(
          child: Text(v, style: dm(13, weight: FontWeight.w600)),
        ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: kBarGrey,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: kInk),
        const SizedBox(width: 6),
        Text(label, style: dm(12, weight: FontWeight.w600)),
      ],
    ),
  );
}

class _Related extends StatelessWidget {
  const _Related({required this.product, required this.onTap});
  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 12),
    child: Tappable(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: product.tint,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Expanded(child: Image.asset(product.image, fit: BoxFit.contain)),
            const SizedBox(height: 4),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: dm(11, weight: FontWeight.w600),
            ),
            Text(money(product.price), style: dm(11, weight: FontWeight.w800)),
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
  Widget build(BuildContext context) => Center(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 22, color: const Color(0xFF1E58D8)),
          ),
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
      height: 52,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    ),
  );
}
