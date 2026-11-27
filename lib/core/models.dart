import 'package:flutter/material.dart';

import 'theme.dart';

class Brand {
  const Brand(this.id, this.title, this.logo);
  final String id;
  final String title;
  final String logo;
}

const brands = [
  Brand(
    'cement',
    'Tiger Cement Products',
    'assets/images/brand_tiger_cement.png',
  ),
  Brand(
    'concrete',
    'Tiger Concrete Products',
    'assets/images/brand_tiger_concrete.png',
  ),
  Brand('sjil', 'SJIL Products', 'assets/images/brand_sjil.png'),
];

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brandId,
    required this.price,
    required this.image,
    required this.tint,
    required this.features,
    this.size,
    this.oldPrice,
    this.unitOverride,
    this.categoryOverride,
    this.demo = false,
    this.photo = false,
  });

  final String id;
  final String name;
  final String brandId;
  final double price;
  final String image;
  final Color tint;
  final String? size;
  final List<String> features;
  final double? oldPrice;
  final String? unitOverride;
  final String? categoryOverride;

  /// The price is only indicative (not published by the manufacturer).
  final bool demo;

  /// The picture is a real scene photo (fills its frame) rather than a
  /// transparent product cut-out (shown whole, with padding).
  final bool photo;

  String get unit => unitOverride ?? (brandId == 'cement' ? 'bag' : 'piece');
  String get category =>
      categoryOverride ??
      (brandId == 'cement' ? 'Cement' : 'Concrete products');

  /// Percent saved when an old price is shown.
  int? get savingPercent => oldPrice == null
      ? null
      : (((oldPrice! - price) / oldPrice!) * 100).round();
}

const products = <Product>[
  Product(
    id: 'opc',
    name: 'Tiger Cement OPC',
    brandId: 'cement',
    price: 530,
    image: 'assets/images/product_opc.png',
    tint: kBeige,
    features: [
      'Provides a strong structure.',
      'Robust and excellent for C15, C20, C25, C30 grade constructions.',
      'Cost effective as lesser amount of cement is required.',
      'Volume of Alkyl, Chloride, Magnesium and lime is very low so it is very good for creating robust and perfect concrete.',
    ],
  ),
  Product(
    id: 'ppc',
    name: 'Tiger Cement PPC',
    brandId: 'cement',
    price: 55,
    image: 'assets/images/product_ppc.png',
    tint: kBeige,
    features: [
      'Provides a strong structure.',
      'Robust and excellent for C15, C20, C25, C30 grade constructions.',
      'Cost effective as lesser amount of cement is required.',
    ],
  ),
  Product(
    id: 'brick3',
    name: '3-Hole Brick',
    brandId: 'concrete',
    price: 12,
    image: 'assets/images/product_brick_3hole.png',
    tint: kPeach,
    size: '240 × 114 × 70 mm',
    features: [
      'Provides a strong structure.',
      'Robust and excellent for C15, C20, C25, C30 grade constructions.',
      'Cost effective as lesser amount of cement is required.',
    ],
  ),
  Product(
    id: 'hollow',
    name: 'Hollow Brick',
    brandId: 'concrete',
    price: 50,
    image: 'assets/images/product_block_hollow.png',
    tint: kPeach,
    features: [
      'Lightweight and easy to handle.',
      'Good thermal and sound insulation.',
      'Cost effective for partition walls.',
    ],
  ),
  Product(
    id: 'geobag',
    name: 'Geo Bag',
    brandId: 'sjil',
    price: 530,
    oldPrice: 600,
    image: 'assets/images/product_geobag.png',
    tint: kMint,
    unitOverride: 'bag',
    categoryOverride: 'Geosynthetics',
    features: [
      'Provides a strong structure.',
      'Robust and excellent for C15, C20, C25, C30 grade constructions.',
      'Cost effective as lesser amount of cement is required.',
    ],
  ),
  Product(
    id: 'padding',
    name: 'Padding',
    brandId: 'sjil',
    price: 530,
    oldPrice: 600,
    image: 'assets/images/product_padding.jpg',
    tint: kMint,
    unitOverride: 'bag',
    categoryOverride: 'Geosynthetics',
    features: [
      'Provides a strong structure.',
      'Robust and excellent for C15, C20, C25, C30 grade constructions.',
      'Cost effective as lesser amount of cement is required.',
    ],
  ),

  // ---- Real Tiger Concrete / SJIL (WSJIL) products. Names, sizes and photos
  // come from the companies' own sites; `demo: true` marks a price that is
  // only indicative. ----
  Product(
    id: 'brick_solid',
    name: 'Solid Brick',
    brandId: 'concrete',
    price: 14,
    image: 'assets/images/product_brick_solid.jpg',
    tint: kPeach,
    size: '240 × 114 × 70 mm',
    photo: true,
    demo: true,
    features: [
      'Applications: boundary wall, soling and base work.',
      'Suitable for any type of building.',
      'Solid concrete brick by Tiger Concrete Products.',
    ],
  ),
  Product(
    id: 'paver_zigzag',
    name: 'Zig Zag Paver',
    brandId: 'concrete',
    price: 18,
    image: 'assets/images/product_paver_zigzag.jpg',
    tint: kPeach,
    size: '222 × 110 × 60 / 80 mm',
    photo: true,
    demo: true,
    features: [
      'Also called Uni Paver; available with or without colour.',
      'Applications: car parking, footpath, internal road, container yard, park and industrial yard.',
      'Interlocking shape for a stable, even surface.',
    ],
  ),
  Product(
    id: 'erosion_block',
    name: 'Erosion Control Block',
    brandId: 'concrete',
    price: 140,
    image: 'assets/images/product_erosion_block.jpg',
    tint: kPeach,
    size: '444 × 315 × 100 mm',
    categoryOverride: 'Concrete products',
    photo: true,
    demo: true,
    features: [
      'Applications: lake, soil and river bank protection, marine application and grass parking.',
      'Interlocking design that holds slopes in place.',
    ],
  ),
  Product(
    id: 'kerb_stone',
    name: 'Kerb Stone (K1)',
    brandId: 'concrete',
    price: 180,
    image: 'assets/images/product_kerb_stone.jpg',
    tint: kPeach,
    size: '550 × 380 × 150 mm',
    photo: true,
    demo: true,
    features: [
      'Also made as K3 (600×300×100/60), K4 (600×200×100) and K6 (500×400×120/65) mm.',
      'Applications: road and pavement edging, landscaping.',
    ],
  ),
  Product(
    id: 'geosheet_200',
    name: 'Geo Sheet 200 GSM',
    brandId: 'sjil',
    price: 38,
    image: 'assets/images/product_geosheet.jpg',
    tint: kMint,
    unitOverride: 'sq m',
    categoryOverride: 'Geosynthetics',
    photo: true,
    features: [
      '100% PSF non-woven geotextile, 200 GSM.',
      'Separation, filtration, drainage and reinforcement.',
      'Riverbank and canal stabilisation; road, railway and airport track construction.',
      'Available in 3 m, 4 m and 5 m widths in different lengths.',
    ],
  ),
  Product(
    id: 'geosheet_400',
    name: 'Geo Sheet 400 GSM',
    brandId: 'sjil',
    price: 65,
    image: 'assets/images/product_geotextile_roll.jpg',
    tint: kMint,
    unitOverride: 'sq m',
    categoryOverride: 'Geosynthetics',
    photo: true,
    features: [
      '100% PSF non-woven geotextile, 400 GSM: heavier and more puncture resistant.',
      'Embankments, land reclamation, drainage and soil stabilisation.',
      'Available in 3 m, 4 m and 5 m widths in different lengths.',
    ],
  ),
];

Product productById(String id) => products.firstWhere((p) => p.id == id);

enum OrderStatus { delivered, processing, cancelled }

/// One look for each order status, used everywhere a status is shown.
extension OrderStatusStyle on OrderStatus {
  Color get color => switch (this) {
    OrderStatus.delivered => kGreen,
    OrderStatus.processing => kWarning,
    OrderStatus.cancelled => kDanger,
  };
  IconData get icon => switch (this) {
    OrderStatus.delivered => Icons.check_circle_outline,
    OrderStatus.processing => Icons.hourglass_bottom,
    OrderStatus.cancelled => Icons.cancel_outlined,
  };
  String get label => switch (this) {
    OrderStatus.delivered => 'Delivered',
    OrderStatus.processing => 'Processing',
    OrderStatus.cancelled => 'Cancelled',
  };
}

class OrderItem {
  const OrderItem(this.productId, this.qty);
  final String productId;
  final int qty;
}

class Order {
  const Order({
    required this.id,
    required this.date,
    required this.tracking,
    required this.quantity,
    required this.total,
    required this.status,
    this.items = const [],
    this.payment = '',
    this.address = '',
    this.subtotal = 0,
    this.discount = 0,
    this.delivery = 0,
    this.estimatedDelivery = '',
  });

  final String id;
  final String date;
  final String tracking;
  final int quantity;
  final double total;
  final OrderStatus status;
  final List<OrderItem> items;
  final String payment;
  final String address;
  final double subtotal;
  final double discount;
  final double delivery;
  final String estimatedDelivery;

  Order copyWith({OrderStatus? status}) => Order(
    id: id,
    date: date,
    tracking: tracking,
    quantity: quantity,
    total: total,
    status: status ?? this.status,
    items: items,
    payment: payment,
    address: address,
    subtotal: subtotal,
    discount: discount,
    delivery: delivery,
    estimatedDelivery: estimatedDelivery,
  );
}

class Address {
  const Address({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.line,
  });

  final String id;
  final String label; // Home, Office …
  final String name;
  final String phone;
  final String line;

  String get oneLine => '$label — $line';
}

/// Only the last four digits are ever kept; the full number and CVV are
/// never stored.
class PayCard {
  const PayCard({
    required this.id,
    required this.brand,
    required this.last4,
    required this.holder,
    required this.expiry,
  });

  final String id;
  final String brand;
  final String last4;
  final String holder;
  final String expiry;
}

class Review {
  const Review({
    required this.productId,
    required this.rating,
    required this.text,
    required this.date,
  });

  final String productId;
  final int rating;
  final String text;
  final String date;
}
