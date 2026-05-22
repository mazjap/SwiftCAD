import Foundation
import Cadova

enum Firework: CaseIterable {
    case first
    case second
    case third
    case fourth
    
    var rawValue: Int {
        switch self {
        case .first: 1
        case .second: 2
        case .third: 3
        case .fourth: 4
        }
    }
    
    var url: URL {
        URL(filePath: "SwiftCad_SwiftCad.bundle/Contents/Resources/src/fireworks/firework_\(rawValue).svg")
    }
}

struct FireworkOrnament: Shape3D {
    private let firework: Firework
    private let outerPadding: Double = 2.5
    
    private var fireworkShape: any Geometry2D {
        Import(svg: firework.url)
    }
    
    init(firework: Firework) {
        self.firework = firework
    }
    
    var body: any Geometry3D {
        fireworkShape
            .aligned(at: .center)
            .measuringBounds { geometry, bounds in
                let scaleX = 70 / bounds.size.x
                let scaleY = 70 / bounds.size.y
                
                geometry.scaled(x: scaleX, y: scaleY)
                    .measuringBounds { geometry, bounds in
                        Stack(.y, spacing: -1.5) {
                            Stack(.z, spacing: 0) {
                                Circle.ellipse(size: bounds.size + outerPadding * 2)
                                    .extruded(height: 3)
                                
                                geometry
                                    .extruded(height: 1.5)
                            }
                            
                            Ring(innerRadius: 1.5, thickness: 1.5)
                                .extruded(height: 3)
                        }
                    }
            }
    }
}
