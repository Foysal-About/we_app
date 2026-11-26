import 'dart:ui' show ImageFilter;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Which tab of the main shell is showing (0 home … 4 profile).
final shellIndex = ValueNotifier<int>(0);

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
        height: 48,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 54,
            height: 36,
            decoration: BoxDecoration(
              color: kBarGrey,
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.arrow_back, size: 20, color: kInk),
          ),
        ),
      ),
    );
  }
}

/// Page header: back button, centred title or logo.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, this.title, this.onBack, this.showLogo = false});
  final String? title;
  final VoidCallback? onBack;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 12,
        20,
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
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(40),
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
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(
                    labels[i],
                    style: dm(
                      14,
                      weight: FontWeight.w600,
                      color: i == index ? Colors.white : Colors.black87,
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
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: dm(15, color: Colors.black54),
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
          border: Border.all(color: Colors.black54),
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
        labelStyle: dm(12, color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
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
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
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
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
            const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
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
                            color: i <= current ? Colors.white : Colors.black54,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  _labels[i],
                  style: dm(
                    11,
                    weight: i == current ? FontWeight.w700 : FontWeight.w500,
                    color: i <= current ? Colors.black : Colors.black45,
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
