import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'addresses_page.dart';
import 'order_success_page.dart';
import 'saved_cards_page.dart';

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
                subtitle: Text(a.line, style: dm(12, color: Colors.black54)),
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
        builder: (context, _) => Column(
          children: [
            const PageHeader(title: 'Select Payment Method'),
            const CheckoutSteps(current: 1),
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
                    children: [
                      _AddressCard(onChange: () => _pickAddress(context)),
                      const SizedBox(height: 22),
                      _Heading('Recommended method(s)'),
                      _Option(
                        selected: _method == PayMethod.card,
                        onTap: () => setState(() => _method = PayMethod.card),
                        leading: const Icon(Icons.credit_card, size: 26),
                        title: 'Credit/Debit Card',
                        trailing: Text(
                          'VISA',
                          style: urbanist(
                            18,
                            weight: FontWeight.w800,
                            color: const Color(0xFF1A3C8C),
                          ),
                        ),
                        detail: _method == PayMethod.card
                            ? _cardDetail(context)
                            : null,
                      ),
                      const SizedBox(height: 18),
                      _Heading('Payment method(s)'),
                      _Option(
                        selected: _method == PayMethod.bkash,
                        onTap: () => setState(() => _method = PayMethod.bkash),
                        leading: _Badge('b', const Color(0xFFE2136E)),
                        title: 'bKash',
                      ),
                      _Option(
                        selected: _method == PayMethod.rocket,
                        onTap: () => setState(() => _method = PayMethod.rocket),
                        leading: _Badge('R', const Color(0xFF8C3494)),
                        title: 'Rocket',
                      ),
                      _Option(
                        selected: _method == PayMethod.nagad,
                        onTap: () => setState(() => _method = PayMethod.nagad),
                        leading: _Badge('N', const Color(0xFFF26522)),
                        title: 'Nagad',
                      ),
                      _Option(
                        selected: _method == PayMethod.cod,
                        onTap: () => setState(() => _method = PayMethod.cod),
                        leading: const Icon(Icons.payments_outlined, size: 26),
                        title: 'Cash On Delivery',
                        subtitle: 'Make payment after getting product.',
                      ),
                      _Option(
                        selected: _method == PayMethod.bank,
                        onTap: () => setState(() => _method = PayMethod.bank),
                        leading: const Icon(
                          Icons.account_balance_outlined,
                          size: 26,
                        ),
                        title: 'Bank Deposit/NPSB/BFTN/RTGS',
                        detail: _method == PayMethod.bank
                            ? const _BankDetails()
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.black45,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Demo checkout — no real payment is taken.',
                              style: dm(12, color: Colors.black45),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: bottom < 12 ? 12 : bottom,
                    child: GlassPanel(
                      radius: 28,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total',
                                  style: dm(12, color: Colors.black54),
                                ),
                                Text(
                                  money(app.total),
                                  style: dm(20, weight: FontWeight.w800),
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
            style: dm(13, color: Colors.black54),
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
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: dm(13, weight: FontWeight.w600, color: Colors.black54),
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge(this.letter, this.color);
  final String letter;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 28,
    height: 28,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      letter,
      style: dm(15, weight: FontWeight.w800, color: Colors.white),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: selected ? kBeige : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? kBrandGreen : kBarGrey,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 22,
                    color: selected ? kBrandGreen : Colors.black45,
                  ),
                  const SizedBox(width: 12),
                  leading,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: dm(14, weight: FontWeight.w600)),
                        if (subtitle != null)
                          Text(subtitle!, style: dm(11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
              if (detail != null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 34),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(k, style: dm(12, color: const Color(0xFFB07A12))),
          ),
          Expanded(
            child: Text(': $v', style: dm(12, color: const Color(0xFFB07A12))),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
      decoration: BoxDecoration(
        color: kBarGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: kInk),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deliver to', style: dm(11, color: Colors.black54)),
                Text(
                  a == null ? 'No delivery address yet' : a.oneLine,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: dm(13, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: Text(
              a == null ? 'Add' : 'Change',
              style: dm(13, weight: FontWeight.w700, color: kBrandGreen),
            ),
          ),
        ],
      ),
    );
  }
}
