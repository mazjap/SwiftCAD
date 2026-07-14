import Cadova
import Foundation

func openURL(_ url: URL) {
    let process = Process()
    #if os(macOS)
    process.executableURL = URL(filePath: "/usr/bin/open")
    #elseif os(Linux)
    process.executableURL = URL(filePath: "/usr/bin/xdg-open")
    #elseif os(Windows)
    process.executableURL = URL(filePath: "C:\\Windows\\System32\\cmd.exe")
    process.arguments = ["/c", "start", url.absoluteString]
    #endif
    process.arguments = [url.absoluteString]
    try? process.run()
}

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
                    wedgeAngle: .degrees(7),
                    inverted: false
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
            
            await Model("moon_surface") {
                Moon()
            }
        }
        
        openURL(URL(filePath: "./output"))
    }
}
