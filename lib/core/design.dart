/// WE design system — the single source of truth for spacing, shape, type
/// and elevation. Colours live in theme.dart next to the ThemeData.
///
/// Principles (from the research behind this file):
///  * 4pt base unit; layout uses 8pt steps.
///  * One typeface (Plus Jakarta Sans) in a small, role-based type scale
///    (12 / 14 / 16 / 18 / 22 / 26 / 34 with matching line heights).
///  * A short radius scale so every surface family looks related.
///  * Controls are 48dp tall (comfortable touch target).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Spacing scale (4pt base).
abstract final class Sp {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20; // page gutter
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x12 = 48;

  /// Horizontal page gutter used by every screen.
  static const double page = x5;

  /// Height of buttons, search bars, pills and standalone steppers.
  static const double control = 48;

  /// Compact controls that live inside a card row (stepper, remove).
  static const double controlCompact = 40;
}

/// Corner radius scale.
abstract final class Rd {
  static const double sm = 8; // tags, tiny chips
  static const double md = 12; // thumbnails, inputs inside sheets
  static const double lg = 16; // cards, fields, tiles
  static const double xl = 24; // panels, banners, floating bars
  static const double xxl = 32; // top of sheets and page panels
  static const double pill = 999; // buttons, chips, nav items
}

/// Elevation presets.
abstract final class Elev {
  static const card = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 3)),
  ];
  static const raised = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
}

const String kFontFamilyName = 'Plus Jakarta Sans';

/// Type scale: every text in the app resolves to one of these sizes.
/// (size, line-height px, tracking)
class _Step {
  const _Step(this.size, this.line, this.tracking);
  final double size;
  final double line;
  final double tracking;
}

const _caption = _Step(12, 16, 0.1);
const _small = _Step(14, 20, 0.1);
const _body = _Step(16, 24, 0);
const _bodyL = _Step(18, 26, 0);
const _title = _Step(22, 30, -0.2);
const _headline = _Step(26, 34, -0.3);
const _display = _Step(34, 42, -0.5);

/// Call sites were written against the old (smaller) scale, so each requested
/// size is mapped up to the right step of this one.
_Step _snap(double size) {
  if (size <= 11.5) return _caption; // 9–11  -> 12
  if (size < 13.5) return _small; //     12–13 -> 14
  if (size <= 15.5) return _body; //     14–15 -> 16
  if (size <= 19.5) return _bodyL; //    16–19 -> 18
  if (size <= 22.5) return _title; //    20–22 -> 22
  if (size <= 27.5) return _headline; // 23–27 -> 26
  return _display; //                    28+   -> 34
}

/// Builds a text style on the type scale. Any requested size is snapped to
/// the nearest step so screens can never drift off-scale.
TextStyle typeStyle(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = Colors.black,
}) {
  final s = _snap(size);
  return GoogleFonts.plusJakartaSans(
    fontSize: s.size,
    height: s.line / s.size,
    letterSpacing: s.tracking,
    fontWeight: weight,
    color: color,
  );
}

/// Material text theme built from the same scale.
TextTheme buildTextTheme(Color ink) {
  TextStyle t(_Step s, FontWeight w) => GoogleFonts.plusJakartaSans(
    fontSize: s.size,
    height: s.line / s.size,
    letterSpacing: s.tracking,
    fontWeight: w,
    color: ink,
  );
  return TextTheme(
    displayLarge: t(_display, FontWeight.w800),
    displayMedium: t(_display, FontWeight.w800),
    displaySmall: t(_headline, FontWeight.w700),
    headlineLarge: t(_headline, FontWeight.w700),
    headlineMedium: t(_headline, FontWeight.w700),
    headlineSmall: t(_title, FontWeight.w700),
    titleLarge: t(_title, FontWeight.w700),
    titleMedium: t(_bodyL, FontWeight.w700),
    titleSmall: t(_body, FontWeight.w700),
    bodyLarge: t(_body, FontWeight.w400),
    bodyMedium: t(_body, FontWeight.w400),
    bodySmall: t(_small, FontWeight.w400),
    labelLarge: t(_body, FontWeight.w600),
    labelMedium: t(_small, FontWeight.w600),
    labelSmall: t(_caption, FontWeight.w600),
  );
}
