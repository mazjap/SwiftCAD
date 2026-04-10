import Cadova
import Foundation

struct OrnamentHook: Shape3D {
    let isRotated: Bool
    
    var body: any Geometry3D {
        Union {
            branchHook
                .stroked(width: 2)
                .extruded(height: 2, topEdge: .chamfer(depth: 0.5), bottomEdge: .chamfer(depth: 0.5))
            
            ornamentHook
                .stroked(width: 2)
                .extruded(height: 2, topEdge: .chamfer(depth: 0.5), bottomEdge: .chamfer(depth: 0.5))
                .withCornerRoundingStyle(.circular)
                .rotated(isRotated ? Angle(degrees: -90) : .zero, around: .y)
                .translated(isRotated ? Vector3D(-7, 0, 9) : .zero)
        }
    }
    
    var branchHook: BezierPath<Vector2D> {
        BezierPath(startPoint: Vector2D(-8, -38))
            .addingLine(to: Vector2D(-8, -8))
            .addingArc(center: Vector2D(0, -8), to: Angle(degrees: 0), clockwise: true)
    }
    
    var ornamentHook: BezierPath<Vector2D> {
        BezierPath(startPoint: Vector2D(8, -32))
            .addingLine(to: Vector2D(-4, -40))
            .addingLine(to: Vector2D(-6, -40))
            .addingArc(center: Vector2D(-6, -38), to: Angle(degrees: 180), clockwise: true)
            .addingLine(to: Vector2D(-8, -36))
    }
}
