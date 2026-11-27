import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/common.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const _faqs = [
    (
      'How do I place an order?',
      'Open a product, choose a quantity and tap Add to cart or Buy Now. In the cart, review the summary and tap Place Order, then pick a payment method.',
    ),
    (
      'Which payment methods can I use?',
      'Credit/debit card, bKash, Rocket, Nagad, Cash On Delivery and bank deposit are all available at checkout.',
    ),
    (
      'How can I track my order?',
      'Go to Profile → My orders and tap Details on any order to see its progress from Order Confirmed to Delivered.',
    ),
    (
      'Can I use a promo code?',
      'Yes. Enter it in the Promo code box in your cart and tap Apply. The discount shows in your order summary.',
    ),
    (
      'How do I save a product for later?',
      'Tap the heart on any product. Everything you save appears in the Favourites tab.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassHeaderColumn(
        children: [
          const PageHeader(title: 'Help & Support'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                20,
                PageHeader.heightOf(context) + Sp.x2,
                20,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                Row(
                  children: [
                    for (final c in const [
                      (Icons.phone_outlined, 'Call'),
                      (Icons.chat_bubble_outline, 'Chat'),
                      (Icons.mail_outline, 'Email'),
                    ])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _Contact(icon: c.$1, label: c.$2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Sp.x6),
                Text(
                  'Frequently asked',
                  style: urbanist(18, weight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                for (final f in _faqs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Sp.x3),
                    child: SurfaceCard(
                      padding: EdgeInsets.zero,
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: Sp.x4,
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            16,
                          ),
                          expandedAlignment: Alignment.centerLeft,
                          shape: const RoundedRectangleBorder(),
                          collapsedShape: const RoundedRectangleBorder(),
                          title: Text(
                            f.$1,
                            style: dm(14, weight: FontWeight.w600),
                          ),
                          children: [
                            Text(
                              f.$2,
                              style: dm(13, color: kInk, height: 1.45),
                            ),
                          ],
                        ),
                      ),
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

class _Contact extends StatelessWidget {
  const _Contact({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: () => toast(context, '$label support is not part of this demo'),
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 84,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: kInk),
            const SizedBox(height: 6),
            Text(label, style: dm(13, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
