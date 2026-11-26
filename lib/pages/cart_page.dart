import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'payment_method_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String _q = '';
  final _promo = TextEditingController();

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  String _eta() {
    final d = DateTime.now().add(const Duration(days: 5));
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${m[d.month - 1]}';
  }

  void _applyPromo() {
    final ok = app.applyPromo(_promo.text);
    _promo.clear();
    FocusScope.of(context).unfocus();
    toast(
      context,
      ok ? 'Promo code applied' : 'That code is not recognised. Try WELCOME10.',
    );
  }

  void _checkout() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PaymentMethodPage()));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final items = app.cart.entries
            .map((e) => (productById(e.key), e.value))
            .where(
              (e) => e.$1.name.toLowerCase().contains(_q.trim().toLowerCase()),
            )
            .toList();
        final bottom = MediaQuery.paddingOf(context).bottom;
        return Column(
          children: [
            PageHeader(
              title: 'Shopping Cart',
              onBack: () => shellIndex.value = 0,
            ),
            const CheckoutSteps(current: 0),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: kBarGrey,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/search_field.svg'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _q = v),
                        style: dm(16, weight: FontWeight.w500, color: kInk),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search product',
                          hintStyle: dm(
                            16,
                            weight: FontWeight.w500,
                            color: kInk.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? EmptyState(
                      icon: Icons.shopping_cart_outlined,
                      message: app.cart.isEmpty
                          ? 'Your cart is empty.\nAdd something from the home page.'
                          : 'No cart items match your search.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1, color: kBarGrey),
                      ),
                      itemBuilder: (_, i) =>
                          _CartRow(product: items[i].$1, qty: items[i].$2),
                    ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(28, 22, 28, bottom + 8 + 67 + 14),
              decoration: const BoxDecoration(
                color: kBarGrey,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Summary', style: dm(16, weight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _PromoRow(
                    controller: _promo,
                    code: app.promoCode,
                    onApply: _applyPromo,
                    onClear: app.clearPromo,
                  ),
                  const SizedBox(height: 8),
                  _Line('Subtotal', money(app.subtotal), bold: true),
                  _Line(
                    'Discount',
                    '(${(app.discountPct * 100).round()}%) -${money(app.discount)}',
                  ),
                  _Line('Delivery charges', money(app.delivery)),
                  _Line('Estimated delivery', _eta()),
                  const Divider(height: 20),
                  _Line('Total', money(app.total), bold: true),
                  const SizedBox(height: 14),
                  Center(
                    child: PrimaryButton(
                      label: 'Place Order',
                      width: 220,
                      onTap: app.cart.isEmpty ? null : _checkout,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = dm(
      13,
      weight: bold ? FontWeight.w700 : FontWeight.w500,
      color: Colors.black87,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.product, required this.qty});
  final Product product;
  final int qty;

  @override
  Widget build(BuildContext context) {
    final brand = brands.firstWhere((b) => b.id == product.brandId);
    final saved = app.isFavorite(product.id);
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: product.tint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(product.image, fit: BoxFit.contain),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: dm(
                  14,
                  weight: FontWeight.w600,
                  color: const Color(0xFF3A3F55),
                ),
              ),
              Text(
                brand.title.replaceAll(' Products', ''),
                style: dm(11, color: Colors.black45),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  _MiniStepper(
                    qty: qty,
                    onChanged: (v) => app.setQty(product.id, v),
                  ),
                  const Spacer(),
                  Text(
                    money(product.price * qty),
                    style: dm(14, weight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          children: [
            _IconAction(
              icon: saved ? Icons.favorite : Icons.favorite_border,
              color: saved ? Colors.red : Colors.black54,
              label: 'Save for later',
              onTap: () => app.toggleFavorite(product.id),
            ),
            _IconAction(
              icon: Icons.delete_outline,
              color: Colors.black54,
              label: 'Remove',
              onTap: () => app.removeFromCart(product.id),
            ),
          ],
        ),
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    tooltip: label,
    visualDensity: VisualDensity.compact,
    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    icon: Icon(icon, size: 20, color: color),
  );
}

class _MiniStepper extends StatelessWidget {
  const _MiniStepper({required this.qty, required this.onChanged});
  final int qty;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData i, VoidCallback f) => GestureDetector(
      onTap: f,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: kBarGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(i, size: 15),
          ),
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(Icons.remove, () => onChanged(qty - 1)),
        SizedBox(
          width: 22,
          child: Center(
            child: Text('$qty', style: dm(14, weight: FontWeight.w600)),
          ),
        ),
        btn(Icons.add, () => onChanged(qty + 1)),
      ],
    );
  }
}

class _PromoRow extends StatelessWidget {
  const _PromoRow({
    required this.controller,
    required this.code,
    required this.onApply,
    required this.onClear,
  });
  final TextEditingController controller;
  final String? code;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (code != null) {
      return Container(
        height: 44,
        padding: const EdgeInsets.only(left: 14, right: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFDDEFD9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer_outlined, size: 18, color: kBuyGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$code applied',
                style: dm(13, weight: FontWeight.w700, color: kBuyGreen),
              ),
            ),
            IconButton(
              tooltip: 'Remove code',
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
      );
    }
    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 14, right: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer_outlined,
            size: 18,
            color: Colors.black45,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) => onApply(),
              style: dm(13, weight: FontWeight.w600),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Promo code',
                hintStyle: dm(13, color: Colors.black38),
              ),
            ),
          ),
          TextButton(
            onPressed: onApply,
            child: Text(
              'Apply',
              style: dm(13, weight: FontWeight.w700, color: kBrandGreen),
            ),
          ),
        ],
      ),
    );
  }
}
