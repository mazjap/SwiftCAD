import Cadova
import Foundation

@main
class Main {
    static func main() async {
        await Project(root: URL(filePath: "./output/"), options: .compression(.smallest)) {
            await Model("egg_ornament") {
                EasterEggOrnament()
                    .withMaterial(.plain(.yellow))
            }
            
            await Model("ornament_hook_rotated") {
                OrnamentHook(isRotated: true)
                    .withMaterial(.plain(.green))
            }
            
            await Model("ornament_hook") {
                OrnamentHook(isRotated: false)
                    .withMaterial(.plain(.green))
            }
            
            await Model("street_sign") {
                StreetSign(text: "Your Text")
            }
            
            await Model("keyboard_left") {
                FerrisSweep()
            }
            
            await Model("hailey60_body") {
                Hailey60KeyboardBody(
                    microcontrollerDimensions: MicrocontrollerDimensions(mainBody: Vector3D(x: 21, y: 25, z: 2), usbOverhang: 1.8, usbWidth: 9),
                    trrsDimensions: TrrsDimensions(mainBody: Vector3D(x: 6, y: 14.2, z: 4.5), openingDiameter: 5, openingOverhang: 2)
                )
            }
        }
    }
}
