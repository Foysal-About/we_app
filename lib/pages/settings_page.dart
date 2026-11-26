import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'help_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) => Column(
          children: [
            const PageHeader(title: 'Settings'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  const _Section('Notifications'),
                  _Switch(
                    title: 'Order updates',
                    subtitle: 'Confirmation, shipping and delivery',
                    value: app.notifyOrders,
                    onChanged: app.setNotifyOrders,
                  ),
                  _Switch(
                    title: 'Offers & promotions',
                    subtitle: 'Discounts on cement and bricks',
                    value: app.notifyOffers,
                    onChanged: app.setNotifyOffers,
                  ),
                  const SizedBox(height: 18),
                  const _Section('Account'),
                  _Tile(
                    icon: Icons.lock_outline,
                    title: 'Change password',
                    onTap: () => _changePassword(context),
                  ),
                  _Tile(
                    icon: Icons.help_outline,
                    title: 'Help & support',
                    onTap: () => Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => const HelpPage())),
                  ),
                  _Tile(
                    icon: Icons.description_outlined,
                    title: 'Terms & privacy',
                    onTap: () => toast(
                      context,
                      'Terms & privacy are not part of this demo',
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _Section('About'),
                  _Tile(
                    icon: Icons.info_outline,
                    title: 'WE app',
                    trailing: 'Version 1.0.0',
                    onTap: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changePassword(BuildContext context) {
    final current = TextEditingController();
    final next = TextEditingController();
    showFormSheet<void>(
      context,
      title: 'Change password',
      child: Column(
        children: [
          WeTextField(
            label: 'Current password',
            controller: current,
            obscure: true,
          ),
          const SizedBox(height: 12),
          WeTextField(label: 'New password', controller: next, obscure: true),
          const SizedBox(height: 18),
          Builder(
            builder: (ctx) => PrimaryButton(
              label: 'Update password',
              color: kBrandGreen,
              width: double.infinity,
              onTap: () {
                Navigator.of(ctx).pop();
                toast(context, 'Password updated (demo)');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 4),
    child: Text(
      text.toUpperCase(),
      style: dm(
        11,
        weight: FontWeight.w700,
        color: Colors.black45,
        spacing: 0.8,
      ),
    ),
  );
}

class _Switch extends StatelessWidget {
  const _Switch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
    decoration: BoxDecoration(
      color: kBeige,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: dm(14, weight: FontWeight.w600)),
              Text(subtitle, style: dm(11, color: Colors.black54)),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: Colors.white,
          activeTrackColor: kBrandGreen,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: kBeige,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: kInk),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: dm(14, weight: FontWeight.w600)),
            ),
            if (trailing != null)
              Text(trailing!, style: dm(12, color: Colors.black54)),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    ),
  );
}
