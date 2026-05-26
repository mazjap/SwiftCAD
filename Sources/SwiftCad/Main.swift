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
            
            await Model("ferris_sweep_plate") {
                FerrisSweepPlate(
                    microcontrollerDimensions: .myRp2040,
                    trrsDimensions: .mine,
                    fingerOffsets: .mine
                )
            }
            
            await Model("ferris_sweep_case") {
                FerrisSweepCase(
                    microcontrollerDimensions: .myRp2040,
                    trrsDimensions: .mine,
                    fingerOffsets: .mine
                )
            }
            
            await Model("hailey60_plate") {
                Hailey60KeyboardPlate(
                    microcontrollerDimensions: .myRp2040,
                    trrsDimensions: .mine
                )
            }
            
            await Model("hailey60_case") {
                Hailey60KeyboardCase(
                    microcontrollerDimensions: .myRp2040,
                    trrsDimensions: .mine,
                    wedgeAngle: .degrees(10)
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
            
            for fireworkType in Firework.allCases {
                await Model("firework_ornament_\(fireworkType.rawValue)") {
                    FireworkOrnament(firework: fireworkType)
                }
            }
        }
        
        NSWorkspace.shared.open(URL(filePath: "./output"))
    }
}
