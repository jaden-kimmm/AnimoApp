#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// Handwriting reveal for the Tired word. `map` stores, for every spot on the word, when the pen reaches it
// (baked from the traced strokes, see PenStrokes.Tired). Its bottom rows are a 0...1 calibration ramp: the
// threshold is read from the ramp at `progress`, so any color conversion of the texture affects both sides
// of the comparison equally.
//
// position: this pixel in the view, in points. origin: where the word's baseline starts, in points.
// field: the map's design-unit rectangle (minX, maxY, width, height). rows: (field rows, total rows).
[[ stitchable ]] half4 penReveal(float2 position, half4 color, texture2d<half> map,
                                 float2 origin, float4 field, float2 rows, float progress) {
    constexpr sampler s(address::clamp_to_edge, filter::linear);
    float2 design = float2(position.x - origin.x, origin.y - position.y);
    float2 uv = float2((design.x - field.x) / field.z,
                       ((field.y - design.y) / field.w) * (rows.x / rows.y));
    half when = map.sample(s, uv).r;
    float rampV = (rows.x + (rows.y - rows.x) * 0.5) / rows.y;
    half threshold = map.sample(s, float2(clamp(progress, 0.0, 1.0), rampV)).r;
    // A soft front so the pen tip is antialiased instead of a hard cut.
    half visible = clamp((threshold - when) / half(0.012) + half(0.5), half(0.0), half(1.0));
    return color * visible;
}
