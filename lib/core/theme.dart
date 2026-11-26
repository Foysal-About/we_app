import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kBeige = Color(0xFFFBF0E9);
const kPeach = Color(0xFFF9D2B8);
const kBarGrey = Color(0xFFEBEBE6);
const kInk = Color(0xFF292927);
const kGreen = Color(0xFF369B36);
const kBrandGreen = Color(0xFF0D9032);
const kDarkGreen = Color(0xFF1F5E2F);
const kBrown = Color(0xFF8E2A14);
const kBuyGreen = Color(0xFF0E6B2B);
const kPanel = Color(0xFFF9F6F3);
const kTaka = '৳';

TextStyle dm(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = Colors.black,
  double? height,
  double? spacing,
}) => GoogleFonts.dmSans(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: spacing,
);

TextStyle urbanist(
  double size, {
  FontWeight weight = FontWeight.w500,
  Color color = Colors.black,
  double? height,
}) => GoogleFonts.urbanist(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);

String money(double v) => '$kTaka${v.toStringAsFixed(2)}';

ThemeData buildTheme() => ThemeData(
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(seedColor: kBrandGreen),
  textTheme: GoogleFonts.dmSansTextTheme(),
  useMaterial3: true,
);
