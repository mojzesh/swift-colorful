import Foundation
import AppKit

import Colorful
import DemoShared

let colors = 10
let blockw = 40
let space = 5


func isbrowny(l: Float64, a: Float64, b: Float64) -> Bool {
	let (h, c, L) = Color.LabToHcl(L: l, a: a, b: b)
	return 10.0 < h && h < 50.0 && 0.1 < c && c < 0.5 && L < 0.5
}

let (image, imageRep) = createImageRep(NSSize(width: colors*blockw+space*(colors-1), height: 6*blockw+8*space))


var warm: [Color] = []
var happy: [Color] = []
var soft: [Color] = []
var brownies: [Color] = []

do {
    warm = try WarmPalette(colors)
} catch let error {
    print("Error generating warm palette: \(error)")
}

let fwarm = FastWarmPalette(colors)

do {
    happy = try HappyPalette(colors)
} catch let error {
    print("Error generating happy palette: \(error)")
}

let fhappy = FastHappyPalette(colors)

do {
    soft = try SoftPalette(colors)
} catch let error {
    print("Error generating soft palette: \(error)")
}

do {
    brownies = try SoftPaletteEx(colorsCount: colors, settings: SoftPaletteSettings(checkColorFn: isbrowny, iterations: 50, manySamples: true))
} catch let error {
    print("Error generating brownies palette: \(error)")
}

for i in 0..<colors {
    drawRect(imageRep: imageRep, rect: NSRect(x: i*(blockw+space), y: 0,                width: blockw, height: blockw), color: warm[i])
    drawRect(imageRep: imageRep, rect: NSRect(x: i*(blockw+space), y: 1*blockw+1*space, width: blockw, height: blockw), color: fwarm[i])
    drawRect(imageRep: imageRep, rect: NSRect(x: i*(blockw+space), y: 2*blockw+3*space, width: blockw, height: blockw), color: happy[i])
    drawRect(imageRep: imageRep, rect: NSRect(x: i*(blockw+space), y: 3*blockw+4*space, width: blockw, height: blockw), color: fhappy[i])
    drawRect(imageRep: imageRep, rect: NSRect(x: i*(blockw+space), y: 4*blockw+6*space, width: blockw, height: blockw), color: soft[i])
    drawRect(imageRep: imageRep, rect: NSRect(x: i*(blockw+space), y: 5*blockw+8*space, width: blockw, height: blockw), color: brownies[i])
}

_ = savePNG(image: image, path: "Sources/Demos/PaletteGens/palettegens.png")
