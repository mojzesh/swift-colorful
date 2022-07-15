
// Uses the HSV color space to generate colors with similar S,V but distributed
// evenly along their Hue. This is fast but not always pretty.
// If you've got time to spare, use Lab (the non-fast below).
public func FastHappyPalette(_ colorsCount: Int) -> [Color] {
    var colors = [Color](repeating: Color(), count: colorsCount) // make([]Color, colorsCount)

    for i in 0..<colorsCount {
        colors[i] = Color.Hsv(H: Float64(i)*(360.0/Float64(colorsCount)), S: 0.8+randomFloat64()*0.2, V: 0.65+randomFloat64()*0.2)
    }

    return colors
}

public func HappyPalette(_ colorsCount: Int) throws -> [Color] {
    func pimpy(l: Float64, a: Float64, b: Float64) -> Bool {
        let (_, c, _) = Color.LabToHcl(L: l, a: a, b: b)
        return 0.3 <= c && 0.4 <= l && l <= 0.8
    }

    return try SoftPaletteEx(colorsCount: colorsCount, settings: SoftPaletteSettings(checkColorFn: pimpy, iterations: 50, manySamples: true))
}
