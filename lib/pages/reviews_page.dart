import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) => Column(
          children: [
            const PageHeader(title: 'My Reviews'),
            Expanded(
              child: app.reviews.isEmpty
                  ? const EmptyState(
                      icon: Icons.rate_review_outlined,
                      message: 'You have not reviewed anything yet.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: app.reviews.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (_, i) =>
                          _ReviewCard(review: app.reviews[i]),
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                8,
                24,
                MediaQuery.paddingOf(context).bottom + 16,
              ),
              child: PrimaryButton(
                label: 'Write a review',
                color: kBrandGreen,
                width: double.infinity,
                onTap: () => _write(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _write(BuildContext context) {
    final text = TextEditingController();
    var selected = products.first.id;
    var rating = 5;
    showFormSheet<void>(
      context,
      title: 'Write a review',
      child: StatefulBuilder(
        builder: (ctx, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final p in products)
                  ChoiceChip(
                    label: Text(p.name),
                    selected: selected == p.id,
                    onSelected: (_) => setState(() => selected = p.id),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: StarRating(
                value: rating,
                size: 38,
                onChanged: (v) => setState(() => rating = v),
              ),
            ),
            const SizedBox(height: 16),
            WeTextField(label: 'Your review', controller: text, maxLines: 4),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Submit',
              color: kBrandGreen,
              width: double.infinity,
              onTap: () {
                app.addReview(selected, rating, text.text);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    final p = productById(review.productId);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: p.tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(p.image, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        p.name,
                        style: dm(14, weight: FontWeight.w700),
                      ),
                    ),
                    Text(review.date, style: dm(11, color: Colors.black45)),
                  ],
                ),
                const SizedBox(height: 4),
                StarRating(value: review.rating, size: 15),
                if (review.text.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(review.text, style: dm(13, height: 1.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
