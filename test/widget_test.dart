import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_app/core/app_state.dart';
import 'package:we_app/core/models.dart';
import 'package:we_app/main.dart';
import 'package:we_app/widgets/common.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('login without validation -> checkout -> order details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<void> settle() async {
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      tester.takeException(); // offline font loading noise
    }

    await tester.pumpWidget(const MyApp());
    // Splash -> onboarding -> skip to login.
    await tester.pump(const Duration(milliseconds: 2000));
    await settle();
    await tester.tap(find.text('Skip'));
    await settle();

    // No validation: logging in with empty fields works.
    await tester.tap(find.text('Login').last);
    await settle();
    expect(app.name, 'Guest');
    expect(find.text('Tiger Cement OPC'), findsOneWidget);

    // Product -> cart (qty 2).
    await tester.tap(find.text('Tiger Cement OPC'));
    await settle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.text('Add to cart'));
    await settle();
    expect(app.cart['opc'], 2);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await settle();

    // Cart: change quantity inline, then checkout.
    shellIndex.value = 2;
    await settle();
    expect(find.text('Order Summary'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add).first);
    await settle();
    expect(app.cart['opc'], 3);
    await tester.tap(find.text('Place Order'));
    await settle();
    expect(find.text('Select Payment Method'), findsOneWidget);

    // Pay on delivery, no address or card required.
    await tester.tap(find.text('Cash On Delivery'));
    await settle();
    await tester.tap(find.text('Make Payment'));
    await settle();
    expect(app.cart, isEmpty);
    expect(app.orders.first.payment, 'Cash On Delivery');
    expect(find.text('Order placed!'), findsOneWidget);

    await tester.tap(find.text('View order'));
    await settle();
    expect(find.text('Order Details'), findsOneWidget);
    expect(find.text('Order Confirmed'), findsOneWidget);
  });

  test('promo code, reorder and cancel', () {
    app.cart.clear();
    app.addToCart('opc', 2);
    expect(app.applyPromo('nope'), isFalse);
    expect(app.applyPromo(' welcome10 '), isTrue);
    expect(app.discountPct, closeTo(0.15, 1e-9));
    final order = app.placeOrder(payment: 'Cash On Delivery', address: '')!;
    expect(app.promoCode, isNull); // consumed by the order
    expect(order.discount, closeTo(1060 * 0.15, 0.001));

    expect(app.reorder(order), 1);
    expect(app.cart['opc'], 2);

    app.cancelOrder(order.id);
    expect(
      app.orders.firstWhere((o) => o.id == order.id).status,
      OrderStatus.cancelled,
    );
  });

  test('recently viewed keeps newest first, max 6', () {
    app.viewed.clear();
    for (final id in ['opc', 'ppc', 'brick3', 'hollow', 'opc']) {
      app.markViewed(id);
    }
    expect(app.viewed.first, 'opc');
    expect(app.viewed.length, 4);
  });

  test('forms accept anything', () {
    app.addCard(number: 'abc', holder: '', expiry: '');
    expect(app.cards.last.last4, '0000');
    app.addReview('opc', 3, '');
    expect(app.reviews.first.rating, 3);
  });
}
