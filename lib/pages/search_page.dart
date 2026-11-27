import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'product_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  String _q = '';

  static const _popular = ['Cement', 'OPC', 'PPC', 'Brick', 'Hollow'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _set(String v) {
    _controller.value = TextEditingValue(
      text: v,
      selection: TextSelection.collapsed(offset: v.length),
    );
    setState(() => _q = v);
  }

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final results = products.where((p) {
      final brand = brands.firstWhere((b) => b.id == p.brandId).title;
      return p.name.toLowerCase().contains(q) ||
          brand.toLowerCase().contains(q);
    }).toList();
    return GlassHeaderColumn(
      children: [
        PageHeader(title: 'Search', onBack: () => shellIndex.value = 0),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Sp.page,
            vertical: Sp.x2,
          ),
          child: Container(
            height: Sp.control,
            padding: const EdgeInsets.only(left: Sp.x4, right: Sp.x1),
            decoration: BoxDecoration(
              color: kBarGrey,
              borderRadius: BorderRadius.circular(Rd.lg),
            ),
            child: Row(
              children: [
                SvgPicture.asset('assets/icons/search_field.svg'),
                const SizedBox(width: Sp.x3),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (v) => setState(() => _q = v),
                    onSubmitted: app.addRecentSearch,
                    textInputAction: TextInputAction.search,
                    style: dm(16, weight: FontWeight.w500, color: kInk),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search product',
                      hintStyle: dm(
                        16,
                        weight: FontWeight.w500,
                        color: kInk.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                if (_q.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear',
                    onPressed: () => _set(''),
                    icon: const Icon(Icons.close, size: 20),
                  ),
              ],
            ),
          ),
        ),
        Expanded(child: q.isEmpty ? _suggestions() : _results(results)),
      ],
    );
  }

  Widget _suggestions() {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x3, Sp.page, 130),
        children: [
          const GlassInsetSpacer(),
          if (app.recentSearches.isNotEmpty) ...[
            Row(
              children: [
                Text('Recent', style: urbanist(16, weight: FontWeight.w800)),
                const Spacer(),
                TextButton(
                  onPressed: app.clearRecentSearches,
                  child: Text('Clear', style: dm(12, color: kMuted)),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in app.recentSearches)
                  ActionChip(
                    avatar: const Icon(Icons.history, size: 16),
                    label: Text(r),
                    onPressed: () => _set(r),
                  ),
              ],
            ),
            const SizedBox(height: 22),
          ],
          Text(
            'Popular searches',
            style: urbanist(16, weight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in _popular)
                ActionChip(
                  avatar: const Icon(Icons.trending_up, size: 16),
                  label: Text(p),
                  onPressed: () => _set(p),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Text('Browse all', style: urbanist(16, weight: FontWeight.w800)),
          const SizedBox(height: Sp.x1),
          for (final p in products) _ResultTile(product: p),
        ],
      ),
    );
  }

  Widget _results(List<Product> results) {
    if (results.isEmpty) {
      return Builder(
        builder: (c) => Padding(
          padding: EdgeInsets.only(top: GlassTopInset.of(c)),
          child: const EmptyState(
            icon: Icons.search_off,
            message: 'No products match your search.',
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(Sp.page, Sp.x1, Sp.page, 130),
      children: [
        const GlassInsetSpacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: Sp.x1),
          child: Text(
            '${results.length} ${results.length == 1 ? 'result' : 'results'}',
            style: dm(12, color: kMuted),
          ),
        ),
        for (final p in results) _ResultTile(product: p, query: _q),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.product, this.query});
  final Product product;
  final String? query;

  @override
  Widget build(BuildContext context) {
    final brand = brands.firstWhere((b) => b.id == product.brandId);
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.x3),
      child: Tappable(
        onTap: () {
          if (query != null) app.addRecentSearch(query!);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: product),
            ),
          );
        },
        child: SurfaceCard(
          padding: const EdgeInsets.all(Sp.x3),
          radius: Rd.lg,
          child: Row(
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: kPanel,
                  borderRadius: BorderRadius.circular(Rd.md),
                ),
                child: ProductImage.of(product),
              ),
              const SizedBox(width: Sp.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: dm(14, weight: FontWeight.w700, color: kInk),
                    ),
                    Text(
                      brand.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: dm(12, color: kMuted),
                    ),
                    const SizedBox(height: Sp.x1),
                    Row(
                      children: [
                        Text(
                          money(product.price),
                          style: urbanist(
                            16,
                            weight: FontWeight.w800,
                            color: product.oldPrice != null ? kBuyGreen : kInk,
                          ),
                        ),
                        Text(
                          ' / ${product.unit}',
                          style: dm(12, color: kMuted),
                        ),
                        if (product.oldPrice != null) ...[
                          const SizedBox(width: Sp.x2),
                          Text(
                            money(product.oldPrice!),
                            style: dm(
                              12,
                              color: kSubtle,
                            ).copyWith(decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Sp.x2),
              // Quick add.
              Tooltip(
                message: 'Add to cart',
                child: Tappable(
                  onTap: () {
                    app.addToCart(product.id);
                    toast(context, '${product.name} added to cart');
                  },
                  child: Container(
                    width: Sp.control,
                    height: Sp.control,
                    decoration: const BoxDecoration(
                      color: kBrandGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                      size: 22,
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
