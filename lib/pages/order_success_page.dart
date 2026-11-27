import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'order_details_page.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Soft green wash behind the celebration.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 380,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kSoftGreen, kSoftGreen.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: MediaQuery.paddingOf(context).top + Sp.x6),
              const CheckoutSteps(current: 2),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sp.page,
                      vertical: Sp.x4,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _Burst(),
                        const SizedBox(height: Sp.x6),
                        _FadeUp(
                          delay: 0.25,
                          child: Text(
                            'Order placed!',
                            style: urbanist(
                              26,
                              weight: FontWeight.w800,
                              color: kInk,
                            ),
                          ),
                        ),
                        const SizedBox(height: Sp.x2),
                        _FadeUp(
                          delay: 0.35,
                          child: Text(
                            'Thank you for shopping with WE.\nWe will keep you posted on your delivery.',
                            textAlign: TextAlign.center,
                            style: dm(14, color: kMuted),
                          ),
                        ),
                        const SizedBox(height: Sp.x6),
                        _FadeUp(delay: 0.5, child: _Receipt(order: order)),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  Sp.page,
                  Sp.x3,
                  Sp.page,
                  bottom + Sp.x4,
                ),
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PrimaryButton(
                      label: 'View order',
                      color: kBrandGreen,
                      width: double.infinity,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsPage(order: order),
                        ),
                      ),
                    ),
                    const SizedBox(height: Sp.x1),
                    TextButton(
                      onPressed: () {
                        shellIndex.value = 0;
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                      child: Text(
                        'Continue shopping',
                        style: dm(14, weight: FontWeight.w700, color: kInk),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Check badge that pops in with two soft rings expanding behind it.
class _Burst extends StatelessWidget {
  const _Burst();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (_, t, _) {
        final pop = Curves.elasticOut.transform((t * 1.4).clamp(0.0, 1.0));
        double ring(double from) =>
            Curves.easeOut.transform(((t - from) / (1 - from)).clamp(0.0, 1.0));
        Widget halo(double size, double r, double alpha) => Opacity(
          opacity: (1 - r) * alpha,
          child: Container(
            width: size * (0.7 + 0.3 * r),
            height: size * (0.7 + 0.3 * r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kBrandGreen.withValues(alpha: 0.18),
            ),
          ),
        );
        return SizedBox(
          width: 190,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              halo(190, ring(0.0), 1),
              halo(150, ring(0.15), 1),
              Transform.scale(
                scale: pop,
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: kBrandGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kBrandGreen.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 60),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Fades and lifts its child in, starting `delay` (0–1) into a 1s animation.
class _FadeUp extends StatelessWidget {
  const _FadeUp({required this.delay, required this.child});
  final double delay;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 1000),
    curve: Interval(delay, 1, curve: Curves.easeOutCubic),
    builder: (_, v, c) => Opacity(
      opacity: v,
      child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: c),
    ),
    child: child,
  );
}

/// Ticket-style receipt: items, a dashed tear line, then the details.
class _Receipt extends StatelessWidget {
  const _Receipt({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final items = order.items.take(3).toList();
    final more = order.items.length - items.length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Sp.x5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Rd.xl),
        boxShadow: Elev.raised,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order number', style: dm(12, color: kMuted)),
                    Text(
                      order.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: urbanist(18, weight: FontWeight.w800, color: kInk),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Copy order number',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: order.id));
                  toast(context, 'Order number copied');
                },
                icon: const Icon(Icons.copy_rounded, size: 20, color: kMuted),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: Sp.x3),
            for (final it in items) _ItemRow(item: it),
            if (more > 0)
              Padding(
                padding: const EdgeInsets.only(top: Sp.x1),
                child: Text(
                  '+ $more more ${more == 1 ? 'item' : 'items'}',
                  style: dm(12, color: kMuted),
                ),
              ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Sp.x4),
            child: _Dashed(),
          ),
          _Row(Icons.payments_outlined, 'Payment', order.payment),
          _Row(
            Icons.local_shipping_outlined,
            'Estimated delivery',
            order.estimatedDelivery,
          ),
          const SizedBox(height: Sp.x2),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Sp.x4,
              vertical: Sp.x3,
            ),
            decoration: BoxDecoration(
              color: kSoftGreen.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(Rd.lg),
            ),
            child: Row(
              children: [
                Text(
                  'Total',
                  style: dm(14, weight: FontWeight.w700, color: kBuyGreen),
                ),
                const Spacer(),
                Text(
                  money(order.total),
                  style: urbanist(
                    22,
                    weight: FontWeight.w800,
                    color: kBuyGreen,
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

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final p = productById(item.productId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.x1),
      child: Row(
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kPanel,
              borderRadius: BorderRadius.circular(Rd.md),
            ),
            child: ProductImage.of(p),
          ),
          const SizedBox(width: Sp.x3),
          Expanded(
            child: Text(
              p.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: dm(14, weight: FontWeight.w600, color: kInk),
            ),
          ),
          Text('× ${item.qty}', style: dm(14, color: kMuted)),
        ],
      ),
    );
  }
}

class _Dashed extends StatelessWidget {
  const _Dashed();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) {
      final n = (c.maxWidth / 10).floor();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < n; i++)
            Container(width: 5, height: 1.5, color: kBarGrey),
        ],
      );
    },
  );
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.k, this.v);
  final IconData icon;
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Sp.x2),
    child: Row(
      children: [
        Icon(icon, size: 18, color: kMuted),
        const SizedBox(width: Sp.x2),
        Text(k, style: dm(14, color: kMuted)),
        const SizedBox(width: Sp.x4),
        Expanded(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: dm(14, weight: FontWeight.w700, color: kInk),
          ),
        ),
      ],
    ),
  );
}
