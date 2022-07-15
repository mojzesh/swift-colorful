import Foundation

typealias edgeIdxs = [Int]
typealias edgeDistance = [edgeIdxs:Float64]

class Element: Equatable {
    weak var parent: Element?
    var rank: Int = 0

    init() {
        self.parent = self
    }

    static func == (lhs: Element, rhs: Element) -> Bool {
        let lhsAddress = Unmanaged.passUnretained(lhs)
        let rhsAddress = Unmanaged.passUnretained(rhs)
        return lhsAddress.toOpaque() == rhsAddress.toOpaque()
    }

    func find() -> Element {
        var e: Element = self
        while e.parent != e {
            e.parent = e.parent!.parent
            e = e.parent!
        }
        return e
    }
}

// allToAllDistancesCIEDE2000 computes the CIEDE2000 distance between each pair of
// colors.  It returns a map from a pair of indices (u, v) with u < v to a
// distance.
func allToAllDistancesCIEDE2000(_ cs: [Color]) -> edgeDistance {
    let nc = cs.count
    var m: edgeDistance = [:]
    for u in 0..<(nc-1) {
        var v = u + 1
        while v < nc {
            m[[u, v]] = cs[u].DistanceCIEDE2000(cs[v])
            v += 1
        }
    }
    return m
}

// sortEdges sorts all edges in a distance map by increasing vertex distance.
func sortEdges(_ m: edgeDistance) -> [edgeIdxs] {
    var es: [edgeIdxs] = [edgeIdxs]()
    es.reserveCapacity(m.count)
    for uv in m.keys {
        es.append(uv)
    }
    es.sort(by: { itemA, itemB in
        m[itemA]! < m[itemB]!
    })
    return es
}

// union establishes the union of two sets when given an element from each set.
// Afterwards, the original sets no longer exist as separate entities.
func union(e1: Element, e2: Element) {
    // Ensure the two elements aren't already part of the same union.
    let e1Root = e1.find()
    let e2Root = e2.find()
    if e1Root == e2Root {
        return
    }

    // Create a union by making the shorter tree point to the root of the
    // larger tree.
    if e1Root.rank < e2Root.rank {
        e1Root.parent = e2Root
    } else if e1Root.rank > e2Root.rank {
        e2Root.parent = e1Root
    } else {
        e2Root.parent = e1Root
        e1Root.rank += 1
    }
}

// traverseMST walks a minimum spanning tree in prefix order.
func traverseMST(mst: [edgeIdxs:Any], root: Int) -> [Int] {
    // Compute a list of neighbors for each vertex.
    var neighs: [Int:[Int]] = [:]
    for uv in mst.keys {
        let (u, v) = (uv[0], uv[1])
        if neighs[u] == nil {
            neighs[u] = [v]
        } else {
            neighs[u]!.append(v)
        }
    }

    for (u, var vs) in neighs {
        vs.sort()

        for (index, _) in neighs[u]!.enumerated() {
            if index >= vs.count {
                break
            }
            neighs[u]![index] = vs[index]
        }
    }

    // Walk the tree from a given vertex.
    var order: [Int] = []
    order.reserveCapacity(neighs.count)
    var visited: [Int: Bool] = [:]
    func walkFrom(_ r: Int) {
        // Visit the starting vertex.
        order.append(r)
        visited[r] = true

        // Recursively visit each child in turn.
        for c in neighs[r] ?? [] {
            if !(visited[c] ?? false) {
                walkFrom(c)
            }
        }
    }

    walkFrom(root)
    return order
}

// minSpanTree computes a minimum spanning tree from a vertex count and a
// distance-sorted edge list.  It returns the subset of edges that belong to
// the tree, including both (u, v) and (v, u) for each edge.
func minSpanTree(nc: Int, es: [edgeIdxs]) -> [edgeIdxs:Any] {
    // Start with each vertex in its own set.

    var elts : [Element] = [Element]()
    for _ in 0..<nc {
        elts.append(Element())
    }

    // Run Kruskal's algorithm to construct a minimal spanning tree.
    var mst: [edgeIdxs: Any] = [:]
    for uv in es {
        let (u, v) = (uv[0], uv[1])
        if elts[u].find() == elts[v].find() {
            continue // Same set: edge would introduce a cycle.
        }
        mst[uv] = []
        mst[[v, u]] = []
        union(e1: elts[u], e2: elts[v])
    }
    return mst
}


// Sorted sorts a list of Color values.  Sorting is not a well-defined operation
// for colors so the intention here primarily is to order colors so that the
// transition from one to the next is fairly smooth.
public func Sorted(_ cs: [Color]) -> [Color] {
    // Do nothing in trivial cases.
    var newCs: [Color] = [Color](repeating: Color(), count: cs.count)
    if cs.count < 2 {
        newCs.append(contentsOf: cs[0...1])
        return newCs
    }

    // Compute the distance from each color to every other color.
    let dists = allToAllDistancesCIEDE2000(cs)

    // Produce a list of edges in increasing order of the distance between
    // their vertices.
    let edges = sortEdges(dists)

    // Construct a minimum spanning tree from the list of edges.
    let mst = minSpanTree(nc: cs.count, es: edges)

    // Find the darkest color in the list.
    let black: Color = Color()
    var dIdx: Int = 0            // Index of darkest color
    var light = Float64.greatestFiniteMagnitude // Lightness of darkest color (distance from black)
    for (i, c) in cs.enumerated() {
        let d = black.DistanceCIEDE2000(c)
        if d < light {
            dIdx = i
            light = d
        }
    }

    // Traverse the tree starting from the darkest color.
    let idxs = traverseMST(mst: mst, root: dIdx)

    // Convert the index list to a list of colors, overwriting the input.
    for (i, idx) in idxs.enumerated() {
        newCs[i] = cs[idx]
    }

    return newCs
}
