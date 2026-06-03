import Cadova
import Foundation

struct ModifiedKeycap: Shape3D {
    private let rotation = Angle.degrees(71.3)
    private let subtractionHeight = 4.995
    var body: any Geometry3D {
        Import(model: URL(filePath: "SwiftCad_SwiftCad.bundle/Contents/Resources/Helpers/src/1U_blank.3mf"))
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
 
