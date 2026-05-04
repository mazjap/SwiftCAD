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
            
            await Model("ferris_sweep") {
                FerrisSweep(
                    microcontrollerDimensions: .myRp2040,
                    trrsDimensions: .mine,
                    fingerOffsets: .mine
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
            
            await Model("modified_keycap") {
                Import(model: URL(filePath: "SwiftCad_SwiftCad.bundle/Contents/Resources/src/1U_blank.3mf"))
                    .rotated(.degrees(71.3), around: .x)
                    .subtracting {
                        let height = 4.995
                        Circle(radius: 2.85)
                            .stroked(width: 1, alignment: .outside, style: .round)
                            .aligned(at: .center)
                            .extruded(height: height)
                            .translated(z: -height)
                    }
                    .rotated(.degrees(-71.3), around: .x)
            }
        }
        
        NSWorkspace.shared.open(URL(filePath: "./output"))
    }
}
