import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'addresses_page.dart';
import 'order_success_page.dart';
import 'saved_cards_page.dart';

// Third-party brand colours (not part of the WE palette).
const _kVisa = Color(0xFF1A3C8C);
const _kBkash = Color(0xFFE2136E);
const _kRocket = Color(0xFF8C3494);
const _kNagad = Color(0xFFF26522);

enum PayMethod { card, bkash, rocket, nagad, cod, bank }

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  PayMethod _method = PayMethod.card;

  String _label() {
    switch (_method) {
      case PayMethod.card:
        final c = app.defaultCard;
        return c == null ? 'Credit/Debit Card' : '${c.brand} •••• ${c.last4}';
      case PayMethod.bkash:
        return 'bKash';
      case PayMethod.rocket:
        return 'Rocket';
      case PayMethod.nagad:
        return 'Nagad';
      case PayMethod.cod:
        return 'Cash On Delivery';
      case PayMethod.bank:
        return 'Bank Deposit';
    }
  }

  void _pickAddress(BuildContext context) {
    if (app.addresses.length < 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AddressesPage()));
      return;
    }
    showFormSheet<void>(
      context,
      title: 'Deliver to',
      child: Column(
        children: [
          for (final a in app.addresses)
            Builder(
              builder: (ctx) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  app.defaultAddress?.id == a.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: kBrandGreen,
                ),
                title: Text(a.label, style: dm(14, weight: FontWeight.w700)),
                subtitle: Text(a.line, style: dm(12, color: kMuted)),
                onTap: () {
                  app.setDefaultAddress(a.id);
                  Navigator.of(ctx).pop();
                },
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: Builder(
              builder: (ctx) => TextButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddressesPage()),
                  );
                },
                icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                label: Text(
                  'Manage addresses',
                  style: dm(13, weight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pay() {
    final addr = app.defaultAddress;
    final order = app.placeOrder(
      payment: _label(),
      address: addr == null ? '' : '${addr.name}, ${addr.line}',
    );
    if (order == null) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => OrderSuccessPage(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) => GlassHeaderColumn(
          children: [
            const PageHeader(title: 'Select Payment Method'),
            const CheckoutSteps(current: 1),
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(
                      Sp.page,
                      Sp.x2,
                      Sp.page,
                      130,
                    ),
                    children: [
                      const GlassInsetSpacer(),
                      _AddressCard(onChange: () => _pickAddress(context)),
                      const SizedBox(height: Sp.x6),
                      _Heading('Recommended method(s)'),
                      _Option(
                        selected: _method == PayMethod.card,
                        onTap: () => setState(() => _method = PayMethod.card),
                        leading: const _IconTile(Icons.credit_card_rounded),
                        title: 'Credit/Debit Card',
                        trailing: Text(
                          'VISA',
                          style: urbanist(
                            18,
                            weight: FontWeight.w800,
                            color: _kVisa,
                          ),
                        ),
                        detail: _method == PayMethod.card
                            ? _cardDetail(context)
                            : null,
                      ),
                      const SizedBox(height: Sp.x5),
                      _Heading('Payment method(s)'),
                      _Option(
                        selected: _method == PayMethod.bkash,
                        onTap: () => setState(() => _method = PayMethod.bkash),
                        leading: _Badge('b', _kBkash),
                        title: 'bKash',
                      ),
                      _Option(
                        selected: _method == PayMethod.rocket,
                        onTap: () => setState(() => _method = PayMethod.rocket),
                        leading: _Badge('R', _kRocket),
                        title: 'Rocket',
                      ),
                      _Option(
                        selected: _method == PayMethod.nagad,
                        onTap: () => setState(() => _method = PayMethod.nagad),
                        leading: _Badge('N', _kNagad),
                        title: 'Nagad',
                      ),
                      _Option(
                        selected: _method == PayMethod.cod,
                        onTap: () => setState(() => _method = PayMethod.cod),
                        leading: const _IconTile(Icons.payments_outlined),
                        title: 'Cash On Delivery',
                        subtitle: 'Make payment after getting product.',
                      ),
                      _Option(
                        selected: _method == PayMethod.bank,
                        onTap: () => setState(() => _method = PayMethod.bank),
                        leading: const _IconTile(
                          Icons.account_balance_outlined,
                        ),
                        title: 'Bank Deposit/NPSB/BFTN/RTGS',
                        detail: _method == PayMethod.bank
                            ? const _BankDetails()
                            : null,
                      ),
                      const SizedBox(height: Sp.x4),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: kSubtle,
                          ),
                          const SizedBox(width: Sp.x2),
                          Expanded(
                            child: Text(
                              'Demo checkout — no real payment is taken.',
                              style: dm(12, color: kSubtle),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    left: Sp.x4,
                    right: Sp.x4,
                    bottom: bottom < 12 ? 12 : bottom,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total', style: dm(12, color: kMuted)),
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
                            PrimaryButton(label: 'Make Payment', onTap: _pay),
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
      ),
    );
  }

  Widget _cardDetail(BuildContext context) {
    final c = app.defaultCard;
    return Row(
      children: [
        Expanded(
          child: Text(
            c == null
                ? 'No saved card yet.'
                : '${c.brand} •••• ${c.last4} · ${c.holder}',
            style: dm(13, color: kMuted),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SavedCardsPage())),
          child: Text(
            c == null ? 'Add card' : 'Manage',
            style: dm(13, weight: FontWeight.w700, color: kBrandGreen),
          ),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Sp.x3),
    child: Text(
      text,
      style: urbanist(16, weight: FontWeight.w800, color: kInk),
    ),
  );
}

/// 40dp rounded tile that holds a method's logo or icon.
class _IconTile extends StatelessWidget {
  const _IconTile(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: kPanel,
      borderRadius: BorderRadius.circular(Rd.md),
    ),
    child: Icon(icon, size: 22, color: kInk),
  );
}

class _Badge extends StatelessWidget {
  const _Badge(this.letter, this.color);
  final String letter;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(Rd.md),
    ),
    child: Text(
      letter,
      style: urbanist(18, weight: FontWeight.w800, color: Colors.white),
    ),
  );
}

class _Option extends StatelessWidget {
  const _Option({
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.detail,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sp.x3),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(Sp.x3),
          decoration: BoxDecoration(
            color: selected ? kSoftGreen.withValues(alpha: 0.5) : Colors.white,
            borderRadius: BorderRadius.circular(Rd.lg),
            border: Border.all(
              color: selected ? kBrandGreen : Colors.transparent,
              width: 2,
            ),
            boxShadow: selected ? null : Elev.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  leading,
                  const SizedBox(width: Sp.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: dm(14, weight: FontWeight.w700, color: kInk),
                        ),
                        if (subtitle != null)
                          Text(subtitle!, style: dm(12, color: kMuted)),
                      ],
                    ),
                  ),
                  ?trailing,
                  const SizedBox(width: Sp.x3),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? kBrandGreen : Colors.transparent,
                      border: Border.all(
                        color: selected ? kBrandGreen : kSubtle,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ],
              ),
              if (detail != null) ...[
                const SizedBox(height: Sp.x3),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Sp.x3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Rd.md),
                  ),
                  child: detail,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BankDetails extends StatelessWidget {
  const _BankDetails();

  @override
  Widget build(BuildContext context) {
    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(k, style: dm(12, color: kMuted)),
          ),
          Expanded(
            child: Text(
              v,
              style: dm(12, weight: FontWeight.w600, color: kInk),
            ),
          ),
        ],
      ),
    );
    return Column(
      children: [
        row('Account Name', 'Madina Cement Industries Ltd.'),
        row('Bank Name', 'Dutch Bangla Bank Ltd.'),
        row('Account Number', '110-323-434-343'),
        row('Branch Name', 'Karwan Bazar'),
        row('Routing Number', '2473953'),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.onChange});
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final a = app.defaultAddress;
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(Sp.x3, Sp.x3, Sp.x2, Sp.x3),
      radius: Rd.lg,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: kSoftGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              size: 22,
              color: kBuyGreen,
            ),
          ),
          const SizedBox(width: Sp.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deliver to', style: dm(12, color: kMuted)),
                Text(
                  a == null ? 'No delivery address yet' : a.oneLine,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: dm(14, weight: FontWeight.w700, color: kInk),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: Text(
              a == null ? 'Add' : 'Change',
              style: dm(14, weight: FontWeight.w700, color: kBrandGreen),
            ),
          ),
        ],
      ),
    );
  }
}
