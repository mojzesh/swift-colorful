import Foundation
import AppKit

import Colorful
import DemoShared

let blocks = 10
let blockw = 40
let space = 5

let (image, imageRep) = createImageRep(NSSize(width: blocks*blockw+space*(blocks-1), height: 4*(blockw+space)))

for i in 0..<blocks {
    let warm = WarmColor()
    let fwarm = FastWarmColor()
    let happy = HappyColor()
    let fhappy = FastHappyColor()

    drawRect(imageRep: imageRep, rect: NSRect(x: i*(blockw+space), y: 0,                width: blockw, height: blockw),           color: warm)
    drawRect(imageRep: imageRep, rect: NSRect(x: i*(blockw+space), y: blockw+space,     width: blockw, height: blockw),   color: fwarm)
    drawRect(imageRep: imageRep, rect: NSRect(x: i*(blockw+space), y: 2*blockw+3*space, width: blockw, height: blockw), color: happy)
    drawRect(imageRep: imageRep, rect: NSRect(x: i*(blockw+space), y: 3*blockw+4*space, width: blockw, height: blockw), color: fhappy)
}

_ = savePNG(image: image, path: "Sources/Demos/ColorGens/colorgens.png")
