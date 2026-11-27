import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design.dart';

export 'design.dart';

// --- Brand palette ---------------------------------------------------------
const kBrandGreen = Color(0xFF0D9032); // primary actions, active states
const kBuyGreen = Color(0xFF0E6B2B); // strong confirm (Buy Now)
const kDarkGreen = Color(0xFF1F5E2F); // deep surfaces
const kGreen = Color(0xFF369B36); // success text / icons
const kAccent = Color(0xFFE36B35); // promos, badges, selection outline
const kBrown = Color(0xFF8E2A14); // add-to-cart

// --- Neutrals & text -------------------------------------------------------
const kInk = Color(0xFF292927); // primary text and icons
const kMuted = Color(0xFF5F5F5A); // secondary text (contrast ≈ 6:1 on white)
const kSubtle = Color(0xFF85857F); // captions, disabled
const kBarGrey = Color(0xFFEBEBE6); // fields, chips, dividers
const kPanel = Color(0xFFF9F6F3); // soft panel

// --- Surface tints (per product family) ------------------------------------
const kBeige = Color(0xFFFBF0E9);
const kPeach = Color(0xFFF9D2B8);
const kMint = Color(0xFFC4ECD7);
const kSoftGreen = Color(0xFFDDEFD9); // success / applied tint
const kSoftPeach = Color(0xFFFFE2CF); // warm gradient end
const kFavorite = Color(0xFFE53935); // filled heart

// Light ends of the promo gradients.
const kAccentLight = Color(0xFFF2A154);
const kGreenLight = Color(0xFF5CBF6B);
const kDarkGreenLight = Color(0xFF3F8F4F);
const kFacebook = Color(0xFF1877F2);

// --- Status ----------------------------------------------------------------
const kDanger = Color(0xFFD32F2F);
const kWarning = Color(0xFFE08A00);
const kInfo = Color(0xFF53D5FF);

const kTaka = '৳';

/// Body text on the type scale (regular by default).
TextStyle dm(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = Colors.black,
  double? height,
  double? spacing,
}) => typeStyle(size, weight: weight, color: color);

/// Headings on the same scale (medium by default). Kept as a separate name
/// so call sites read as "heading", but it is the same family and scale.
TextStyle urbanist(
  double size, {
  FontWeight weight = FontWeight.w600,
  Color color = Colors.black,
  double? height,
}) => typeStyle(size, weight: weight, color: color);

/// Estimated delivery date, a few days from now (e.g. "3 Dec").
String deliveryEta([int days = 5]) {
  final d = DateTime.now().add(Duration(days: days));
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${m[d.month - 1]}';
}

String money(double v) => '$kTaka${v.toStringAsFixed(2)}';

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kBrandGreen,
    primary: kBrandGreen,
    surface: Colors.white,
    error: kDanger,
  );
  final text = buildTextTheme(kInk);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    // Soft panel behind pages made of cards; free-form pages set white.
    scaffoldBackgroundColor: kPanel,
    textTheme: text,
    primaryTextTheme: text,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.white,
    ),
    // iOS-style slide + swipe-back on every platform for one navigation feel.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    dividerTheme: const DividerThemeData(
      color: kBarGrey,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kInk,
      contentTextStyle: typeStyle(
        14,
        weight: FontWeight.w500,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rd.lg)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Rd.xl)),
      titleTextStyle: text.titleLarge,
      contentTextStyle: text.bodyMedium,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: kBarGrey,
      selectedColor: kBrandGreen.withValues(alpha: 0.16),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      labelStyle: typeStyle(12, weight: FontWeight.w600, color: kInk),
      padding: const EdgeInsets.symmetric(horizontal: Sp.x1),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: kBarGrey,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Rd.xxl)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? kBrandGreen : kSubtle,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        textStyle: typeStyle(14, weight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kInk,
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
    ),
  );
}
