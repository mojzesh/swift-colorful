import Foundation
import AppKit

import Colorful
import DemoShared

struct GradientKeyPoint {
    let Col: Color
    let Pos: Float64
}

// This table contains the "keypoints" of the colorgradient you want to generate.
// The position of each keypoint has to live in the range [0,1]
class Gradient {
    var gt: [GradientKeyPoint] = []

    init(_ keyPoints: [GradientKeyPoint]) {
        self.gt = keyPoints
    }
    // This is the meat of the gradient computation. It returns a HCL-blend between
    // the two colors around `t`.
    // Note: It relies heavily on the fact that the gradient keypoints are sorted.
    func GetInterpolatedColorFor(_ t: Float64) -> Color {
        var t: Float64 = t
        for i in 0..<gt.count-1 {
            let c1 = gt[i]
            let c2 = gt[i+1]
            if c1.Pos <= t && t <= c2.Pos {
                // We are in between c1 and c2. Go blend them!
                t = (t - c1.Pos) / (c2.Pos - c1.Pos)
                return c1.Col.BlendHcl(c2: c2.Col, t: t).Clamped()
            }
        }

        // Nothing found? Means we're at (or past) the last gradient keypoint.
        return gt[gt.count-1].Col
    }
}

// This is a very nice thing Golang forces you to do!
// It is necessary so that we can write out the literal of the colortable below.
func MustParseHex(_ s: String) -> Color {
    do {
        return try! Color.Hex(s)
    }
}


// The "keypoints" of the gradient.
let keypoints: [GradientKeyPoint] = [
    GradientKeyPoint(Col: MustParseHex("#9e0142"), Pos: 0.0),
    GradientKeyPoint(Col: MustParseHex("#d53e4f"), Pos: 0.1),
    GradientKeyPoint(Col: MustParseHex("#f46d43"), Pos: 0.2),
    GradientKeyPoint(Col: MustParseHex("#fdae61"), Pos: 0.3),
    GradientKeyPoint(Col: MustParseHex("#fee090"), Pos: 0.4),
    GradientKeyPoint(Col: MustParseHex("#ffffbf"), Pos: 0.5),
    GradientKeyPoint(Col: MustParseHex("#e6f598"), Pos: 0.6),
    GradientKeyPoint(Col: MustParseHex("#abdda4"), Pos: 0.7),
    GradientKeyPoint(Col: MustParseHex("#66c2a5"), Pos: 0.8),
    GradientKeyPoint(Col: MustParseHex("#3288bd"), Pos: 0.9),
    GradientKeyPoint(Col: MustParseHex("#5e4fa2"), Pos: 1.0),
]

let gradient = Gradient(keypoints)

let h = 1024
let w = 40

let (image, imageRep) = createImageRep(NSSize(width: w, height: h))

var y = h - 1
while y >= 0 {
    let c = gradient.GetInterpolatedColorFor(Float64(y) / Float64(h))
    drawRect(imageRep: imageRep, rect: NSRect(x: 0, y: y, width: w, height: 1), color: c)
    y -= 1
}

_ = savePNG(image: image, path: "Sources/Demos/GradientGen/gradientgen.png")
