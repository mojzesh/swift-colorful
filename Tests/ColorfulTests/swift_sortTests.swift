import class Foundation.Bundle
import XCTest

@testable import Colorful

extension swift_colorfulTests {
    // testSortSimple tests the sorting of a small set of colors.
    func testSortSimple() {
        // Sort a list of reds and blues.
        var In: [Color] = []
        In.reserveCapacity(6)

        for i in 0..<3 {
            In.append(Color(R: 1.0 - Float64(i+1)*0.25, G: 0.0, B: 0.0)) // Reds
            In.append(Color(R: 0.0, G: 0.0, B: 1.0 - Float64(i+1)*0.25)) // Blues
        }

        let out = Sorted(In)

        // Ensure the output matches what we expected.
        let exp: [Color] = [
            Color(R: 0.25, G: 0.0, B:  0.0),
            Color(R: 0.50, G: 0.0, B:  0.0),
            Color(R: 0.75, G: 0.0, B:  0.0),
            Color(R:  0.0, G: 0.0, B: 0.25),
            Color(R:  0.0, G: 0.0, B: 0.50),
            Color(R:  0.0, G: 0.0, B: 0.75),
        ]

        for (i, e) in exp.enumerated() {
            if out[i] != e {
                XCTFail(String(format: "%@. Sorted(%@) want (%@)", i, out[i].description, e.description))
            }
        }
    }
}