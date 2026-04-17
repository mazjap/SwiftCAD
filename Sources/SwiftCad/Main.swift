import Cadova
import Foundation
import AppKit

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
                    microcontrollerDimensions: MicrocontrollerDimensions(mainBody: Vector3D(x: 18.5, y: 23.8, z: 1.2), usbOverhang: 1.1, usbWidth: 9),
                    trrsDimensions: TrrsDimensions(mainBody: Vector3D(x: 6.2, y: 12.4, z: 5), openingDiameter: 5, openingOverhang: 2)
                )
            }
        }
        
        NSWorkspace.shared.open(URL(filePath: "./output"))
    }
}
