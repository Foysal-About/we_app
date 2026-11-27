import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'help_page.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final o = order;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: GlassHeaderColumn(
        children: [
          const PageHeader(title: 'Order Details'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                Sp.page,
                PageHeader.heightOf(context) + Sp.x3,
                Sp.page,
                bottom + Sp.x6,
              ),
              children: [
                _HeaderCard(order: o),
                const SizedBox(height: Sp.x4),
                _Card(child: _Tracker(status: o.status)),
                if (o.items.isNotEmpty) ...[
                  const SizedBox(height: Sp.x4),
                  _Card(
                    title: 'Items',
                    child: Column(
                      children: [
                        for (var i = 0; i < o.items.length; i++) ...[
                          if (i > 0)
                            const Divider(height: Sp.x6, color: kBarGrey),
                          _ItemRow(item: o.items[i]),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: Sp.x4),
                _Card(
                  child: Column(
                    children: [
                      _Info(
                        icon: Icons.payments_outlined,
                        label: 'Payment',
                        value: o.payment.isEmpty ? 'Not recorded' : o.payment,
                      ),
                      const Divider(height: Sp.x6, color: kBarGrey),
                      _Info(
                        icon: Icons.location_on_outlined,
                        label: 'Delivery address',
                        value: o.address.isEmpty
                            ? 'No address on file'
                            : o.address,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Sp.x4),
                _Card(
                  title: 'Order summary',
                  child: _Summary(order: o),
                ),
                const SizedBox(height: Sp.x4),
                _Card(
                  title: 'Need help?',
                  child: Column(
                    children: [
                      for (final h in const [
                        (Icons.report_gmailerrorred_outlined, 'Order issues'),
                        (Icons.local_shipping_outlined, 'Delivery info'),
                        (Icons.assignment_return_outlined, 'Returns'),
                      ])
                        _HelpRow(
                          icon: h.$1,
                          label: h.$2,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const HelpPage()),
                          ),
                        ),
                    ],
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

/// White rounded section with an optional title.
class _Card extends StatelessWidget {
  const _Card({required this.child, this.title});
  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: SurfaceCard(
      radius: Rd.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: urbanist(18, weight: FontWeight.w800, color: kInk),
            ),
            const SizedBox(height: Sp.x3),
          ],
          child,
        ],
      ),
    ),
  );
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final o = order;
    final color = order.status.color;
    final icon = order.status.icon;
    final label = order.status.label;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order ID', style: dm(12, color: kMuted)),
                    Text(
                      o.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: urbanist(20, weight: FontWeight.w800, color: kInk),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Copy order ID',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: o.id));
                  toast(context, 'Order ID copied');
                },
                icon: const Icon(Icons.copy_rounded, size: 20, color: kMuted),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sp.x3,
                  vertical: Sp.x1,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Rd.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: Sp.x1),
                    Text(
                      label,
                      style: dm(12, weight: FontWeight.w700, color: color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Sp.x3),
          Container(
            padding: const EdgeInsets.all(Sp.x3),
            decoration: BoxDecoration(
              color: kPanel,
              borderRadius: BorderRadius.circular(Rd.lg),
            ),
            child: Row(
              children: [
                Expanded(child: _Fact('Order date', o.date)),
                if (o.estimatedDelivery.isNotEmpty)
                  Expanded(
                    child: _Fact(
                      'Estimated delivery',
                      o.estimatedDelivery,
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

class _Fact extends StatelessWidget {
  const _Fact(this.k, this.v, {this.color = kInk});
  final String k;
  final String v;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(k, style: dm(12, color: kMuted)),
      const SizedBox(height: 2),
      Text(
        v,
        style: dm(14, weight: FontWeight.w700, color: color),
      ),
    ],
  );
}

class _Tracker extends StatelessWidget {
  const _Tracker({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kDanger.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel_outlined, color: kDanger),
          ),
          const SizedBox(width: Sp.x3),
          Expanded(
            child: Text(
              'This order was cancelled',
              style: dm(14, weight: FontWeight.w700, color: kDanger),
            ),
          ),
        ],
      );
    }
    final done = status == OrderStatus.delivered ? 3 : 1;
    const labels = ['Order Confirmed', 'Ex-Factory', 'Delivered'];
    const icons = [
      Icons.receipt_long_outlined,
      Icons.factory_outlined,
      Icons.home_outlined,
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        color: i == 0
                            ? Colors.transparent
                            : (i < done ? kBrandGreen : kBarGrey),
                      ),
                    ),
                    _Dot(icon: icons[i], done: i < done, current: i == done),
                    Expanded(
                      child: Container(
                        height: 3,
                        color: i == 2
                            ? Colors.transparent
                            : (i + 1 < done ? kBrandGreen : kBarGrey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Sp.x2),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: dm(
                    12,
                    weight: i < done ? FontWeight.w700 : FontWeight.w500,
                    color: i < done ? kBuyGreen : kSubtle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// A tracker step: filled green when done, outlined when it is up next.
class _Dot extends StatelessWidget {
  const _Dot({required this.icon, required this.done, required this.current});
  final IconData icon;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: done ? kBrandGreen : Colors.white,
      border: Border.all(
        color: done || current ? kBrandGreen : kBarGrey,
        width: 2,
      ),
    ),
    child: Icon(
      done ? Icons.check : icon,
      size: 18,
      color: done ? Colors.white : (current ? kBrandGreen : kSubtle),
    ),
  );
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final p = productById(item.productId);
    return Row(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: kPanel,
            borderRadius: BorderRadius.circular(Rd.md),
          ),
          child: ProductImage.of(p),
        ),
        const SizedBox(width: Sp.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: dm(14, weight: FontWeight.w700, color: kInk),
              ),
              const SizedBox(height: 2),
              Text(
                '${money(p.price)} × ${item.qty}',
                style: dm(12, color: kMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: Sp.x2),
        Text(
          money(p.price * item.qty),
          style: dm(14, weight: FontWeight.w800, color: kInk),
        ),
      ],
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: kPanel, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: kInk),
      ),
      const SizedBox(width: Sp.x3),
      Expanded(
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
      ),
    ],
  );
}

class _Summary extends StatelessWidget {
  const _Summary({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final o = order;
    return Column(
      children: [
        if (o.items.isNotEmpty) ...[
          _Line('Subtotal', money(o.subtotal)),
          if (o.discount > 0)
            _Line('Discount', '-${money(o.discount)}', color: kBuyGreen),
          _Line(
            'Delivery',
            o.delivery == 0 ? 'Free' : money(o.delivery),
            color: o.delivery == 0 ? kBuyGreen : kInk,
          ),
        ] else
          _Line('Items', '${o.quantity}'),
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
                money(o.total),
                style: urbanist(22, weight: FontWeight.w800, color: kBuyGreen),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.k, this.v, {this.color = kInk});
  final String k;
  final String v;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Sp.x1),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: dm(14, color: kMuted)),
        Text(
          v,
          style: dm(14, weight: FontWeight.w700, color: color),
        ),
      ],
    ),
  );
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(Rd.md),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.x3),
      child: Row(
        children: [
          Icon(icon, size: 22, color: kInk),
          const SizedBox(width: Sp.x3),
          Expanded(
            child: Text(
              label,
              style: dm(14, weight: FontWeight.w600, color: kInk),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: kSubtle),
        ],
      ),
    ),
  );
}
