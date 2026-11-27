import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class AddressesPage extends StatelessWidget {
  const AddressesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) => GlassHeaderColumn(
          children: [
            const PageHeader(title: 'Shipping Addresses'),
            Expanded(
              child: app.addresses.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // Offset so the content centres in the area below the bar.
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const EmptyState(
                          icon: Icons.location_off_outlined,
                          message: 'No delivery addresses yet.',
                        ),
                        PrimaryButton(
                          label: 'Add address',
                          color: kBrandGreen,
                          onTap: () => _edit(context, null),
                        ),
                        const SizedBox(height: 80),
                      ],
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        Sp.page,
                        PageHeader.heightOf(context) + Sp.x1,
                        Sp.page,
                        100,
                      ),
                      itemCount: app.addresses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (_, i) => _AddressTile(
                        address: app.addresses[i],
                        onEdit: () => _edit(context, app.addresses[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: app,
        builder: (_, _) => app.addresses.isEmpty
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                onPressed: () => _edit(context, null),
                icon: const Icon(Icons.add),
                label: Text(
                  'Add address',
                  style: dm(14, weight: FontWeight.w600, color: Colors.white),
                ),
              ),
      ),
    );
  }

  void _edit(BuildContext context, Address? existing) {
    final name = TextEditingController(text: existing?.name ?? app.name);
    final phone = TextEditingController(text: existing?.phone ?? '');
    final line = TextEditingController(text: existing?.line ?? '');
    var label = existing?.label ?? 'Home';
    showFormSheet<void>(
      context,
      title: existing == null ? 'New address' : 'Edit address',
      child: StatefulBuilder(
        builder: (ctx, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final l in const ['Home', 'Office', 'Other'])
                  ChoiceChip(
                    label: Text(l),
                    selected: label == l,
                    onSelected: (_) => setState(() => label = l),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            WeTextField(label: 'Full name', controller: name),
            const SizedBox(height: Sp.x3),
            WeTextField(
              label: 'Phone',
              controller: phone,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: Sp.x3),
            WeTextField(label: 'Address', controller: line, maxLines: 2),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Save address',
              color: kBrandGreen,
              width: double.infinity,
              onTap: () {
                app.saveAddress(
                  Address(
                    id: existing?.id ?? app.newAddressId(),
                    label: label,
                    name: name.text.trim(),
                    phone: phone.text.trim(),
                    line: line.text.trim(),
                  ),
                );
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({required this.address, required this.onEdit});
  final Address address;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final isDefault = app.defaultAddress?.id == address.id;
    return GestureDetector(
      onTap: () => app.setDefaultAddress(address.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(Sp.x4, Sp.x4, Sp.x2, Sp.x3),
        decoration: BoxDecoration(
          color: isDefault ? kSoftGreen.withValues(alpha: 0.5) : Colors.white,
          borderRadius: BorderRadius.circular(Rd.lg),
          border: Border.all(
            color: isDefault ? kBrandGreen : Colors.transparent,
            width: 2,
          ),
          boxShadow: isDefault ? null : Elev.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              address.label == 'Office'
                  ? Icons.business_outlined
                  : address.label == 'Home'
                  ? Icons.home_outlined
                  : Icons.place_outlined,
              color: kInk,
            ),
            const SizedBox(width: Sp.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label,
                        style: dm(14, weight: FontWeight.w700),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: Sp.x2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Sp.x2,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: kBrandGreen,
                            borderRadius: BorderRadius.circular(Rd.xl),
                          ),
                          child: Text(
                            'Default',
                            style: dm(
                              10,
                              weight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: Sp.x1),
                  Text(
                    [
                      address.name,
                      address.phone,
                    ].where((s) => s.isNotEmpty).join(' · '),
                    style: dm(12, color: kMuted),
                  ),
                  if (address.line.isNotEmpty)
                    Text(address.line, style: dm(13, height: 1.35)),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () => app.removeAddress(address.id),
                  icon: const Icon(Icons.delete_outline, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
