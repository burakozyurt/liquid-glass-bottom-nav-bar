import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../accessibility/a11y_resolver.dart';
import '../models/liquid_glass_settings.dart';
import '../widgets/fallback_glass_layer.dart';
import 'glass_field.dart';
import 'liquid_glass_uniforms.dart';

/// The primary (Impeller) glass body: the live backdrop is run through
/// `liquid_glass.frag` via [ui.ImageFilter.shader] to produce real edge
/// refraction, specular rim and adaptive tint. [child] (the bar contents) is
/// painted above it.
///
/// While the shader program is still loading — or if loading fails — this
/// gracefully renders the [FallbackGlassLayer] so the bar is never blank.
class ShaderGlassLayer extends StatefulWidget {
  /// Creates the shader glass body.
  const ShaderGlassLayer({
    super.key,
    required this.borderRadius,
    required this.field,
    required this.settings,
    required this.a11y,
    required this.child,
  });

  /// Shape of the clip / glass body.
  final BorderRadius borderRadius;

  /// The SDF field (shapes + blend) sampled by the shader.
  final GlassField field;

  /// Visual tuning.
  final LiquidGlassSettings settings;

  /// Resolved accessibility decisions (used by the fallback).
  final ResolvedA11y a11y;

  /// Bar contents drawn above the glass.
  final Widget child;

  /// Asset key of the bundled fragment program.
  static const String shaderAsset =
      'packages/liquid_glass_bottom_nav_bar/shaders/liquid_glass.frag';

  @override
  State<ShaderGlassLayer> createState() => _ShaderGlassLayerState();
}

class _ShaderGlassLayerState extends State<ShaderGlassLayer> {
  // The compiled program is process-wide; load it once and share.
  static Future<ui.FragmentProgram>? _programFuture;

  ui.FragmentShader? _shader;
  bool _failed = false;

  /// The bar's top-left in the backdrop's coordinate space. `ImageFilter.shader`
  /// runs over the whole backdrop, so the shapes must be shifted to where the
  /// bar actually sits on screen; this is read from the render object after
  /// layout and fed to [LiquidGlassUniforms.pack].
  Offset _origin = Offset.zero;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Keep [_origin] in sync with the bar's painted position. Runs after layout
  // (the offset is unknown during build) and only rebuilds when it moves, so it
  // settles after the first frame instead of looping.
  void _syncOrigin() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final origin = box.localToGlobal(Offset.zero);
    if (origin != _origin) setState(() => _origin = origin);
  }

  Future<void> _load() async {
    try {
      _programFuture ??= ui.FragmentProgram.fromAsset(
        ShaderGlassLayer.shaderAsset,
      );
      final program = await _programFuture!;
      if (!mounted) return;
      setState(() => _shader = program.fragmentShader());
    } catch (error, stack) {
      // Surface *why* the shader path was abandoned rather than silently
      // dropping to the frosted fallback — otherwise "the glass isn't
      // refracting" is undebuggable. The fallback still renders; in release
      // builds this report is stripped and the drop stays silent.
      assert(() {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'liquid_glass_bottom_nav_bar',
            context: ErrorDescription(
              'loading the Liquid Glass fragment program '
              '("${ShaderGlassLayer.shaderAsset}") — falling back to '
              'frosted glass',
            ),
          ),
        );
        return true;
      }());
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The painted offset is only known after layout; re-check each frame and
    // repack if the bar moved (rotation, scroll-minimize, keyboard inset).
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncOrigin());

    final shader = _shader;
    if (shader == null || _failed) {
      return FallbackGlassLayer(
        borderRadius: widget.borderRadius,
        settings: widget.settings,
        a11y: widget.a11y,
        child: widget.child,
      );
    }

    final screen = MediaQuery.sizeOf(context);
    LiquidGlassUniforms.pack(
      shader,
      widget.field,
      widget.settings,
      _origin,
      screen,
    );

    // The frosted blur is done *inside* the shader (it samples the full,
    // un-clipped backdrop), so we don't compose an ImageFilter.blur here:
    // composing a blur with a BackdropFilter inside a ClipRRect produced
    // clip/bounds artifacts (a ghost reflection below the bar, edge falloff and
    // a horizontal seam). A bare shader filter has none of those.
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: BackdropFilter(
        filter: ui.ImageFilter.shader(shader),
        child: widget.child,
      ),
    );
  }
}
