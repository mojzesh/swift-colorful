import class Foundation.Bundle
import XCTest

@testable import Colorful

struct Values: Codable {
    var lch: [Float64]
    var luv: [Float64]
    var rgb: [Float64]
    var xyz: [Float64]
    var hpluv: [Float64]
    var hsluv: [Float64]
}

func loadValuesFromJson(filename fileName: String) -> [String: Values]? {
    if let url = Bundle.module.url(forResource: fileName, withExtension: "") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData: [String: Values] = try decoder.decode([String: Values].self, from: data)
            return jsonData
        } catch {
            print("error:\(error)")
        }
    }
    return nil
}

var mapping: [String: Values] = .init()

func fromHex(_ s: String) -> Color {
    let c = try! Color.Hex(s)
    return c
}

func compareHex(result: String , expected: String, method: String, hex: String) {
    if result != expected {
        XCTFail(String(format: "result: %@ expected: %@, testing %s with test case %s", result, expected, method, hex))
    }
}

// const delta = 0.00000001
let hsluvTestDelta = 0.0000000001 // Two more zeros than the original delta, because values are divided by 100

func compareTuple(result: [Float64], expected: [Float64], method: String, hex: String) {
    var err = false
    var errs = [Bool](repeatElement(false, count: 3))
    for i in 0 ..< 3 {
        if abs(result[i] - expected[i]) > hsluvTestDelta {
            err = true
            errs[i] = true
        }
    }
    if err {
        var resultOutput = "["
        for i in 0 ..< 3 {
            resultOutput += String(format: "%f", arguments: [result[i]])
            if errs[i] {
                resultOutput += " *"
            }
            if i < 2 {
                resultOutput += ", "
            }
        }
        resultOutput += "]"
        XCTFail(String(format: "result: %s expected: %@, testing %s with test case %s", resultOutput, expected, method, hex))
    }
}

extension swift_colorfulTests {
    func testHSLuv() {
        let snapshot = loadValuesFromJson(filename: "hsluv-snapshot-rev4.json")
        for (hex, var colorValues) in snapshot! {
            // print("Testing public methods for test case %s", hex)

            // Adjust color values to be in the ranges this library uses
            colorValues.hsluv[1] /= 100.0
            colorValues.hsluv[2] /= 100.0
            colorValues.hpluv[1] /= 100.0
            colorValues.hpluv[2] /= 100.0

            var col = Color.HSLuv(h: colorValues.hsluv[0], s: colorValues.hsluv[1], l: colorValues.hsluv[2])
            compareHex(result: col.Hex(), expected: hex, method: "HsluvToHex", hex: hex)

            col = Color.HSLuv(h: colorValues.hsluv[0],s: colorValues.hsluv[1],l: colorValues.hsluv[2])
            compareTuple(result: [col.R, col.G, col.B], expected: colorValues.rgb, method: "HsluvToRGB", hex: hex)

            var hsl = fromHex(hex).HSLuv()
            compareTuple(result: [hsl.h, hsl.s, hsl.l], expected: colorValues.hsluv, method: "HsluvFromHex", hex: hex)

            hsl = Color(R: colorValues.rgb[0], G: colorValues.rgb[1], B: colorValues.rgb[2]).HSLuv()
            compareTuple(result: [hsl.h, hsl.s, hsl.l], expected: colorValues.hsluv, method: "HsluvFromRGB", hex: hex)

            col = Color.HPLuv(h: colorValues.hpluv[0],s: colorValues.hpluv[1],l: colorValues.hpluv[2])
            compareHex(result: col.Hex(), expected: hex, method: "HpluvToHex", hex: hex)

            col = Color.HPLuv(h: colorValues.hpluv[0], s: colorValues.hpluv[1], l: colorValues.hpluv[2])
            compareTuple(result: [col.R, col.G, col.B], expected: colorValues.rgb, method: "HpluvToRGB", hex: hex)

            hsl = fromHex(hex).HPLuv()
            compareTuple(result: [hsl.h, hsl.s, hsl.l], expected: colorValues.hpluv, method: "HpluvFromHex", hex: hex)

            hsl = Color(R: colorValues.rgb[0], G: colorValues.rgb[1], B: colorValues.rgb[2]).HPLuv()
            compareTuple(result: [hsl.h, hsl.s, hsl.l], expected: colorValues.hpluv, method: "HpluvFromRGB", hex: hex)

            // print("Testing internal methods for test case %s", hex)

            colorValues.lch[0] /= 100.0
            colorValues.lch[1] /= 100.0
            colorValues.luv[0] /= 100.0
            colorValues.luv[1] /= 100.0
            colorValues.luv[2] /= 100.0

            col = Color.LuvLChWhiteRef(l: colorValues.lch[0], c: colorValues.lch[1], h: colorValues.lch[2], wref: hSLuvD65)
            compareTuple(result: [col.R, col.G, col.B], expected: colorValues.rgb, method: "convLchRgb", hex: hex)

            var lch = Color(R: colorValues.rgb[0], G: colorValues.rgb[1], B: colorValues.rgb[2]).LuvLChWhiteRef(wref: hSLuvD65)
            compareTuple(result: [lch.l, lch.c, lch.h], expected: colorValues.lch, method: "convRgbLch", hex: hex)

            let luv = Color.XyzToLuvWhiteRef(x: colorValues.xyz[0], y: colorValues.xyz[1], z: colorValues.xyz[2], wref: hSLuvD65)
            compareTuple(result: [luv.l, luv.u, luv.v], expected: colorValues.luv, method: "convXyzLuv", hex: hex)

            var xyz = Color.LuvToXyzWhiteRef(l: colorValues.luv[0], u: colorValues.luv[1], v: colorValues.luv[2], wref: hSLuvD65)
            compareTuple(result: [xyz.x, xyz.y, xyz.z], expected: colorValues.xyz, method: "convLuvXyz", hex: hex)

            lch = Color.LuvToLuvLCh(L: colorValues.luv[0], u: colorValues.luv[1], v: colorValues.luv[2])
            compareTuple(result: [lch.l, lch.c, lch.h], expected: colorValues.lch, method: "convLuvLch", hex: hex)

            let Luv = Color.LuvLChToLuv(l: colorValues.lch[0], c: colorValues.lch[1], h: colorValues.lch[2])
            compareTuple(result: [Luv.L, Luv.u, Luv.v], expected: colorValues.luv, method: "convLchLuv", hex: hex)


            let LCh = Color.HSLuvToLuvLCh(h: colorValues.hsluv[0],s: colorValues.hsluv[1],l: colorValues.hsluv[2])
            compareTuple(result: [LCh.L, LCh.C, LCh.h], expected: colorValues.lch, method: "convHsluvLch", hex: hex)

            hsl = Color.LuvLChToHSLuv(l: colorValues.lch[0], c: colorValues.lch[1], h: colorValues.lch[2])
            compareTuple(result: [hsl.h, hsl.s, hsl.l], expected: colorValues.hsluv, method: "convLchHsluv", hex: hex)

            lch = Color.HPLuvToLuvLCh(h: colorValues.hpluv[0], s: colorValues.hpluv[1], l: colorValues.hpluv[2])
            compareTuple(result: [lch.l, lch.c, lch.h], expected: colorValues.lch, method: "convHpluvLch", hex: hex)

            hsl = Color.LuvLChToHPLuv(l: colorValues.lch[0],c: colorValues.lch[1],h: colorValues.lch[2])
            compareTuple(result: [hsl.h, hsl.s, hsl.l], expected: colorValues.hpluv, method: "convLchHpluv", hex: hex)

            let rgb = Color.XyzToLinearRgb(x: colorValues.xyz[0], y: colorValues.xyz[1], z: colorValues.xyz[2])
            col = Color.LinearRgb(r: rgb.r, g: rgb.g, b: rgb.b)
            compareTuple(result: [col.R, col.G, col.B], expected: colorValues.rgb, method: "convXyzRgb", hex: hex)

            xyz = Color(R: colorValues.rgb[0], G: colorValues.rgb[1], B: colorValues.rgb[2]).Xyz()
            compareTuple(result: [xyz.x, xyz.y, xyz.z], expected: colorValues.xyz, method: "convRgbXyz", hex: hex)
        }
    }
}
