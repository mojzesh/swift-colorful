import Foundation
import Colorful

let TESTS_COUNT = 10000

func BenchmarkColorToLinear() {
    measure(label: "ColorToLinear", tests: TESTS_COUNT) {
        let (r, g, b) = Color(R: randomFloat64(), G: randomFloat64(), B: randomFloat64()).LinearRgb()
        _ = r
        _ = g
        _ = b
    }
}

func BenchmarkFastColorToLinear() {
    measure(label: "FastColorToLinear", tests: TESTS_COUNT) {
        let (r, g, b) = Color(R: randomFloat64(), G: randomFloat64(), B: randomFloat64()).FastLinearRgb()
        _ = r
        _ = g
        _ = b
    }
}

func BenchmarkLinearToColor() {
    measure(label: "LinearToColor", tests: TESTS_COUNT) {
        let c = Color.LinearRgb(r: randomFloat64(), g: randomFloat64(), b: randomFloat64())
        _ = c
    }
}

func BenchmarkFastLinearToColor() {
    measure(label: "FastLinearToColor", tests: TESTS_COUNT) {
        let c = Color.FastLinearRgb(r: randomFloat64(), g: randomFloat64(), b: randomFloat64())
        _ = c
    }
}

BenchmarkColorToLinear()
BenchmarkFastColorToLinear()
BenchmarkLinearToColor()
BenchmarkFastLinearToColor()

//--------------------------------------------------------
// this benchmarking function has been taken from:
// https://stackoverflow.com/a/53403129
//--------------------------------------------------------
@_transparent @discardableResult public func measure(label: String? = nil, tests: Int = 1, printResults output: Bool = true, setup: @escaping () -> Void = { return }, _ block: @escaping () -> Void) -> Double {

    guard tests > 0 else { fatalError("Number of tests must be greater than 0") }

    var avgExecutionTime : CFAbsoluteTime = 0
    for _ in 1...tests {
        setup()
        let start = CFAbsoluteTimeGetCurrent()
        block()
        let end = CFAbsoluteTimeGetCurrent()
        avgExecutionTime += end - start
    }

    avgExecutionTime /= CFAbsoluteTime(tests)

    if output {
        let avgTimeStr = "\(avgExecutionTime)".replacingOccurrences(of: "e|E", with: " × 10^", options: .regularExpression, range: nil)

        if let label = label {
            print(label, "▿")
            print("\tExecution time: \(avgTimeStr)s")
            print("\tNumber of tests: \(tests)\n")
        } else {
            print("Execution time: \(avgTimeStr)s")
            print("Number of tests: \(tests)\n")
        }
    }

    return avgExecutionTime
}

