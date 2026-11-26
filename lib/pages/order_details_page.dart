import 'package:flutter/material.dart';

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
      body: Column(
        children: [
          const PageHeader(title: 'Order Details'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 4, 20, bottom + 24),
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Order ID : ',
                        style: dm(16, weight: FontWeight.w500),
                      ),
                      TextSpan(
                        text: o.id,
                        style: dm(16, weight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Order date: ${o.date}',
                      style: dm(12, color: Colors.black54),
                    ),
                    if (o.estimatedDelivery.isNotEmpty) ...[
                      const Spacer(),
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 14,
                        color: kBrandGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Estimated delivery: ${o.estimatedDelivery}',
                        style: dm(
                          12,
                          weight: FontWeight.w600,
                          color: kBrandGreen,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 22),
                _Tracker(status: o.status),
                const SizedBox(height: 22),
                if (o.items.isNotEmpty) ...[
                  for (final it in o.items) _ItemRow(item: it),
                  const Divider(height: 28),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Block(
                        'Payment',
                        o.payment.isEmpty ? 'Not recorded' : o.payment,
                      ),
                    ),
                    Expanded(
                      child: _Block(
                        'Delivery',
                        o.address.isEmpty ? 'No address on file' : o.address,
                        title2: 'Address',
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need Help',
                            style: dm(14, weight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          for (final h in const [
                            'Order Issues',
                            'Delivery Info',
                            'Returns',
                          ])
                            InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const HelpPage(),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      h,
                                      style: dm(
                                        12,
                                        weight: FontWeight.w600,
                                        color: const Color(0xFF3A5BA9),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.north_east,
                                      size: 12,
                                      color: Color(0xFF3A5BA9),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style: dm(14, weight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          if (o.items.isNotEmpty) ...[
                            _Sum('Subtotal', money(o.subtotal)),
                            _Sum('Discount', '-${money(o.discount)}'),
                            _Sum('Delivery', money(o.delivery)),
                          ] else
                            _Sum('Items', '${o.quantity}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: dm(16, weight: FontWeight.w600)),
                    Text(
                      money(o.total),
                      style: dm(20, weight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tracker extends StatelessWidget {
  const _Tracker({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: Color(0xFFD32F2F)),
            const SizedBox(width: 10),
            Text(
              'This order was cancelled',
              style: dm(
                14,
                weight: FontWeight.w600,
                color: const Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
      );
    }
    final done = status == OrderStatus.delivered ? 3 : 1;
    const labels = ['Order Confirmed', 'Ex-Factory', 'Delivered'];
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == 0
                            ? Colors.transparent
                            : (i < done ? kBrandGreen : kBarGrey),
                      ),
                    ),
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: i < done ? kBrandGreen : kBarGrey,
                      child: i < done
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == 2
                            ? Colors.transparent
                            : (i + 1 < done ? kBrandGreen : kBarGrey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: dm(
                    11,
                    weight: i < done ? FontWeight.w700 : FontWeight.w500,
                    color: i < done ? kBrandGreen : Colors.black45,
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

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final p = productById(item.productId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 56,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: p.tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(p.image, fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(p.name, style: dm(14, weight: FontWeight.w600)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(money(p.price), style: dm(13, weight: FontWeight.w700)),
              Text(
                'Quantity: ${item.qty}',
                style: dm(11, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block(this.title, this.text, {this.title2});
  final String title;
  final String text;
  final String? title2;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: dm(14, weight: FontWeight.w800)),
        const SizedBox(height: 6),
        if (title2 != null) Text(title2!, style: dm(11, color: Colors.black54)),
        Text(text, style: dm(12, color: Colors.black87, height: 1.4)),
      ],
    ),
  );
}

class _Sum extends StatelessWidget {
  const _Sum(this.k, this.v);
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(k, style: dm(11, color: Colors.black54)),
        ),
        Text(v, style: dm(11, weight: FontWeight.w600)),
      ],
    ),
  );
}
