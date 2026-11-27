import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'addresses_page.dart';
import 'auth_page.dart';
import 'help_page.dart';
import 'orders_page.dart';
import 'reviews_page.dart';
import 'saved_cards_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  void _edit(BuildContext context) {
    final name = TextEditingController(text: app.name);
    final email = TextEditingController(text: app.email);
    showFormSheet<void>(
      context,
      title: 'Edit profile',
      child: Column(
        children: [
          WeTextField(label: 'Full name', controller: name),
          const SizedBox(height: Sp.x3),
          WeTextField(
            label: 'Email',
            controller: email,
            keyboard: TextInputType.emailAddress,
          ),
          const SizedBox(height: Sp.x5),
          Builder(
            builder: (ctx) => PrimaryButton(
              label: 'Save',
              color: kBrandGreen,
              width: double.infinity,
              onTap: () {
                app.signIn(email: email.text.trim(), name: name.text);
                Navigator.of(ctx).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final navHeight = 64 + (bottom < 12 ? 12.0 : bottom);
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final card = app.defaultCard;
        final n = app.addresses.length;
        return GlassHeaderColumn(
          children: [
            PageHeader(title: 'My profile', onBack: () => shellIndex.value = 0),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  Sp.page,
                  PageHeader.heightOf(context) + Sp.x2,
                  Sp.page,
                  navHeight + Sp.x6,
                ),
                children: [
                  _ProfileCard(onEdit: () => _edit(context)),
                  const SizedBox(height: Sp.x6),
                  const _GroupTitle('My account'),
                  _Group(
                    children: [
                      _Row(
                        icon: Icons.receipt_long_outlined,
                        color: kAccent,
                        title: 'My orders',
                        subtitle: 'Already have ${app.orders.length} orders',
                        onTap: () => _open(context, const OrdersPage()),
                      ),
                      _Row(
                        icon: Icons.location_on_outlined,
                        color: kBrandGreen,
                        title: 'Shipping addresses',
                        subtitle: n == 0
                            ? 'No addresses yet'
                            : '$n ${n == 1 ? 'address' : 'addresses'}',
                        onTap: () => _open(context, const AddressesPage()),
                      ),
                      _Row(
                        icon: Icons.credit_card_outlined,
                        color: kFacebook,
                        title: 'Payment methods',
                        subtitle: card == null
                            ? 'No saved cards'
                            : '${card.brand} •• ${card.last4.substring(2)}',
                        onTap: () => _open(context, const SavedCardsPage()),
                      ),
                      _Row(
                        icon: Icons.star_outline_rounded,
                        color: kWarning,
                        title: 'My reviews',
                        subtitle: 'Reviews for ${app.reviews.length} items',
                        onTap: () => _open(context, const ReviewsPage()),
                        last: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.x5),
                  const _GroupTitle('More'),
                  _Group(
                    children: [
                      _Row(
                        icon: Icons.settings_outlined,
                        color: kMuted,
                        title: 'Settings',
                        subtitle: 'Notifications, password',
                        onTap: () => _open(context, const SettingsPage()),
                      ),
                      _Row(
                        icon: Icons.help_outline,
                        color: kInfo,
                        title: 'Help & support',
                        subtitle: 'FAQs and contact',
                        onTap: () => _open(context, const HelpPage()),
                        last: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: Sp.x6),
                  OutlinedButton.icon(
                    onPressed: () {
                      app.signOut();
                      shellIndex.value = 0;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthPage()),
                        (_) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, size: 20),
                    label: Text(
                      'Log out',
                      style: dm(14, weight: FontWeight.w700, color: kDanger),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kDanger,
                      minimumSize: const Size.fromHeight(Sp.control),
                      side: const BorderSide(color: kDanger),
                      shape: const StadiumBorder(),
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

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.onEdit});
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final name = app.name.isEmpty ? 'Guest' : app.name;
    return Container(
      padding: const EdgeInsets.all(Sp.x5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Rd.xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kBeige, kSoftPeach],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: kBrandGreen,
                  child: Text(
                    name[0].toUpperCase(),
                    style: urbanist(
                      26,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Sp.x4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: urbanist(22, weight: FontWeight.w800, color: kInk),
                    ),
                    if (app.email.isNotEmpty)
                      Text(
                        app.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: dm(12, color: kMuted),
                      ),
                    const SizedBox(height: Sp.x2),
                    Tappable(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sp.x3,
                          vertical: Sp.x1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(Rd.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: kInk,
                            ),
                            const SizedBox(width: Sp.x1),
                            Text(
                              'Edit profile',
                              style: dm(
                                12,
                                weight: FontWeight.w700,
                                color: kInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Sp.x5),
          Row(
            children: [
              _Stat('${app.orders.length}', 'Orders'),
              const SizedBox(width: Sp.x2),
              _Stat('${app.favorites.length}', 'Saved'),
              const SizedBox(width: Sp.x2),
              _Stat('${app.cartCount}', 'In cart'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: Sp.x3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(Rd.lg),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: urbanist(22, weight: FontWeight.w800, color: kInk),
          ),
          Text(label, style: dm(12, color: kMuted)),
        ],
      ),
    ),
  );
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: Sp.x1, bottom: Sp.x2),
    child: Text(
      text.toUpperCase(),
      style: dm(12, weight: FontWeight.w700, color: kSubtle),
    ),
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: EdgeInsets.zero,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(Rd.lg),
      child: Column(children: children),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.last = false,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Sp.x4, vertical: Sp.x3),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: kBarGrey)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Rd.md),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: Sp.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: dm(14, weight: FontWeight.w700, color: kInk),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: dm(12, color: kMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kSubtle),
          ],
        ),
      ),
    );
  }
}
