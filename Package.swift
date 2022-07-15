// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-colorful",
    products: [
        .library(name: "Colorful", targets: ["Colorful"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Colorful",
            dependencies: []),
        .testTarget(
            name: "ColorfulTests",
            dependencies: ["Colorful"],
            resources: [.process("Resources/hsluv-snapshot-rev4.json")]),
    ]
)

//--------------------------------------------
// Demo projects
//--------------------------------------------
#if os(macOS)
    //--------------------------------------------
    // DemoShared
    //--------------------------------------------
    package.products.append(.executable(name: "DemoColorBlend-macOS", targets: ["DemoColorBlend"]))
    package.targets.append(.target(name: "DemoShared",
                                   dependencies: ["Colorful"],
                                   path: "Sources/Demos/Shared"))

    //--------------------------------------------
    // DemoColorBlend
    //--------------------------------------------
    package.targets.append(.executableTarget(name: "DemoColorBlend",
                                             dependencies: ["Colorful", "DemoShared"],
                                             path: "Sources/Demos/ColorBlend",
                                             exclude:["colorblend.png", "invalid.xcf", "invalid.png", "clamped.png", "clamped.xcf"]))

    //--------------------------------------------
    // DemoColorDist
    //--------------------------------------------
    package.products.append(.executable(name: "DemoColorDist-macOS", targets: ["DemoColorDist"]))
    package.targets.append(.executableTarget(name: "DemoColorDist",
                                             dependencies: ["Colorful"],
                                             path: "Sources/Demos/ColorDist",
                                             exclude:["colordist.png", "colordist.xcf"]))

    //--------------------------------------------
    // DemoColorGens
    //--------------------------------------------
    package.products.append(.executable(name: "DemoColorGens-macOS", targets: ["DemoColorGens"]))
    package.targets.append(.executableTarget(name: "DemoColorGens",
                                             dependencies: ["Colorful", "DemoShared"],
                                             path: "Sources/Demos/ColorGens",
                                             exclude:["colorgens.png"]))

    //--------------------------------------------
    // DemoColorSort
    //--------------------------------------------
    package.products.append(.executable(name: "DemoColorSort-macOS", targets: ["DemoColorSort"]))
    package.targets.append(.executableTarget(name: "DemoColorSort",
                                             dependencies: ["Colorful", "DemoShared"],
                                             path: "Sources/Demos/ColorSort",
                                             exclude:["colorsort.png"]))

    //--------------------------------------------
    // DemoGradientGen
    //--------------------------------------------
    package.products.append(.executable(name: "DemoGradientGen-macOS", targets: ["DemoGradientGen"]))
    package.targets.append(.executableTarget(name: "DemoGradientGen",
                                             dependencies: ["Colorful", "DemoShared"],
                                             path: "Sources/Demos/GradientGen",
                                             exclude:["gradientgen.png"]))

    //--------------------------------------------
    // DemoPaletteGens
    //--------------------------------------------
    package.products.append(.executable(name: "DemoPaletteGens-macOS", targets: ["DemoPaletteGens"]))
    package.targets.append(.executableTarget(name: "DemoPaletteGens",
                                             dependencies: ["Colorful", "DemoShared"],
                                             path: "Sources/Demos/PaletteGens",
                                             exclude:["palettegens.png"]))

    //--------------------------------------------
    // Benchmark
    //--------------------------------------------
    package.products.append(.executable(name: "Benchmark-macOS", targets: ["Benchmark"]))
    package.targets.append(.executableTarget(name: "Benchmark",
                                             dependencies: ["Colorful", "DemoShared"],
                                             path: "Sources/Demos/Benchmark"))
#endif
