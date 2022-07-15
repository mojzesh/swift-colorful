// This program generates an example of go-colorful's Sorted function.  It
// produces an image with three stripes of color.  The first is unsorted.
// The second is sorted in the CIE-L\*C\*h° space, ordered primarily by
// lightness, then by hue angle, and finally by chroma.  The third is
// sorted using colorful.Sorted.
import Foundation
import AppKit

import Colorful
import DemoShared

// randomColors produces a slice of random colors.
func randomColors(_ n: Int) -> [Color] {
    var cs: [Color] = [Color](repeating: Color(), count: n)
    for (i, _) in cs.enumerated() {
        cs[i] = Color(
            R: randomFloat64(),
            G: randomFloat64(),
            B: randomFloat64()
        )
    }
    return cs
}

// drawStripes creates an image with three sets of stripes.
func drawStripes(cs1: [Color], cs2: [Color], cs3: [Color], ht: Int, sep: Int) -> NSImage {
    let (image, imageRep) = createImageRep(NSSize(width: cs1.count, height: 3*ht+2*sep))
    for (c, _) in cs1.enumerated() {
        for r in 0..<ht {
            setPixel(imageRep: imageRep, pos: NSPoint(x: c, y: r), color: cs1[c].Clamped())
            setPixel(imageRep: imageRep, pos: NSPoint(x: c, y: r+ht+sep), color: cs2[c].Clamped())
            setPixel(imageRep: imageRep, pos: NSPoint(x: c, y: r+(ht+sep)*2), color: cs3[c].Clamped())
        }
    }
    return image
}

let n = 512
let cs1 = randomColors(n)
var cs2: [Color] = [Color](repeating: Color(), count: n)

cs2.append(contentsOf: cs1)

let cs2Tuples = cs2.enumerated().sorted(by: {
    let (l1, c1, h1) = cs2[$0.0].LuvLCh()
    let (l2, c2, h2) = cs2[$1.0].LuvLCh()
    if l1 != l2 {
        return l1 < l2
    }

    if h1 != h2 {
        return h1 < h2
    }

    if c1 != c2 {
        return c1 < c2
    }
    return false
})

cs2 = []
for (_, c) in cs2Tuples {
    cs2.append(c)
}

let cs3 = Sorted(cs1)
let image = drawStripes(cs1: cs1, cs2: cs2, cs3: cs3, ht: 64, sep: 16)
_ = savePNG(image: image, path: "Sources/Demos/ColorSort/colorsort.png")
