import class Foundation.Bundle
import XCTest

@testable import Colorful

// Checks whether the relative error is below eps
func almosteq_eps(v1: Float64, v2: Float64, eps: Float64) -> Bool {
    if abs(v1) > delta {
        return abs((v1 - v2) / v1) < eps
    }
    return true
}

// Checks whether the relative error is below the 8bit RGB delta, which should be good enough.
let delta = 1.0 / 256.0

func almosteq(v1: Float64, v2: Float64) -> Bool {
    return almosteq_eps(v1: v1, v2: v2, eps: delta)
}

struct TestVals {
    let c: Color
    let hsl: [Float64]
    let hsv: [Float64]
    let hex: String
    let xyz: [Float64]
    let xyy: [Float64]
    let lab: [Float64]
    let lab50: [Float64]
    let luv: [Float64]
    let luv50: [Float64]
    let hcl: [Float64]
    let hcl50: [Float64]
    let rgba: [UInt32]
    let rgb255: [uint8]
}

let vals: [TestVals] = [
    TestVals(c: Color(R: 1.0, G: 1.0, B: 1.0), hsl: [0.0, 0.0, 1.00], hsv: [0.0, 0.0, 1.0], hex: "#ffffff", xyz: [0.950470, 1.000000, 1.088830], xyy: [0.312727, 0.329023, 1.000000], lab: [1.000000, 0.000000, 0.000000], lab50: [1.000000, -0.023881, -0.193622], luv: [1.00000, 0.00000, 0.00000], luv50: [1.00000, -0.14716, -0.25658], hcl: [0.0000, 0.000000, 1.000000], hcl50: [262.9688, 0.195089, 1.000000], rgba: [65535, 65535, 65535, 65535], rgb255: [255, 255, 255]),
    TestVals(c: Color(R: 0.5, G: 1.0, B: 1.0), hsl: [180.0, 1.0, 0.75], hsv: [180.0, 0.5, 1.0], hex: "#80ffff", xyz: [0.626296, 0.832848, 1.073634], xyy: [0.247276, 0.328828, 0.832848], lab: [0.931390, -0.353319, -0.108946], lab50: [0.931390, -0.374100, -0.301663], luv: [0.93139, -0.53909, -0.11630], luv50: [0.93139, -0.67615, -0.35528], hcl: [197.1371, 0.369735, 0.931390], hcl50: [218.8817, 0.480574, 0.931390], rgba: [32768, 65535, 65535, 65535], rgb255: [128, 255, 255]),
    TestVals(c: Color(R: 1.0, G: 0.5, B: 1.0), hsl: [300.0, 1.0, 0.75], hsv: [300.0, 0.5, 1.0], hex: "#ff80ff", xyz: [0.669430, 0.437920, 0.995150], xyy: [0.318397, 0.208285, 0.437920], lab: [0.720892, 0.651673, -0.422133], lab50: [0.720892, 0.630425, -0.610035], luv: [0.72089, 0.60047, -0.77626], luv50: [0.72089, 0.49438, -0.96123], hcl: [327.0661, 0.776450, 0.720892], hcl50: [315.9417, 0.877257, 0.720892], rgba: [65535, 32768, 65535, 65535], rgb255: [255, 128, 255]),
    TestVals(c: Color(R: 1.0, G: 1.0, B: 0.5), hsl: [60.0, 1.0, 0.75], hsv: [60.0, 0.5, 1.0], hex: "#ffff80", xyz: [0.808654, 0.943273, 0.341930], xyy: [0.386203, 0.450496, 0.943273], lab: [0.977637, -0.165795, 0.602017], lab50: [0.977637, -0.188424, 0.470410], luv: [0.97764, 0.05759, 0.79816], luv50: [0.97764, -0.08628, 0.54731], hcl: [105.3975, 0.624430, 0.977637], hcl50: [111.8287, 0.506743, 0.977637], rgba: [65535, 65535, 32768, 65535], rgb255: [255, 255, 128]),
    TestVals(c: Color(R: 0.5, G: 0.5, B: 1.0), hsl: [240.0, 1.0, 0.75], hsv: [240.0, 0.5, 1.0], hex: "#8080ff", xyz: [0.345256, 0.270768, 0.979954], xyy: [0.216329, 0.169656, 0.270768], lab: [0.590453, 0.332846, -0.637099], lab50: [0.590453, 0.315806, -0.824040], luv: [0.59045, -0.07568, -1.04877], luv50: [0.59045, -0.16257, -1.20027], hcl: [297.5843, 0.718805, 0.590453], hcl50: [290.9689, 0.882482, 0.590453], rgba: [32768, 32768, 65535, 65535], rgb255: [128, 128, 255]),
    TestVals(c: Color(R: 1.0, G: 0.5, B: 0.5), hsl: [0.0, 1.0, 0.75], hsv: [0.0, 0.5, 1.0], hex: "#ff8080", xyz: [0.527613, 0.381193, 0.248250], xyy: [0.455996, 0.329451, 0.381193], lab: [0.681085, 0.483884, 0.228328], lab50: [0.681085, 0.464258, 0.110043], luv: [0.68108, 0.92148, 0.19879], luv50: [0.68106, 0.82106, 0.02393], hcl: [25.2610, 0.535049, 0.681085], hcl50: [13.3347, 0.477121, 0.681085], rgba: [65535, 32768, 32768, 65535], rgb255: [255, 128, 128]),
    TestVals(c: Color(R: 0.5, G: 1.0, B: 0.5), hsl: [120.0, 1.0, 0.75], hsv: [120.0, 0.5, 1.0], hex: "#80ff80", xyz: [0.484480, 0.776121, 0.326734], xyy: [0.305216, 0.488946, 0.776121], lab: [0.906026, -0.600870, 0.498993], lab50: [0.906026, -0.619946, 0.369365], luv: [0.90603, -0.58869, 0.76102], luv50: [0.90603, -0.72202, 0.52855], hcl: [140.2920, 0.781050, 0.906026], hcl50: [149.2134, 0.721640, 0.906026], rgba: [32768, 65535, 32768, 65535], rgb255: [128, 255, 128]),
    TestVals(c: Color(R: 0.5, G: 0.5, B: 0.5), hsl: [0.0, 0.0, 0.50], hsv: [0.0, 0.0, 0.5], hex: "#808080", xyz: [0.203440, 0.214041, 0.233054], xyy: [0.312727, 0.329023, 0.214041], lab: [0.533890, 0.000000, 0.000000], lab50: [0.533890, -0.014285, -0.115821], luv: [0.53389, 0.00000, 0.00000], luv50: [0.53389, -0.07857, -0.13699], hcl: [0.0000, 0.000000, 0.533890], hcl50: [262.9688, 0.116699, 0.533890], rgba: [32768, 32768, 32768, 65535], rgb255: [128, 128, 128]),
    TestVals(c: Color(R: 0.0, G: 1.0, B: 1.0), hsl: [180.0, 1.0, 0.50], hsv: [180.0, 1.0, 1.0], hex: "#00ffff", xyz: [0.538014, 0.787327, 1.069496], xyy: [0.224656, 0.328760, 0.787327], lab: [0.911132, -0.480875, -0.141312], lab50: [0.911132, -0.500630, -0.333781], luv: [0.91113, -0.70477, -0.15204], luv50: [0.91113, -0.83886, -0.38582], hcl: [196.3762, 0.501209, 0.911132], hcl50: [213.6923, 0.601698, 0.911132], rgba: [0, 65535, 65535, 65535], rgb255: [0, 255, 255]),
    TestVals(c: Color(R: 1.0, G: 0.0, B: 1.0), hsl: [300.0, 1.0, 0.50], hsv: [300.0, 1.0, 1.0], hex: "#ff00ff", xyz: [0.592894, 0.284848, 0.969638], xyy: [0.320938, 0.154190, 0.284848], lab: [0.603242, 0.982343, -0.608249], lab50: [0.603242, 0.961939, -0.794531], luv: [0.60324, 0.84071, -1.08683], luv50: [0.60324, 0.75194, -1.24161], hcl: [328.2350, 1.155407, 0.603242], hcl50: [320.4444, 1.247640, 0.603242], rgba: [65535, 0, 65535, 65535], rgb255: [255, 0, 255]),
    TestVals(c: Color(R: 1.0, G: 1.0, B: 0.0), hsl: [60.0, 1.0, 0.50], hsv: [60.0, 1.0, 1.0], hex: "#ffff00", xyz: [0.770033, 0.927825, 0.138526], xyy: [0.419320, 0.505246, 0.927825], lab: [0.971393, -0.215537, 0.944780], lab50: [0.971393, -0.237800, 0.847398], luv: [0.97139, 0.07706, 1.06787], luv50: [0.97139, -0.06590, 0.81862], hcl: [102.8512, 0.969054, 0.971393], hcl50: [105.6754, 0.880131, 0.971393], rgba: [65535, 65535, 0, 65535], rgb255: [255, 255, 0]),
    TestVals(c: Color(R: 0.0, G: 0.0, B: 1.0), hsl: [240.0, 1.0, 0.50], hsv: [240.0, 1.0, 1.0], hex: "#0000ff", xyz: [0.180437, 0.072175, 0.950304], xyy: [0.150000, 0.060000, 0.072175], lab: [0.322970, 0.791875, -1.078602], lab50: [0.322970, 0.778150, -1.263638], luv: [0.32297, -0.09405, -1.30342], luv50: [0.32297, -0.14158, -1.38629], hcl: [306.2849, 1.338076, 0.322970], hcl50: [301.6248, 1.484014, 0.322970], rgba: [0, 0, 65535, 65535], rgb255: [0, 0, 255]),
    TestVals(c: Color(R: 0.0, G: 1.0, B: 0.0), hsl: [120.0, 1.0, 0.50], hsv: [120.0, 1.0, 1.0], hex: "#00ff00", xyz: [0.357576, 0.715152, 0.119192], xyy: [0.300000, 0.600000, 0.715152], lab: [0.877347, -0.861827, 0.831793], lab50: [0.877347, -0.879067, 0.739170], luv: [0.87735, -0.83078, 1.07398], luv50: [0.87735, -0.95989, 0.84887], hcl: [136.0160, 1.197759, 0.877347], hcl50: [139.9409, 1.148534, 0.877347], rgba: [0, 65535, 0, 65535], rgb255: [0, 255, 0]),
    TestVals(c: Color(R: 1.0, G: 0.0, B: 0.0), hsl: [0.0, 1.0, 0.50], hsv: [0.0, 1.0, 1.0], hex: "#ff0000", xyz: [0.412456, 0.212673, 0.019334], xyy: [0.640000, 0.330000, 0.212673], lab: [0.532408, 0.800925, 0.672032], lab50: [0.532408, 0.782845, 0.621518], luv: [0.53241, 1.75015, 0.37756], luv50: [0.53241, 1.67180, 0.24096], hcl: [39.9990, 1.045518, 0.532408], hcl50: [38.4469, 0.999566, 0.532408], rgba: [65535, 0, 0, 65535], rgb255: [255, 0, 0]),
    TestVals(c: Color(R: 0.0, G: 0.0, B: 0.0), hsl: [0.0, 0.0, 0.00], hsv: [0.0, 0.0, 0.0], hex: "#000000", xyz: [0.000000, 0.000000, 0.000000], xyy: [0.312727, 0.329023, 0.000000], lab: [0.000000, 0.000000, 0.000000], lab50: [0.000000, 0.000000, 0.000000], luv: [0.00000, 0.00000, 0.00000], luv50: [0.00000, 0.00000, 0.00000], hcl: [0.0000, 0.000000, 0.000000], hcl50: [0.0000, 0.000000, 0.000000], rgba: [0, 0, 0, 65535], rgb255: [0, 0, 0]),
]

struct ShortHex {
    var c: Color
    var hex: String
}

var shorthexvals: [ShortHex] = [
    ShortHex(c: Color(R: 1.0, G: 1.0, B: 1.0), hex: "#fff"),
    ShortHex(c: Color(R: 0.6, G: 1.0, B: 1.0), hex: "#9ff"),
    ShortHex(c: Color(R: 1.0, G: 0.6, B: 1.0), hex: "#f9f"),
    ShortHex(c: Color(R: 1.0, G: 1.0, B: 0.6), hex: "#ff9"),
    ShortHex(c: Color(R: 0.6, G: 0.6, B: 1.0), hex: "#99f"),
    ShortHex(c: Color(R: 1.0, G: 0.6, B: 0.6), hex: "#f99"),
    ShortHex(c: Color(R: 0.6, G: 1.0, B: 0.6), hex: "#9f9"),
    ShortHex(c: Color(R: 0.6, G: 0.6, B: 0.6), hex: "#999"),
    ShortHex(c: Color(R: 0.0, G: 1.0, B: 1.0), hex: "#0ff"),
    ShortHex(c: Color(R: 1.0, G: 0.0, B: 1.0), hex: "#f0f"),
    ShortHex(c: Color(R: 1.0, G: 1.0, B: 0.0), hex: "#ff0"),
    ShortHex(c: Color(R: 0.0, G: 0.0, B: 1.0), hex: "#00f"),
    ShortHex(c: Color(R: 0.0, G: 1.0, B: 0.0), hex: "#0f0"),
    ShortHex(c: Color(R: 1.0, G: 0.0, B: 0.0), hex: "#f00"),
    ShortHex(c: Color(R: 0.0, G: 0.0, B: 0.0), hex: "#000"),
]

struct DistStruct {
    let c1:  Color
    let c2:  Color
    let d76: Float64 // That's also dLab
    let d94: Float64
    let d00: Float64
}

// Ground-truth from http://www.brucelindbloom.com/index.html?ColorDifferenceCalcHelp.html
var dists: [DistStruct] = [
    DistStruct(c1: Color(R: 1.0, G: 1.0, B: 1.0), c2: Color(R: 1.0, G: 1.0, B: 1.0), d76: 0.0, d94: 0.0, d00: 0.0),
    DistStruct(c1: Color(R: 0.0, G: 0.0, B: 0.0), c2: Color(R: 0.0, G: 0.0, B: 0.0), d76: 0.0, d94: 0.0, d00: 0.0),

    // Just pairs of values of the table way above.
    DistStruct(c1: Color.Lab(l: 1.000000, a: 0.000000,  b: 0.000000),  c2: Color.Lab(l: 0.931390, a: -0.353319, b: -0.108946), d76: 0.37604638, d94: 0.37604638, d00: 0.23528129),
    DistStruct(c1: Color.Lab(l: 0.720892, a: 0.651673,  b: -0.422133), c2: Color.Lab(l: 0.977637, a: -0.165795, b: 0.602017),  d76: 1.33531088, d94: 0.65466377, d00: 0.75175896),
    DistStruct(c1: Color.Lab(l: 0.590453, a: 0.332846,  b: -0.637099), c2: Color.Lab(l: 0.681085, a: 0.483884,  b: 0.228328),  d76: 0.88317072, d94: 0.42541075, d00: 0.37688153),
    DistStruct(c1: Color.Lab(l: 0.906026, a: -0.600870, b: 0.498993),  c2: Color.Lab(l: 0.533890, a: 0.000000,  b: 0.000000),  d76: 0.86517280, d94: 0.41038323, d00: 0.39960503),
    DistStruct(c1: Color.Lab(l: 0.911132, a: -0.480875, b: -0.141312), c2: Color.Lab(l: 0.603242, a: 0.982343,  b: -0.608249), d76: 1.56647162, d94: 0.87431457, d00: 0.57983482),
    DistStruct(c1: Color.Lab(l: 0.971393, a: -0.215537, b: 0.944780),  c2: Color.Lab(l: 0.322970, a: 0.791875,  b: -1.078602), d76: 2.35146891, d94: 1.11858192, d00: 1.03426977),
    DistStruct(c1: Color.Lab(l: 0.877347, a: -0.861827, b: 0.831793),  c2: Color.Lab(l: 0.532408, a: 0.800925,  b: 0.672032),  d76: 1.70565338, d94: 0.68800270, d00: 0.86608245),
]

struct AngleVals {
	let a0: Float64
	let a1: Float64
	let t:  Float64
	let at: Float64
}

// For testing angular interpolation internal function
// NOTE: They are being tested in both directions.
var anglevals: [AngleVals] = [
    AngleVals(a0: 0.0, a1: 1.0, t: 0.0, at: 0.0),
    AngleVals(a0: 0.0, a1: 1.0, t: 0.25, at: 0.25),
    AngleVals(a0: 0.0, a1: 1.0, t: 0.5, at: 0.5),
    AngleVals(a0: 0.0, a1: 1.0, t: 1.0, at: 1.0),
    AngleVals(a0: 0.0, a1: 90.0, t: 0.0, at: 0.0),
    AngleVals(a0: 0.0, a1: 90.0, t: 0.25, at: 22.5),
    AngleVals(a0: 0.0, a1: 90.0, t: 0.5, at: 45.0),
    AngleVals(a0: 0.0, a1: 90.0, t: 1.0, at: 90.0),
    AngleVals(a0: 0.0, a1: 178.0, t: 0.0, at: 0.0), // Exact 0-180 is ambiguous.
    AngleVals(a0: 0.0, a1: 178.0, t: 0.25, at: 44.5),
    AngleVals(a0: 0.0, a1: 178.0, t: 0.5, at: 89.0),
    AngleVals(a0: 0.0, a1: 178.0, t: 1.0, at: 178.0),
    AngleVals(a0: 0.0, a1: 182.0, t: 0.0, at: 0.0), // Exact 0-180 is ambiguous.
    AngleVals(a0: 0.0, a1: 182.0, t: 0.25, at: 315.5),
    AngleVals(a0: 0.0, a1: 182.0, t: 0.5, at: 271.0),
    AngleVals(a0: 0.0, a1: 182.0, t: 1.0, at: 182.0),
    AngleVals(a0: 0.0, a1: 270.0, t: 0.0, at: 0.0),
    AngleVals(a0: 0.0, a1: 270.0, t: 0.25, at: 337.5),
    AngleVals(a0: 0.0, a1: 270.0, t: 0.5, at: 315.0),
    AngleVals(a0: 0.0, a1: 270.0, t: 1.0, at: 270.0),
    AngleVals(a0: 0.0, a1: 359.0, t: 0.0, at: 0.0),
    AngleVals(a0: 0.0, a1: 359.0, t: 0.25, at: 359.75),
    AngleVals(a0: 0.0, a1: 359.0, t: 0.5, at: 359.5),
    AngleVals(a0: 0.0, a1: 359.0, t: 1.0, at: 359.0),
]

class swift_colorfulTests: XCTestCase {
    /// RGBA ///
    ////////////

    func testRGBAConversion() {
        for (_, tt) in vals.enumerated() {
            let (r, g, b, a) = tt.c.RGBA()
            if r != tt.rgba[0] || g != tt.rgba[1] || b != tt.rgba[2] || a != tt.rgba[3] {
                XCTFail("\(r)!=\(tt.rgba[0]) or \(g)!=\(tt.rgba[1]) or \(b)!=\(tt.rgba[2]) or \(a)!=\(tt.rgba[3])")
            }
        }
    }

    /// RGB255 ///
    ////////////

    func testRGB255Conversion() {
        for (_, tt) in vals.enumerated() {
            let (r, g, b) = tt.c.RGB255()
            if r != tt.rgb255[0] || g != tt.rgb255[1] || b != tt.rgb255[2] {
                XCTFail("\(r)!=\(tt.rgb255[0]) or \(g)!=\(tt.rgb255[1]) or \(b)!=\(tt.rgb255[2])")
            }
        }
    }

    /// HSV ///
    ///////////

    func testHsvCreation() {
        for (i, tt) in vals.enumerated() {
            let c = Color.Hsv(H: tt.hsv[0], S: tt.hsv[1], V: tt.hsv[2])
            if !c.AlmostEqualRgb(tt.c) {
                XCTFail(String(format: "%i. Hsv(%@) => (%@), want %@ (delta %f)", i, tt.hsv.description, c.description, tt.c.description, delta))
            }
        }
    }

    func testHsvConversion() {
        for (i, tt) in vals.enumerated() {
            let (h, s, v) = tt.c.Hsv()
            if !almosteq(v1: h, v2: tt.hsv[0]) || !almosteq(v1: s, v2: tt.hsv[1]) || !almosteq(v1: v, v2: tt.hsv[2]) {
                XCTFail(String(format: "%i. %@.Hsv() => (%@), want %@ (delta %f)", i, tt.c.description, [h, s, v].description, tt.hsv.description, delta))
            }
        }
    }

    /// HSL ///
    ///////////

    func testHslCreation() {
        for (i, tt) in vals.enumerated() {
            let c = Color.Hsl(h: tt.hsl[0], s: tt.hsl[1], l: tt.hsl[2])
            if !c.AlmostEqualRgb(tt.c) {
                XCTFail(String(format: "%i. Hsl(%@) => (%@), want %@ (delta %f)", i, tt.hsl.description, c.description, tt.c.description, delta))
            }
        }
    }

    func testHslConversion() {
        for (i, tt) in vals.enumerated() {
            let (h, s, l) = tt.c.Hsl()
            if !almosteq(v1: h, v2: tt.hsl[0]) || !almosteq(v1: s, v2: tt.hsl[1]) || !almosteq(v1: l, v2: tt.hsl[2]) {
                XCTFail(String(format: "%i. %@.Hsl() => (%@), want %@ (delta %f)", i, tt.c.description, [h, s, l].description, tt.hsl.description, delta))
            }
        }
    }

    /// Hex ///
    ///////////

    func testHexCreation() {
        for (i, tt) in vals.enumerated() {
            var c: Color
            do {
                c = try Color.Hex(tt.hex)
            } catch {
                XCTFail("testHexCreation failed!")
                continue
            }
            if !c.AlmostEqualRgb(tt.c) {
                XCTFail(String(format: "%i. Hex(%@) => (%@), want %@ (delta %f)", i, tt.hex, c.description, tt.c.description, delta))
            }
        }
    }

    func testHEXCreation() {
        for (i, tt) in vals.enumerated() {
            var c: Color
            do {
                c = try Color.Hex(tt.hex.uppercased())
            } catch {
                XCTFail("testHEXCreation failed!")
                continue
            }
            if  !c.AlmostEqualRgb(tt.c) {
                XCTFail(String(format: "%i. HEX(%@) => (%@), want %@ (delta %f)", i, tt.hex.uppercased(), c.description, tt.c.description, delta))
            }
        }
    }

    func testShortHexCreation() {
        for (i, tt) in shorthexvals.enumerated() {
            var c: Color
            do {
                c = try Color.Hex(tt.hex)
            } catch {
                XCTFail("testShortHexCreation failed!")
                continue
            }

            if !c.AlmostEqualRgb(tt.c) {
                XCTFail(String(format: "%i. Hex(%@) => (%@), want %@ (delta %f)", i, tt.hex, c.description, tt.c.description, delta))
            }
        }
    }

    func testShortHEXCreation() {
        for (i, tt) in shorthexvals.enumerated() {
            var c: Color
            do {
                c = try Color.Hex(tt.hex.uppercased())
            } catch {
                XCTFail("testShortHEXCreation failed!")
                continue
            }

            if !c.AlmostEqualRgb(tt.c) {
                XCTFail(String(format: "%i. Hex(%@) => (%@), want %@ (delta %f)", i, tt.hex.uppercased(), c.description, tt.c.description, delta))
            }
        }
    }

    func testHexConversion() {
        for (i, tt) in vals.enumerated() {
            let hex = tt.c.Hex()
            if hex != tt.hex {
                XCTFail(String(format: "%i. %@.Hex() => (%@), want %@ (delta %f)", i, tt.c.description, hex, tt.hex, delta))
            }
        }
    }

    /// Linear ///
    //////////////

    // LinearRgb itself is implicitly tested by XYZ conversions below (they use it).
    // So what we do here is just test that the FastLinearRgb approximation is "good enough"
    func testFastLinearRgb() {
        let eps = 6.0 / 255.0 // We want that "within 6 RGB values total" is "good enough".

        for r in stride(from: 0.0, to: 256.0, by: 1.0) {
            for g in stride(from: 0.0, to: 256.0, by: 1.0) {
                for b in stride(from: 0.0, to: 256.0, by: 1.0) {
                    let c = Color(R: r / 255.0, G: g / 255.0, B: b / 255.0)
                    let (r_want, g_want, b_want) = c.LinearRgb()
                    let (r_appr, g_appr, b_appr) = c.FastLinearRgb()
                    var (dr, dg, db) = (abs(r_want-r_appr), abs(g_want-g_appr), abs(b_want-b_appr))
                    if dr+dg+db > eps {
                        XCTFail(String(format: "FastLinearRgb not precise enough for %@: differences are (%f, %f, %f), allowed total difference is %f", c.description, dr, dg, db, eps))
                        return
                    }

                    let c_want = Color.LinearRgb(r: r/255.0, g: g/255.0, b: b/255.0)
                    let c_appr = Color.FastLinearRgb(r: r/255.0, g: g/255.0, b: b/255.0)
                    (dr, dg, db) = (abs(c_want.R-c_appr.R), abs(c_want.G-c_appr.G), abs(c_want.B-c_appr.B))
                    if dr+dg+db > eps {
                        XCTFail(String(format: "FastLinearRgb not precise enough for (%f, %f, %f): differences are (%f, %f, %f), allowed total difference is %f", r, g, b, dr, dg, db, eps))
                        return
                    }
                }
            }
        }
    }

    /// XYZ ///
    ///////////
    func testXyzCreation() {
        for (i, tt) in vals.enumerated() {
            let c = Color.Xyz(x: tt.xyz[0], y: tt.xyz[1], z: tt.xyz[2])
            if !c.AlmostEqualRgb(tt.c) {
                XCTFail(String(format: "%i. Xyz(%@) => (%@), want %@ (delta %f)", i, tt.xyz.description, c.description, tt.c.description, delta))
            }
        }
    }

    func testXyzConversion() {
        for (i, tt) in vals.enumerated() {
            let (x, y, z) = tt.c.Xyz()
            if !almosteq(v1: x, v2: tt.xyz[0]) || !almosteq(v1: y, v2: tt.xyz[1]) || !almosteq(v1: z, v2: tt.xyz[2]) {
                XCTFail(String(format: "%i. %@.Xyz() => (%@), want %@ (delta %f)", i, tt.c.description, [x, y, z].description, tt.xyz.description, delta))
            }
        }
    }

    /// xyY ///
    ///////////
    func testXyyCreation() {
        for (i, tt) in vals.enumerated() {
            let c = Color.Xyy(x: tt.xyy[0], y: tt.xyy[1], Y: tt.xyy[2])
            if !c.AlmostEqualRgb(tt.c) {
                XCTFail(String(format: "%i. Xyy(%@) => (%@), want %@ (delta %f)", i, tt.xyy.description, c.description, tt.c.description, delta))
            }
        }
    }

    func testXyyConversion() {
        for (i, tt) in vals.enumerated() {
            let (x, y, Y) = tt.c.Xyy()
            if !almosteq(v1: x, v2: tt.xyy[0]) || !almosteq(v1: y, v2: tt.xyy[1]) || !almosteq(v1: Y, v2: tt.xyy[2]) {
                XCTFail(String(format: "%i. %@.Xyy() => (%@), want %@ (delta %f)", i, tt.c.description, [x, y, Y].description, tt.xyy.description, delta))
            }
        }
    }

    /// L*a*b* ///
    //////////////
    func testLabCreation() {
        for (i, tt) in vals.enumerated() {
            let c = Color.Lab(l: tt.lab[0], a: tt.lab[1], b: tt.lab[2])
            if !c.AlmostEqualRgb(tt.c) {
                XCTFail(String(format: "%i. Lab(%@) => (%@), want %@ (delta %f)", i, tt.lab.description, c.description, tt.c.description, delta))
            }
        }
    }

    func testLabConversion() {
        for (i, tt) in vals.enumerated() {
            let (l, a, b) = tt.c.Lab()
            if !almosteq(v1: l, v2: tt.lab[0]) || !almosteq(v1: a, v2: tt.lab[1]) || !almosteq(v1: b, v2: tt.lab[2]) {
                XCTFail(String(format: "%i. %@.Lab() => (%@), want %@ (delta %f)", i, tt.c.description, [l, a, b].description, tt.lab.description, delta))
            }
        }
    }

    func testLabWhiteRefCreation() {
        for (i, tt) in vals.enumerated() {
            let c = Color.LabWhiteRef(l: tt.lab50[0], a: tt.lab50[1], b: tt.lab50[2], wref: D50)
            if !c.AlmostEqualRgb(tt.c) {
                XCTFail(String(format: "%i. LabWhiteRef(%@, D50) => (%@), want %@ (delta %f)", i, tt.lab50.description, c.description, tt.c.description, delta))
            }
        }
    }

    func testLabWhiteRefConversion() {
        for (i, tt) in vals.enumerated() {
            let (l, a, b) = tt.c.LabWhiteRef(wref: D50)
            if !almosteq(v1: l, v2: tt.lab50[0]) || !almosteq(v1: a, v2: tt.lab50[1]) || !almosteq(v1: b, v2: tt.lab50[2]) {
                XCTFail(String(format: "%i. %@.LabWhiteRef(D50) => (%@), want %@ (delta %f)", i, tt.c.description, [l, a, b].description, tt.lab50.description, delta))
            }
        }
    }

    /// L*u*v* ///
    //////////////
    func testLuvCreation() {
        for (i, tt) in vals.enumerated() {
            let c = Color.Luv(l: tt.luv[0], u: tt.luv[1], v: tt.luv[2])
            if !c.AlmostEqualRgb(tt.c) {
                XCTFail(String(format: "%i. Luv(%@) => (%@), want %@ (delta %f)", i, tt.luv.description, c.description, tt.c.description, delta))
            }
        }
    }

    func testLuvConversion() {
        for (i, tt) in vals.enumerated() {
            let (l, u, v) = tt.c.Luv()
            if !almosteq(v1: l, v2: tt.luv[0]) || !almosteq(v1: u, v2: tt.luv[1]) || !almosteq(v1: v, v2: tt.luv[2]) {
                XCTFail(String(format: "%i. %@.Luv() => (%@), want %@ (delta %f)", i, tt.c.description, [l, u, v].description, tt.luv.description, delta))
            }
        }
    }

    func testLuvWhiteRefCreation() {
        for (i, tt) in vals.enumerated() {
            let c = Color.LuvWhiteRef(l: tt.luv50[0], u: tt.luv50[1], v: tt.luv50[2], wref: D50)
            if !c.AlmostEqualRgb(tt.c) {
                XCTFail(String(format: "%i. LuvWhiteRef(%@, D50) => (%@), want %@ (delta %f)", i, tt.luv50.description, c.description, tt.c.description, delta))
            }
        }
    }

    func testLuvWhiteRefConversion() {
        for (i, tt) in vals.enumerated() {
            let (l, u, v) = tt.c.LuvWhiteRef(wref: D50)
            if !almosteq(v1: l, v2: tt.luv50[0]) || !almosteq(v1: u, v2: tt.luv50[1]) || !almosteq(v1: v, v2: tt.luv50[2]) {
                XCTFail(String(format: "%i. %@.LuvWhiteRef(D50) => (%@), want %@ (delta %f)", i, tt.c.description, [l, u, v].description, tt.luv50.description, delta))
            }
        }
    }

    /// HCL ///
    ///////////
    // CIE-L*a*b* in polar coordinates.
    func testHclCreation() {
        for (i, tt) in vals.enumerated() {
            let c = Color.Hcl(h: tt.hcl[0], c: tt.hcl[1], l: tt.hcl[2])
            if !c.AlmostEqualRgb(tt.c) {
                XCTFail(String(format: "%i. Hcl(%@) => (%@), want %@ (delta %f)", i, tt.hcl.description, c.description, tt.c.description, delta))
            }
        }
    }

    func testHclConversion() {
        for (i, tt) in vals.enumerated() {
            let (h, c, l) = tt.c.Hcl()
            if !almosteq(v1: h, v2: tt.hcl[0]) || !almosteq(v1: c, v2: tt.hcl[1]) || !almosteq(v1: l, v2: tt.hcl[2]) {
                XCTFail(String(format: "%i. %@.Hcl() => (%@), want %@ (delta %f)", i, tt.c.description, [h, c, l].description, tt.hcl.description, delta))
            }
        }
    }

    func testHclWhiteRefCreation() {
        for (i, tt) in vals.enumerated() {
            let c = Color.HclWhiteRef(h: tt.hcl50[0], c: tt.hcl50[1], l: tt.hcl50[2], wref: D50)
            if !c.AlmostEqualRgb(tt.c) {
                XCTFail(String(format: "%i. HclWhiteRef(%@, D50) => (%@), want %@ (delta %f)", i, tt.hcl50.description, c.description, tt.c.description, delta))
            }
        }
    }

    func testHclWhiteRefConversion() {
        for (i, tt) in vals.enumerated() {
            let (h, c, l) = tt.c.HclWhiteRef(wref: D50)
            if !almosteq(v1: h, v2: tt.hcl50[0]) || !almosteq(v1: c, v2: tt.hcl50[1]) || !almosteq(v1: l, v2: tt.hcl50[2]) {
                XCTFail(String(format: "%i. %@.HclWhiteRef(D50) => (%@), want %@ (delta %f)", i, tt.c.description, [h, c, l].description, tt.hcl50.description, delta))
            }
        }
    }

    /// Test distances ///
    //////////////////////

    func testLabDistance() {
        for (i, tt) in dists.enumerated() {
            let d = tt.c1.DistanceCIE76(tt.c2)
            if !almosteq(v1: d, v2: tt.d76) {
                XCTFail(String(format: "%i. %@.DistanceCIE76(%@) => (%f), want %f (delta %f)", i, tt.c1.description, tt.c2.description, d, tt.d76, delta))
            }
        }
    }

    func testCIE94Distance() {
        for (i, tt) in dists.enumerated() {
            let d = tt.c1.DistanceCIE94(tt.c2)
            if !almosteq(v1: d, v2: tt.d94) {
                XCTFail(String(format: "%i. %@.DistanceCIE94(%@) => (%f), want %f (delta %f)", i, tt.c1.description, tt.c2.description, d, tt.d94, delta))
            }
        }
    }

    func testCIEDE2000Distance() {
        for (i, tt) in dists.enumerated() {
            let d = tt.c1.DistanceCIEDE2000(tt.c2)
            if !almosteq(v1: d, v2: tt.d00) {
                XCTFail(String(format: "%i. %@.DistanceCIEDE2000(%@) => (%f), want %f (delta %f)", i, tt.c1.description, tt.c2.description, d, tt.d00, delta))
            }
        }
    }
    /// Test utilities ///
    //////////////////////

    func testClamp() {
        let c_orig = Color(R: 1.1, G: -0.1, B: 0.5)
        let c_want = Color(R: 1.0, G: 0.0, B: 0.5)
        if c_orig.Clamped() != c_want {
            XCTFail(String(format: "%@.Clamped() => %@, want %@", c_orig.description, c_orig.Clamped().description, c_want.description))
        }
    }

    // func testMakeColor() {
    //     c_orig_nrgba := color.NRGBA{123, 45, 67, 255}
    //     c_ours, ok := MakeColor(c_orig_nrgba)
    //     r, g, b := c_ours.RGB255()
    //     if r != 123 || g != 45 || b != 67 || !ok {
    //         t.Errorf("NRGBA->Colorful->RGB255 error: %v became (%v, %v, %v, %t)", c_orig_nrgba, r, g, b, ok)
    //     }

    //     c_orig_nrgba64 := color.NRGBA64{123 << 8, 45 << 8, 67 << 8, 0xffff}
    //     c_ours, ok = MakeColor(c_orig_nrgba64)
    //     r, g, b = c_ours.RGB255()
    //     if r != 123 || g != 45 || b != 67 || !ok {
    //         t.Errorf("NRGBA64->Colorful->RGB255 error: %v became (%v, %v, %v, %t)", c_orig_nrgba64, r, g, b, ok)
    //     }

    //     c_orig_gray := color.Gray{123}
    //     c_ours, ok = MakeColor(c_orig_gray)
    //     r, g, b = c_ours.RGB255()
    //     if r != 123 || g != 123 || b != 123 || !ok {
    //         t.Errorf("Gray->Colorful->RGB255 error: %v became (%v, %v, %v, %t)", c_orig_gray, r, g, b, ok)
    //     }

    //     c_orig_gray16 := color.Gray16{123 << 8}
    //     c_ours, ok = MakeColor(c_orig_gray16)
    //     r, g, b = c_ours.RGB255()
    //     if r != 123 || g != 123 || b != 123 || !ok {
    //         t.Errorf("Gray16->Colorful->RGB255 error: %v became (%v, %v, %v, %t)", c_orig_gray16, r, g, b, ok)
    //     }

    //     c_orig_rgba := color.RGBA{255, 255, 255, 0}
    //     c_ours, ok = MakeColor(c_orig_rgba)
    //     r, g, b = c_ours.RGB255()
    //     if r != 0 || g != 0 || b != 0 || ok {
    //         t.Errorf("RGBA->Colorful->RGB255 error: %v became (%v, %v, %v, %t)", c_orig_rgba, r, g, b, ok)
    //     }
    // }

    /// Issues raised on github ///
    ///////////////////////////////

    // https://github.com/lucasb-eyer/go-colorful/issues/11
    func testIssue11() {
        let c1hex = "#1a1a46"
        let c2hex = "#666666"

        do {
            let c1 = try Color.Hex(c1hex)
            let c2 = try Color.Hex(c2hex)

            var blend = c1.BlendHsv(c2: c2, t: 0).Hex()
            if blend != c1hex {
                XCTFail(String(format: "Issue11: %@ --Hsv-> %@ = %@, want %@", c1hex, c2hex, blend, c1hex))
            }
            blend = c1.BlendHsv(c2: c2, t: 1).Hex()
            if blend != c2hex {
                XCTFail(String(format: "Issue11: %@ --Hsv-> %@ = %@, want %@", c1hex, c2hex, blend, c2hex))
            }

            blend = c1.BlendLuv(c2: c2, t: 0).Hex()
            if blend != c1hex {
                XCTFail(String(format: "Issue11: %@ --Luv-> %@ = %@, want %@", c1hex, c2hex, blend, c1hex))
            }
            blend = c1.BlendLuv(c2: c2, t: 1).Hex()
            if blend != c2hex {
                XCTFail(String(format: "Issue11: %@ --Luv-> %@ = %@, want %@", c1hex, c2hex, blend, c2hex))
            }

            blend = c1.BlendRgb(c2: c2, t: 0).Hex()
            if blend != c1hex {
                XCTFail(String(format: "Issue11: %@ --Rgb-> %@ = %@, want %@", c1hex, c2hex, blend, c1hex))
            }
            blend = c1.BlendRgb(c2: c2, t: 1).Hex()
            if blend != c2hex {
                XCTFail(String(format: "Issue11: %@ --Rgb-> %@ = %@, want %@", c1hex, c2hex, blend, c2hex))
            }

            blend = c1.BlendLinearRgb(c2: c2, t: 0).Hex()
            if blend != c1hex {
                XCTFail(String(format: "Issue11: %@ --LinearRgb-> %@ = %@, want %@", c1hex, c2hex, blend, c1hex))
            }
            blend = c1.BlendLinearRgb(c2: c2, t: 1).Hex()
            if blend != c2hex {
                XCTFail(String(format: "Issue11: %@ --LinearRgb-> %@ = %@, want %@", c1hex, c2hex, blend, c2hex))
            }

            blend = c1.BlendLab(c2: c2, t: 0).Hex()
            if blend != c1hex {
                XCTFail(String(format: "Issue11: %@ --Lab-> %@ = %@, want %@", c1hex, c2hex, blend, c1hex))
            }
            blend = c1.BlendLab(c2: c2, t: 1).Hex()
            if blend != c2hex {
                XCTFail(String(format: "Issue11: %@ --Lab-> %@ = %@, want %@", c1hex, c2hex, blend, c2hex))
            }

            blend = c1.BlendHcl(c2: c2, t: 0).Hex()
            if blend != c1hex {
                XCTFail(String(format: "Issue11: %@ --Hcl-> %@ = %@, want %@", c1hex, c2hex, blend, c1hex))
            }
            blend = c1.BlendHcl(c2: c2, t: 1).Hex()
            if blend != c2hex {
                XCTFail(String(format: "Issue11: %@ --Hcl-> %@ = %@, want %@", c1hex, c2hex, blend, c2hex))
            }

            blend = c1.BlendLuvLCh(c2: c2, t: 0).Hex()
            if blend != c1hex {
                XCTFail(String(format: "Issue11: %@ --LuvLCh-> %@ = %@, want %@", c1hex, c2hex, blend, c1hex))
            }
            blend = c1.BlendLuvLCh(c2: c2, t: 1).Hex()
            if blend != c2hex {
                XCTFail(String(format: "Issue11: %@ --LuvLCh-> %@ = %@, want %@", c1hex, c2hex, blend, c2hex))
            }
        } catch {
            XCTFail("testIssue11 failed!")
        }
    }

    func testInterpolation() {
        // Forward
        for (i, tt) in anglevals.enumerated() {
            let res = Color.interp_angle(a0: tt.a0, a1: tt.a1, t: tt.t)
            if !almosteq_eps(v1: res, v2: tt.at, eps: 1e-15) {
                XCTFail(String(format: "%i. interp_angle(%f, %f, %f) => (%f), want %f", i, tt.a0, tt.a1, tt.t, res, tt.at))
            }
        }
        // Backward
        for (i, tt) in anglevals.enumerated() {
            let res = Color.interp_angle(a0: tt.a1, a1: tt.a0, t: 1.0-tt.t)
            if !almosteq_eps(v1: res, v2: tt.at, eps: 1e-15) {
                XCTFail(String(format: "%i. interp_angle(%f, %f, %f) => (%f), want %f", i, tt.a1, tt.a0, 1.0-tt.t, res, tt.at))
            }
        }
    }

}
