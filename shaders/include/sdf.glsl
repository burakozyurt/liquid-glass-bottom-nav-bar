// 2D signed distance functions (after Inigo Quilez) and smooth-min blending,
// shared by the Liquid Glass fragment shader.
//
// Conventions: distances are negative inside the shape, positive outside, zero
// on the boundary. Points are expressed relative to each shape's centre.

#ifndef LGBB_SDF_GLSL
#define LGBB_SDF_GLSL

// Rounded box. `b` are the half-extents (before the corner radius is carved
// out) and `r` is the corner radius. A capsule is a rounded box whose radius
// equals its smaller half-extent.
float sdRoundedBox(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + vec2(r);
  return min(max(q.x, q.y), 0.0) + length(max(q, vec2(0.0))) - r;
}

// Polynomial smooth minimum. `k` is the blend radius (the metaball threshold):
// shapes closer than `k` fuse into one. Falls back to a hard min when k <= 0.
float sminPoly(float a, float b, float k) {
  if (k <= 0.0) {
    return min(a, b);
  }
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

#endif
