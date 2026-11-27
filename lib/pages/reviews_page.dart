import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/models.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final barBottom = bottom < 12 ? 12.0 : bottom;
    return Scaffold(
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final reviews = app.reviews;
          return GlassHeaderColumn(
            children: [
              const PageHeader(title: 'My Reviews'),
              Expanded(
                child: Stack(
                  children: [
                    Builder(
                      builder: (ctx) {
                        final inset = GlassTopInset.of(ctx);
                        if (reviews.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.only(top: inset),
                            child: const EmptyState(
                              icon: Icons.rate_review_outlined,
                              message: 'You have not reviewed anything yet.',
                            ),
                          );
                        }
                        return ListView(
                          padding: EdgeInsets.fromLTRB(
                            Sp.page,
                            inset + Sp.x2,
                            Sp.page,
                            barBottom + 96,
                          ),
                          children: [
                            _Summary(reviews: reviews),
                            const SizedBox(height: Sp.x5),
                            Text(
                              'Your reviews',
                              style: urbanist(
                                18,
                                weight: FontWeight.w800,
                                color: kInk,
                              ),
                            ),
                            const SizedBox(height: Sp.x3),
                            for (final r in reviews)
                              Padding(
                                padding: const EdgeInsets.only(bottom: Sp.x3),
                                child: _ReviewCard(review: r),
                              ),
                          ],
                        );
                      },
                    ),
                    // Floating glass action bar.
                    Positioned(
                      left: Sp.x4,
                      right: Sp.x4,
                      bottom: barBottom,
                      child: GlassPanel(
                        radius: Rd.xl,
                        child: Padding(
                          padding: const EdgeInsets.all(Sp.x3),
                          child: PrimaryButton(
                            label: 'Write a review',
                            color: kBrandGreen,
                            width: double.infinity,
                            onTap: () => _write(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
            Text(
              'Product',
              style: dm(14, weight: FontWeight.w700, color: kInk),
            ),
            const SizedBox(height: Sp.x2),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, _) => const SizedBox(width: Sp.x2),
                itemBuilder: (_, i) {
                  final p = products[i];
                  final on = selected == p.id;
                  return GestureDetector(
                    onTap: () => setState(() => selected = p.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 92,
                      padding: const EdgeInsets.all(Sp.x2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(Rd.md),
                        border: Border.all(
                          color: on ? kBrandGreen : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Rd.sm),
                              child: ProductImage.of(p),
                            ),
                          ),
                          const SizedBox(height: Sp.x1),
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: dm(
                              12,
                              weight: on ? FontWeight.w700 : FontWeight.w500,
                              color: kInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: Sp.x4),
            Center(
              child: StarRating(
                value: rating,
                size: 38,
                onChanged: (v) => setState(() => rating = v),
              ),
            ),
            const SizedBox(height: Sp.x4),
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

/// Average rating and a 5-to-1 star breakdown.
class _Summary extends StatelessWidget {
  const _Summary({required this.reviews});
  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    final n = reviews.length;
    final avg = reviews.fold<int>(0, (a, r) => a + r.rating) / n;
    int count(int star) => reviews.where((r) => r.rating == star).length;
    return SurfaceCard(
      padding: const EdgeInsets.all(Sp.x5),
      radius: Rd.xl,
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: urbanist(34, weight: FontWeight.w800, color: kInk),
              ),
              const SizedBox(height: Sp.x1),
              StarRating(value: avg.round(), size: 16),
              const SizedBox(height: Sp.x1),
              Text(
                '$n ${n == 1 ? 'review' : 'reviews'}',
                style: dm(12, color: kMuted),
              ),
            ],
          ),
          const SizedBox(width: Sp.x5),
          Expanded(
            child: Column(
              children: [
                for (var star = 5; star >= 1; star--)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14,
                          child: Text(
                            '$star',
                            style: dm(
                              12,
                              weight: FontWeight.w600,
                              color: kMuted,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: kWarning,
                        ),
                        const SizedBox(width: Sp.x2),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Rd.pill),
                            child: LinearProgressIndicator(
                              value: count(star) / n,
                              minHeight: 6,
                              backgroundColor: kBarGrey,
                              valueColor: const AlwaysStoppedAnimation(
                                kWarning,
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
        ],
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
    return SurfaceCard(
      padding: const EdgeInsets.all(Sp.x4),
      radius: Rd.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kPanel,
                  borderRadius: BorderRadius.circular(Rd.md),
                ),
                child: ProductImage.of(p),
              ),
              const SizedBox(width: Sp.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: dm(14, weight: FontWeight.w700, color: kInk),
                    ),
                    const SizedBox(height: 2),
                    StarRating(value: review.rating, size: 16),
                  ],
                ),
              ),
              Text(review.date, style: dm(12, color: kSubtle)),
            ],
          ),
          if (review.text.isNotEmpty) ...[
            const SizedBox(height: Sp.x3),
            Text(review.text, style: dm(14, color: kInk)),
          ],
        ],
      ),
    );
  }
}
