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
    return Column(
      children: [
        PageHeader(title: 'Search', onBack: () => shellIndex.value = 0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            height: 48,
            padding: const EdgeInsets.only(left: 16, right: 4),
            decoration: BoxDecoration(
              color: kBarGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                SvgPicture.asset('assets/icons/search_field.svg'),
                const SizedBox(width: 12),
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
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 130),
        children: [
          if (app.recentSearches.isNotEmpty) ...[
            Row(
              children: [
                Text('Recent', style: urbanist(16, weight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                  onPressed: app.clearRecentSearches,
                  child: Text('Clear', style: dm(12, color: Colors.black54)),
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
            style: urbanist(16, weight: FontWeight.w700),
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
          Text('Browse all', style: urbanist(16, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          for (final p in products) _ResultTile(product: p),
        ],
      ),
    );
  }

  Widget _results(List<Product> results) {
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        message: 'No products match your search.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 130),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '${results.length} ${results.length == 1 ? 'result' : 'results'}',
            style: dm(12, color: Colors.black54),
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
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        if (query != null) app.addRecentSearch(query!);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: product.tint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.asset(product.image, fit: BoxFit.contain),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: urbanist(16, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(brand.title, style: dm(12, color: Colors.black54)),
                ],
              ),
            ),
            Text(money(product.price), style: dm(15, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
