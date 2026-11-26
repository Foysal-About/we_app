import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';
import 'notifications_page.dart';
import 'product_detail_page.dart';

enum _Sort { popular, priceLow, priceHigh }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _brand = 0;
  _Sort _sort = _Sort.popular;

  List<Product> _items(Brand brand) {
    final items = products.where((p) => p.brandId == brand.id).toList();
    switch (_sort) {
      case _Sort.popular:
        break;
      case _Sort.priceLow:
        items.sort((a, b) => a.price.compareTo(b.price));
      case _Sort.priceHigh:
        items.sort((a, b) => b.price.compareTo(a.price));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final brand = brands[_brand];
    final items = _items(brand);
    final tint = items.isEmpty ? kBeige : items.first.tint;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Header(onSearch: () => shellIndex.value = 1),
        ),
        SliverToBoxAdapter(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PromoCarousel(onBrand: () => setState(() => _brand = 0)),
                ListenableBuilder(
                  listenable: app,
                  builder: (context, _) => app.viewed.isEmpty
                      ? const SizedBox(height: 22)
                      : _RecentlyViewed(ids: List.of(app.viewed)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 23),
                  child: Text('Choose Brand', style: _label),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < brands.length; i++)
                        _BrandTile(
                          brand: brands[i],
                          selected: i == _brand,
                          onTap: () => setState(() => _brand = i),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Padding(
                  padding: const EdgeInsets.only(left: 23),
                  child: Text(brand.title, style: _label),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 19),
                    children: [
                      _SortChip(
                        'Popular',
                        _sort == _Sort.popular,
                        () => setState(() => _sort = _Sort.popular),
                      ),
                      _SortChip(
                        'Price: low to high',
                        _sort == _Sort.priceLow,
                        () => setState(() => _sort = _Sort.priceLow),
                      ),
                      _SortChip(
                        'Price: high to low',
                        _sort == _Sort.priceHigh,
                        () => setState(() => _sort = _Sort.priceHigh),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: tint,
              child: const EmptyState(
                icon: Icons.inventory_2_outlined,
                message: 'No products from this brand yet.',
              ),
            ),
          )
        else ...[
          DecoratedSliver(
            decoration: BoxDecoration(color: tint),
            sliver: SliverPadding(
              padding: const EdgeInsets.only(top: 12),
              sliver: ProductGrid(items: items),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: tint,
              constraints: const BoxConstraints(minHeight: 130),
            ),
          ),
        ],
      ],
    );
  }
}

TextStyle get _label =>
    dm(16, height: 21 / 16, color: Colors.black.withValues(alpha: 0.7));

class _SortChip extends StatelessWidget {
  const _SortChip(this.label, this.selected, this.onTap);
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tappable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected
                ? Colors.black
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            style: dm(
              13,
              weight: FontWeight.w600,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel({required this.onBrand});
  final VoidCallback onBrand;

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  final _controller = PageController(viewportFraction: 0.88);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = [
      _Banner(
        title: 'Extra 10% off',
        body: 'Apply code WELCOME10 to your cart',
        cta: 'Apply code',
        icon: Icons.local_offer_outlined,
        colors: const [Color(0xFFE36B35), Color(0xFFF2A154)],
        onTap: () {
          app.applyPromo('WELCOME10');
          toast(context, 'WELCOME10 added — see it in your cart');
        },
      ),
      _Banner(
        title: 'Strong foundations',
        body: 'Tiger Cement OPC & PPC, ready to order',
        cta: 'Shop cement',
        icon: Icons.foundation_outlined,
        colors: const [Color(0xFF0D9032), Color(0xFF5CBF6B)],
        onTap: widget.onBrand,
      ),
      _Banner(
        title: 'Free delivery',
        body: 'Delivery charges are ৳0 on every order',
        cta: 'View cart',
        icon: Icons.local_shipping_outlined,
        colors: const [Color(0xFF1F5E2F), Color(0xFF3F8F4F)],
        onTap: () => shellIndex.value = 2,
      ),
    ];
    return Column(
      children: [
        SizedBox(
          height: 128,
          child: PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: banners[i],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < banners.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page ? Colors.black87 : Colors.black26,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.title,
    required this.body,
    required this.cta,
    required this.icon,
    required this.colors,
    required this.onTap,
  });
  final String title;
  final String body;
  final String cta;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -22,
            child: Icon(
              icon,
              size: 120,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: urbanist(
                    20,
                    weight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: dm(12, color: Colors.white.withValues(alpha: 0.92)),
                ),
                const Spacer(),
                Tappable(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cta,
                      style: dm(
                        12,
                        weight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onSearch});
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final signedIn = app.name.isNotEmpty;
        final unread = !app.notificationsSeen && app.orders.isNotEmpty;
        return SizedBox(
          height: top + 244,
          child: Stack(
            children: [
              Positioned(
                top: top + 8,
                left: 0,
                right: 0,
                child: const Center(child: WeLogo(width: 118)),
              ),
              Positioned(
                left: 32,
                top: top + 34.5,
                child: SvgPicture.asset('assets/icons/menu.svg'),
              ),
              Positioned(
                right: 24,
                top: top + 26,
                child: Semantics(
                  button: true,
                  label: 'Notifications',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      app.markNotificationsSeen();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsPage(),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            size: 30,
                            color: kInk,
                          ),
                          if (unread)
                            Positioned(
                              right: 11,
                              top: 10,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE53935),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 34,
                right: 40,
                top: top + 89,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: signedIn ? 'Welcome back\n' : 'Discover our\n',
                        style: urbanist(
                          24,
                          color: Colors.black.withValues(alpha: 0.5),
                          height: 29 / 24,
                        ),
                      ),
                      TextSpan(
                        text: signedIn ? app.name : 'perfect product',
                        style: urbanist(
                          24,
                          weight: FontWeight.w700,
                          height: 29 / 24,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                left: 32,
                right: 33,
                top: top + 166,
                child: Tappable(
                  onTap: onSearch,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: kBarGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/icons/search_field.svg'),
                        const SizedBox(width: 12),
                        Text(
                          'Search...',
                          style: dm(
                            16,
                            weight: FontWeight.w500,
                            height: 1.5,
                            spacing: -0.4,
                            color: kInk.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({
    required this.brand,
    required this.selected,
    required this.onTap,
  });
  final Brand brand;
  final bool selected;
  final VoidCallback onTap;

  Widget _logo() {
    switch (brand.id) {
      case 'concrete':
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -28,
              top: -78,
              width: 174,
              height: 238.77,
              child: Image.asset(brand.logo, fit: BoxFit.fill),
            ),
          ],
        );
      case 'sjil':
        return Padding(
          padding: const EdgeInsets.fromLTRB(4, 5, 0, 0),
          child: Image.asset(
            brand.logo,
            width: 114,
            height: 60,
            fit: BoxFit.cover,
          ),
        );
      default:
        return Image.asset(brand.logo, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 118,
        height: 70,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFFEFEFE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFFE36B35) : Colors.transparent,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: _logo(),
      ),
    );
  }
}

class _RecentlyViewed extends StatelessWidget {
  const _RecentlyViewed({required this.ids});
  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.only(left: 23),
          child: Text('Recently viewed', style: _label),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 74,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 19),
            children: [
              for (final id in ids)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Tappable(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailPage(product: productById(id)),
                      ),
                    ),
                    child: Container(
                      width: 190,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            productById(id).image,
                            width: 54,
                            height: 54,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productById(id).name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: dm(12, weight: FontWeight.w700),
                                ),
                                Text(
                                  money(productById(id).price),
                                  style: dm(12, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }
}
