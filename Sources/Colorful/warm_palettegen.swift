// Uses the HSV color space to generate colors with similar S,V but distributed
// evenly along their Hue. This is fast but not always pretty.
// If you've got time to spare, use Lab (the non-fast below).
public func FastWarmPalette(_ colorsCount: Int) -> [Color] {
    var colors = [Color](repeating: Color(), count: colorsCount)

    for i in 0..<colorsCount {
        colors[i] = Color.Hsv(H: Float64(i)*(360.0/Float64(colorsCount)), S: 0.55+randomFloat64()*0.2, V: 0.35+randomFloat64()*0.2)
    }

    return colors
}

public func WarmPalette(_ colorsCount: Int) throws -> [Color] {
    func warmy(l: Float64, a: Float64, b: Float64) -> Bool {
        let (_, c, _) = Color.LabToHcl(L: l, a: a, b: b)
        return 0.1 <= c && c <= 0.4 && 0.2 <= l && l <= 0.5
    }

    return try SoftPaletteEx(colorsCount: colorsCount, settings: SoftPaletteSettings(checkColorFn: warmy, iterations: 50, manySamples: true))
}
