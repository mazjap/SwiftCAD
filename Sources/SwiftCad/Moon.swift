import Cadova

struct Moon: Shape3D {
    var body: any Cadova.Geometry3D {
        let cols = 3, rows = 3

        let topVertex: (Int, Int) -> Vector3D = { i, j in
            (i == 1 && j == 1) ? Vector3D(Double(i), Double(j), 20) : Vector3D(Double(i), Double(j), 0.1)
        }
        let bottomVertex: (Int, Int) -> Vector3D = { i, j in
            Vector3D(Double(i), Double(j), 0)
        }

        let topFaces = heightfieldFaces(cols: cols, rows: rows, vertex: topVertex)
        let bottomFaces = heightfieldFaces(cols: cols, rows: rows, vertex: bottomVertex)
            .map { Array($0.reversed()) }
        let sideFaces = wallFaces(cols: cols, rows: rows, top: topVertex, bottom: bottomVertex)

        let mesh = Mesh(faces: topFaces + bottomFaces + sideFaces, name: "Test")
        print(mesh.validate())
        return mesh
        .wrappedAroundSphere(radius: 100)
    }

    private func heightfieldFaces(
        cols: Int, rows: Int,
        vertex: (Int, Int) -> Vector3D
    ) -> [[Vector3D]] {
        var faces: [[Vector3D]] = []
        for j in 0..<(rows - 1) {
            for i in 0..<(cols - 1) {
                let a = vertex(i, j)
                let b = vertex(i + 1, j)
                let c = vertex(i + 1, j + 1)
                let d = vertex(i, j + 1)
                faces.append([a, b, c])
                faces.append([a, c, d])
            }
        }
        return faces
    }

    private func boundaryLoop(cols: Int, rows: Int) -> [(Int, Int)] {
        var points: [(Int, Int)] = []
        for i in 0..<cols { points.append((i, 0)) }
        for j in 1..<rows { points.append((cols - 1, j)) }
        for i in stride(from: cols - 2, through: 0, by: -1) { points.append((i, rows - 1)) }
        for j in stride(from: rows - 2, through: 1, by: -1) { points.append((0, j)) }
        return points
    }

    private func wallFaces(
        cols: Int, rows: Int,
        top: (Int, Int) -> Vector3D, bottom: (Int, Int) -> Vector3D
    ) -> [[Vector3D]] {
        let loop = boundaryLoop(cols: cols, rows: rows)
        var faces: [[Vector3D]] = []
        for k in 0..<loop.count {
            let p0 = loop[k]
            let p1 = loop[(k + 1) % loop.count]
            let (t0, t1) = (top(p0.0, p0.1), top(p1.0, p1.1))
            let (b0, b1) = (bottom(p0.0, p0.1), bottom(p1.0, p1.1))
            faces.append([b1, t1, t0])
            faces.append([b0, b1, t0])
        }
        return faces
    }
}
