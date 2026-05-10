import 'package:flutter/material.dart';

/// Shared design system for TaskHive inner pages.
/// Mirrors the _TH palette used in dashboard.dart.
class TH {
  // Canvas & surfaces
  static const canvas = Color(0xFFFDFBFA);
  static const white = Color(0xFFFFFFFF);
  static const surface1 = Color(0xFFF8F5F3);
  static const surface2 = Color(0xFFF2EDEB);

  // Blush — brand signature
  static const blush = Color(0xFFCB6679);
  static const blushLight = Color(0xFFE9A0AB);
  static const blushFaint = Color(0xFFFAEFF1);
  static const blushBorder = Color(0xFFEDD3D8);

  // Soft Rose - Premium variant
  static const softRose = Color(0xFFBF5A6E);
  static const softRoseLight = Color(0xFFD4758A);

  // Ink — warm charcoal
  static const ink = Color(0xFF211418);
  static const ink2 = Color(0xFF5A3D44);
  static const ink3 = Color(0xFF9A7E86);
  static const ink4 = Color(0xFFD8C8CB);

  // Semantic
  static const green = Color(0xFF2E8B65);
  static const greenFaint = Color(0xFFE4F5EE);
  static const greenBorder = Color(0xFFB4DDD0);
  static const amber = Color(0xFF9B6E1A);
  static const amberFaint = Color(0xFFF9F0E0);
  static const amberBorder = Color(0xFFDFC89A);
  static const crimson = Color(0xFFB03040);
  static const crimsonFaint = Color(0xFFFBE9EC);
  static const crimsonBorder = Color(0xFFE5B0B8);

  // Gradients
  static const blushGrad = LinearGradient(
    colors: [Color(0xFFD97080), Color(0xFFCB6679)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const softRoseGrad = LinearGradient(
    colors: [softRoseLight, softRose],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF3D1F26).withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: const Color(0xFF3D1F26).withValues(alpha: 0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> floatShadow = [
    BoxShadow(
      color: const Color(0xFFCB6679).withValues(alpha: 0.28),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  // Helpers
  static BoxDecoration cardDecoration({
    Color? color,
    double radius = 20,
    Color? borderColor,
  }) =>
      BoxDecoration(
        color: color ?? white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? ink4.withValues(alpha: 0.7)),
        boxShadow: cardShadow,
      );

  static InputDecoration inputDecoration(
    BuildContext context, {
    required String label,
    String? hint,
    IconData? icon,
    Widget? suffix,
    int maxLines = 1,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: icon == null
            ? null
            : maxLines > 1
                ? Padding(
                    padding: EdgeInsets.only(bottom: (maxLines - 1) * 20.0),
                    child: Icon(icon, color: blush),
                  )
                : Icon(icon, color: blush),
        suffixIcon: suffix,
        labelStyle: const TextStyle(color: ink3, fontWeight: FontWeight.w600),
        hintStyle: const TextStyle(color: ink4),
        filled: true,
        fillColor: surface1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ink4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: ink4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: blush, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: crimson, width: 1.2),
        ),
      );

  /// A styled AppBar consistent with the dashboard.
  static AppBar appBar(
    BuildContext context, {
    required String title,
    List<Widget>? actions,
    bool showBack = true,
  }) =>
      AppBar(
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: showBack,
        iconTheme: const IconThemeData(color: ink),
        titleSpacing: showBack ? 0 : 22,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ink,
            letterSpacing: -0.5,
          ),
        ),
        actions: actions,
      );

  /// Priority colour helper
  static Color priorityColor(String? p) {
    switch ((p ?? '').toLowerCase()) {
      case 'high':
        return crimson;
      case 'medium':
        return amber;
      case 'low':
        return green;
      default:
        return ink3;
    }
  }

  static Color priorityFaint(String? p) {
    switch ((p ?? '').toLowerCase()) {
      case 'high':
        return crimsonFaint;
      case 'medium':
        return amberFaint;
      case 'low':
        return greenFaint;
      default:
        return surface1;
    }
  }

  static Color priorityBorder(String? p) {
    switch ((p ?? '').toLowerCase()) {
      case 'high':
        return crimsonBorder;
      case 'medium':
        return amberBorder;
      case 'low':
        return greenBorder;
      default:
        return ink4;
    }
  }

  /// Status colour
  static Color statusColor(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'done':
        return green;
      case 'in progress':
        return amber;
      case 'to do':
        return blush;
      default:
        return ink3;
    }
  }

  static Color statusFaint(String? s) {
    switch ((s ?? '').toLowerCase()) {
      case 'done':
        return greenFaint;
      case 'in progress':
        return amberFaint;
      case 'to do':
        return blushFaint;
      default:
        return surface1;
    }
  }

  /// Primary action button
  static Widget primaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
  }) =>
      SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: blushGrad,
            borderRadius: BorderRadius.circular(16),
            boxShadow: floatShadow,
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
}
