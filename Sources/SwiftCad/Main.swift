import Cadova
import Foundation

@main
class Main {
    static func main() async {
        await Project(root: URL(filePath: "./output/"), options: .compression(.smallest)) {
            await Model("egg_ornament") {
                EasterEggOrnament()
                    .withMaterial(Material.plain(.yellow))
            }
            
            await Model("ornament_hook_rotated") {
                OrnamentHook(isRotated: true)
                    .withMaterial(Material.plain(.green))
            }
            
            await Model("ornament_hook") {
                OrnamentHook(isRotated: false)
                    .withMaterial(Material.plain(.green))
            }
        }
    }
}
