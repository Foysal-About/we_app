import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'order_details_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late int _tab = widget.initialTab;

  static const _names = ['Delivered', 'Processing', 'Cancelled'];
  static const _status = [
    OrderStatus.delivered,
    OrderStatus.processing,
    OrderStatus.cancelled,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          int count(int i) =>
              app.orders.where((o) => o.status == _status[i]).length;
          final list = app.orders
              .where((o) => o.status == _status[_tab])
              .toList();
          return GlassHeaderColumn(
            children: [
              PageHeader(
                title: 'My Orders',
                onBack: () => Navigator.of(context).pop(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Sp.page,
                  Sp.x1,
                  Sp.page,
                  Sp.x4,
                ),
                child: PillTabs(
                  labels: [
                    for (var i = 0; i < _names.length; i++)
                      '${_names[i]} (${count(i)})',
                  ],
                  index: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (ctx) {
                    final inset = GlassTopInset.of(ctx);
                    if (list.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: inset),
                        child: EmptyHero(
                          icon: Icons.receipt_long_outlined,
                          title: 'No ${_names[_tab].toLowerCase()} orders',
                          message: _tab == 1
                              ? 'Orders you place show up here while they are on the way.'
                              : 'Nothing to show in this list yet.',
                          tint: kBarGrey,
                          iconColor: kMuted,
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        Sp.page,
                        inset + Sp.x4,
                        Sp.page,
                        MediaQuery.paddingOf(context).bottom + Sp.x6,
                      ),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: Sp.x4),
                      itemBuilder: (_, i) => _OrderCard(order: list[i]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final color = order.status.color;
    final icon = order.status.icon;
    final label = order.status.label;
    final total =
        '$kTaka${order.total.toStringAsFixed(order.total % 1 == 0 ? 0 : 2)}';
    return SurfaceCard(
      radius: Rd.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order id + date, status pill on the right.
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ${order.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: urbanist(16, weight: FontWeight.w800, color: kInk),
                    ),
                    const SizedBox(height: 2),
                    Text(order.date, style: dm(12, color: kMuted)),
                  ],
                ),
              ),
              const SizedBox(width: Sp.x2),
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
          // Summary panel: thumbnails, item count, total, tracking.
          Container(
            padding: const EdgeInsets.all(Sp.x3),
            decoration: BoxDecoration(
              color: kPanel,
              borderRadius: BorderRadius.circular(Rd.lg),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _Thumbs(order: order),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${order.quantity} ${order.quantity == 1 ? 'item' : 'items'}',
                          style: dm(12, color: kMuted),
                        ),
                        Text(
                          total,
                          style: urbanist(
                            20,
                            weight: FontWeight.w800,
                            color: kInk,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: Sp.x3),
                Row(
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      size: 16,
                      color: kMuted,
                    ),
                    const SizedBox(width: Sp.x2),
                    Text('Tracking', style: dm(12, color: kMuted)),
                    const SizedBox(width: Sp.x2),
                    Expanded(
                      child: Text(
                        order.tracking,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: dm(12, weight: FontWeight.w700, color: kInk),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Sp.x3),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailsPage(order: order),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kInk,
                    minimumSize: const Size.fromHeight(Sp.control),
                    side: const BorderSide(color: kBarGrey, width: 1.5),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Details',
                    style: dm(14, weight: FontWeight.w700),
                  ),
                ),
              ),
              if (order.items.isNotEmpty) ...[
                const SizedBox(width: Sp.x3),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      final n = app.reorder(order);
                      toast(
                        context,
                        '$n item${n == 1 ? '' : 's'} added to your cart',
                      );
                    },
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    style: FilledButton.styleFrom(
                      backgroundColor: kBuyGreen,
                      minimumSize: const Size.fromHeight(Sp.control),
                      shape: const StadiumBorder(),
                    ),
                    label: Text(
                      'Reorder',
                      style: dm(
                        14,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (order.status == OrderStatus.processing)
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () => _confirmCancel(context),
                icon: const Icon(Icons.close, size: 18),
                label: Text(
                  'Cancel order',
                  style: dm(14, weight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(foregroundColor: kDanger),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Cancel this order?',
          style: urbanist(20, weight: FontWeight.w700),
        ),
        content: Text('Order ${order.id} will be cancelled.', style: dm(14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Keep order', style: dm(14, color: kMuted)),
          ),
          TextButton(
            onPressed: () {
              app.cancelOrder(order.id);
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Cancel order',
              style: dm(14, weight: FontWeight.w700, color: kDanger),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlapping product thumbnails (or a placeholder for older orders).
class _Thumbs extends StatelessWidget {
  const _Thumbs({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    const size = 52.0;
    final items = order.items;
    if (items.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Rd.md),
        ),
        child: const Icon(Icons.inventory_2_outlined, color: kAccent),
      );
    }
    final shown = items.take(3).toList();
    final extra = items.length - shown.length;
    return SizedBox(
      width: size + (shown.length - 1) * 28 + (extra > 0 ? 28 : 0),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * 28.0,
              child: Container(
                clipBehavior: Clip.antiAlias,
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Rd.md),
                  border: Border.all(color: kPanel, width: 2),
                ),
                child: ProductImage.of(productById(shown[i].productId)),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * 28.0,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kBarGrey,
                  borderRadius: BorderRadius.circular(Rd.md),
                  border: Border.all(color: kPanel, width: 2),
                ),
                child: Text(
                  '+$extra',
                  style: dm(12, weight: FontWeight.w700, color: kInk),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
