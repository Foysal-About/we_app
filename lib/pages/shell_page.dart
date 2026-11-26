import 'package:flutter/material.dart';

import '../widgets/bottom_bar.dart';
import '../widgets/common.dart';
import 'cart_page.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'search_page.dart';

/// Main screen: the five tabs of the bottom bar.
class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  static const _pages = <Widget>[
    HomePage(),
    SearchPage(),
    CartPage(),
    FavoritesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: shellIndex,
      builder: (context, index, _) => Scaffold(
        extendBody: true,
        bottomNavigationBar: WeBottomBar(
          index: index,
          onChanged: (i) => shellIndex.value = i,
        ),
        body: IndexedStack(index: index, children: _pages),
      ),
    );
  }
}
