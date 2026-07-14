import Cadova
import Foundation

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

struct MoonElevationMap {
    let width: Int
    let height: Int
    private let floats: [Float32]
    
    init(url: URL, width: Int, height: Int) throws {
        let data = try Data(contentsOf: url)
        self.floats = data.withUnsafeBytes { Array($0.bindMemory(to: Float32.self)) }
        self.width = width
        self.height = height
    }
    
    func sampleHeight(at coordinate: (lat: Angle, lon: Angle)) -> Double {
        let u = (coordinate.lon.radians + .pi) / (2 * .pi) // 0...1
        let v = (.pi / 2 - coordinate.lat.radians) / .pi // 0...1, row 0 = north pole
        
        let x = u * Double(width)
        let y = v * Double(height)
        
        return bilinearSample(x: x, y: y)
    }
    
    private func bilinearSample(x: Double, y: Double) -> Double {
        let x0 = Int(x.rounded(.down))
        let y0 = max(0, min(height - 1, Int(y.rounded(.down))))
        let y1 = max(0, min(height - 1, y0 + 1))
        
        // wrap horizontally to avoid a seam
        let x1 = (x0 + 1) % width
        let wrappedX0 = ((x0 % width) + width) % width
        
        let fx = x - Double(x0)
        let fy = y - Double(y0)
        
        let h00 = elevation(row: y0, col: wrappedX0)
        let h10 = elevation(row: y0, col: x1)
        let h01 = elevation(row: y1, col: wrappedX0)
        let h11 = elevation(row: y1, col: x1)
        
        let top = h00 * (1 - fx) + h10 * fx
        let bottom = h01 * (1 - fx) + h11 * fx
        return top * (1 - fy) + bottom * fy
    }
    
    private func elevation(row: Int, col: Int) -> Double {
        Double(floats[row * width + col])
    }
    
    static let `default` = try! MoonElevationMap(url: Bundle.module.url(forResource: "src/moon_elevations", withExtension: "bin")!, width: 2880, height: 1440)
}

struct Moon: Shape3D {
    private static let moonRadiusMeters = 1_737_000.0
    
    let baseRadius: Double
    let subdivisions: Int
    let exaggeration: Double
    let superCoolVersion: Bool = false
    let elevationMap: MoonElevationMap
    
    init(baseRadius: Double = 100, subdivisions: Int = 7, exaggeration: Double = 3, elevationMap: MoonElevationMap = .default) {
        self.baseRadius = baseRadius
        self.subdivisions = subdivisions
        self.exaggeration = exaggeration
        self.elevationMap = elevationMap
    }
    
    var body: any Cadova.Geometry3D {
        let icosphere = Icosphere(radius: baseRadius, subdivisions: subdivisions, normalize: !superCoolVersion)
        
        let displaced = icosphere.vertices.map { vector in
            let direction = vector.normalized
            let coordinate = latLon(from: direction)
            let h = superCoolVersion ? 0 : elevationMap.sampleHeight(at: coordinate)
            let normalizedHeight = h / Self.moonRadiusMeters
            let scaledHeight = normalizedHeight * baseRadius
            return direction * (baseRadius + scaledHeight * exaggeration)
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
    
    func latLon(from direction: Vector3D) -> (lat: Angle, lon: Angle) {
        let lat = Cadova.asin(min(max(direction.z, -1), 1))
        let lon = Cadova.atan2(direction.y, direction.x)
        return (lat, lon)
    }
}
