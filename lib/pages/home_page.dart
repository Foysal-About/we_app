import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';
import 'notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _brand = 0;
  final _scroll = ScrollController();
  final _offset = ValueNotifier<double>(0);
  Timer? _adTimer;
  int _ad = 0;
  bool _adOpen = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() => _offset.value = _scroll.offset);
    _adTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted && _adOpen) setState(() => _ad = (_ad + 1) % 3);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheProductImages(context);
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _scroll.dispose();
    _offset.dispose();
    super.dispose();
  }

  List<Product> _items(Brand brand) =>
      products.where((p) => p.brandId == brand.id).toList();

  List<_Promo> _promos(BuildContext context) => [
    _Promo(
      title: 'Extra 10% off',
      body: 'Code WELCOME10 on your first order',
      icon: Icons.local_offer_rounded,
      colors: const [kAccent, kAccentLight],
      onTap: () {
        app.applyPromo('WELCOME10');
        toast(context, 'WELCOME10 added — see it in your cart');
      },
    ),
    _Promo(
      title: 'Strong foundations',
      body: 'Tiger Cement OPC & PPC, ready to order',
      icon: Icons.foundation_rounded,
      colors: const [kBrandGreen, kGreenLight],
      onTap: () => setState(() => _brand = 0),
    ),
    _Promo(
      title: 'Free delivery',
      body: 'Delivery is ৳0 on every order',
      icon: Icons.local_shipping_rounded,
      colors: const [kDarkGreen, kDarkGreenLight],
      onTap: () => shellIndex.value = 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final brand = brands[_brand];
    final items = _items(brand);
    final tint = items.isEmpty ? kBeige : items.first.tint;

    final scrollView = CustomScrollView(
      controller: _scroll,
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
                top: Radius.circular(Rd.xxl),
              ),
            ),
            padding: const EdgeInsets.only(top: Sp.x6, bottom: Sp.x2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: Sp.page),
                  child: Text('Choose brand', style: _label),
                ),
                const SizedBox(height: Sp.x3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sp.page),
                  child: Row(
                    children: [
                      for (var i = 0; i < brands.length; i++) ...[
                        if (i > 0) const SizedBox(width: Sp.x3),
                        Expanded(
                          child: _BrandTile(
                            brand: brands[i],
                            selected: i == _brand,
                            onTap: () => setState(() => _brand = i),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: Sp.x6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sp.page),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(child: Text(brand.title, style: _label)),
                      Text(
                        '${items.length} ${items.length == 1 ? 'product' : 'products'}',
                        style: dm(12, color: kMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          SliverToBoxAdapter(
            child: Container(
              color: tint,
              height: 240,
              child: const EmptyState(
                icon: Icons.inventory_2_outlined,
                message: 'No products from this brand yet.',
              ),
            ),
          )
        else
          DecoratedSliver(
            decoration: BoxDecoration(color: tint),
            sliver: SliverPadding(
              padding: const EdgeInsets.only(top: Sp.x3),
              sliver: ProductGrid(items: items),
            ),
          ),
        // Room for the floating tab bar.
        SliverFillRemaining(
          hasScrollBody: false,
          child: Container(
            color: tint,
            // Tab bar + the sticky ad above it.
            constraints: BoxConstraints(minHeight: _adOpen ? 220 : 130),
          ),
        ),
      ],
    );
    final inset = MediaQuery.paddingOf(context).bottom;
    // Height of the floating glass tab bar this page sits above.
    final navHeight = 64 + (inset < 12 ? 12.0 : inset);
    final promos = _promos(context);
    return Stack(
      children: [
        scrollView,
        if (_adOpen)
          Positioned(
            left: Sp.x4,
            right: Sp.x4,
            bottom: navHeight + Sp.x2,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.25),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _StickyAd(
                key: ValueKey(_ad),
                promo: promos[_ad],
                onClose: () => setState(() => _adOpen = false),
              ),
            ),
          ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ValueListenableBuilder<double>(
            valueListenable: _offset,
            builder: (_, y, child) {
              // Fades in once the big header's search field has scrolled off.
              final t = ((y - 110) / 60).clamp(0.0, 1.0);
              return IgnorePointer(
                ignoring: t == 0,
                child: Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, -12 * (1 - t)),
                    child: child,
                  ),
                ),
              );
            },
            child: _StickyBar(onSearch: () => shellIndex.value = 1),
          ),
        ),
      ],
    );
  }
}

TextStyle get _label => urbanist(18, weight: FontWeight.w800, color: kInk);

class _Promo {
  const _Promo({
    required this.title,
    required this.body,
    required this.icon,
    required this.colors,
    required this.onTap,
  });
  final String title;
  final String body;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
}

/// Compact ad pinned above the tab bar. Rotates through the offers and can be
/// dismissed for the session.
class _StickyAd extends StatelessWidget {
  const _StickyAd({super.key, required this.promo, required this.onClose});
  final _Promo promo;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${promo.title}. ${promo.body}',
      child: GestureDetector(
        onTap: promo.onTap,
        child: Container(
          height: 72,
          padding: const EdgeInsets.fromLTRB(Sp.x3, Sp.x2, Sp.x1, Sp.x2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Rd.xl),
            gradient: LinearGradient(
              colors: promo.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: promo.colors.first.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
                child: Icon(promo.icon, size: 24, color: Colors.white),
              ),
              const SizedBox(width: Sp.x3),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promo.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: urbanist(
                        18,
                        weight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      promo.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: dm(
                        12,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: promo.colors.first,
                ),
              ),
              IconButton(
                tooltip: 'Dismiss',
                onPressed: onClose,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Time-of-day greeting for the Home header.
String greetingFor([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h >= 5 && h < 12) return 'Good morning';
  if (h >= 12 && h < 17) return 'Good afternoon';
  if (h >= 17 && h < 21) return 'Good evening';
  return 'Good night';
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
        final name = signedIn ? app.name : 'Guest';
        return Padding(
          padding: EdgeInsets.fromLTRB(Sp.page, top + Sp.x3, Sp.page, Sp.x5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand on the left, actions on the right.
              Row(
                children: [
                  const WeLogo(width: 56),
                  const Spacer(),
                  const _BellButton(),
                  const SizedBox(width: Sp.x2),
                  Semantics(
                    button: true,
                    label: 'Open profile',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => shellIndex.value = 4,
                      child: CircleAvatar(
                        radius: Sp.control / 2,
                        backgroundColor: kBeige,
                        child: Text(
                          name[0].toUpperCase(),
                          style: urbanist(
                            18,
                            weight: FontWeight.w800,
                            color: kBrandGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Sp.x5),
              // Large greeting.
              Text(greetingFor(), style: dm(14, color: kMuted)),
              const SizedBox(height: Sp.x1),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: urbanist(26, weight: FontWeight.w800, color: kInk),
              ),
              const SizedBox(height: Sp.x4),
              // Search.
              Tappable(
                onTap: onSearch,
                child: Container(
                  height: Sp.control,
                  padding: const EdgeInsets.symmetric(horizontal: Sp.x4),
                  decoration: BoxDecoration(
                    color: kBarGrey,
                    borderRadius: BorderRadius.circular(Rd.lg),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/search_field.svg'),
                      const SizedBox(width: Sp.x3),
                      Text(
                        'Search cement, bricks…',
                        style: dm(14, color: kMuted),
                      ),
                    ],
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

/// Notification bell with an unread dot. Shared by the header and sticky bar.
class _BellButton extends StatelessWidget {
  const _BellButton();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final unread = !app.notificationsSeen && app.orders.isNotEmpty;
        return Semantics(
          button: true,
          label: 'Notifications',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              app.markNotificationsSeen();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
            child: Container(
              width: Sp.control,
              height: Sp.control,
              decoration: const BoxDecoration(
                color: kBarGrey,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 24,
                    color: kInk,
                  ),
                  if (unread)
                    Positioned(
                      right: 12,
                      top: 11,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: kFavorite,
                          shape: BoxShape.circle,
                          border: Border.all(color: kBarGrey, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Compact frosted-glass bar pinned to the top of Home once you scroll:
/// logo, a search pill and the bell.
class _StickyBar extends StatelessWidget {
  const _StickyBar({required this.onSearch});
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return GlassBar(
      padding: EdgeInsets.fromLTRB(Sp.page, top + Sp.x2, Sp.page, Sp.x2),
      child: Row(
        children: [
          const WeLogo(width: 44),
          const SizedBox(width: Sp.x3),
          Expanded(
            child: Tappable(
              onTap: onSearch,
              child: Container(
                height: Sp.control,
                padding: const EdgeInsets.symmetric(horizontal: Sp.x4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(Rd.pill),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, size: 20, color: kMuted),
                    const SizedBox(width: Sp.x2),
                    Expanded(
                      child: Text(
                        'Search cement, bricks…',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: dm(14, color: kMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: Sp.x3),
          const _BellButton(),
        ],
      ),
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
          padding: const EdgeInsets.fromLTRB(Sp.x1, 5, 0, 0),
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
        height: 72,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Rd.md),
          border: Border.all(
            color: selected ? kAccent : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected ? Elev.card : null,
        ),
        // Logos are laid out for a 118x70 box; scale that box to the tile.
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(width: 118, height: 70, child: _logo()),
        ),
      ),
    );
  }
}
