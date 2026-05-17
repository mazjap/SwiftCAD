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
            
            await Model("ferris_sweep_frame") {
                FerrisSweep(
                    microcontrollerDimensions: .myRp2040,
                    trrsDimensions: .mine,
                    fingerOffsets: .mine,
                    frame: true
                )
            }
            
            await Model("ferris_sweep_case") {
                FerrisSweep(
                    microcontrollerDimensions: .myRp2040,
                    trrsDimensions: .mine,
                    fingerOffsets: .mine,
                    frame: false
                )
            }
            
            await Model("hailey60_frame") {
                Hailey60KeyboardBody(
                    microcontrollerDimensions: .myRp2040,
                    trrsDimensions: .mine,
                    frame: true
                )
            }
            
            await Model("hailey60_case") {
                Hailey60KeyboardBody(
                    microcontrollerDimensions: .myRp2040,
                    trrsDimensions: .mine,
                    frame: false
                )
            }
            
            await Model("switch_container_frame") {
                SwitchContainer(isFrame: true)
            }
            
            await Model("switch_container_lid") {
                SwitchContainer(isFrame: false)
            }
            
            await Model("modified_keycap") {
                ModifiedKeycap()
            }
        }
        
        NSWorkspace.shared.open(URL(filePath: "./output"))
    }
}
