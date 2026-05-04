import Cadova

struct MicrocontrollerDimensions {
    let mainBody: Vector3D
    let usbOverhang: Double
    let usbWidth: Double
    
    static let myRp2040 = MicrocontrollerDimensions(mainBody: Vector3D(x: 18.5, y: 23.8, z: 1.2), usbOverhang: 1.1, usbWidth: 9)
}
