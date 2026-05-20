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
    
    private var fireworkShape: any Geometry2D {
        Import(svg: firework.url)
    }
    
    init(firework: Firework) {
        self.firework = firework
    }
    
    var body: any Geometry3D {
        fireworkShape
            .extruded(height: 2)
    }
}
