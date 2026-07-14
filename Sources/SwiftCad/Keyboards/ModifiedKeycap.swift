import Cadova
import Foundation

struct ModifiedKeycap: Shape3D {
    private let rotation = Angle.degrees(71.3)
    private let subtractionHeight = 4.995
    private let url = Bundle.module.url(forResource: "src/1U_blank", withExtension: "3mf")!
    
    var body: any Geometry3D {
        Import(model: url)
            .rotated(rotation, around: .x)
            .subtracting {
                Circle(radius: 2.85)
                    .stroked(width: 1, alignment: .outside, style: .round)
                    .aligned(at: .center)
                    .extruded(height: subtractionHeight)
                    .translated(z: -subtractionHeight)
            }
            .rotated(-rotation, around: .x)
    }
}
