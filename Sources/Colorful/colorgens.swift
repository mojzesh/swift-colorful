// Various ways to generate single random colors

public func randomFloat64() -> Float64 {
    return Float64.random(in: 0.0...1.0)
}

// // Creates a random dark, "warm" color through a restricted HSV space.
public func FastWarmColor() -> Color {
    return Color.Hsv(
        H: randomFloat64()*360.0,
        S: 0.5+randomFloat64()*0.3,
        V: 0.3+randomFloat64()*0.3)
}

// Creates a random dark, "warm" color through restricted HCL space.
// This is slower than FastWarmColor but will likely give you colors which have
// the same "warmness" if you run it many times.
public func WarmColor() -> Color {
    var c = randomWarm()
    while !c.IsValid() {
        c = randomWarm()
    }

    return c
}

func randomWarm() -> Color {
    return Color.Hcl(h: randomFloat64()*360.0,
                 c: 0.1+randomFloat64()*0.3,
                 l: 0.2+randomFloat64()*0.3)
}

// Creates a random bright, "pimpy" color through a restricted HSV space.
public func FastHappyColor() -> Color {
    return Color.Hsv(H: randomFloat64()*360.0,
                     S: 0.7+randomFloat64()*0.3,
                     V: 0.6+randomFloat64()*0.3)
}

// Creates a random bright, "pimpy" color through restricted HCL space.
// This is slower than FastHappyColor but will likely give you colors which
// have the same "brightness" if you run it many times.
public func HappyColor() -> Color {
    var c: Color = randomPimp()
    while !c.IsValid() {
        c = randomPimp()
    }

    return c
}

func randomPimp() -> Color {
    return Color.Hcl(h: randomFloat64()*360.0,
                 c: 0.5+randomFloat64()*0.3,
                 l: 0.5+randomFloat64()*0.3)
}
