import Cadova

protocol KeyboardDimensions {
    var maxThickness: Double { get }
}

protocol Keyboard<Dimensions>: Shape3D {
    associatedtype Dimensions: KeyboardDimensions
    var dimensions: Dimensions { get }
    var microcontroller: MicrocontrollerDimensions { get }
    var trrs: TrrsDimensions { get }
}

extension Keyboard {
    func latchAttachedTo(edge: Edge) -> any Geometry3D {
        let rotation: Angle = switch edge {
        case .bottom: .degrees(0)
        case .top: .degrees(180)
        case .right: .degrees(270)
        case .left: .degrees(90)
        }
        
        let width: Double = 1.5
        let height: Double = dimensions.maxThickness
        let maxDepth: Double = 0.8
        
        return Polygon([
            Vector2D(0, 0),
            Vector2D(height, 0),
            Vector2D(height * 0.6, 0.95 * maxDepth),
            Vector2D(height * 0.5, maxDepth),
            Vector2D(height * 0.4, 0.95 * maxDepth),
        ])
        .extruded(height: width)
        .rotated(.degrees(-90), around: .y)
        .rotated(rotation, around: .z)
        .aligned(at: edge == .top ? .back : .front, .bottom, edge == .left ? .right : .left)
    }
}
