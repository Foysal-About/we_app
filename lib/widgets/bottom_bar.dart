import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import 'common.dart';

/// Floating frosted-glass tab bar. The active tab expands into a green pill
/// with its label; content scrolls behind the glass (Scaffold.extendBody).
class WeBottomBar extends StatelessWidget {
  const WeBottomBar({super.key, required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  static const _icons = [
    'assets/icons/nav_home.svg',
    'assets/icons/nav_search.svg',
    'assets/icons/nav_cart.svg',
    'assets/icons/nav_heart.svg',
    'assets/icons/nav_user.svg',
  ];
  static const _labels = ['Home', 'Search', 'Cart', 'Saved', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => Padding(
        padding: EdgeInsets.fromLTRB(
          Sp.x4,
          0,
          Sp.x4,
          bottom < 12 ? 12 : bottom,
        ),
        child: GlassPanel(
          child: SizedBox(
            height: 64,
            child: LayoutBuilder(
              builder: (context, c) {
                const pad = 10.0;
                const small = 52.0;
                final inner = c.maxWidth - pad * 2;
                final big = (inner - small * 4).clamp(small, 116.0);
                final gap = (inner - small * 4 - big) / 4;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: pad),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _icons.length; i++) ...[
                        _NavItem(
                          icon: _icons[i],
                          label: _labels[i],
                          active: index == i,
                          width: index == i ? big : small,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onChanged(i);
                          },
                          badge: i == 2
                              ? app.cartCount
                              : i == 3
                              ? app.favorites.length
                              : 0,
                          badgeColor: i == 2 ? kAccent : kInfo,
                          badgeTextColor: i == 2 ? Colors.white : kInk,
                        ),
                        if (i < _icons.length - 1)
                          SizedBox(width: gap.clamp(0, 40)),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.width,
    required this.onTap,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
  });

  final String icon;
  final String label;
  final bool active;
  final double width;
  final VoidCallback onTap;
  final int badge;
  final Color badgeColor;
  final Color badgeTextColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: width,
          height: 46,
          decoration: BoxDecoration(
            color: active ? kBrandGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(Rd.pill),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: kBrandGreen.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              ClipRect(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      icon,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        active ? Colors.white : kInk,
                        BlendMode.srcIn,
                      ),
                    ),
                    if (active)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            label,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
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
              if (badge > 0)
                Positioned(
                  right: active ? 4 : 2,
                  top: -2,
                  child: IgnorePointer(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      transitionBuilder: (child, a) => ScaleTransition(
                        scale: CurvedAnimation(
                          parent: a,
                          curve: Curves.elasticOut,
                        ),
                        child: child,
                      ),
                      child: Container(
                        key: ValueKey(badge),
                        height: 16,
                        constraints: const BoxConstraints(minWidth: 16),
                        padding: const EdgeInsets.symmetric(horizontal: Sp.x1),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(Rd.pill),
                          border: Border.all(color: Colors.white, width: 1.2),
                        ),
                        child: Text(
                          badge > 99 ? '99+' : '$badge',
                          style: dm(
                            8.5,
                            weight: FontWeight.w700,
                            color: badgeTextColor,
                          ),
                        ),
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
