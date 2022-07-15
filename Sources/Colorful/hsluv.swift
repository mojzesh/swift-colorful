// Source: https://github.com/hsluv/hsluv-go
// Under MIT License
// Modified so that Saturation and Luminance are in [0..1] instead of [0..100].

// HSLuv uses a rounded version of the D65. This has no impact on the final RGB
// values, but to keep high levels of accuracy for internal operations and when
// comparing to the test values, this modified white reference is used internally.
//
// See this GitHub thread for details on these values:
//     https://github.com/hsluv/hsluv/issues/79
import Foundation

public var hSLuvD65: WhiteReference = WhiteReference(X: 0.95045592705167, Y: 1.0, Z: 1.089057750759878)

extension Color {
    public static func LuvLChToHSLuv(l: Float64, c: Float64, h: Float64) -> (h: Float64, s: Float64, l: Float64) {
        // [-1..1] but the code expects it to be [-100..100]
        let c: Float64 = c * 100.0
        let l: Float64 = l * 100.0

        var s, max: Float64
        if l > 99.9999999 || l < 0.00000001 {
            s = 0.0
        } else {
            max = Color.maxChromaForLH(l: l, h: h)
            s = c / max * 100.0
        }
        return (h, clamp01(s / 100.0), clamp01(l / 100.0))
    }

    public static func HSLuvToLuvLCh(h: Float64, s: Float64, l: Float64) -> (L: Float64, C: Float64, h: Float64) {
        let l: Float64 = l * 100.0
        let s: Float64 = s * 100.0

        var c, max: Float64
        if l > 99.9999999 || l < 0.00000001 {
            c = 0.0
        } else {
            max = Color.maxChromaForLH(l: l, h: h)
            c = max / 100.0 * s
        }

        // c is [-100..100], but for LCh it's supposed to be almost [-1..1]
        return (clamp01(l / 100.0), c / 100.0, h)
    }

    public static func LuvLChToHPLuv(l: Float64, c: Float64, h: Float64) -> (h: Float64, s: Float64, l: Float64) {
        // [-1..1] but the code expects it to be [-100..100]
        let c: Float64 = c * 100.0
        let l: Float64 = l * 100.0

        var s, max: Float64
        if l > 99.9999999 || l < 0.00000001 {
            s = 0.0
        } else {
            max = Color.maxSafeChromaForL(l)
            s = c / max * 100.0
        }
        return (h, s / 100.0, l / 100.0)
    }

    public static func HPLuvToLuvLCh(h: Float64, s: Float64, l: Float64) -> (l: Float64, c: Float64, h: Float64) {
        // [-1..1] but the code expects it to be [-100..100]
        let l = l * 100.0
        let s = s * 100.0

        var c, max: Float64
        if l > 99.9999999 || l < 0.00000001 {
            c = 0.0
        } else {
            max = Color.maxSafeChromaForL(l)
            c = max / 100.0 * s
        }
        return (l / 100.0, c / 100.0, h)
    }

    // HSLuv returns the Hue, Saturation and Luminance of the color in the HSLuv
    // color space. Hue in [0..360], a Saturation [0..1], and a Luminance
    // (lightness) in [0..1].
    public func HSLuv() -> (h: Float64, s: Float64, l: Float64) {
        // sRGB -> Linear RGB -> CIEXYZ -> CIELUV -> LuvLCh -> HSLuv
        var s: Float64
        var (l, c, h) = LuvLChWhiteRef(wref: hSLuvD65)
        (h, s, l) = Color.LuvLChToHSLuv(l: l, c: c, h: h)
        return (h, s, l)
    }

    // HPLuv returns the Hue, Saturation and Luminance of the color in the HSLuv
    // color space. Hue in [0..360], a Saturation [0..1], and a Luminance
    // (lightness) in [0..1].
    //
    // Note that HPLuv can only represent pastel colors, and so the Saturation
    // value could be much larger than 1 for colors it can't represent.
    public func HPLuv() -> (h: Float64, s: Float64, l: Float64) {
        var s: Float64
        var (l, c, h) = LuvLChWhiteRef(wref: hSLuvD65)
        (h, s, l) = Color.LuvLChToHPLuv(l: l, c: c, h: h)
        return (h, s, l)
    }

    // DistanceHPLuv calculates Euclidean distance in the HPLuv colorspace. No idea
    // how useful this is.

    // The Hue value is divided by 100 before the calculation, so that H, S, and L
    // have the same relative ranges.
    public func DistanceHPLuv(c2: Color) -> Float64 {
        let (h1, s1, l1) = HPLuv()
        let (h2, s2, l2) = c2.HPLuv()
        return (sq((h1 - h2) / 100.0) + sq(s1 - s2) + sq(l1 - l2)).squareRoot()
    }

    // HSLuv creates a new Color from values in the HSLuv color space.
    // Hue in [0..360], a Saturation [0..1], and a Luminance (lightness) in [0..1].
    //
    // The returned color values are clamped (using .Clamped), so this will never output
    // an invalid color.
    public static func HSLuv(h: Float64, s: Float64, l: Float64) -> Color {
        // HSLuv -> LuvLCh -> CIELUV -> CIEXYZ -> Linear RGB -> sRGB
        var u, v: Float64
        var (l, c, h) = Color.HSLuvToLuvLCh(h: h, s: s, l: l)
        (l, u, v) = Color.LuvLChToLuv(l: l, c: c, h: h)
        let (x, y, z) = Color.LuvToXyzWhiteRef(l: l, u: u, v: v, wref: hSLuvD65)
        let (r, g, b) = Color.XyzToLinearRgb(x: x, y: y, z: z)
        return Color.LinearRgb(r: r, g: g, b: b).Clamped()
    }

    // HPLuv creates a new Color from values in the HPLuv color space.
    // Hue in [0..360], a Saturation [0..1], and a Luminance (lightness) in [0..1].
    //
    // The returned color values are clamped (using .Clamped), so this will never output
    // an invalid color.
    public static func HPLuv(h: Float64, s: Float64, l: Float64) -> Color {
        // HPLuv -> LuvLCh -> CIELUV -> CIEXYZ -> Linear RGB -> sRGB
        var u, v: Float64
        var (l, c, h) = Color.HPLuvToLuvLCh(h: h, s: s, l: l)
        (l, u, v) = Color.LuvLChToLuv(l: l, c: c, h: h)
        let (x, y, z) = Color.LuvToXyzWhiteRef(l: l, u: u, v: v, wref: hSLuvD65)
        let (r, g, b) = Color.XyzToLinearRgb(x: x, y: y, z: z)
        return Color.LinearRgb(r: r, g: g, b: b).Clamped()
    }

    static var m: [[Float64]] = [
        [3.2409699419045214, -1.5373831775700935, -0.49861076029300328],
        [-0.96924363628087983, 1.8759675015077207, 0.041555057407175613],
        [0.055630079696993609, -0.20397695888897657, 1.0569715142428786],
    ]

    static let kappa = 903.2962962962963
    static let epsilon = 0.0088564516790356308

    static func maxChromaForLH(l: Float64, h: Float64) -> Float64 {
        let hRad = h / 360.0 * Float64.pi * 2.0
        var minLength = Float64.greatestFiniteMagnitude
        for line in Color.getBounds(l) {
            let length = lengthOfRayUntilIntersect(theta: hRad, x: line[0], y: line[1])
            if length > 0.0, length < minLength {
                minLength = length
            }
        }
        return minLength
    }

    static func getBounds(_ l: Float64) -> [[Float64]] {
        var sub2: Float64
        var ret = [[Float64]](repeating: [Float64](repeating: Float64(), count: 2), count: 6)
        let sub1 = pow(l + 16.0, 3.0) / 1_560_896.0
        if sub1 > epsilon {
            sub2 = sub1
        } else {
            sub2 = l / kappa
        }
        for (i, _) in m.enumerated() {
            for k in 0 ..< 2 {
                let top1: Float64 = (284_517.0 * m[i][0] - 94839.0 * m[i][2]) * sub2
                let top2: Float64 = (838_422.0 * m[i][2] + 769_860.0 * m[i][1] + 731_718.0 * m[i][0]) * l * sub2 - 769_860.0 * Float64(k) * l
                let bottom: Float64 = (632_260.0 * m[i][2] - 126_452.0 * m[i][1]) * sub2 + 126_452.0 * Float64(k)
                ret[i * 2 + k][0] = top1 / bottom
                ret[i * 2 + k][1] = top2 / bottom
            }
        }
        return ret
    }

    static func lengthOfRayUntilIntersect(theta: Float64, x: Float64, y: Float64) -> Float64 {
        return y / (sin(theta) - x * cos(theta))
    }

    static func maxSafeChromaForL(_ l: Float64) -> Float64 {
        var minLength = Float64.greatestFiniteMagnitude
        for line in Color.getBounds(l) {
            let m1 = line[0]
            let b1 = line[1]
            let x = Color.intersectLineLine(x1: m1, y1: b1, x2: -1.0 / m1, y2: 0.0)
            let dist = Color.distanceFromPole(x: x, y: b1 + x * m1)
            if dist < minLength {
                minLength = dist
            }
        }
        return minLength
    }

    static func intersectLineLine(x1: Float64, y1: Float64, x2: Float64, y2: Float64) -> Float64 {
        return (y1 - y2) / (x2 - x1)
    }

    static func distanceFromPole(x: Float64, y: Float64) -> Float64 {
        return (pow(x, 2.0) + pow(y, 2.0)).squareRoot()
    }
}
