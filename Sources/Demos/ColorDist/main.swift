import Foundation

import Colorful

let c1a = Color(R: 150.0 / 255.0, G: 10.0  / 255.0, B: 150.0 / 255.0)
let c1b = Color(R: 53.0  / 255.0, G: 10.0  / 255.0, B: 150.0 / 255.0)
let c2a = Color(R: 10.0  / 255.0, G: 150.0 / 255.0, B: 50.0  / 255.0)
let c2b = Color(R: 99.9  / 255.0, G: 150.0 / 255.0, B: 10.0  / 255.0)

print(String(format: "DistanceRgb:       c1: %.17f\tand c2: %.17f", c1a.DistanceRgb(c1b), c2a.DistanceRgb(c2b)))
print(String(format: "DistanceLab:       c1: %.17f\tand c2: %.17f", c1a.DistanceLab(c1b), c2a.DistanceLab(c2b)))
print(String(format: "DistanceLuv:       c1: %.17f\tand c2: %.17f", c1a.DistanceLuv(c1b), c2a.DistanceLuv(c2b)))
print(String(format: "DistanceCIE76:     c1: %.17f\tand c2: %.17f", c1a.DistanceCIE76(c1b), c2a.DistanceCIE76(c2b)))
print(String(format: "DistanceCIE94:     c1: %.17f\tand c2: %.17f", c1a.DistanceCIE94(c1b), c2a.DistanceCIE94(c2b)))
print(String(format: "DistanceCIEDE2000: c1: %.17f\tand c2: %.17f", c1a.DistanceCIEDE2000(c1b), c2a.DistanceCIEDE2000(c2b)))
