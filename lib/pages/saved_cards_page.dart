import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class SavedCardsPage extends StatelessWidget {
  const SavedCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) => GlassHeaderColumn(
          children: [
            const PageHeader(title: 'Payment Method'),
            Expanded(
              child: app.cards.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // Offset so the content centres in the area below the bar.
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const EmptyState(
                          icon: Icons.credit_card_off_outlined,
                          message: 'No saved cards yet.',
                        ),
                        PrimaryButton(
                          label: 'Add a card',
                          color: kBrandGreen,
                          onTap: () => _addCard(context),
                        ),
                        const SizedBox(height: 80),
                      ],
                    )
                  : ListView(
                      padding: EdgeInsets.fromLTRB(
                        Sp.page,
                        PageHeader.heightOf(context) + Sp.x1,
                        Sp.page,
                        100,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: Sp.x3),
                          child: Text(
                            'Your payment cards',
                            style: dm(14, weight: FontWeight.w600),
                          ),
                        ),
                        for (var i = 0; i < app.cards.length; i++)
                          _CardTile(card: app.cards[i], dark: i.isEven),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: app,
        builder: (_, _) => app.cards.isEmpty
            ? const SizedBox.shrink()
            : FloatingActionButton(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                tooltip: 'Add card',
                onPressed: () => _addCard(context),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  void _addCard(BuildContext context) {
    final holder = TextEditingController(text: app.name);
    final number = TextEditingController();
    final expiry = TextEditingController();
    showFormSheet<void>(
      context,
      title: 'Add a card',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeTextField(label: 'Card holder name', controller: holder),
          const SizedBox(height: Sp.x3),
          WeTextField(
            label: 'Card number',
            controller: number,
            keyboard: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
            ],
          ),
          const SizedBox(height: Sp.x3),
          WeTextField(
            label: 'Expiry (MM/YY)',
            controller: expiry,
            keyboard: TextInputType.datetime,
          ),
          const SizedBox(height: 10),
          Text(
            'Only the last 4 digits are kept on this device.',
            style: dm(11, color: kMuted),
          ),
          const SizedBox(height: Sp.x4),
          Builder(
            builder: (ctx) => PrimaryButton(
              label: 'Save card',
              color: kBrandGreen,
              width: double.infinity,
              onTap: () {
                app.addCard(
                  number: number.text,
                  holder: holder.text,
                  expiry: expiry.text.isEmpty ? '--/--' : expiry.text,
                );
                Navigator.of(ctx).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card, required this.dark});
  final PayCard card;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final isDefault = app.defaultCard?.id == card.id;
    final fg = dark ? Colors.white : Colors.white;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 190,
            padding: const EdgeInsets.fromLTRB(Sp.x6, Sp.x5, Sp.x6, Sp.x5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Rd.xl),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? const [Color(0xFF3A3A3A), Color(0xFF111111)]
                    : const [Color(0xFFB4B4B4), Color(0xFF8C8C8C)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 38,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2B33D),
                        borderRadius: BorderRadius.circular(Rd.sm),
                      ),
                    ),
                    Text(
                      card.brand.toUpperCase(),
                      style: urbanist(18, weight: FontWeight.w800, color: fg),
                    ),
                  ],
                ),
                const Spacer(),
                Center(
                  child: Text(
                    '****  ****  ****  ${card.last4}',
                    style: dm(
                      20,
                      weight: FontWeight.w600,
                      color: fg,
                      spacing: 2,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _Meta(
                      'Card Holder Name',
                      card.holder.isEmpty ? '—' : card.holder,
                      fg,
                    ),
                    _Meta('Expiry Date', card.expiry, fg),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Flexible(
                child: InkWell(
                  onTap: () => app.setDefaultCard(card.id),
                  borderRadius: BorderRadius.circular(Rd.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Sp.x2,
                      horizontal: Sp.x1,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isDefault
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 22,
                          color: isDefault ? kBrandGreen : kMuted,
                        ),
                        const SizedBox(width: Sp.x2),
                        Flexible(
                          child: Text(
                            'Use as default payment method',
                            overflow: TextOverflow.ellipsis,
                            style: dm(13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Remove card',
                onPressed: () => app.removeCard(card.id),
                icon: const Icon(Icons.delete_outline, color: kMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: dm(9, color: color.withValues(alpha: 0.8))),
      const SizedBox(height: 2),
      Text(
        value,
        style: dm(13, weight: FontWeight.w600, color: color),
      ),
    ],
  );
}
