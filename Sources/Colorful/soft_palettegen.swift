
struct lab_t: Equatable {
    var L, A, B: Float64
    init(L: Float64 = 0.0, A: Float64 = 0.0, B: Float64 = 0.0) {
        self.L = L
        self.A = A
        self.B = B
    }
    static func == (lhs: lab_t, rhs: lab_t) -> Bool {
        return lhs.L == rhs.L &&
               lhs.A == rhs.A &&
               lhs.B == rhs.B
    }
}

public func randomIntInRange(min: Int, max: Int) -> Int {
    return Int.random(in: min...max)
}

public typealias CheckColorFn = (Float64, Float64, Float64) -> Bool

public struct SoftPaletteSettings {
    // A function which can be used to restrict the allowed color-space.
    var CheckColor: CheckColorFn?

    // The higher, the better quality but the slower. Usually two figures.
    var Iterations: Int

    // Use up to 160000 or 8000 samples of the L*a*b* space (and thus calls to CheckColor).
    // Set this to true only if your CheckColor shapes the Lab space weirdly.
    var ManySamples: Bool

    public init(checkColorFn: CheckColorFn?, iterations: Int, manySamples: Bool) {
        self.CheckColor = checkColorFn
        self.Iterations = iterations
        self.ManySamples = manySamples
    }
}


// An example error we can throw
public enum SoftPaletteError: Error {
    case tooManyColorsRequested(String)
}

// Yeah, windows-stype Foo, FooEx, screw you golang...
// Uses K-means to cluster the color-space and return the means of the clusters
// as a new palette of distinctive colors. Falls back to K-medoid if the mean
// happens to fall outside of the color-space, which can only happen if you
// specify a CheckColor function.
public func SoftPaletteEx(colorsCount: Int, settings: SoftPaletteSettings) throws -> [Color] {

    // Checks whether it's a valid RGB and also fulfills the potentially provided constraint.
    func checkIfRGBValid(col: lab_t) -> Bool {
        let c = Color.Lab(l: col.L, a: col.A, b: col.B)
        return c.IsValid() && (settings.CheckColor == nil || settings.CheckColor!(col.L, col.A, col.B))
    }

    let check = checkIfRGBValid

    // Sample the color space. These will be the points k-means is run on.
    var dl = 0.05
    var dab = 0.1
    if settings.ManySamples {
        dl = 0.01
        dab = 0.05
    }

    var samples: [lab_t] = [lab_t]()
    samples.reserveCapacity(Int(1.0/dl*2.0/dab*2.0/dab))

    for l in stride(from: 0.0, through: 1.0, by: dl) {
        for a in stride(from: -1.0, through: 1.0, by: dab) {
            for b in stride(from: -1.0, through: 1.0, by: dab) {
                if check(lab_t(L: l, A: a, B: b)) {
                    samples.append(lab_t(L: l, A: a, B: b))
                }
            }
        }
    }

    // That would cause some infinite loops down there...
    if samples.count < colorsCount {
        throw SoftPaletteError.tooManyColorsRequested(String(format: "palettegen: more colors requested (%@) than samples available (%@). Your requested color count may be wrong, you might want to use many samples or your constraint function makes the valid color space too small", colorsCount, samples.count))
    } else if samples.count == colorsCount {
        return labs2cols(samples) // Oops?
    }

    // We take the initial means out of the samples, so they are in fact medoids.
    // This helps us avoid infinite loops or arbitrary cutoffs with too restrictive constraints.
    // means := make([]lab_t, colorsCount)
    var means = [lab_t](repeating: lab_t(), count: colorsCount)
    for i in 0..<colorsCount {
        means[i] = samples[randomIntInRange(min: 0, max: samples.count)]
        while In(haystack: means, upto: i, needle: means[i]) {
            means[i] = samples[randomIntInRange(min: 0, max: samples.count)]
        }

    }

    var clusters = [Int](repeating: Int(), count: samples.count)
    var samples_used: [Bool] = [Bool](repeating: Bool(), count: samples.count)

    // The actual k-means/medoid iterations
    for _ in 0..<settings.Iterations {
        // Reassing the samples to clusters, i.e. to their closest mean.
        // By the way, also check if any sample is used as a medoid and if so, mark that.
        for (isample, sample) in samples.enumerated() {
            samples_used[isample] = false
            var mindist = Float64.infinity
            for (imean, mean) in means.enumerated() {
                let dist = lab_dist(lab1: sample, lab2: mean)
                if dist < mindist {
                    mindist = dist
                    clusters[isample] = imean
                }

                // Mark samples which are used as a medoid.
                if lab_eq(lab1: sample, lab2: mean) {
                    samples_used[isample] = true
                }
            }
        }

        // Compute new means according to the samples.
        for (imean, _) in means.enumerated() {
            // The new mean is the average of all samples belonging to it..
            var nsamples = 0
            var newmean = lab_t(L: 0.0, A: 0.0, B: 0.0)
            for (isample, sample) in samples.enumerated() {
                if clusters[isample] == imean {
                    nsamples += 1
                    newmean.L += sample.L
                    newmean.A += sample.A
                    newmean.B += sample.B
                }
            }
            if nsamples > 0 {
                newmean.L /= Float64(nsamples)
                newmean.A /= Float64(nsamples)
                newmean.B /= Float64(nsamples)
            } else {
                // That mean doesn't have any samples? Get a new mean from the sample list!
                var inewmean: Int = randomIntInRange(min: 0, max: samples_used.count)
                while samples_used[inewmean] {
                    inewmean = randomIntInRange(min: 0, max: samples_used.count)
                }
                newmean = samples[inewmean]
                samples_used[inewmean] = true
            }

            // But now we still need to check whether the new mean is an allowed color.
            if nsamples > 0 && check(newmean) {
                // It does, life's good (TM)
                means[imean] = newmean
            } else {
                // New mean isn't an allowed color or doesn't have any samples!
                // Switch to medoid mode and pick the closest (unused) sample.
                // This should always find something thanks to len(samples) >= colorsCount
                var mindist = Float64.infinity
                for (isample, sample) in samples.enumerated() {
                    if !samples_used[isample] {
                        let dist = lab_dist(lab1: sample, lab2: newmean)
                        if dist < mindist {
                            mindist = dist
                            newmean = sample
                        }
                    }
                }
            }
        }
    }
    return labs2cols(means)
}


// A wrapper which uses common parameters.
public func SoftPalette(_ colorsCount: Int) throws -> [Color] {
    let settings = SoftPaletteSettings(checkColorFn: nil, iterations: 50, manySamples: false)
    do {
        return try SoftPaletteEx(colorsCount: colorsCount, settings: settings)
    } catch let error {
        throw error
    }
}


func In(haystack: [lab_t], upto: Int, needle: lab_t) -> Bool {
    var i = 0
    while (i < upto && i < haystack.count) {
        if haystack[i] == needle {
            return true
        }
        i += 1
    }
    return false
}

let LAB_DELTA = 1e-6

func lab_eq(lab1: lab_t, lab2: lab_t) -> Bool {
    return abs(lab1.L-lab2.L) < LAB_DELTA &&
        abs(lab1.A-lab2.A) < LAB_DELTA &&
        abs(lab1.B-lab2.B) < LAB_DELTA
}

// That's faster than using colorful's DistanceLab since we would have to
// convert back and forth for that. Here is no conversion.
func lab_dist(lab1: lab_t, lab2: lab_t) -> Float64 {
    return (sq(lab1.L-lab2.L) + sq(lab1.A-lab2.A) + sq(lab1.B-lab2.B)).squareRoot()
}

func labs2cols(_ labs: [lab_t]) -> [Color] {
    var cols = [Color](repeating: Color(), count: labs.count)

    for (k, v) in labs.enumerated() {
        cols[k] = Color.Lab(l: v.L, a: v.A, b: v.B)
    }

    return cols
}
