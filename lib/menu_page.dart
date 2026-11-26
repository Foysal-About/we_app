import 'package:flutter/material.dart';

const _beige = Color(0xFFFBF0E9);
const _barGrey = Color(0xFFEBEBE6);
const _ink = Color(0xFF292927);
const _green = Color(0xFF369B36);
const _rust = Color(0xFFA73016);

class Product {
  const Product(this.name, this.price, {this.favorite = false});
  final String name;
  final String price;
  final bool favorite;
}

const _products = [
  Product('Tiger Cement OPC', '530.00', favorite: true),
  Product('Tiger Cement PPC', '55.00'),
  Product('Tiger Cement OPC', '530.00'),
  Product('Tiger Cement PPC', '55.00'),
  Product('Tiger Cement OPC', '530.00'),
  Product('Tiger Cement PPC', '55.00'),
  Product('Tiger Cement OPC', '530.00'),
  Product('Tiger Cement PPC', '55.00'),
  Product('Tiger Cement OPC', '530.00'),
  Product('Tiger Cement PPC', '55.00'),
];

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      bottomNavigationBar: const _BottomBar(),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _Header()),
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: _beige,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                padding: const EdgeInsets.fromLTRB(19, 29, 19, 0),
                child: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text('Choose Brand', style: _label),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _BrandContainer()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(19, 0, 19, 120),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 34,
                  childAspectRatio: 178 / 223,
                ),
                itemCount: _products.length,
                itemBuilder: (_, i) => ProductCard(product: _products[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _label = TextStyle(
  fontFamily: 'DM Sans',
  fontSize: 16,
  height: 21 / 16,
  color: Color(0xB3000000),
);

/// Beige background wrapper holding brand tiles + "Tiger Cement Products".
class _BrandContainer extends StatelessWidget {
  const _BrandContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _beige,
      padding: const EdgeInsets.fromLTRB(19, 14, 19, 0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _BrandTile(label: 'Tiger', selected: true)),
              SizedBox(width: 34),
              Expanded(child: _BrandTile(label: 'Brand 2')),
              SizedBox(width: 34),
              Expanded(child: _BrandTile(label: 'WSJIL')),
            ],
          ),
          SizedBox(height: 28),
          Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text('Tiger Cement Products', style: _label),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({required this.label, this.selected = false});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFEFEFE),
        borderRadius: BorderRadius.circular(10),
        border: selected ? Border.all(color: const Color(0xFFE36B35)) : null,
        boxShadow: selected
            ? const [
                BoxShadow(
                    color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 1))
              ]
            : null,
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, color: _ink),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            onPressed: () {},
            icon: const Icon(Icons.menu, size: 33, color: Colors.black),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text(
              'Discover our\nperfect product',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w500,
                fontSize: 24,
                height: 29 / 24,
                color: Color(0x80000000),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _barGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: _ink.withValues(alpha: 0.5)),
                const SizedBox(width: 12),
                Text(
                  'Search',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    letterSpacing: -0.4,
                    color: _ink.withValues(alpha: 0.5),
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

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _fav = widget.product.favorite;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.fromLTRB(11, 6, 11, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => setState(() => _fav = !_fav),
              child: Icon(
                Icons.favorite,
                size: 24,
                color: _fav ? const Color(0xFFFB0000) : const Color(0xFFB8B8B8),
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Icon(Icons.inventory_2_outlined,
                  size: 90, color: Color(0xFFB8B8B8)),
            ),
          ),
          Text(
            p.name,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
              fontSize: 10,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          const _RatingBars(),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.check_circle_outline, size: 8, color: _green),
              SizedBox(width: 2),
              Text(
                'In stock',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                  fontSize: 9,
                  color: _green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            p.price,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _RatingBars extends StatelessWidget {
  const _RatingBars();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (i) => Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 2),
          color: i < 4 ? _rust : Colors.black,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    Widget item(IconData icon, {bool active = false, Widget? badge}) {
      return Container(
        width: 56,
        height: 40,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0D9032) : null,
          borderRadius: BorderRadius.circular(360),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [Icon(icon, color: _ink), ?badge],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottom + 12),
      decoration: const BoxDecoration(
        color: _barGrey,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x2E000000),
            blurRadius: 64,
            spreadRadius: -12,
            offset: Offset(0, -11),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          item(Icons.home_outlined, active: true),
          item(Icons.search),
          item(Icons.shopping_cart_outlined),
          item(
            Icons.favorite_border,
            badge: Positioned(
              right: 8,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF53D5FF),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('1', style: TextStyle(fontSize: 8)),
              ),
            ),
          ),
          item(Icons.person_outline),
        ],
      ),
    );
  }
}
