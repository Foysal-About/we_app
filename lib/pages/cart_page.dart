import 'package:flutter/material.dart';

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
  final _promo = TextEditingController();

  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  void _checkout() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PaymentMethodPage()));
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

  void _remove(Product p, int qty) {
    app.removeFromCart(p.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${p.name} removed'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: kInfo,
            onPressed: () => app.setQty(p.id, qty),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    // Height of the floating glass tab bar this page sits above.
    final navHeight = 64 + (bottom < 12 ? 12.0 : bottom);
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final items = app.cart.entries
            .map((e) => (productById(e.key), e.value))
            .toList();
        return GlassHeaderColumn(
          children: [
            PageHeader(
              title: 'Shopping Cart',
              onBack: () => shellIndex.value = 0,
            ),
            const CheckoutSteps(current: 0),
            Expanded(
              child: items.isEmpty
                  ? _Empty(onShop: () => shellIndex.value = 0)
                  : Stack(
                      children: [
                        ListView(
                          padding: EdgeInsets.fromLTRB(
                            Sp.page,
                            Sp.x3,
                            Sp.page,
                            navHeight + 120,
                          ),
                          children: [
                            const GlassInsetSpacer(),
                            _CountRow(count: app.cartCount),
                            if (app.discount > 0) ...[
                              const SizedBox(height: Sp.x3),
                              _SavingBanner(amount: app.discount),
                            ],
                            const SizedBox(height: Sp.x3),
                            for (final e in items)
                              Padding(
                                padding: const EdgeInsets.only(bottom: Sp.x3),
                                child: Dismissible(
                                  key: ValueKey(e.$1.id),
                                  direction: DismissDirection.endToStart,
                                  onDismissed: (_) => _remove(e.$1, e.$2),
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(
                                      right: Sp.x6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kDanger,
                                      borderRadius: BorderRadius.circular(
                                        Rd.lg,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: _CartCard(
                                    product: e.$1,
                                    qty: e.$2,
                                    onRemove: () => _remove(e.$1, e.$2),
                                  ),
                                ),
                              ),
                            const SizedBox(height: Sp.x1),
                            _PromoCard(
                              controller: _promo,
                              code: app.promoCode,
                              onApply: _applyPromo,
                              onClear: app.clearPromo,
                            ),
                            const SizedBox(height: Sp.x4),
                            const _Summary(),
                          ],
                        ),
                        // Sticky checkout bar above the tab bar.
                        Positioned(
                          left: Sp.x4,
                          right: Sp.x4,
                          bottom: navHeight + Sp.x2,
                          child: GlassPanel(
                            radius: Rd.xl,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                Sp.x5,
                                Sp.x3,
                                Sp.x3,
                                Sp.x3,
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total · ${app.cartCount} ${app.cartCount == 1 ? 'item' : 'items'}',
                                        style: dm(12, color: kMuted),
                                      ),
                                      Text(
                                        money(app.total),
                                        style: urbanist(
                                          20,
                                          weight: FontWeight.w800,
                                          color: kInk,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  PrimaryButton(
                                    label: 'Place Order',
                                    color: kBrandGreen,
                                    onTap: _checkout,
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
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onShop});
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Sp.x8,
          Sp.x8 + GlassTopInset.of(context),
          Sp.x8,
          Sp.x8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: kBeige,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 52,
                color: kAccent,
              ),
            ),
            const SizedBox(height: Sp.x6),
            Text(
              'Your cart is empty',
              style: urbanist(22, weight: FontWeight.w800, color: kInk),
            ),
            const SizedBox(height: Sp.x2),
            Text(
              'Add cement, bricks or geosynthetics and they will show up here.',
              textAlign: TextAlign.center,
              style: dm(14, color: kMuted),
            ),
            const SizedBox(height: Sp.x6),
            PrimaryButton(
              label: 'Start shopping',
              color: kBrandGreen,
              onTap: onShop,
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        '$count ${count == 1 ? 'item' : 'items'}',
        style: dm(14, weight: FontWeight.w600, color: kMuted),
      ),
      const Spacer(),
      const Icon(Icons.swipe_left_alt_rounded, size: 16, color: kSubtle),
      const SizedBox(width: Sp.x1),
      Text('Swipe to remove', style: dm(12, color: kSubtle)),
    ],
  );
}

class _SavingBanner extends StatelessWidget {
  const _SavingBanner({required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x3),
    decoration: BoxDecoration(
      color: kSoftGreen,
      borderRadius: BorderRadius.circular(Rd.lg),
    ),
    child: Row(
      children: [
        const Icon(Icons.savings_outlined, color: kBuyGreen),
        const SizedBox(width: Sp.x3),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'You are saving ',
                  style: dm(14, color: kBuyGreen),
                ),
                TextSpan(
                  text: money(amount),
                  style: dm(14, weight: FontWeight.w800, color: kBuyGreen),
                ),
                TextSpan(
                  text: ' on this order',
                  style: dm(14, color: kBuyGreen),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _CartCard extends StatelessWidget {
  const _CartCard({
    required this.product,
    required this.qty,
    required this.onRemove,
  });
  final Product product;
  final int qty;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final brand = brands
        .firstWhere((b) => b.id == product.brandId)
        .title
        .replaceAll(' Products', '');
    return SurfaceCard(
      padding: const EdgeInsets.all(Sp.x3),
      radius: Rd.lg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: kPanel,
              borderRadius: BorderRadius.circular(Rd.md),
            ),
            child: ProductImage.of(product),
          ),
          const SizedBox(width: Sp.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: dm(14, weight: FontWeight.w700, color: kInk),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      onPressed: onRemove,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: Sp.controlCompact,
                        minHeight: Sp.controlCompact,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: kSubtle,
                      ),
                    ),
                  ],
                ),
                Text(brand, style: dm(12, color: kMuted)),
                const SizedBox(height: 2),
                Text(
                  '${money(product.price)} / ${product.unit}',
                  style: dm(12, weight: FontWeight.w600, color: kBuyGreen),
                ),
                const SizedBox(height: Sp.x2),
                Row(
                  children: [
                    _MiniQty(
                      qty: qty,
                      onChanged: (v) => app.setQty(product.id, v),
                    ),
                    const Spacer(),
                    Text(
                      money(product.price * qty),
                      style: urbanist(16, weight: FontWeight.w800, color: kInk),
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

class _MiniQty extends StatelessWidget {
  const _MiniQty({required this.qty, required this.onChanged});
  final int qty;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData i, String tip, VoidCallback f) => IconButton(
      tooltip: tip,
      onPressed: f,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(
        minWidth: Sp.controlCompact,
        minHeight: Sp.controlCompact,
      ),
      icon: Icon(i, size: 18, color: kInk),
    );
    return Container(
      decoration: BoxDecoration(
        color: kPanel,
        borderRadius: BorderRadius.circular(Rd.pill),
        border: Border.all(color: kBarGrey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove, 'Decrease', () => onChanged(qty - 1)),
          SizedBox(
            width: 28,
            child: Center(
              child: Text(
                '$qty',
                style: dm(14, weight: FontWeight.w800, color: kInk),
              ),
            ),
          ),
          btn(Icons.add, 'Increase', () => onChanged(qty + 1)),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
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
    final applied = code != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x1),
      decoration: BoxDecoration(
        color: applied ? kSoftGreen : kPanel,
        borderRadius: BorderRadius.circular(Rd.lg),
        border: Border.all(color: applied ? Colors.transparent : kBarGrey),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 20,
            color: applied ? kBuyGreen : kMuted,
          ),
          const SizedBox(width: Sp.x3),
          Expanded(
            child: applied
                ? Text(
                    '$code applied',
                    style: dm(14, weight: FontWeight.w700, color: kBuyGreen),
                  )
                : TextField(
                    controller: controller,
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => onApply(),
                    style: dm(14, weight: FontWeight.w600, color: kInk),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Have a promo code?',
                      hintStyle: dm(14, color: kSubtle),
                    ),
                  ),
          ),
          if (applied)
            IconButton(
              tooltip: 'Remove code',
              onPressed: onClear,
              icon: const Icon(Icons.close, size: 20, color: kBuyGreen),
            )
          else
            TextButton(
              onPressed: onApply,
              child: Text(
                'Apply',
                style: dm(14, weight: FontWeight.w700, color: kBrandGreen),
              ),
            ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary();

  @override
  Widget build(BuildContext context) {
    // Sits in the page ListView, which already gives it the full width.
    return SurfaceCard(
      padding: const EdgeInsets.all(Sp.x5),
      radius: Rd.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: urbanist(18, weight: FontWeight.w800, color: kInk),
          ),
          const SizedBox(height: Sp.x3),
          _Line('Subtotal', money(app.subtotal)),
          if (app.discount > 0)
            _Line(
              'Discount (${(app.discountPct * 100).round()}%)',
              '-${money(app.discount)}',
              color: kBuyGreen,
            ),
          _Line('Delivery', 'Free', color: kBuyGreen),
          _Line('Estimated delivery', deliveryEta()),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Sp.x3),
            child: Divider(color: kBarGrey),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: dm(16, weight: FontWeight.w700, color: kInk),
              ),
              Text(
                money(app.total),
                style: urbanist(22, weight: FontWeight.w800, color: kInk),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.color = kInk});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Sp.x1),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: dm(14, color: kMuted)),
        Text(
          value,
          style: dm(14, weight: FontWeight.w700, color: color),
        ),
      ],
    ),
  );
}
