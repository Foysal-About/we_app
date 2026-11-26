import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final items = <_Note>[
            if (app.notifyOffers)
              const _Note(
                icon: Icons.local_offer_outlined,
                color: Color(0xFFE08A00),
                title: 'Extra 10% off',
                body: 'Use code WELCOME10 at checkout on your next order.',
                when: 'Offer',
              ),
            if (app.notifyOrders)
              for (final o in app.orders) _Note.fromOrder(o),
            const _Note(
              icon: Icons.waving_hand_outlined,
              color: kBrandGreen,
              title: 'Welcome to WE',
              body: 'Browse cement and bricks, and order in a few taps.',
              when: 'Welcome',
            ),
          ];
          return Column(
            children: [
              const PageHeader(title: 'Notifications'),
              Expanded(
                child: items.isEmpty
                    ? const EmptyState(
                        icon: Icons.notifications_off_outlined,
                        message: 'Nothing new right now.',
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          4,
                          20,
                          MediaQuery.paddingOf(context).bottom + 24,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _NoteTile(note: items[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Note {
  const _Note({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.when,
  });

  factory _Note.fromOrder(Order o) {
    switch (o.status) {
      case OrderStatus.delivered:
        return _Note(
          icon: Icons.check_circle_outline,
          color: kGreen,
          title: 'Order delivered',
          body: 'Order ${o.id} has been delivered.',
          when: o.date,
        );
      case OrderStatus.processing:
        return _Note(
          icon: Icons.hourglass_bottom,
          color: const Color(0xFFE08A00),
          title: 'Order confirmed',
          body: 'Order ${o.id} is being prepared.',
          when: o.date,
        );
      case OrderStatus.cancelled:
        return _Note(
          icon: Icons.cancel_outlined,
          color: const Color(0xFFD32F2F),
          title: 'Order cancelled',
          body: 'Order ${o.id} was cancelled.',
          when: o.date,
        );
    }
  }

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String when;
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note});
  final _Note note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: note.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(note.icon, color: note.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        note.title,
                        style: dm(14, weight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(note.when, style: dm(11, color: Colors.black45)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  note.body,
                  style: dm(12.5, color: Colors.black54, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
