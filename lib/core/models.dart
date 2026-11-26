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
  });

  final String id;
  final String name;
  final String brandId;
  final double price;
  final String image;
  final Color tint;
  final String? size;
  final List<String> features;

  String get unit => brandId == 'cement' ? 'bag' : 'piece';
  String get category => brandId == 'cement' ? 'Cement' : 'Concrete products';
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
    size: '222 × 110 × 60 mm',
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
];

Product productById(String id) => products.firstWhere((p) => p.id == id);

enum OrderStatus { delivered, processing, cancelled }

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
