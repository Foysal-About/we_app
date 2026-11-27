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
                color: kWarning,
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
          return GlassHeaderColumn(
            children: [
              const PageHeader(title: 'Notifications'),
              Expanded(
                child: items.isEmpty
                    ? Padding(
                        padding: EdgeInsets.only(
                          top: PageHeader.heightOf(context),
                        ),
                        child: const EmptyState(
                          icon: Icons.notifications_off_outlined,
                          message: 'Nothing new right now.',
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          PageHeader.heightOf(context) + Sp.x2,
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
          icon: OrderStatus.delivered.icon,
          color: OrderStatus.delivered.color,
          title: 'Order delivered',
          body: 'Order ${o.id} has been delivered.',
          when: o.date,
        );
      case OrderStatus.processing:
        return _Note(
          icon: OrderStatus.processing.icon,
          color: OrderStatus.processing.color,
          title: 'Order confirmed',
          body: 'Order ${o.id} is being prepared.',
          when: o.date,
        );
      case OrderStatus.cancelled:
        return _Note(
          icon: OrderStatus.cancelled.icon,
          color: OrderStatus.cancelled.color,
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
    return SurfaceCard(
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
                    const SizedBox(width: Sp.x2),
                    Text(note.when, style: dm(11, color: kSubtle)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(note.body, style: dm(12.5, color: kMuted, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
