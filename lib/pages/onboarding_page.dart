import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/common.dart';
import 'auth_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      title: 'Quality cement\nand bricks',
      body:
          'Browse trusted Tiger Cement and Tiger Concrete products in one place.',
      image: 'assets/images/product_opc.png',
      tint: kBeige,
    ),
    _Slide(
      title: 'Order in\na few taps',
      body:
          'Add to cart, apply a promo code and pay your way — card, mobile wallet, cash or bank.',
      image: 'assets/images/product_brick_3hole.png',
      tint: kPeach,
    ),
    _Slide(
      title: 'Track every\ndelivery',
      body:
          'Follow each order from confirmation to your doorstep, all in My Orders.',
      image: 'assets/images/product_ppc.png',
      tint: kSoftGreen,
    ),
  ];

  void _finish() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthPage()));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _slides.length - 1;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(28, Sp.x2, 28, bottom + 24),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: TextButton(
                    onPressed: _finish,
                    child: Text('Skip', style: dm(14, color: kMuted)),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _page ? 26 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page ? kBrandGreen : kBarGrey,
                            borderRadius: BorderRadius.circular(Rd.sm),
                          ),
                        ),
                    ],
                  ),
                ),
                PrimaryButton(
                  label: last ? 'Get started' : 'Next',
                  color: kBrandGreen,
                  onTap: last
                      ? _finish
                      : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
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

class _Slide {
  const _Slide({
    required this.title,
    required this.body,
    required this.image,
    required this.tint,
  });
  final String title;
  final String body;
  final String image;
  final Color tint;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: slide.tint,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(Rd.xxl),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Positioned(top: 12, child: WeLogo(width: 80)),
                  Container(
                    width: 270,
                    height: 270,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Image.asset(
                      slide.image,
                      width: 230,
                      height: 230,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Sp.x8, Sp.x8, Sp.x8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slide.title,
                  style: urbanist(32, weight: FontWeight.w800, height: 1.15),
                ),
                const SizedBox(height: 14),
                Text(slide.body, style: dm(15, color: kMuted, height: 1.45)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
