import Cadova
import CoreLocation

struct EdgeKey: Hashable {
    let a: Int, b: Int
    init(_ x: Int, _ y: Int) { a = min(x, y); b = max(x, y) }
}

struct Icosphere {
    private(set) var vertices: [Vector3D]
    private(set) var faces: [(Int, Int, Int)]

    init(radius: Double, subdivisions: Int, normalize: Bool) {
        let t = (1 + 5.0.squareRoot()) / 2
        var verts: [Vector3D] = [
            Vector3D(-1, t, 0), Vector3D(1, t, 0), Vector3D(-1, -t, 0), Vector3D(1, -t, 0),
            Vector3D(0, -1, t), Vector3D(0, 1, t), Vector3D(0, -1, -t), Vector3D(0, 1, -t),
            Vector3D(t, 0, -1), Vector3D(t, 0, 1), Vector3D(-t, 0, -1), Vector3D(-t, 0, 1)
        ].map { $0.normalized * radius }

        var idxFaces: [(Int, Int, Int)] = [
            (0,11,5),(0,5,1),(0,1,7),(0,7,10),(0,10,11),
            (1,5,9),(5,11,4),(11,10,2),(10,7,6),(7,1,8),
            (3,9,4),(3,4,2),(3,2,6),(3,6,8),(3,8,9),
            (4,9,5),(2,4,11),(6,2,10),(8,6,7),(9,8,1)
        ]

        for _ in 0..<subdivisions {
            var edgeCache: [EdgeKey: Int] = [:]
            func midpoint(_ a: Int, _ b: Int) -> Int {
                let key = EdgeKey(a, b)
                if let cached = edgeCache[key] { return cached }
                let unnormalizedMid = (verts[a] + verts[b]) / 2
                let mid = (normalize ? unnormalizedMid.normalized : unnormalizedMid) * radius
                verts.append(mid)
                let index = verts.count - 1
                edgeCache[key] = index
                return index
            }

            idxFaces = idxFaces.flatMap { (a, b, c) -> [(Int, Int, Int)] in
                let ab = midpoint(a, b), bc = midpoint(b, c), ca = midpoint(c, a)
                return [(a, ab, ca), (b, bc, ab), (c, ca, bc), (ab, bc, ca)]
            }
        }

        vertices = verts
        faces = idxFaces
    }
}

struct Moon: Shape3D {
    let baseRadius: Double
    let subdivisions: Int
    let exaggeration: Double
    let superCoolVersion: Bool = false
    
    init(baseRadius: Double = 100, subdivisions: Int = 6, exaggeration: Double = 8) {
        self.baseRadius = baseRadius
        self.subdivisions = subdivisions
        self.exaggeration = exaggeration
    }
    
    var body: any Cadova.Geometry3D {
        let icosphere = Icosphere(radius: baseRadius, subdivisions: subdivisions, normalize: !superCoolVersion)

        let displaced = icosphere.vertices.map { vector in
            let direction = vector.normalized
            let coordinate = latLon(from: direction)
            let h = superCoolVersion ? 0 : sampleHeight(at: coordinate)
            return direction * (baseRadius + h * exaggeration)
        }

        let meshFaces = icosphere.faces.map { (a, b, c) in
            [displaced[a], displaced[b], displaced[c]]
        }

        Mesh(
            faces: meshFaces,
            name: "MoonIcosphere",
            cacheParameters: subdivisions, baseRadius, exaggeration
        )
    }
    
    func latLon(from direction: Vector3D) -> CLLocationCoordinate2D {
        let lat = Cadova.asin(min(max(direction.z, -1), 1))
        let lon = Cadova.atan2(direction.y, direction.x)
        return CLLocationCoordinate2D(latitude: lat.degrees, longitude: lon.degrees)
    }
    
    private func sampleHeight(at coordinate: CLLocationCoordinate2D) -> Double {
        return 0 // TODO: - Use displacement image to return elevation at coordinate
    }
}
