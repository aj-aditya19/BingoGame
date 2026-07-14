import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFF4F7FB);
  static const bgSoft = Color(0xFFE9EFF7);
  static const panel = Color(0xFFFFFFFF);
  static const line = Color(0xFFD8E2EF);
  static const text = Color(0xFF1F2A37);
  static const muted = Color(0xFF5F6F82);

  static const accent = Color(0xFFF59E0B);
  static const accent2 = Color(0xFF2563EB);
  static const accentDark = Color(0xFF1D4ED8);
  static const success = Color(0xFF0F9F62);
  static const danger = Color(0xFFDC2626);

  static const softBlueBg = Color(0xFFE8F0FF);
  static const softBlueBorder = Color(0xFFBFDBFE);

  static const amberBadgeBg = Color(0xFFFFF3D4);
  static const amberBadgeBorder = Color(0xFFF9D58B);
  static const amberBadgeText = Color(0xFF8A5A00);

  static const greenPillBg = Color(0xFFEEFDF4);
  static const greenPillBorder = Color(0xFFB9EFCF);

  static const chosenCellBg = Color(0xFFDBEAFE);
  static const chosenCellText = Color(0xFF1D4ED8);

  static const completedCellBg = Color(0xFFFEF3C7);
  static const completedCellText = Color(0xFF92400E);
  static const completedCellBorder = Color(0xFFF9D58B);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: "Segoe UI",

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent2,
        primary: AppColors.accent2,
        secondary: AppColors.accent,
        error: AppColors.danger,
        surface: AppColors.panel,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.text),
        bodyMedium: TextStyle(color: AppColors.text),
      ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.panel,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        color: AppColors.panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFDFEFE),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF60A5FA), width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.muted),
        hintStyle: const TextStyle(color: AppColors.muted),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent2,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.line,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentDark,
          backgroundColor: AppColors.softBlueBg,
          side: const BorderSide(color: AppColors.softBlueBorder),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accentDark),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.text,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF9FBFF), AppColors.bg],
            ),
          ),
        ),
        Positioned(top: -60, left: -60, child: _glow(const Color(0x33F59E0B))),

        Positioned(
          bottom: -80,
          right: -80,
          child: _glow(const Color(0x332563EB)),
        ),
        child,
      ],
    );
  }

  Widget _glow(Color color) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class AppBadge extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;
  final Color border;
  final Widget? leading;

  const AppBadge({
    super.key,
    required this.text,
    this.background = AppColors.amberBadgeBg,
    this.foreground = AppColors.amberBadgeText,
    this.border = AppColors.amberBadgeBorder,
  }) : leading = null;

  const AppBadge.withDot({
    super.key,
    required this.text,
    this.background = AppColors.greenPillBg,
    this.foreground = AppColors.success,
    this.border = AppColors.greenPillBorder,
  }) : leading = const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
      ),
    );
  }
}

class CenteredCardPage extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CenteredCardPage({super.key, required this.child, this.maxWidth = 420});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Card(
                child: Padding(padding: const EdgeInsets.all(24), child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
