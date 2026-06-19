import 'package:flutter/material.dart';

/// Visual styling for [LiquidGlassBottomBar] contents (colors, labels, pill).
///
/// Register it on your [ThemeData] via `extensions: [LiquidGlassBarTheme(...)]`
/// or pass one directly to the bar. Missing values fall back to
/// brightness-aware defaults.
@immutable
class LiquidGlassBarTheme extends ThemeExtension<LiquidGlassBarTheme> {
  /// Creates a bar theme. Any null field uses a resolved default.
  const LiquidGlassBarTheme({
    this.iconColor,
    this.selectedIconColor,
    this.labelStyle,
    this.selectedLabelStyle,
    this.pillColor,
    this.showLabels = true,
  });

  /// Color of unselected icons/labels.
  final Color? iconColor;

  /// Color of the selected icon/label.
  final Color? selectedIconColor;

  /// Text style for unselected labels.
  final TextStyle? labelStyle;

  /// Text style for the selected label.
  final TextStyle? selectedLabelStyle;

  /// Fill color of the selection pill.
  final Color? pillColor;

  /// Whether labels are shown beneath icons.
  final bool showLabels;

  /// Resolves an effective theme from an [override], the ambient theme
  /// extension and brightness-aware defaults.
  static LiquidGlassBarTheme resolve(
    BuildContext context,
    LiquidGlassBarTheme? override,
  ) {
    final ambient = Theme.of(context).extension<LiquidGlassBarTheme>();
    final brightness = Theme.of(context).brightness;
    final defaults = _defaultsFor(brightness);
    return defaults.merge(ambient).merge(override);
  }

  static LiquidGlassBarTheme _defaultsFor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? Colors.white : const Color(0xFF1C1C1E);
    return LiquidGlassBarTheme(
      iconColor: base.withValues(alpha: 0.62),
      selectedIconColor: base,
      labelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: base.withValues(alpha: 0.62),
      ),
      selectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      pillColor: base.withValues(alpha: isDark ? 0.18 : 0.10),
    );
  }

  /// Returns a copy of this theme with [other]'s non-null fields applied.
  LiquidGlassBarTheme merge(LiquidGlassBarTheme? other) {
    if (other == null) return this;
    return copyWith(
      iconColor: other.iconColor,
      selectedIconColor: other.selectedIconColor,
      labelStyle: other.labelStyle,
      selectedLabelStyle: other.selectedLabelStyle,
      pillColor: other.pillColor,
      showLabels: other.showLabels,
    );
  }

  @override
  LiquidGlassBarTheme copyWith({
    Color? iconColor,
    Color? selectedIconColor,
    TextStyle? labelStyle,
    TextStyle? selectedLabelStyle,
    Color? pillColor,
    bool? showLabels,
  }) {
    return LiquidGlassBarTheme(
      iconColor: iconColor ?? this.iconColor,
      selectedIconColor: selectedIconColor ?? this.selectedIconColor,
      labelStyle: labelStyle ?? this.labelStyle,
      selectedLabelStyle: selectedLabelStyle ?? this.selectedLabelStyle,
      pillColor: pillColor ?? this.pillColor,
      showLabels: showLabels ?? this.showLabels,
    );
  }

  @override
  LiquidGlassBarTheme lerp(
    ThemeExtension<LiquidGlassBarTheme>? other,
    double t,
  ) {
    if (other is! LiquidGlassBarTheme) return this;
    return LiquidGlassBarTheme(
      iconColor: Color.lerp(iconColor, other.iconColor, t),
      selectedIconColor: Color.lerp(
        selectedIconColor,
        other.selectedIconColor,
        t,
      ),
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t),
      selectedLabelStyle: TextStyle.lerp(
        selectedLabelStyle,
        other.selectedLabelStyle,
        t,
      ),
      pillColor: Color.lerp(pillColor, other.pillColor, t),
      showLabels: t < 0.5 ? showLabels : other.showLabels,
    );
  }
}
