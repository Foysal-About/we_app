import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'addresses_page.dart';
import 'auth_page.dart';
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
          const SizedBox(height: 12),
          WeTextField(
            label: 'Email',
            controller: email,
            keyboard: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
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
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final card = app.defaultCard;
        final n = app.addresses.length;
        return Column(
          children: [
            PageHeader(title: 'My profile', onBack: () => shellIndex.value = 0),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 12, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: kBarGrey,
                    child: Text(
                      app.name.isEmpty ? '?' : app.name[0],
                      style: urbanist(30, weight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name.isEmpty ? 'Guest' : app.name,
                          style: urbanist(20, weight: FontWeight.w700),
                        ),
                        if (app.email.isNotEmpty)
                          Text(app.email, style: dm(13, color: Colors.black54)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit profile',
                    onPressed: () => _edit(context),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                children: [
                  Row(
                    children: [
                      _Stat(
                        '${app.orders.length}',
                        'Orders',
                        Icons.receipt_long_outlined,
                      ),
                      const SizedBox(width: 10),
                      _Stat(
                        '${app.favorites.length}',
                        'Saved',
                        Icons.favorite_border,
                      ),
                      const SizedBox(width: 10),
                      _Stat(
                        '${app.cartCount}',
                        'In cart',
                        Icons.shopping_cart_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _Row(
                    title: 'My orders',
                    subtitle: 'Already have ${app.orders.length} orders',
                    onTap: () => _open(context, const OrdersPage()),
                  ),
                  _Row(
                    title: 'Shipping addresses',
                    subtitle: n == 0
                        ? 'No addresses yet'
                        : '$n ${n == 1 ? 'address' : 'addresses'}',
                    onTap: () => _open(context, const AddressesPage()),
                  ),
                  _Row(
                    title: 'Payment methods',
                    subtitle: card == null
                        ? 'No saved cards'
                        : '${card.brand} **${card.last4.substring(2)}',
                    onTap: () => _open(context, const SavedCardsPage()),
                  ),
                  _Row(
                    title: 'My reviews',
                    subtitle: 'Reviews for ${app.reviews.length} items',
                    onTap: () => _open(context, const ReviewsPage()),
                  ),
                  _Row(
                    title: 'Settings',
                    subtitle: 'Notifications, password',
                    onTap: () => _open(context, const SettingsPage()),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: PrimaryButton(
                      label: 'Log out',
                      width: 200,
                      onTap: () {
                        app.signOut();
                        shellIndex.value = 0;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const AuthPage()),
                          (_) => false,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.paddingOf(context).bottom + 67 + 32,
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

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kBarGrey)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: urbanist(16, weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: dm(12, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.icon);
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: kBeige,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: kInk),
          const SizedBox(height: 6),
          Text(value, style: urbanist(20, weight: FontWeight.w800)),
          Text(label, style: dm(11, color: Colors.black54)),
        ],
      ),
    ),
  );
}
