import Foundation

public struct WhiteReference {
    var wref: [Float64] = [0, 0, 0]
    init(X: Float64, Y: Float64, Z: Float64) {
        self.wref = [X, Y, Z]
    }
}

func sq(_ v: Float64) -> Float64 {
    return v * v
}

func cub(_ v: Float64) -> Float64 {
    return v * v * v
}

// clamp01 clamps from 0 to 1.
func clamp01(_ v: Float64) -> Float64 {
    return max(0.0, min(v, 1.0))
}

// This is the tolerance used when comparing colors using AlmostEqualRgb.
let Delta: Float64 = 1.0 / 255.0

// This is the default reference white point.
public var D65: WhiteReference = WhiteReference(X: 0.95047, Y: 1.00000, Z: 1.08883)

// And another one.
public var D50: WhiteReference = WhiteReference(X: 0.96422, Y: 1.00000, Z: 0.82521)

public struct Color: CustomStringConvertible, Equatable, Comparable {
    var R: Float64
    var G: Float64
    var B: Float64

    public init(R: Float64 = 0.0, G: Float64 = 0.0, B: Float64 = 0.0) {
        self.R = R
        self.G = G
        self.B = B
    }

    public func RGBA() -> (UInt32, UInt32, UInt32, UInt32) {
        let r = UInt32(self.R * 65535.0 + 0.5)
        let g = UInt32(self.G * 65535.0 + 0.5)
        let b = UInt32(self.B * 65535.0 + 0.5)
        let a: UInt32 = 0xFFFF
        return (r, g, b, a)
    }

    // Might come in handy sometimes to reduce boilerplate code.
    public func RGB255() -> (r: UInt8, g: UInt8, b: UInt8) {
        let r = UInt8((self.R * 255.0) + 0.5)
        let g = UInt8((self.G * 255.0) + 0.5)
        let b = UInt8((self.B * 255.0) + 0.5)
        return (r, g, b)
    }

    // Used to simplify HSLuv testing.
    public func Values() -> (R: Float64, G: Float64, B: Float64) {
        return (self.R, self.G, self.B)
    }

    // Checks whether the color exists in RGB space, i.e. all values are in [0..1]
    func IsValid() -> Bool {
        return self.R >= 0.0 && self.R <= 1.0 &&
               self.G >= 0.0 && self.G <= 1.0 &&
               self.B >= 0.0 && self.B <= 1.0
    }

    // Returns Clamps the color into valid range, clamping each value to [0..1]
    // If the color is valid already, this is a no-op.
    public func Clamped() -> Color {
        return Color(R: clamp01(self.R), G: clamp01(self.G), B: clamp01(self.B))
    }

    // DistanceRgb computes the distance between two colors in RGB space.
    // This is not a good measure! Rather do it in Lab space.
    public func DistanceRgb(_ c2: Color) -> Float64 {
        return (sq(self.R - c2.R) + sq(self.G - c2.G) + sq(self.B - c2.B)).squareRoot()
    }

    // DistanceLinearRgb computes the distance between two colors in linear RGB
    // space. This is not useful for measuring how humans perceive color, but
    // might be useful for other things, like dithering.
    public func DistanceLinearRgb(_ c2: Color) -> Float64 {
        let (r1, g1, b1) = self.LinearRgb()
        let (r2, g2, b2) = c2.LinearRgb()
        return (sq(r1 - r2) + sq(g1 - g2) + sq(b1 - b2)).squareRoot()
    }

    // DistanceLinearRGB is deprecated in favour of DistanceLinearRgb.
    // They do the exact same thing.
    public func DistanceLinearRGB(_ c2: Color) -> Float64 {
        return DistanceLinearRgb(c2)
    }

    // DistanceRiemersma is a color distance algorithm developed by Thiadmer Riemersma.
    // It uses RGB coordinates, but he claims it has similar results to CIELUV.
    // This makes it both fast and accurate.
    //
    // Sources:
    //
    //     https://www.compuphase.com/cmetric.htm
    //     https://github.com/lucasb-eyer/go-colorful/issues/52
    public func DistanceRiemersma(c2: Color) -> Float64 {
        let rAvg: Float64 = (self.R + c2.R) / 2.0
        // Deltas
        let dR: Float64 = self.R - c2.R
        let dG: Float64 = self.G - c2.G
        let dB: Float64 = self.B - c2.B

        return ((2 + rAvg) * dR * dR + 4 * dG * dG + (2 + (1 - rAvg)) * dB * dB).squareRoot()
    }

    // Check for equality between colors within the tolerance Delta (1/255).
    public func AlmostEqualRgb(_ c2: Color) -> Bool {
        return abs(self.R - c2.R) +
               abs(self.G - c2.G) +
               abs(self.B - c2.B) < (3.0 * Delta)
    }

    // You don't really want to use this, do you? Go for BlendLab, BlendLuv or BlendHcl.
    public func BlendRgb(c2: Color, t: Float64) -> Color {
        return Color(R: self.R + t * (c2.R - self.R),
                     G: self.G + t * (c2.G - self.G),
                     B: self.B + t * (c2.B - self.B))
    }

    // Utility used by Hxx color-spaces for interpolating between two angles in [0,360].
    static func interp_angle(a0: Float64, a1: Float64, t: Float64) -> Float64 {
        // Based on the answer here: http://stackoverflow.com/a/14498790/2366315
        // With potential proof that it works here: http://math.stackexchange.com/a/2144499
        let delta = ((a1 - a0).truncatingRemainder(dividingBy: 360.0) + 540).truncatingRemainder(dividingBy: 360.0) - 180.0
        return (a0 + t * delta + 360.0).truncatingRemainder(dividingBy: 360.0)
    }

    /// HSV ///
    ///////////
    // From http://en.wikipedia.org/wiki/HSL_and_HSV
    // Note that h is in [0..360] and s,v in [0..1]

    // Hsv returns the Hue [0..360], Saturation and Value [0..1] of the color.
    public func Hsv() -> (h: Float64, s: Float64, v: Float64) {
        let min = min(min(self.R, self.G), self.B)
        let v = max(max(self.R, self.G), self.B)
        let C = v - min

        var s = 0.0
        if v != 0.0 {
            s = C / v
        }

        var h = 0.0 // We use 0 instead of undefined as in wp.
        if min != v {
            if v == self.R {
                h = ((self.G - self.B) / C).truncatingRemainder(dividingBy: 6.0)
            }
            if v == self.G {
                h = (self.B - self.R) / C + 2.0
            }
            if v == self.B {
                h = (self.R - self.G) / C + 4.0
            }
            h *= 60.0
            if h < 0.0 {
                h += 360.0
            }
        }
        return (h, s, v)
    }

    // Hsv creates a new Color given a Hue in [0..360], a Saturation and a Value in [0..1]
    public static func Hsv(H: Float64, S: Float64, V: Float64) -> Color {
        let Hp = H / 60.0
        let C = V * S
        let X = C * (1.0 - abs(Hp.truncatingRemainder(dividingBy: 2.0) - 1.0))

        let m = V - C
        var (r, g, b) = (0.0, 0.0, 0.0)

        if Hp >= 0.0, Hp < 1.0 {
            r = C
            g = X
        } else if Hp >= 1.0, Hp < 2.0 {
            r = X
            g = C
        } else if Hp >= 2.0, Hp < 3.0 {
            g = C
            b = X
        } else if Hp >= 3.0, Hp < 4.0 {
            g = X
            b = C
        } else if Hp >= 4.0, Hp < 5.0 {
            r = X
            b = C
        } else if Hp >= 5.0, Hp < 6.0 {
            r = C
            b = X
        }

        return Color(R: m + r, G: m + g, B: m + b)
    }

    // You don't really want to use this, do you? Go for BlendLab, BlendLuv or BlendHcl.
    public func BlendHsv(c2: Color, t: Float64) -> Color {
        var (h1, s1, v1) = self.Hsv()
        var (h2, s2, v2) = c2.Hsv()

        // https://github.com/lucasb-eyer/go-colorful/pull/60
        if s1 == 0, s2 != 0 {
            h1 = h2
        } else if s2 == 0, s1 != 0 {
            h2 = h1
        }

        // We know that h are both in [0..360]
        return Color.Hsv(H: Color.interp_angle(a0: h1, a1: h2, t: t), S: s1 + t * (s2 - s1), V: v1 + t * (v2 - v1))
    }

    /// HSL ///
    ///////////

    // Hsl returns the Hue [0..360], Saturation [0..1], and Luminance (lightness) [0..1] of the color.
    public func Hsl() -> (h: Float64, s: Float64, l: Float64) {
        let min: Float64 = min(min(self.R, self.G), self.B)
        let max: Float64 = max(max(self.R, self.G), self.B)

        let l: Float64 = (max + min) / 2

        let s: Float64
        var h: Float64

        if min == max {
            s = 0
            h = 0
        } else {
            if l < 0.5 {
                s = (max - min) / (max + min)
            } else {
                s = (max - min) / (2.0 - max - min)
            }

            if max == self.R {
                h = (self.G - self.B) / (max - min)
            } else if max == self.G {
                h = 2.0 + (self.B - self.R) / (max - min)
            } else {
                h = 4.0 + (self.R - self.G) / (max - min)
            }

            h *= 60

            if h < 0 {
                h += 360
            }
        }

        return (h, s, l)
    }

    // Hsl creates a new Color given a Hue in [0..360], a Saturation [0..1], and a Luminance (lightness) in [0..1]
    public static func Hsl(h: Float64, s: Float64, l: Float64) -> Color {
        if s == 0 {
            return Color(R: l, G: l, B: l)
        }

        var r, g, b: Float64
        var t1: Float64
        var t2: Float64
        var tr: Float64
        var tg: Float64
        var tb: Float64

        if l < 0.5 {
            t1 = l * (1.0 + s)
        } else {
            t1 = l + s - l * s
        }

        t2 = 2 * l - t1
        let h = h / 360
        tr = h + 1.0 / 3.0
        tg = h
        tb = h - 1.0 / 3.0

        if tr < 0 {
            tr += 1
        }
        if tr > 1 {
            tr -= 1
        }
        if tg < 0 {
            tg += 1
        }
        if tg > 1 {
            tg -= 1
        }
        if tb < 0 {
            tb += 1
        }
        if tb > 1 {
            tb -= 1
        }

        // Red
        if 6 * tr < 1 {
            r = t2 + (t1 - t2) * 6 * tr
        } else if 2 * tr < 1 {
            r = t1
        } else if 3 * tr < 2 {
            r = t2 + (t1 - t2) * (2.0 / 3.0 - tr) * 6
        } else {
            r = t2
        }

        // Green
        if 6 * tg < 1 {
            g = t2 + (t1 - t2) * 6 * tg
        } else if 2 * tg < 1 {
            g = t1
        } else if 3 * tg < 2 {
            g = t2 + (t1 - t2) * (2.0 / 3.0 - tg) * 6
        } else {
            g = t2
        }

        // Blue
        if 6 * tb < 1 {
            b = t2 + (t1 - t2) * 6 * tb
        } else if 2 * tb < 1 {
            b = t1
        } else if 3 * tb < 2 {
            b = t2 + (t1 - t2) * (2.0 / 3.0 - tb) * 6
        } else {
            b = t2
        }

        return Color(R: r, G: g, B: b)
    }

    /// Hex ///
    ///////////

    // Hex returns the hex "html" representation of the color, as in #ff0080.
    public func Hex() -> String {
        // Add 0.5 for rounding
        return String(format: "#%02x%02x%02x", UInt8(self.R * 255.0 + 0.5), UInt8(self.G * 255.0 + 0.5), UInt8(self.B * 255.0 + 0.5))
    }

    // An example error we can throw
    public enum HexColorError: Error {
        case isNotHexColor
        case incorrectFormat
        case unknownError
    }

    // Hex parses a "html" hex color-string, either in the 3 "#f0c" or 6 "#ff1034" digits form.
    public static func Hex(_ scol: String) throws -> Color {
        let r, g, b: Float64

        if scol.hasPrefix("#") {
            let start = scol.index(scol.startIndex, offsetBy: 1)
            let hexColor = String(scol[start...])
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if hexColor.count == 6 {
                if scanner.scanHexInt64(&hexNumber) {
                    r = Float64((hexNumber & 0xFF0000) >> 16) / 255
                    g = Float64((hexNumber & 0x00FF00) >> 8) / 255
                    b = Float64((hexNumber & 0x0000FF) >> 0) / 255
                    return Color(R: r, G: g, B: b)
                }
            } else if hexColor.count == 3 {
                if scanner.scanHexInt64(&hexNumber) {
                    r = Float64((hexNumber & 0x000F00) >> 8) / 15
                    g = Float64((hexNumber & 0x0000F0) >> 4) / 15
                    b = Float64((hexNumber & 0x00000F) >> 0) / 15
                    return Color(R: r, G: g, B: b)
                }
            } else {
                throw HexColorError.incorrectFormat
            }
        } else {
            throw HexColorError.isNotHexColor
        }

        throw HexColorError.unknownError
    }

    /// Linear ///
    //////////////
    // http://www.sjbrown.co.uk/2004/05/14/gamma-correct-rendering/
    // http://www.brucelindbloom.com/Eqn_RGB_to_XYZ.html

    public static func linearize(_ v: Float64) -> Float64 {
        if v <= 0.04045 {
            return v / 12.92
        }
        return pow((v + 0.055) / 1.055, 2.4)
    }

    // LinearRgb converts the color into the linear RGB space (see http://www.sjbrown.co.uk/2004/05/14/gamma-correct-rendering/).
    public func LinearRgb() -> (r: Float64, g: Float64, b: Float64) {
        let r = Color.linearize(self.R)
        let g = Color.linearize(self.G)
        let b = Color.linearize(self.B)
        return (r, g, b)
    }

    // A much faster and still quite precise linearization using a 6th-order Taylor approximation.
    // See the accompanying Jupyter notebook for derivation of the constants.
    public static func linearize_fast(_ v: Float64) -> Float64 {
        let v1 = v - 0.5
        let v2 = v1 * v1
        let v3 = v2 * v1
        let v4 = v2 * v2
        // v5 := v3*v2
        return -0.248750514614486 + 0.925583310193438 * v + 1.16740237321695 * v2 + 0.280457026598666 * v3 - 0.0757991963780179 * v4 // + 0.0437040411548932*v5
    }

    // FastLinearRgb is much faster than and almost as accurate as LinearRgb.
    // BUT it is important to NOTE that they only produce good results for valid colors r,g,b in [0,1].
    public func FastLinearRgb() -> (r: Float64, g: Float64, b: Float64) {
        let r = Color.linearize_fast(self.R)
        let g = Color.linearize_fast(self.G)
        let b = Color.linearize_fast(self.B)
        return (r, g, b)
    }

    public static func delinearize(_ v: Float64) -> Float64 {
        if v <= 0.0031308 {
            return 12.92 * v
        }
        return 1.055 * pow(v, 1.0 / 2.4) - 0.055
    }

    // LinearRgb creates an sRGB color out of the given linear RGB color (see http://www.sjbrown.co.uk/2004/05/14/gamma-correct-rendering/).
    public static func LinearRgb(r: Float64, g: Float64, b: Float64) -> Color {
        return Color(R: Color.delinearize(r), G: Color.delinearize(g), B: Color.delinearize(b))
    }

    public static func delinearize_fast(_ v: Float64) -> Float64 {
        var v1, v2, v3, v4, v5: Float64
        // This function (fractional root) is much harder to linearize, so we need to split.
        if v > 0.2 {
            v1 = v - 0.6
            v2 = v1 * v1
            v3 = v2 * v1
            v4 = v2 * v2
            v5 = v3 * v2
            return 0.442430344268235 + 0.592178981271708 * v - 0.287864782562636 * v2 + 0.253214392068985 * v3 - 0.272557158129811 * v4 + 0.325554383321718 * v5
        } else if v > 0.03 {
            v1 = v - 0.115
            v2 = v1 * v1
            v3 = v2 * v1
            v4 = v2 * v2
            v5 = v3 * v2
            return 0.194915592891669 + 1.55227076330229 * v - 3.93691860257828 * v2 + 18.0679839248761 * v3 - 101.468750302746 * v4 + 632.341487393927 * v5
        } else {
            v1 = v - 0.015
            v2 = v1 * v1
            v3 = v2 * v1
            v4 = v2 * v2
            v5 = v3 * v2
            // You can clearly see from the involved constants that the low-end is highly nonlinear.
            return 0.0519565234928877 + 5.09316778537561 * v - 99.0338180489702 * v2 + 3484.52322764895 * v3 - 150_028.083412663 * v4 + 7_168_008.42971613 * v5
        }
    }

    // FastLinearRgb is much faster than and almost as accurate as LinearRgb.
    // BUT it is important to NOTE that they only produce good results for valid inputs r,g,b in [0,1].
    public static func FastLinearRgb(r: Float64, g: Float64, b: Float64) -> Color {
        return Color(R: Color.delinearize_fast(r), G: Color.delinearize_fast(g), B: Color.delinearize_fast(b))
    }

    // XyzToLinearRgb converts from CIE XYZ-space to Linear RGB space.
    public static func XyzToLinearRgb(x: Float64, y: Float64, z: Float64) -> (r: Float64, g: Float64, b: Float64) {
        let r = 3.2409699419045214 * x - 1.5373831775700935 * y - 0.49861076029300328 * z
        let g = -0.96924363628087983 * x + 1.8759675015077207 * y + 0.041555057407175613 * z
        let b = 0.055630079696993609 * x - 0.20397695888897657 * y + 1.0569715142428786 * z
        return (r, g, b)
    }

    public static func LinearRgbToXyz(r: Float64, g: Float64, b: Float64) -> (x: Float64, y: Float64, z: Float64) {
        let x = 0.41239079926595948 * r + 0.35758433938387796 * g + 0.18048078840183429 * b
        let y = 0.21263900587151036 * r + 0.71516867876775593 * g + 0.072192315360733715 * b
        let z = 0.019330818715591851 * r + 0.11919477979462599 * g + 0.95053215224966058 * b
        return (x, y, z)
    }

    // BlendLinearRgb blends two colors in the Linear RGB color-space.
    // Unlike BlendRgb, this will not produce dark color around the center.
    // t == 0 results in c1, t == 1 results in c2
    public func BlendLinearRgb(c2: Color, t: Float64) -> Color {
        let (r1, g1, b1) = self.LinearRgb()
        let (r2, g2, b2) = c2.LinearRgb()
        return Color.LinearRgb(
            r: r1 + t * (r2 - r1),
            g: g1 + t * (g2 - g1),
            b: b1 + t * (b2 - b1)
        )
    }

    /// XYZ ///
    ///////////
    // http://www.sjbrown.co.uk/2004/05/14/gamma-correct-rendering/

    public func Xyz() -> (x: Float64, y: Float64, z: Float64) {
        let (r, g, b) = self.LinearRgb()
        return Color.LinearRgbToXyz(r: r, g: g, b: b)
    }

    public static func Xyz(x: Float64, y: Float64, z: Float64) -> Color {
        let (r, g, b) = Color.XyzToLinearRgb(x: x, y: y, z: z)
        return Color.LinearRgb(r: r, g: g, b: b)
    }

    /// xyY ///
    ///////////
    // http://www.brucelindbloom.com/Eqn_XYZ_to_xyY.html

    // Well, the name is bad, since it's xyY but Golang needs me to start with a
    // capital letter to make the method public.
    public static func XyzToXyy(X: Float64, Y: Float64, Z: Float64) -> (x: Float64, y: Float64, Yout: Float64) {
        return Color.XyzToXyyWhiteRef(X: X, Y: Y, Z: Z, wref: D65)
    }

    public static func XyzToXyyWhiteRef(X: Float64, Y: Float64, Z: Float64, wref: WhiteReference) -> (x: Float64, y: Float64, Yout: Float64) {
        var x, y: Float64
        let Yout = Y
        let N = X + Y + Z
        if abs(N) < 1e-14 {
            // When we have black, Bruce Lindbloom recommends to use
            // the reference white's chromacity for x and y.
            x = wref.wref[0] / (wref.wref[0] + wref.wref[1] + wref.wref[2])
            y = wref.wref[1] / (wref.wref[0] + wref.wref[1] + wref.wref[2])
        } else {
            x = X / N
            y = Y / N
        }
        return (x, y, Yout)
    }

    public static func XyyToXyz(x: Float64, y: Float64, Y: Float64) -> (X: Float64, Yout: Float64, Z: Float64) {
        let X, Z: Float64
        let Yout = Y

        if y > -1e-14 && y < 1e-14 {
            X = 0.0
            Z = 0.0
        } else {
            X = Y / y * x
            Z = Y / y * (1.0 - x - y)
        }

        return (X, Yout, Z)
    }

    // Converts the given color to CIE xyY space using D65 as reference white.
    // (Note that the reference white is only used for black input.)
    // x, y and Y are in [0..1]
    public func Xyy() -> (x: Float64, y: Float64, Y: Float64) {
        let (x, y, z) = self.Xyz()
        let (X, Y, Yout) = Color.XyzToXyy(X: x, Y: y, Z: z)
        return (X, Y, Yout)
    }

    // Converts the given color to CIE xyY space, taking into account
    // a given reference white. (i.e. the monitor's white)
    // (Note that the reference white is only used for black input.)
    // x, y and Y are in [0..1]
    public func XyyWhiteRef(wref: WhiteReference) -> (x: Float64, y: Float64, Y: Float64) {
        let (X, Y2, Z) = self.Xyz()
        let (x, y, Yout) = Color.XyzToXyyWhiteRef(X: X, Y: Y2, Z: Z, wref: wref)
        return (x, y, Yout)
    }

    // Generates a color by using data given in CIE xyY space.
    // x, y and Y are in [0..1]
    public static func Xyy(x: Float64, y: Float64, Y: Float64) -> Color {
        let (X, Yout, Z) = Color.XyyToXyz(x: x, y: y, Y: Y)
        return Color.Xyz(x: X, y: Yout, z: Z)
    }

    /// L*a*b* ///
    //////////////
    // http://en.wikipedia.org/wiki/Lab_color_space#CIELAB-CIEXYZ_conversions
    // For L*a*b*, we need to L*a*b*<->XYZ->RGB and the first one is device dependent.

    public static func lab_f(_ t: Float64) -> Float64 {
        if t > 6.0 / 29.0 * 6.0 / 29.0 * 6.0 / 29.0 {
            return cbrt(t)
        }
        return t / 3.0 * 29.0 / 6.0 * 29.0 / 6.0 + 4.0 / 29.0
    }

    public static func XyzToLab(x: Float64, y: Float64, z: Float64) -> (l: Float64, a: Float64, b: Float64) {
        // Use D65 white as reference point by default.
        // http://www.fredmiranda.com/forum/topic/1035332
        // http://en.wikipedia.org/wiki/Standard_illuminant
        return Color.XyzToLabWhiteRef(x: x, y: y, z: z, wref: D65)
    }

    public static func XyzToLabWhiteRef(x: Float64, y: Float64, z: Float64, wref: WhiteReference) -> (l: Float64, a: Float64, b: Float64) {
        let fy = Color.lab_f(y / wref.wref[1])
        let l = 1.16 * fy - 0.16
        let a = 5.0 * (Color.lab_f(x / wref.wref[0]) - fy)
        let b = 2.0 * (fy - Color.lab_f(z / wref.wref[2]))
        return (l, a, b)
    }

    public static func lab_finv(_ t: Float64) -> Float64 {
        if t > 6.0 / 29.0 {
            return t * t * t
        }
        return 3.0 * 6.0 / 29.0 * 6.0 / 29.0 * (t - 4.0 / 29.0)
    }

    public static func LabToXyz(l: Float64, a: Float64, b: Float64) -> (x: Float64, y: Float64, z: Float64) {
        // D65 white (see above).
        return Color.LabToXyzWhiteRef(l: l, a: a, b: b, wref: D65)
    }

    public static func LabToXyzWhiteRef(l: Float64, a: Float64, b: Float64, wref: WhiteReference) -> (x: Float64, y: Float64, z: Float64) {
        let l2 = (l + 0.16) / 1.16
        let x = wref.wref[0] * Color.lab_finv(l2 + a / 5.0)
        let y = wref.wref[1] * Color.lab_finv(l2)
        let z = wref.wref[2] * Color.lab_finv(l2 - b / 2.0)
        return (x, y, z)
    }

    // Converts the given color to CIE L*a*b* space using D65 as reference white.
    public func Lab() -> (l: Float64, a: Float64, b: Float64) {
        let (x, y, z) = self.Xyz()
        return Color.XyzToLab(x: x, y: y, z: z)
    }

    // Converts the given color to CIE L*a*b* space, taking into account
    // a given reference white. (i.e. the monitor's white)
    public func LabWhiteRef(wref: WhiteReference) -> (l: Float64, a: Float64, b: Float64) {
        let (x, y, z) = self.Xyz()
        return Color.XyzToLabWhiteRef(x: x, y: y, z: z, wref: wref)
    }

    // Generates a color by using data given in CIE L*a*b* space using D65 as reference white.
    // WARNING: many combinations of `l`, `a`, and `b` values do not have corresponding
    // valid RGB values, check the FAQ in the README if you're unsure.
    public static func Lab(l: Float64, a: Float64, b: Float64) -> Color {
        let (x, y, z) = Color.LabToXyz(l: l, a: a, b: b)
        return Color.Xyz(x: x, y: y, z: z)
    }

    // Generates a color by using data given in CIE L*a*b* space, taking
    // into account a given reference white. (i.e. the monitor's white)
    public static func LabWhiteRef(l: Float64, a: Float64, b: Float64, wref: WhiteReference) -> Color {
        let (x, y, z) = Color.LabToXyzWhiteRef(l: l, a: a, b: b, wref: wref)
        return Color.Xyz(x: x, y: y, z: z)
    }

    // DistanceLab is a good measure of visual similarity between two colors!
    // A result of 0 would mean identical colors, while a result of 1 or higher
    // means the colors differ a lot.
    public func DistanceLab(_ c2: Color) -> Float64 {
        let (l1, a1, b1) = Lab()
        let (l2, a2, b2) = c2.Lab()
        return (sq(l1 - l2) + sq(a1 - a2) + sq(b1 - b2)).squareRoot()
    }

    // DistanceCIE76 is the same as DistanceLab.
    public func DistanceCIE76(_ c2: Color) -> Float64 {
        return self.DistanceLab(c2)
    }

    // Uses the CIE94 formula to calculate color distance. More accurate than
    // DistanceLab, but also more work.
    public func DistanceCIE94(_ cr: Color) -> Float64 {
        var (l1, a1, b1) = self.Lab()
        var (l2, a2, b2) = cr.Lab()

        // NOTE: Since all those formulas expect L,a,b values 100x larger than we
        //       have them in this library, we either need to adjust all constants
        //       in the formula, or convert the ranges of L,a,b before, and then
        //       scale the distances down again. The latter is less error-prone.
        (l1, a1, b1) = (l1 * 100.0, a1 * 100.0, b1 * 100.0)
        (l2, a2, b2) = (l2 * 100.0, a2 * 100.0, b2 * 100.0)

        let kl = 1.0 // 2.0 for textiles
        let kc = 1.0
        let kh = 1.0
        let k1 = 0.045 // 0.048 for textiles
        let k2 = 0.015 // 0.014 for textiles.

        let deltaL = l1 - l2
        let c1 = (sq(a1) + sq(b1)).squareRoot()
        let c2 = (sq(a2) + sq(b2)).squareRoot()
        let deltaCab = c1 - c2

        // Not taking Sqrt here for stability, and it's unnecessary.
        let deltaHab2 = sq(a1 - a2) + sq(b1 - b2) - sq(deltaCab)
        let sl = 1.0
        let sc = 1.0 + k1 * c1
        let sh = 1.0 + k2 * c1

        let vL2 = sq(deltaL / (kl * sl))
        let vC2 = sq(deltaCab / (kc * sc))
        let vH2 = deltaHab2 / sq(kh * sh)

        return (vL2 + vC2 + vH2).squareRoot() * 0.01 // See above.
    }

    // DistanceCIEDE2000 uses the Delta E 2000 formula to calculate color
    // distance. It is more expensive but more accurate than both DistanceLab
    // and DistanceCIE94.
    public func DistanceCIEDE2000(_ cr: Color) -> Float64 {
        return self.DistanceCIEDE2000klch(cr: cr, kl: 1.0, kc: 1.0, kh: 1.0)
    }

    // DistanceCIEDE2000klch uses the Delta E 2000 formula with custom values
    // for the weighting factors kL, kC, and kH.
    public func DistanceCIEDE2000klch(cr: Color, kl: Float64, kc: Float64, kh: Float64) -> Float64 {
        var (l1, a1, b1) = self.Lab()
        var (l2, a2, b2) = cr.Lab()

        // As with CIE94, we scale up the ranges of L,a,b beforehand and scale
        // them down again afterwards.
        (l1, a1, b1) = (l1 * 100.0, a1 * 100.0, b1 * 100.0)
        (l2, a2, b2) = (l2 * 100.0, a2 * 100.0, b2 * 100.0)

        let cab1 = (sq(a1) + sq(b1)).squareRoot()
        let cab2 = (sq(a2) + sq(b2)).squareRoot()
        let cabmean = (cab1 + cab2) / 2

        let g = 0.5 * (1 - (pow(cabmean, 7) / (pow(cabmean, 7) + pow(25, 7))).squareRoot())
        let ap1 = (1 + g) * a1
        let ap2 = (1 + g) * a2
        let cp1 = (sq(ap1) + sq(b1)).squareRoot()
        let cp2 = (sq(ap2) + sq(b2)).squareRoot()

        var hp1 = 0.0
        if b1 != ap1 || ap1 != 0 {
            hp1 = atan2(b1, ap1)
            if hp1 < 0 {
                hp1 += Float64.pi * 2
            }
            hp1 *= 180 / Float64.pi
        }
        var hp2 = 0.0
        if b2 != ap2 || ap2 != 0 {
            hp2 = atan2(b2, ap2)
            if hp2 < 0 {
                hp2 += Float64.pi * 2
            }
            hp2 *= 180 / Float64.pi
        }

        let deltaLp = l2 - l1
        let deltaCp = cp2 - cp1
        var dhp = 0.0
        let cpProduct = cp1 * cp2
        if cpProduct != 0 {
            dhp = hp2 - hp1
            if dhp > 180 {
                dhp -= 360
            } else if dhp < -180 {
                dhp += 360
            }
        }
        let deltaHp = 2 * cpProduct.squareRoot() * sin(dhp / 2 * Float64.pi / 180)

        let lpmean = (l1 + l2) / 2
        let cpmean = (cp1 + cp2) / 2
        var hpmean = hp1 + hp2
        if cpProduct != 0 {
            hpmean /= 2
            if abs(hp1 - hp2) > 180 {
                if hp1 + hp2 < 360 {
                    hpmean += 180
                } else {
                    hpmean -= 180
                }
            }
        }

        let t = 1 - 0.17 * cos((hpmean - 30) * Float64.pi / 180) + 0.24 * cos(2 * hpmean * Float64.pi / 180) + 0.32 * cos((3 * hpmean + 6) * Float64.pi / 180) - 0.2 * cos((4 * hpmean - 63) * Float64.pi / 180)
        let deltaTheta = 30 * exp(-sq((hpmean - 275) / 25))
        let rc = 2 * (pow(cpmean, 7) / (pow(cpmean, 7) + pow(25, 7))).squareRoot()
        let sl = 1 + (0.015 * sq(lpmean - 50)) / (20 + sq(lpmean - 50)).squareRoot()
        let sc = 1 + 0.045 * cpmean
        let sh = 1 + 0.015 * cpmean * t
        let rt = -sin(2 * deltaTheta * Float64.pi / 180) * rc

        return (sq(deltaLp / (kl * sl)) + sq(deltaCp / (kc * sc)) + sq(deltaHp / (kh * sh)) + rt * (deltaCp / (kc * sc)) * (deltaHp / (kh * sh))).squareRoot() * 0.01
    }

    // BlendLab blends two colors in the L*a*b* color-space, which should result in a smoother blend.
    // t == 0 results in c1, t == 1 results in c2
    public func BlendLab(c2: Color, t: Float64) -> Color {
        let (l1, a1, b1) = self.Lab()
        let (l2, a2, b2) = c2.Lab()
        return Color.Lab(l: l1 + t * (l2 - l1),
                         a: a1 + t * (a2 - a1),
                         b: b1 + t * (b2 - b1))
    }

    /// L*u*v* ///
    //////////////
    // http://en.wikipedia.org/wiki/CIELUV#XYZ_.E2.86.92_CIELUV_and_CIELUV_.E2.86.92_XYZ_conversions
    // For L*u*v*, we need to L*u*v*<->XYZ<->RGB and the first one is device dependent.

    public static func XyzToLuv(x: Float64, y: Float64, z: Float64) -> (l: Float64, a: Float64, b: Float64) {
        // Use D65 white as reference point by default.
        // http://www.fredmiranda.com/forum/topic/1035332
        // http://en.wikipedia.org/wiki/Standard_illuminant
        let (l, u, v) = Color.XyzToLuvWhiteRef(x: x, y: y, z: z, wref: D65)
        return (l, u, v)
    }

    public static func XyzToLuvWhiteRef(x: Float64, y: Float64, z: Float64, wref: WhiteReference) -> (l: Float64, u: Float64, v: Float64) {
        let l, u, v: Float64
        if y / wref.wref[1] <= 6.0 / 29.0 * 6.0 / 29.0 * 6.0 / 29.0 {
            l = y / wref.wref[1] * (29.0 / 3.0 * 29.0 / 3.0 * 29.0 / 3.0) / 100.0
        } else {
            l = 1.16 * cbrt(y / wref.wref[1]) - 0.16
        }
        let (ubis, vbis) = Color.xyz_to_uv(x: x, y: y, z: z)
        let (un, vn) = Color.xyz_to_uv(x: wref.wref[0], y: wref.wref[1], z: wref.wref[2])
        u = 13.0 * l * (ubis - un)
        v = 13.0 * l * (vbis - vn)
        return (l, u, v)
    }

    // For this part, we do as R's graphics.hcl does, not as wikipedia does.
    // Or is it the same?
    public static func xyz_to_uv(x: Float64, y: Float64, z: Float64) -> (u: Float64, v: Float64) {
        var u, v: Float64
        let denom = x + 15.0 * y + 3.0 * z
        if denom == 0.0 {
            (u, v) = (0.0, 0.0)
        } else {
            u = 4.0 * x / denom
            v = 9.0 * y / denom
        }
        return (u, v)
    }

    public static func LuvToXyz(l: Float64, u: Float64, v: Float64) -> (x: Float64, y: Float64, z: Float64) {
        // D65 white (see above).
        return Color.LuvToXyzWhiteRef(l: l, u: u, v: v, wref: D65)
    }

    public static func LuvToXyzWhiteRef(l: Float64, u: Float64, v: Float64, wref: WhiteReference) -> (x: Float64, y: Float64, z: Float64) {
        var x, y, z: Float64
        z = 0.0

        // y = wref[1] * lab_finv((l + 0.16) / 1.16)
        if l <= 0.08 {
            y = wref.wref[1] * l * 100.0 * 3.0 / 29.0 * 3.0 / 29.0 * 3.0 / 29.0
        } else {
            y = wref.wref[1] * cub((l + 0.16) / 1.16)
        }

        let (un, vn) = Color.xyz_to_uv(x: wref.wref[0], y: wref.wref[1], z: wref.wref[2])
        if l != 0.0 {
            let ubis = u / (13.0 * l) + un
            let vbis = v / (13.0 * l) + vn
            x = y * 9.0 * ubis / (4.0 * vbis)
            z = y * (12.0 - 3.0 * ubis - 20.0 * vbis) / (4.0 * vbis)
        } else {
            (x, y) = (0.0, 0.0)
        }

        return (x, y, z)
    }

    // Converts the given color to CIE L*u*v* space using D65 as reference white.
    // L* is in [0..1] and both u* and v* are in about [-1..1]
    public func Luv() -> (l: Float64, u: Float64, v: Float64) {
        let (x, y, z) = self.Xyz()
        let (l, u, v) = Color.XyzToLuv(x: x, y: y, z: z)
        return (l, u, v)
    }

    // Converts the given color to CIE L*u*v* space, taking into account
    // a given reference white. (i.e. the monitor's white)
    // L* is in [0..1] and both u* and v* are in about [-1..1]
    public func LuvWhiteRef(wref: WhiteReference) -> (l: Float64, u: Float64, v: Float64) {
        let (x, y, z) = self.Xyz()
        let (l, u, v) = Color.XyzToLuvWhiteRef(x: x, y: y, z: z, wref: wref)
        return (l, u, v)
    }

    // Generates a color by using data given in CIE L*u*v* space using D65 as reference white.
    // L* is in [0..1] and both u* and v* are in about [-1..1]
    // WARNING: many combinations of `l`, `u`, and `v` values do not have corresponding
    // valid RGB values, check the FAQ in the README if you're unsure.
    public static func Luv(l: Float64, u: Float64, v: Float64) -> Color {
        let (x, y, z) = Color.LuvToXyz(l: l, u: u, v: v)
        return Color.Xyz(x: x, y: y, z: z)
    }

    // Generates a color by using data given in CIE L*u*v* space, taking
    // into account a given reference white. (i.e. the monitor's white)
    // L* is in [0..1] and both u* and v* are in about [-1..1]
    public static func LuvWhiteRef(l: Float64, u: Float64, v: Float64, wref: WhiteReference) -> Color {
        let (x, y, z) = Color.LuvToXyzWhiteRef(l: l, u: u, v: v, wref: wref)
        return Color.Xyz(x: x, y: y, z: z)
    }

    // DistanceLuv is a good measure of visual similarity between two colors!
    // A result of 0 would mean identical colors, while a result of 1 or higher
    // means the colors differ a lot.
    public func DistanceLuv(_ c2: Color) -> Float64 {
        let (l1, u1, v1) = self.Luv()
        let (l2, u2, v2) = c2.Luv()
        return (sq(l1 - l2) + sq(u1 - u2) + sq(v1 - v2)).squareRoot()
    }

    // BlendLuv blends two colors in the CIE-L*u*v* color-space, which should result in a smoother blend.
    // t == 0 results in c1, t == 1 results in c2
    public func BlendLuv(c2: Color, t: Float64) -> Color {
        let (l1, u1, v1) = self.Luv()
        let (l2, u2, v2) = c2.Luv()
        return Color.Luv(l: l1 + t * (l2 - l1),
                         u: u1 + t * (u2 - u1),
                         v: v1 + t * (v2 - v1))
    }

    /// HCL ///
    ///////////
    // HCL is nothing else than L*a*b* in cylindrical coordinates!
    // (this was wrong on English wikipedia, I fixed it, let's hope the fix stays.)
    // But it is widely popular since it is a "correct HSV"
    // http://www.hunterlab.com/appnotes/an09_96a.pdf

    // Converts the given color to HCL space using D65 as reference white.
    // H values are in [0..360], C and L values are in [0..1] although C can overshoot 1.0
    public func Hcl() -> (h: Float64, c: Float64, l: Float64) {
        return self.HclWhiteRef(wref: D65)
    }

    public static func LabToHcl(L: Float64, a: Float64, b: Float64) -> (h: Float64, c: Float64, l: Float64) {
        let h: Float64
        // Oops, floating point workaround necessary if a ~= b and both are very small (i.e. almost zero).
        if abs(b - a) > 1e-4, abs(a) > 1e-4 {
            h = (57.29577951308232087721 * atan2(b, a) + 360.0).truncatingRemainder(dividingBy: 360.0) // Rad2Deg
        } else {
            h = 0.0
        }
        let c = (sq(a) + sq(b)).squareRoot()
        let l = L
        return (h, c, l)
    }

    // Converts the given color to HCL space, taking into account
    // a given reference white. (i.e. the monitor's white)
    // H values are in [0..360], C and L values are in [0..1]
    public func HclWhiteRef(wref: WhiteReference) -> (h: Float64, c: Float64, l: Float64) {
        let (L, a, b) = self.LabWhiteRef(wref: wref)
        return Color.LabToHcl(L: L, a: a, b: b)
    }

    // Generates a color by using data given in HCL space using D65 as reference white.
    // H values are in [0..360], C and L values are in [0..1]
    // WARNING: many combinations of `h`, `c`, and `l` values do not have corresponding
    // valid RGB values, check the FAQ in the README if you're unsure.
    public static func Hcl(h: Float64, c: Float64, l: Float64) -> Color {
        return Color.HclWhiteRef(h: h, c: c, l: l, wref: D65)
    }

    public static func HclToLab(h: Float64, c: Float64, l: Float64) -> (L: Float64, a: Float64, b: Float64) {
        let H = 0.01745329251994329576 * h // Deg2Rad
        let a = c * cos(H)
        let b = c * sin(H)
        let L = l
        return (L, a, b)
    }

    // Generates a color by using data given in HCL space, taking
    // into account a given reference white. (i.e. the monitor's white)
    // H values are in [0..360], C and L values are in [0..1]
    public static func HclWhiteRef(h: Float64, c: Float64, l: Float64, wref: WhiteReference) -> Color {
        let (L, a, b) = Color.HclToLab(h: h, c: c, l: l)
        return Color.LabWhiteRef(l: L, a: a, b: b, wref: wref)
    }

    // BlendHcl blends two colors in the CIE-L*C*h° color-space, which should result in a smoother blend.
    // t == 0 results in c1, t == 1 results in c2
    public func BlendHcl(c2: Color, t: Float64) -> Color {
        var (h1, c1, l1) = Hcl()
        var (h2, c2, l2) = c2.Hcl()

        // https://github.com/lucasb-eyer/go-colorful/pull/60
        if c1 <= 0.00015, c2 >= 0.00015 {
            h1 = h2
        } else if c2 <= 0.00015, c1 >= 0.00015 {
            h2 = h1
        }

        // We know that h are both in [0..360]
        return Color.Hcl(h: Color.interp_angle(a0: h1, a1: h2, t: t), c: c1 + t * (c2 - c1), l: l1 + t * (l2 - l1)).Clamped()
    }

    // LuvLch

    // Converts the given color to LuvLCh space using D65 as reference white.
    // h values are in [0..360], C and L values are in [0..1] although C can overshoot 1.0
    public func LuvLCh() -> (l: Float64, c: Float64, h: Float64) {
        return LuvLChWhiteRef(wref: D65)
    }

    public static func LuvToLuvLCh(L: Float64, u: Float64, v: Float64) -> (l: Float64, c: Float64, h: Float64) {
        let l, c, h: Float64
        // Oops, floating point workaround necessary if u ~= v and both are very small (i.e. almost zero).
        if abs(v - u) > 1e-4, abs(u) > 1e-4 {
            h = (57.29577951308232087721 * atan2(v, u) + 360.0).truncatingRemainder(dividingBy: 360.0) // Rad2Deg
        } else {
            h = 0.0
        }
        l = L
        c = (sq(u) + sq(v)).squareRoot()
        return (l, c, h)
    }

    // Converts the given color to LuvLCh space, taking into account
    // a given reference white. (i.e. the monitor's white)
    // h values are in [0..360], c and l values are in [0..1]
    public func LuvLChWhiteRef(wref: WhiteReference) -> (l: Float64, c: Float64, h: Float64) {
        let (l, u, v) = LuvWhiteRef(wref: wref)
        return Color.LuvToLuvLCh(L: l, u: u, v: v)
    }

    // Generates a color by using data given in LuvLCh space using D65 as reference white.
    // h values are in [0..360], C and L values are in [0..1]
    // WARNING: many combinations of `l`, `c`, and `h` values do not have corresponding
    // valid RGB values, check the FAQ in the README if you're unsure.
    public func LuvLCh(l: Float64, c: Float64, h: Float64) -> Color {
        return Color.LuvLChWhiteRef(l: l, c: c, h: h, wref: D65)
    }

    public static func LuvLChToLuv(l: Float64, c: Float64, h: Float64) -> (L: Float64, u: Float64, v: Float64) {
        let H = 0.01745329251994329576 * h // Deg2Rad
        let u = c * cos(H)
        let v = c * sin(H)
        let L = l
        return (L, u, v)
    }

    // Generates a color by using data given in LuvLCh space, taking
    // into account a given reference white. (i.e. the monitor's white)
    // h values are in [0..360], C and L values are in [0..1]
    public static func LuvLChWhiteRef(l: Float64, c: Float64, h: Float64, wref: WhiteReference) -> Color {
        let (L, u, v) = Color.LuvLChToLuv(l: l, c: c, h: h)
        return Color.LuvWhiteRef(l: L, u: u, v: v, wref: wref)
    }

    // BlendLuvLCh blends two colors in the cylindrical CIELUV color space.
    // t == 0 results in c1, t == 1 results in c2
    public func BlendLuvLCh(c2: Color, t: Float64) -> Color {
        let (l1, c1, h1) = LuvLCh()
        let (l2, c2, h2) = c2.LuvLCh()

        // We know that h are both in [0..360]
        return LuvLCh(l: l1 + t * (l2 - l1), c: c1 + t * (c2 - c1), h: Color.interp_angle(a0: h1, a1: h2, t: t))
    }

    public var description: String {
        return "R: \(R), G: \(G) B: \(B)"
    }

    public static func == (c1: Color, c2: Color) -> Bool {
        return c1.R == c2.R &&
               c1.G == c2.G &&
               c1.B == c2.B
    }

    public static func < (c1: Color, c2: Color) -> Bool {
        if c1.R != c2.R {
            return c1.R < c2.R
        } else if c1.G != c2.G {
            return c1.G < c2.G
        } else {
            return c1.B < c2.B
        }
    }
}
