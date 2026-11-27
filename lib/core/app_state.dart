import 'dart:math';

import 'package:flutter/foundation.dart';

import 'models.dart';

/// In-memory app state shared by every page (demo data, no backend).
class AppState extends ChangeNotifier {
  AppState._();
  static final instance = AppState._();

  String name = '';
  String email = '';

  final Set<String> favorites = {};
  final Map<String, int> cart = {};
  final List<Address> addresses = [];
  final List<PayCard> cards = [];
  final List<Review> reviews = [];
  String? defaultAddressId;
  String? defaultCardId;

  String? promoCode;
  double promoPct = 0;
  bool notificationsSeen = false;
  final List<String> recentSearches = [];

  bool notifyOrders = true;
  bool notifyOffers = false;

  final List<Order> orders = [
    const Order(
      id: '642624624248',
      date: '05-12-2019',
      tracking: 'IW3475453455',
      quantity: 5,
      total: 2000,
      status: OrderStatus.delivered,
    ),
    const Order(
      id: '19470343544',
      date: '05-12-2019',
      tracking: 'IW3475453455',
      quantity: 3,
      total: 112,
      status: OrderStatus.delivered,
    ),
    const Order(
      id: '1947034',
      date: '05-12-2019',
      tracking: 'IW3475453455',
      quantity: 3,
      total: 112,
      status: OrderStatus.delivered,
    ),
  ];

  int _seq = 0;
  String _newId() => '${DateTime.now().microsecondsSinceEpoch}${_seq++}';

  // --- auth -----------------------------------------------------------
  void signIn({required String email, String? name}) {
    this.email = email;
    final base = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : email.split('@').first;
    this.name = base.isEmpty
        ? 'Guest'
        : base[0].toUpperCase() + base.substring(1);
    notifyListeners();
  }

  void signOut() {
    name = '';
    email = '';
    favorites.clear();
    cart.clear();
    addresses.clear();
    cards.clear();
    reviews.clear();
    recentSearches.clear();
    promoCode = null;
    promoPct = 0;
    notificationsSeen = false;
    defaultAddressId = null;
    defaultCardId = null;
    notifyListeners();
  }

  // --- favourites -----------------------------------------------------
  bool isFavorite(String id) => favorites.contains(id);

  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    notifyListeners();
  }

  // --- cart -----------------------------------------------------------
  int get cartCount => cart.values.fold(0, (a, b) => a + b);

  void addToCart(String id, [int qty = 1]) {
    cart[id] = (cart[id] ?? 0) + qty;
    notifyListeners();
  }

  void setQty(String id, int qty) {
    qty <= 0 ? cart.remove(id) : cart[id] = qty;
    notifyListeners();
  }

  void removeFromCart(String id) {
    cart.remove(id);
    notifyListeners();
  }

  double get subtotal => cart.entries.fold(
    0.0,
    (sum, e) => sum + productById(e.key).price * e.value,
  );
  double get discountPct => 0.05 + promoPct;
  double get discount => subtotal * discountPct;

  /// Known promo codes (demo). Returns false when the code is not recognised.
  bool applyPromo(String code) {
    final c = code.trim().toUpperCase();
    const codes = {'WELCOME10': 0.10, 'BUILD5': 0.05};
    if (!codes.containsKey(c)) return false;
    promoCode = c;
    promoPct = codes[c]!;
    notifyListeners();
    return true;
  }

  void clearPromo() {
    promoCode = null;
    promoPct = 0;
    notifyListeners();
  }

  double get delivery => 0;
  double get total => subtotal - discount + delivery;

  // --- addresses ------------------------------------------------------
  Address? get defaultAddress {
    for (final a in addresses) {
      if (a.id == defaultAddressId) return a;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  void saveAddress(Address a) {
    final i = addresses.indexWhere((x) => x.id == a.id);
    i >= 0 ? addresses[i] = a : addresses.add(a);
    defaultAddressId ??= a.id;
    notifyListeners();
  }

  String newAddressId() => _newId();

  void removeAddress(String id) {
    addresses.removeWhere((a) => a.id == id);
    if (defaultAddressId == id) {
      defaultAddressId = addresses.isEmpty ? null : addresses.first.id;
    }
    notifyListeners();
  }

  void setDefaultAddress(String id) {
    defaultAddressId = id;
    notifyListeners();
  }

  // --- cards ----------------------------------------------------------
  PayCard? get defaultCard {
    for (final c in cards) {
      if (c.id == defaultCardId) return c;
    }
    return cards.isEmpty ? null : cards.first;
  }

  void addCard({
    required String number,
    required String holder,
    required String expiry,
  }) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    final brand = digits.startsWith('4')
        ? 'Visa'
        : (digits.startsWith('5') || digits.startsWith('2'))
        ? 'Mastercard'
        : 'Card';
    final card = PayCard(
      id: _newId(),
      brand: brand,
      last4: digits.length >= 4
          ? digits.substring(digits.length - 4)
          : digits.padLeft(4, '0'),
      holder: holder.trim(),
      expiry: expiry,
    );
    cards.add(card);
    defaultCardId ??= card.id;
    notifyListeners();
  }

  void removeCard(String id) {
    cards.removeWhere((c) => c.id == id);
    if (defaultCardId == id) {
      defaultCardId = cards.isEmpty ? null : cards.first.id;
    }
    notifyListeners();
  }

  void setDefaultCard(String id) {
    defaultCardId = id;
    notifyListeners();
  }

  // --- reviews --------------------------------------------------------
  void addReview(String productId, int rating, String text) {
    reviews.insert(
      0,
      Review(
        productId: productId,
        rating: rating,
        text: text.trim(),
        date: _today(),
      ),
    );
    notifyListeners();
  }

  // --- notifications / search ----------------------------------------
  void markNotificationsSeen() {
    if (notificationsSeen) return;
    notificationsSeen = true;
    notifyListeners();
  }

  void addRecentSearch(String q) {
    final t = q.trim();
    if (t.isEmpty) return;
    recentSearches.remove(t);
    recentSearches.insert(0, t);
    if (recentSearches.length > 6) recentSearches.removeLast();
    notifyListeners();
  }

  void clearRecentSearches() {
    recentSearches.clear();
    notifyListeners();
  }

  // --- order actions --------------------------------------------------
  void cancelOrder(String id) {
    final i = orders.indexWhere((o) => o.id == id);
    if (i < 0) return;
    orders[i] = orders[i].copyWith(status: OrderStatus.cancelled);
    notificationsSeen = false;
    notifyListeners();
  }

  /// Puts the order's items back in the cart; returns how many lines were added.
  int reorder(Order o) {
    for (final it in o.items) {
      cart[it.productId] = (cart[it.productId] ?? 0) + it.qty;
    }
    if (o.items.isNotEmpty) notifyListeners();
    return o.items.length;
  }

  // --- settings -------------------------------------------------------
  void setNotifyOrders(bool v) {
    notifyOrders = v;
    notifyListeners();
  }

  void setNotifyOffers(bool v) {
    notifyOffers = v;
    notifyListeners();
  }

  // --- orders ---------------------------------------------------------
  Order? placeOrder({required String payment, required String address}) {
    if (cart.isEmpty) return null;
    final rnd = Random();
    final eta = DateTime.now().add(const Duration(days: 5));
    final order = Order(
      id: (100000000000 + rnd.nextInt(899999999)).toString(),
      date: _fmt(DateTime.now()),
      tracking: 'IW${3000000000 + rnd.nextInt(999999999)}',
      quantity: cartCount,
      total: total,
      status: OrderStatus.processing,
      items: [for (final e in cart.entries) OrderItem(e.key, e.value)],
      payment: payment,
      address: address,
      subtotal: subtotal,
      discount: discount,
      delivery: delivery,
      estimatedDelivery: _fmt(eta),
    );
    orders.insert(0, order);
    cart.clear();
    promoCode = null;
    promoPct = 0;
    notificationsSeen = false;
    notifyListeners();
    return order;
  }

  static String _today() => _fmt(DateTime.now());

  static String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}-${two(d.month)}-${d.year}';
  }
}

final app = AppState.instance;
