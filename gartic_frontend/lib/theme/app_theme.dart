import 'package:flutter/material.dart';

/// Central design tokens for the Draw & Guess UI.
/// Keep all colours / gradients / text styles here so every screen stays
/// consistent. This file is presentation-only and never touches game logic.
class AppColors {
  static const backgroundTop = Color(0xff20124d);
  static const backgroundMid = Color(0xff2d1b69);
  static const backgroundBottom = Color(0xff0f2027);

  static const primary = Color(0xff7c5cff);
  static const primaryDark = Color(0xff4b2fd6);
  static const accent = Color(0xfffdcb6e);
  static const accentDeep = Color(0xffe1a100);
  static const cyan = Color(0xff48dbfb);
  static const success = Color(0xff2ecc71);
  static const danger = Color(0xffe74c3c);

  static const surface = Colors.white;
  static const card = Color(0xfff6f7fb);
  static const ink = Color(0xff12203a);
  static const inkSoft = Color(0xff5b6880);
  static const line = Color(0xffe2e6f0);

  static const chatSurface = Color(0xff101426);
}

class AppGradients {
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.backgroundTop, AppColors.backgroundMid, AppColors.backgroundBottom],
  );

  static const primaryButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  static const wordBadge = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accent, AppColors.accentDeep],
  );

  static const timer = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.cyan, AppColors.primary],
  );

  static const timerLow = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.accent, AppColors.danger],
  );
}

class AppText {
  static const String display = 'gravitas';
  static const String body = 'fsgravity';

  static const TextStyle title = TextStyle(
    fontFamily: display,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: 0.4,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: display,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle label = TextStyle(
    fontFamily: body,
    fontSize: 15,
    color: AppColors.inkSoft,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: body,
    fontSize: 16,
    color: AppColors.ink,
  );

  static const TextStyle onDark = TextStyle(
    fontFamily: body,
    fontSize: 16,
    color: Colors.white,
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.backgroundTop,
    fontFamily: AppText.body,
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontFamily: AppText.display,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 1.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: AppText.body,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: const TextStyle(color: AppColors.inkSoft),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}

/// Full-screen gradient background used by every page.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: child,
    );
  }
}

/// Frosted elevated panel used to group content on the dark background.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
    this.color = AppColors.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Top banner describing the player's current role / phase.
class TurnBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Gradient gradient;
  const TurnBanner({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.gradient = AppGradients.primaryButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppText.display,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: AppText.body,
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
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

/// Small rounded label / badge.
class Pill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final Color textColor;
  const Pill({
    super.key,
    required this.text,
    this.icon,
    this.color = AppColors.primary,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: AppText.body,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
