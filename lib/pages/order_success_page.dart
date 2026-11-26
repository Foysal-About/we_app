import 'package:flutter/material.dart';

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
      body: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top + 24),
          const CheckoutSteps(current: 2),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.4, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (_, v, child) =>
                          Transform.scale(scale: v, child: child),
                      child: const CircleAvatar(
                        radius: 52,
                        backgroundColor: kBrandGreen,
                        child: Icon(Icons.check, color: Colors.white, size: 60),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Order placed!',
                      style: urbanist(30, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thank you for shopping with WE.\nWe will keep you posted on your delivery.',
                      textAlign: TextAlign.center,
                      style: dm(14, color: Colors.black54, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: kBeige,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _Row('Order No', order.id),
                          _Row('Payment', order.payment),
                          _Row('Estimated delivery', order.estimatedDelivery),
                          _Row('Total', money(order.total), bold: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, bottom + 20),
            child: Column(
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
                const SizedBox(height: 10),
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
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.k, this.v, {this.bold = false});
  final String k;
  final String v;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: dm(13, color: Colors.black54)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: dm(14, weight: bold ? FontWeight.w800 : FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
