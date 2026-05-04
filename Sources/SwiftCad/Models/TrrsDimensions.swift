import Cadova

struct TrrsDimensions {
    let mainBody: Vector3D
    let openingDiameter: Double
    let openingOverhang: Double
    
    static let mine = TrrsDimensions(mainBody: Vector3D(x: 6.2, y: 12.4, z: 5), openingDiameter: 5, openingOverhang: 2)
}
