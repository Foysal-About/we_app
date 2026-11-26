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

  static const _tabs = ['Delivered', 'Processing', 'Cancelled'];
  static const _status = [
    OrderStatus.delivered,
    OrderStatus.processing,
    OrderStatus.cancelled,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                PageHeader(
                  title: 'My Orders',
                  onBack: () => Navigator.of(context).pop(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                  child: PillTabs(
                    labels: _tabs,
                    index: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: app,
              builder: (context, _) {
                final list = app.orders
                    .where((o) => o.status == _status[_tab])
                    .toList();
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: 'No ${_tabs[_tab].toLowerCase()} orders.',
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    MediaQuery.paddingOf(context).bottom + 24,
                  ),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 20),
                  itemBuilder: (_, i) => _OrderCard(order: list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final Order order;

  Color get _statusColor => switch (order.status) {
    OrderStatus.delivered => kGreen,
    OrderStatus.processing => const Color(0xFFE08A00),
    OrderStatus.cancelled => const Color(0xFFD32F2F),
  };

  String get _statusLabel => switch (order.status) {
    OrderStatus.delivered => 'Delivered',
    OrderStatus.processing => 'Processing',
    OrderStatus.cancelled => 'Cancelled',
  };

  @override
  Widget build(BuildContext context) {
    final grey = dm(13, color: Colors.black54);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Order No: ',
                        style: dm(15, weight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: order.id,
                        style: dm(15, weight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              Text(order.date, style: grey),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('Tracking number:  ', style: grey),
              Text(order.tracking, style: dm(13, weight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Quantity:  ', style: grey),
                      TextSpan(
                        text: '${order.quantity}',
                        style: dm(14, weight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Total Amount:  ', style: grey),
                      TextSpan(
                        text:
                            order.total.toStringAsFixed(
                              order.total % 1 == 0 ? 0 : 2,
                            ) +
                            kTaka,
                        style: dm(14, weight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsPage(order: order),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                ),
                child: Text('Details', style: dm(13, weight: FontWeight.w500)),
              ),
              Text(
                _statusLabel,
                style: dm(13, weight: FontWeight.w500, color: _statusColor),
              ),
            ],
          ),
          if (order.items.isNotEmpty ||
              order.status == OrderStatus.processing) ...[
            const Divider(height: 24),
            Row(
              children: [
                if (order.status == OrderStatus.processing)
                  TextButton.icon(
                    onPressed: () => _confirmCancel(context),
                    icon: const Icon(Icons.close, size: 18),
                    label: Text(
                      'Cancel order',
                      style: dm(13, weight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFD32F2F),
                    ),
                  ),
                const Spacer(),
                if (order.items.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      final n = app.reorder(order);
                      toast(
                        context,
                        '$n item${n == 1 ? '' : 's'} added to your cart',
                      );
                    },
                    icon: const Icon(Icons.replay, size: 18),
                    label: Text(
                      'Reorder',
                      style: dm(13, weight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(foregroundColor: kBuyGreen),
                  ),
              ],
            ),
          ],
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
            child: Text('Keep order', style: dm(14, color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              app.cancelOrder(order.id);
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Cancel order',
              style: dm(
                14,
                weight: FontWeight.w700,
                color: const Color(0xFFD32F2F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
