// Optical helpers for the Liquid Glass material: bevel normals, Snell-law edge
// displacement, Fresnel rim and tint/saturation. Renderer-agnostic recipe from
// the research dossier (refraction is concentrated at the rounded bevel; the
// body stays near-flat).

#ifndef LGBB_GLASS_GLSL
#define LGBB_GLASS_GLSL

const vec3 kLuma = vec3(0.2126, 0.7152, 0.0722);

// 3D surface normal of the bevel at signed distance `sd` (negative inside).
// `grad` is the normalized 2D gradient of the scene SDF (points outward).
// `thickness` is the bevel depth in the same units as `sd`.
//
// Deep inside (sd <= -thickness) the surface is flat → (0,0,1). Approaching the
// edge (sd → 0) it tips over toward horizontal, so refraction peaks at the rim.
vec3 glassNormal(float sd, vec2 grad, float thickness) {
  float t = clamp(-sd / max(thickness, 1e-3), 0.0, 1.0); // 1 inside → 0 at edge
  float z = smoothstep(0.0, 1.0, t);
  float horiz = sqrt(max(0.0, 1.0 - z * z));
  return normalize(vec3(grad * horiz, max(z, 1e-3)));
}

// UV displacement (in normalized texture space) produced by refraction through
// the bevel. `ior` is the index of refraction; `pxToUv` converts pixels→uv;
// `strength` scales the effect (the bevel depth in pixels).
vec2 refractOffset(vec3 n, float ior, float strength, vec2 pxToUv) {
  vec3 incident = vec3(0.0, 0.0, -1.0);
  vec3 r = refract(incident, n, 1.0 / max(ior, 1.0));
  return r.xy * strength * pxToUv;
}

// Fresnel-like rim term: 0 on the flat body, →1 at the grazing edge.
float glassFresnel(vec3 n) {
  return pow(1.0 - clamp(n.z, 0.0, 1.0), 3.0);
}

// Specular rim highlight facing the virtual light at `lightAngle`.
float glassSpecular(vec3 n, float lightAngle, float intensity) {
  vec2 l = vec2(cos(lightAngle), sin(lightAngle));
  float facing = clamp(dot(normalize(n.xy + vec2(1e-5)), l), 0.0, 1.0);
  return glassFresnel(n) * facing * intensity;
}

// Tints and saturates the (already displaced) backdrop sample. `glass.a` is the
// tint strength; `saturation` boosts vibrancy (1.0 == unchanged).
//
// Adaptive (Apple "Regular" behavior): over a dark backdrop the tint leans
// toward `glass.rgb` (light by default) and lightens the bar; over a bright
// backdrop it leans toward black and darkens it — so the control stays legible
// against either, instead of washing out.
vec3 applyGlassColor(vec3 base, vec4 glass, float saturation) {
  float lum = dot(base, kLuma);
  vec3 saturated = mix(vec3(lum), base, saturation);
  float bg = dot(saturated, kLuma);
  vec3 tint = mix(glass.rgb, vec3(0.0), smoothstep(0.5, 0.9, bg));
  return mix(saturated, tint, glass.a);
}

#endif
