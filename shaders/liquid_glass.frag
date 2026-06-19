#version 460 core
#include <flutter/runtime_effect.glsl>
#include "include/sdf.glsl"
#include "include/glass.glsl"

// Liquid Glass material, applied to the live backdrop via ImageFilter.shader.
//
// Uniform contract (ImageFilter.shader): the FIRST uniform must be a vec2 (the
// engine fills it with the input texture size) and the FIRST sampler is the
// backdrop. All other floats are packed by LiquidGlassUniforms in this exact
// order — keep Dart and GLSL in lockstep (see uniform_packing_test).
//
// As a BackdropFilter, FlutterFragCoord and uSize span the whole backdrop
// (≈ the screen), not the bar. So geometry (uThickness, uBlend, uShapeData) is
// packed as a FRACTION of uSize and rebuilt to pixels here via `frac * uSize`;
// this stays correct regardless of dpr and of where the bar sits on screen.

uniform vec2 uSize;            // 0..1  (engine: texture size in px)
uniform float uThickness;      // 2     bevel depth, fraction of width
uniform float uRefractiveIndex;// 3
uniform float uLightAngle;     // 4     radians
uniform float uLightIntensity; // 5
uniform float uAmbient;        // 6
uniform vec4 uGlassColor;      // 7..10 rgb + tint alpha
uniform float uSaturation;     // 11
uniform float uOutline;        // 12    inner specular sheen
uniform float uChromatic;      // 13    chromatic aberration (0 = off)
uniform float uShapeCount;     // 14
uniform float uBlend;          // 15    smin radius, fraction of width
uniform float uBlur;           // 16    frosted blur radius, fraction of width
uniform float uShapeData[48];  // 17..64  8 shapes × (kind,cx,cy,halfW,halfH,r)
                               //          cx,cy,halfW,halfH,r are uSize fractions

uniform sampler2D uBackdrop;   // sampler 0 (engine: filter input)

out vec4 fragColor;

const int kMaxShapes = 8;

// Combined signed distance of all active shapes, smin-blended. Geometry is
// stored as a fraction of the backdrop; multiply by uSize to get pixels in the
// same space as FlutterFragCoord. Scalars (corner radius, blend) use uSize.x —
// the per-axis ratio is identical, so x and y share one scale.
float sceneSDF(vec2 p) {
  float d = 1.0e9;
  int count = int(uShapeCount + 0.5);
  float blendPx = uBlend * uSize.x;
  for (int i = 0; i < kMaxShapes; i++) {
    if (i >= count) {
      break;
    }
    int o = i * 6;
    vec2 c = vec2(uShapeData[o + 1], uShapeData[o + 2]) * uSize;
    vec2 b = vec2(uShapeData[o + 3], uShapeData[o + 4]) * uSize;
    float r = uShapeData[o + 5] * uSize.x;
    float di = sdRoundedBox(p - c, b, r);
    d = (i == 0) ? di : sminPoly(d, di, blendPx);
  }
  return d;
}

// Outward-pointing gradient of the scene SDF (central differences).
vec2 sceneGrad(vec2 p) {
  const float e = 1.0;
  float dx = sceneSDF(p + vec2(e, 0.0)) - sceneSDF(p - vec2(e, 0.0));
  float dy = sceneSDF(p + vec2(0.0, e)) - sceneSDF(p - vec2(0.0, e));
  return normalize(vec2(dx, dy) + vec2(1.0e-6));
}

// Frosted (Apple-like) blur of the backdrop around [uv], radius in pixels.
// Sampling the full, *un-clipped* backdrop here — rather than pre-blurring via
// ImageFilter.compose — is what avoids the clip/bounds artifacts a
// BackdropFilter blur produces inside a ClipRRect (ghost reflection below the
// bar, edge falloff, and the horizontal seam across it).
//
// Samples are placed on a golden-angle (Vogel) spiral with a Gaussian weight:
// the spiral fills the disc evenly (no concentric rings → no visible banding /
// "stepping") and `r = sqrt(t)` gives uniform area density. 24 taps reads as a
// smooth frost.
vec3 frostedSample(vec2 uv, vec2 pxToUv, float radiusPx) {
  if (radiusPx <= 0.5) {
    return texture(uBackdrop, uv).rgb;
  }
  const int kTaps = 24;
  const float kGolden = 2.399963229728653; // golden angle, radians
  vec3 sum = vec3(0.0);
  float wsum = 0.0;
  for (int i = 0; i < kTaps; i++) {
    float t = (float(i) + 0.5) / float(kTaps);
    float rad = sqrt(t) * radiusPx;       // uniform disc coverage
    float a = float(i) * kGolden;
    float w = exp(-2.0 * t);              // Gaussian falloff (t == (r/R)^2)
    vec2 off = vec2(cos(a), sin(a)) * rad * pxToUv;
    sum += texture(uBackdrop, uv + off).rgb * w;
    wsum += w;
  }
  return sum / wsum;
}

void main() {
  vec2 fragPx = FlutterFragCoord().xy;
  vec2 uv = fragPx / uSize;
#ifdef IMPELLER_TARGET_OPENGLES
  uv.y = 1.0 - uv.y;
#endif

  float sd = sceneSDF(fragPx);

  // Outside the glass: pass the backdrop through (ClipRRect removes it anyway).
  if (sd > 0.0) {
    fragColor = texture(uBackdrop, uv);
    return;
  }

  float thicknessPx = uThickness * uSize.x; // fraction → pixels
  vec2 pxToUv = vec2(1.0) / uSize;

  // Bubble lensing — radial and uniform. The whole displacement is driven by
  // the SDF gradient (the outward rim normal), so every edge AND corner bends
  // the same way, like Apple's material. Both axes share one sign on purpose:
  // giving X and Y opposite signs shears the field diagonally (one corner grows
  // while the opposite shrinks).
  vec2 grad = sceneGrad(fragPx);
  vec3 n = glassNormal(sd, grad, thicknessPx);

  // Gather the SURROUNDING content into the rim — the defining Liquid-Glass
  // move. Snell's law: the horizontal drift of the view ray as it crosses the
  // glass is tan(angle) * thickness, and tan(angle) DIVERGES as the bevel
  // steepens toward the edge. That divergence (1 / n.z, where the surface tips
  // from facing the viewer to nearly horizontal at the rim) is what pulls a wide
  // band of the content from OUTSIDE the bar inward and compresses it at the
  // edge — not just the pixels directly under it.
  //
  // The displacement runs outward along the rim normal (grad), so it stays
  // radially symmetric (a per-axis sign shears it into one-corner-grows). n.z is
  // clamped so the rim reach stays finite.
  const float kReach = 1.0;     // overall gather strength
  const float kRimClamp = 0.13; // caps the rim divergence (1 / 0.13 ≈ 7.7x)
  const float kBand = 1.6;      // how far inward the refracting rim band reaches
  float edge = clamp(1.0 + sd / (max(thicknessPx, 1.0) * kBand), 0.0, 1.0); // 0 centre → 1 rim
  float reach = thicknessPx * kReach / max(n.z, kRimClamp);
  // Radial, continuous, INWARD. The displacement runs along the rim normal but
  // points inward (-grad), so the rim compresses and bends the content from
  // BEHIND/inside the edge instead of reaching outward. -grad rotates smoothly
  // around the rounded corners → one unbroken ring, symmetric, no break at the
  // corners — and no dark margin dragged in at the sides (a full-width bar has
  // nothing colourful beside it to pull outward, so we look inward instead).
  vec2 gather = -grad * edge * reach * pxToUv;

  float blurPx = uBlur * uSize.x; // fraction → pixels
  vec3 col;
  if (uChromatic > 0.0) {
    // Chromatic dispersion: channels gather from slightly different distances.
    col = vec3(
      frostedSample(uv + gather * (1.0 + uChromatic), pxToUv, blurPx).r,
      frostedSample(uv + gather, pxToUv, blurPx).g,
      frostedSample(uv + gather * (1.0 - uChromatic), pxToUv, blurPx).b
    );
  } else {
    col = frostedSample(uv + gather, pxToUv, blurPx);
  }

  // Tint + vibrancy (adaptive), ambient lift.
  col = applyGlassColor(col, uGlassColor, uSaturation);
  col += uAmbient * 0.05;

  // Directional edge light: a bright, crisp highlight on the rim facing the
  // light; a subtle shade on the opposite rim (rounded-edge 3D cue); a faint
  // all-around inner sheen. This is the signature Apple "rim of light".
  //
  // The vertical component is negated because this fragment/SDF space runs
  // y-down, so a light "from above" must point toward smaller y. (The capsule
  // is vertically symmetric, so the shape looks right either way — but without
  // this, the highlight lands on the bottom edge instead of the top.)
  vec2 L = vec2(cos(uLightAngle), -sin(uLightAngle));
  float facing = dot(normalize(n.xy + vec2(1e-5)), L); // -1..1
  float rim = glassFresnel(n);                         // 0 centre → 1 edge
  col += rim * smoothstep(0.0, 1.0, facing) * uLightIntensity * 0.9;
  col -= rim * smoothstep(0.0, 1.0, -facing) * 0.10;
  col += rim * uOutline * 0.12;

  fragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
