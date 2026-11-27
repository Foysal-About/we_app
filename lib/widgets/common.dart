import 'dart:ui' show ImageFilter;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../core/models.dart';
import '../core/theme.dart';

/// Which tab of the main shell is showing (0 home … 4 profile).
final shellIndex = ValueNotifier<int>(0);

/// One way to show any product picture, everywhere: centred, never cropped,
/// smooth scaling, a soft fade-in instead of popping, and a calm fallback if
/// the file is missing. Opaque JPGs get their white background blended into
/// the surface behind them so they sit naturally on a tinted panel.
class ProductImage extends StatelessWidget {
  const ProductImage(
    this.asset, {
    super.key,
    this.background = kPanel,
    this.fit = BoxFit.contain,
  });
  final String asset;
  final BoxFit fit;

  /// Colour of the surface behind the picture (used to blend opaque JPGs).
  final Color background;

  /// Fills the frame for every product. Scene photos cover it edge to edge
  /// (the parent clips the corners); transparent cut-outs scale up to the
  /// edges with only a thin margin and are never cropped. [contain] shows a
  /// photo whole instead (hero and zoom views).
  static Widget of(
    Product p, {
    Color background = kPanel,
    bool contain = false,
  }) {
    if (!p.photo) {
      return Padding(
        padding: const EdgeInsets.all(Sp.x1),
        child: ProductImage(p.image, background: background),
      );
    }
    if (contain) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(Rd.sm),
        child: ProductImage(p.image, background: background),
      );
    }
    return SizedBox.expand(
      child: ProductImage(p.image, background: background, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opaque = asset.toLowerCase().endsWith('.jpg');
    return Image.asset(
      asset,
      fit: fit,
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      gaplessPlayback: true,
      color: opaque ? background : null,
      colorBlendMode: opaque ? BlendMode.multiply : null,
      frameBuilder: (_, child, frame, sync) => sync
          ? child
          : AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              child: child,
            ),
      errorBuilder: (_, _, _) => const Center(
        child: Icon(Icons.image_not_supported_outlined, color: kSubtle),
      ),
    );
  }
}

/// Loads every product picture into the image cache so screens open with the
/// image already there.
void precacheProductImages(BuildContext context) {
  for (final p in products) {
    precacheImage(AssetImage(p.image), context);
  }
}

class WeLogo extends StatelessWidget {
  const WeLogo({super.key, this.width = 90});
  final double width;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/we_logo.png',
    width: width,
    fit: BoxFit.contain,
  );
}

class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        height: Sp.x12,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 54,
            height: 36,
            decoration: BoxDecoration(
              color: kBarGrey,
              borderRadius: BorderRadius.circular(Rd.pill),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: kInk),
          ),
        ),
      ),
    );
  }
}

/// The app's standard raised card: white, rounded, soft shadow. Pass
/// [onTap] to make the whole card a button with an ink ripple.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Sp.x4),
    this.radius = Rd.lg,
    this.onTap,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: r,
        boxShadow: Elev.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: r,
        child: InkWell(
          onTap: onTap,
          borderRadius: r,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Frosted-glass surface: blurs what is behind it, with a bright-to-soft white
/// gradient so it reads as glass (not transparent, not a flat white bar).
class GlassBar extends StatelessWidget {
  const GlassBar({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final solid = MediaQuery.highContrastOf(context);
    final bar = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: solid ? Colors.white : null,
        gradient: solid
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.86),
                  Colors.white.withValues(alpha: 0.66),
                ],
              ),
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.07)),
        ),
        boxShadow: solid
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
    if (solid) return bar;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: bar,
      ),
    );
  }
}

/// Marks that an ancestor already provides the glass (see GlassHeaderColumn).
class _InGlass extends InheritedWidget {
  const _InGlass({required super.child});
  static bool of(BuildContext c) =>
      c.getInheritedWidgetOfExactType<_InGlass>() != null;
  @override
  bool updateShouldNotify(_InGlass old) => false;
}

/// Height of the glass top area, for bodies that scroll underneath it.
class GlassTopInset extends InheritedNotifier<ValueNotifier<double>> {
  const GlassTopInset({
    super.key,
    required ValueNotifier<double> inset,
    required super.child,
  }) : super(notifier: inset);

  /// Inset below the glass top area (0 outside a [GlassHeaderColumn]).
  static double of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<GlassTopInset>();
    final v = w?.notifier?.value ?? 0;
    if (w == null) return 0; // not under a glass top area
    return v > 0 ? v : PageHeader.heightOf(context);
  }
}

/// First item of a list under a [GlassHeaderColumn]: pushes the content down
/// so it starts below the glass, then scrolls up beneath it.
class GlassInsetSpacer extends StatelessWidget {
  const GlassInsetSpacer({super.key});

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: GlassTopInset.of(context));
}

/// Page header: back button, centred title or logo. On its own it is a glass
/// bar; inside a [GlassHeaderColumn] the column supplies the glass instead.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, this.title, this.onBack, this.showLogo = false});
  final String? title;
  final VoidCallback? onBack;
  final bool showLogo;

  /// Total height of the bar including the status-bar inset.
  static double heightOf(BuildContext context) =>
      MediaQuery.paddingOf(context).top + 12 + 40 + 12;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.fromLTRB(
        Sp.page,
        MediaQuery.paddingOf(context).top + 12,
        Sp.page,
        12,
      ),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CircleBackButton(onTap: onBack),
            ),
            if (showLogo) const WeLogo(width: 72),
            if (title != null)
              Text(title!, style: urbanist(20, weight: FontWeight.w700)),
          ],
        ),
      ),
    );
    return _InGlass.of(context) ? content : GlassBar(child: content);
  }
}

/// Lays out `[top widgets…, Expanded(body)]` with one glass surface over the
/// top widgets; the body fills the whole area and scrolls *under* the glass.
/// The body reads [GlassTopInset.of] (from a Builder inside it) to pad its top.
class GlassHeaderColumn extends StatefulWidget {
  const GlassHeaderColumn({super.key, required this.children})
    : assert(children.length >= 2);
  final List<Widget> children;

  @override
  State<GlassHeaderColumn> createState() => _GlassHeaderColumnState();
}

class _GlassHeaderColumnState extends State<GlassHeaderColumn> {
  final _topKey = GlobalKey();
  final _inset = ValueNotifier<double>(0);

  void _measure() {
    final h = _topKey.currentContext?.size?.height;
    if (h != null && h != _inset.value) _inset.value = h;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void dispose() {
    _inset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = widget.children.last;
    final top = widget.children.sublist(0, widget.children.length - 1);
    return GlassTopInset(
      inset: _inset,
      child: Stack(
        children: [
          Positioned.fill(child: last is Expanded ? last.child : last),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NotificationListener<SizeChangedLayoutNotification>(
              onNotification: (_) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
                return true;
              },
              child: SizeChangedLayoutNotifier(
                child: _InGlass(
                  child: GlassBar(
                    child: Column(
                      key: _topKey,
                      mainAxisSize: MainAxisSize.min,
                      children: top,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill-shaped segmented tabs (Log In / Sign Up, Delivered / Processing …).
class PillTabs extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    this.background = Colors.white,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Sp.control,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Rd.pill),
        border: Border.all(color: kBarGrey),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(Rd.pill),
                  ),
                  child: Text(
                    labels[i],
                    style: dm(
                      14,
                      weight: FontWeight.w600,
                      color: i == index ? Colors.white : kInk,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.black26),
            const SizedBox(height: Sp.x3),
            Text(
              message,
              textAlign: TextAlign.center,
              style: dm(15, color: kMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small +/- quantity control used on the product page.
class QtyStepper extends StatelessWidget {
  const QtyStepper({super.key, required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData i, VoidCallback f) => GestureDetector(
      onTap: f,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: kMuted),
        ),
        child: Icon(i, size: 15),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(Icons.remove, () => value > 1 ? onChanged(value - 1) : null),
        SizedBox(
          width: 40,
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: dm(16, weight: FontWeight.w500),
            ),
          ),
        ),
        btn(Icons.add, () => onChanged(value + 1)),
      ],
    );
  }
}

/// Rounded white text field used in forms and sheets.
class WeTextField extends StatelessWidget {
  const WeTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboard,
    this.maxLines = 1,
    this.obscure = false,
    this.formatters,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final int maxLines;
  final bool obscure;
  final List<TextInputFormatter>? formatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      obscureText: obscure,
      inputFormatters: formatters,
      style: dm(14, weight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: dm(12, color: kMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Sp.x4,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Rd.lg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 16,
  });
  final int value;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          GestureDetector(
            onTap: onChanged == null ? null : () => onChanged!(i),
            child: Icon(
              i <= value ? Icons.star : Icons.star_border,
              size: size,
              color: const Color(0xFFA73016),
            ),
          ),
      ],
    );
  }
}

/// Green pill button used for primary actions.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = Colors.black,
    this.width,
  });
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Container(
          width: width,
          height: Sp.control,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(Rd.pill),
          ),
          child: Text(
            label,
            style: dm(15, weight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet with a title and a form body that lifts above the keyboard.
Future<T?> showFormSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: kBarGrey,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(Rd.xxl)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.viewInsetsOf(ctx).bottom + 28,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: urbanist(22, weight: FontWeight.w700)),
            const SizedBox(height: Sp.x4),
            child,
          ],
        ),
      ),
    ),
  );
}

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}

/// Adds a subtle press-scale and haptic tick to any tappable widget.
class Tappable extends StatefulWidget {
  const Tappable({super.key, required this.child, required this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<Tappable> createState() => _TappableState();
}

class _TappableState extends State<Tappable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 90),
        child: widget.child,
      ),
    );
  }
}

/// Cart → Payment → Done progress shown through the checkout flow.
class CheckoutSteps extends StatelessWidget {
  const CheckoutSteps({super.key, required this.current});
  final int current; // 0 cart, 1 payment, 2 done

  static const _labels = ['Cart', 'Payment', 'Done'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sp.x8, vertical: 6),
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: i <= current ? kBrandGreen : kBarGrey,
                  child: i < current
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : Text(
                          '${i + 1}',
                          style: dm(
                            11,
                            weight: FontWeight.w700,
                            color: i <= current ? Colors.white : kMuted,
                          ),
                        ),
                ),
                const SizedBox(height: Sp.x1),
                Text(
                  _labels[i],
                  style: dm(
                    11,
                    weight: i == current ? FontWeight.w700 : FontWeight.w500,
                    color: i <= current ? Colors.black : kSubtle,
                  ),
                ),
              ],
            ),
            if (i < _labels.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 18, left: 6, right: 6),
                  color: i < current ? kBrandGreen : kBarGrey,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Frosted-glass surface: blurs whatever scrolls behind it.
///
/// Falls back to a solid surface when the system asks for high contrast, so
/// the content on top always stays readable.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = 32,
    this.blur = 16,
    this.tint = Colors.white,
    this.opacity = 0.62,
  });

  final Widget child;
  final double radius;
  final double blur;
  final Color tint;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final solid = MediaQuery.highContrastOf(context);
    final r = BorderRadius.circular(radius);
    final surface = Container(
      decoration: BoxDecoration(
        borderRadius: r,
        gradient: solid
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(alpha: opacity + 0.12),
                  tint.withValues(alpha: opacity - 0.08),
                ],
              ),
        color: solid ? kBarGrey : null,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 1.2,
        ),
      ),
      child: child,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        clipBehavior: Clip.antiAlias,
        child: solid
            ? surface
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: surface,
              ),
      ),
    );
  }
}

/// Friendly empty state: icon in a soft circle, title, message, optional CTA.
class EmptyHero extends StatelessWidget {
  const EmptyHero({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.tint = kBeige,
    this.iconColor = kAccent,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Sp.x8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                child: Icon(icon, size: 48, color: iconColor),
              ),
              const SizedBox(height: Sp.x6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: urbanist(22, weight: FontWeight.w800, color: kInk),
              ),
              const SizedBox(height: Sp.x2),
              Text(
                message,
                textAlign: TextAlign.center,
                style: dm(14, color: kMuted),
              ),
              if (actionLabel != null) ...[
                const SizedBox(height: Sp.x6),
                PrimaryButton(
                  label: actionLabel!,
                  color: kBrandGreen,
                  onTap: onAction,
                ),
              ],
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }
}
