import Foundation
import AppKit

import Colorful
import DemoShared

let blocks = 10
let blockw = 40

let (image, imageRep) = createImageRep(NSSize(width: blocks*blockw, height: 200))

let c1 = try! Color.Hex("#fdffcc")
let c2 = try! Color.Hex("#242a42")

// Use these colors to get invalid RGB in the gradient.
// let c1 = try! Color.Hex("#EEEF61")
// let c2 = try! Color.Hex("#1E3140")

var col = Color()
for i in 0..<blocks {
    col = c1.BlendHsv(c2: c2, t: Float64(i)/Float64(blocks-1))
    drawRect(imageRep: imageRep, rect: NSRect(x: i*blockw, y: 0, width: blockw, height: blockw), color: col)
    col = c1.BlendLuv(c2: c2, t: Float64(i)/Float64(blocks-1))
    drawRect(imageRep: imageRep, rect: NSRect(x: i*blockw, y: 40, width: blockw, height: blockw), color: col)
    col = c1.BlendRgb(c2: c2, t: Float64(i)/Float64(blocks-1))
    drawRect(imageRep: imageRep, rect: NSRect(x: i*blockw, y: 80, width: blockw, height: blockw), color: col)
    col = c1.BlendLab(c2: c2, t: Float64(i)/Float64(blocks-1))
    drawRect(imageRep: imageRep, rect: NSRect(x: i*blockw, y: 120, width: blockw, height: blockw), color: col)
    col = c1.BlendHcl(c2: c2, t: Float64(i)/Float64(blocks-1))
    drawRect(imageRep: imageRep, rect: NSRect(x: i*blockw, y: 160, width: blockw, height: blockw), color: col)

    // This can be used to "fix" invalid colors in the gradient.
    // col = c1.BlendHcl(c2: c2, t: Float64(i)/Float64(blocks-1)).Clamped()
    // drawRect(imageRep: imageRep, rect: NSRect(x: i*blockw,y: 160,width: blockw, height: blockw), color: col)
}

_ = savePNG(image: image, path: "Sources/Demos/ColorBlend/colorblend.png")
