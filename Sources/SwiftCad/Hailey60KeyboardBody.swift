import Cadova

//   ____________________________________________
//  / ┌─────┬─────┬─────┬─────┬─────┬─────┐┌|  |┐\
//  | |     |     |     |     |     |     ||    ||
//  | ├─────┼─────┼─────┼─────┼─────┼─────┤|    ||
//  | |     |     |     |     |     |     |└────┘|
//  | ├─────┼─────┼─────┼─────┼─────┼─────┤┌────┐|
//  | |     |     |     |     |     |     |└────┘|
//  | ├─────┼─────┼─────┼─────┼─────┼─────┤     /
//  | |     |     |     |     |     |     |    /
//  | ├─────┼─────┼─────┼─────┼─────┼─────┤   /
//  | |     |     |     |     |     |     |  /
//  \ └─────┴─────┴─────┴─────┴─────┴─────┘ /
//   ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
//
// ┌─────┐
// |     | = A cherry mx keycap+switch
// └─────┘
// ┌────┐
// └────┘ = A TRRS female connector
//
//     ↓ USB Overhang
// ┌|  |┐
// |    | = A microcontroller (I'm using a RP2040-zero, but promicro or others will work)
// |    |
// └────┘

extension Hailey60KeyboardBody {
    struct Dimensions {
        let switchHoleSize: Double = 14.1
        let spacingBetweenSwitchHole: Double = 5
        let minThickness: Double = 1.6
        let maxThickness: Double = 5.5
        let bottomSupportHeight: Double = 2.0
        
        let outerSpacing: Double
        let wallThickness: Double
        let minSwitchX: Double
        let maxSwitchX: Double
        let minSwitchY: Double
        let maxSwitchY: Double
        let minMicrocontrollerX: Double
        let maxMicrocontrollerX: Double
        let maxX: Double
        let maxY: Double
        let minMicrocontrollerY: Double
        let minTrrsX: Double
        let maxTrrsY: Double
        let minTrrsY: Double
        
        init(microcontroller: MicrocontrollerDimensions, trrs: TrrsDimensions) {
            self.outerSpacing = spacingBetweenSwitchHole / 2
            self.wallThickness = 3
            self.minSwitchX = outerSpacing
            self.maxSwitchX = 6 * (switchHoleSize + spacingBetweenSwitchHole) - spacingBetweenSwitchHole + minSwitchX
            self.minSwitchY = outerSpacing
            self.maxSwitchY = outerSpacing + 5 * (switchHoleSize + spacingBetweenSwitchHole) - spacingBetweenSwitchHole
            self.minMicrocontrollerX = maxSwitchX + spacingBetweenSwitchHole
            self.maxMicrocontrollerX = minMicrocontrollerX + microcontroller.mainBody.x
            self.maxX = 6 * (switchHoleSize + spacingBetweenSwitchHole) + spacingBetweenSwitchHole + microcontroller.mainBody.x + outerSpacing
            self.maxY = maxSwitchY + outerSpacing
            self.minMicrocontrollerY = maxY - (microcontroller.mainBody.y + microcontroller.usbOverhang)
            self.minTrrsX = maxX - outerSpacing - trrs.openingOverhang - trrs.mainBody.y
            self.maxTrrsY = minMicrocontrollerY - spacingBetweenSwitchHole
            self.minTrrsY = maxTrrsY - trrs.mainBody.x
        }
    }
}

struct Hailey60KeyboardBody: Shape3D {
    private let dimensions: Dimensions
    
    private let microcontroller: MicrocontrollerDimensions
    private let trrs: TrrsDimensions
    
    private let frame: Bool
    
    init(microcontrollerDimensions: MicrocontrollerDimensions, trrsDimensions: TrrsDimensions, frame: Bool) {
        self.dimensions = Dimensions(microcontroller: microcontrollerDimensions, trrs: trrsDimensions)
        self.microcontroller = microcontrollerDimensions
        self.trrs = trrsDimensions
        self.frame = frame
    }
    
    var body: any Geometry3D {
        Union {
            if frame {
                frameGeometry
            } else {
                caseGeometry
            }
        }
    }
    
    private var frameGeometry: any Geometry3D {
        return bounds
            .extruded(height: dimensions.maxThickness)
            .aligned(at: .top)
            .subtracting {
                switchHolePolygons
                    .extruded(height: dimensions.minThickness)
                    .aligned(at: .top, .left, .front)
            }
            .aligned(at: .left, .front)
            .subtracting {
                microcontrollerPolygon
                    .extruded(height: dimensions.maxThickness)
                    .aligned(at: .top, .left, .back)
                    .translated(
                        x: 6 * (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole) + dimensions.outerSpacing,
                        y: 5 * (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole)
                    )
            }
            .subtracting {
                trrsPolygon
                    .extruded(height: dimensions.maxThickness)
                    .aligned(at: .top, .left, .front)
                    .translated(
                        x: 6 * (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole) + dimensions.outerSpacing + microcontroller.mainBody.x - trrs.mainBody.y - trrs.openingOverhang + dimensions.outerSpacing,
                        y: 5 * (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole) - microcontroller.mainBody.y - microcontroller.usbOverhang - trrs.mainBody.x - dimensions.spacingBetweenSwitchHole
                    )
            }
            .aligned(at: .bottom)
            .subtracting {
                Union {
                    for i in 0..<6 {
                        Rectangle(x: dimensions.switchHoleSize, y: 5 * (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole) - dimensions.spacingBetweenSwitchHole + 2)
                            .translated(x: dimensions.outerSpacing + Double(i) * (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole), y: dimensions.outerSpacing - 1)
                    }
                    
                    Polygon([
                        Vector2D(
                            x: dimensions.minMicrocontrollerX,
                            y: dimensions.maxY - microcontroller.mainBody.y - dimensions.outerSpacing - trrs.mainBody.x - dimensions.spacingBetweenSwitchHole - dimensions.outerSpacing
                        ),
                        Vector2D( // Middle-ish right
                            x: dimensions.maxMicrocontrollerX,
                            y: dimensions.maxY - microcontroller.mainBody.y - dimensions.outerSpacing - trrs.mainBody.x - dimensions.spacingBetweenSwitchHole - dimensions.outerSpacing
                        ),
                        Vector2D( // Middle-ish bottom
                            x: dimensions.minMicrocontrollerX,
                            y: dimensions.minSwitchY + dimensions.outerSpacing * 2
                        )
                    ])
                }
                .extruded(height: dimensions.maxThickness - dimensions.minThickness)
            }
            .adding {
                Rectangle(x: microcontroller.mainBody.x, y: 1.5)
                    .extruded(height: dimensions.maxThickness - microcontroller.mainBody.z)
                    .translated(x: dimensions.minMicrocontrollerX, y: dimensions.minMicrocontrollerY, z: 0)
                
                Rectangle(x: microcontroller.usbWidth, y: microcontroller.usbOverhang)
                    .extruded(height: dimensions.maxThickness - 0.4)
                    .translated(x: dimensions.minMicrocontrollerX + (microcontroller.mainBody.x - microcontroller.usbWidth) / 2, y: dimensions.maxY - microcontroller.usbOverhang, z: 0)
                
                Rectangle(x: 1.5, y: trrs.mainBody.x / 2)
                    .extruded(height: 1)
                    .translated(x: dimensions.minTrrsX, y: dimensions.minTrrsY + (trrs.mainBody.x / 4), z: 0)
                
                Rectangle(x: trrs.openingOverhang, y: trrs.mainBody.x)
                    .extruded(height: (trrs.mainBody.z - trrs.openingDiameter) / 2 + 1)
                    .translated(x: dimensions.maxX - dimensions.outerSpacing - trrs.openingOverhang, y: dimensions.minTrrsY, z: 0)
            }
            .translated(x: dimensions.wallThickness, y: dimensions.wallThickness, z: dimensions.minThickness + dimensions.bottomSupportHeight)
            .adding {
                latches
            }
    }
    
    private var caseGeometry: any Geometry3D {
        Union {
            bounds.fillingHoles()
                .extruded(height: dimensions.minThickness + dimensions.bottomSupportHeight)
                .subtracting {
                    bounds.fillingHoles()
                        .offset(amount: -2.5, style: .square)
                        .extruded(height: dimensions.bottomSupportHeight)
                        .translated(z: dimensions.minThickness)
                }
            
            Union {
                for y in 1..<5 {
                    for x in 1..<6 {
                        Rectangle(dimensions.spacingBetweenSwitchHole)
                            .translated(
                                x: Double(x) * (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole) - dimensions.spacingBetweenSwitchHole,
                                y: Double(y) * (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole) - dimensions.spacingBetweenSwitchHole
                            )
                    }
                }
            }
            .extruded(height: dimensions.bottomSupportHeight)
            .translated(z: dimensions.minThickness)
            
            let filletRadius = dimensions.wallThickness / 2
            
            bounds.stroked(width: dimensions.wallThickness, alignment: .outside, style: .round)
                .extruded(height: dimensions.minThickness + dimensions.bottomSupportHeight + dimensions.maxThickness, topEdge: .fillet(radius: filletRadius))
            
            bounds.stroked(width: filletRadius, alignment: .outside, style: .round)
                .extruded(height: dimensions.minThickness + dimensions.bottomSupportHeight + dimensions.maxThickness)
        }
        .aligned(at: .bottom, .left, .front)
        .subtracting {
            let microcontrollerWallHole: Double = 13
            
            Rectangle(
                x: microcontrollerWallHole,
                y: dimensions.wallThickness
            )
            .extruded(height: dimensions.maxThickness + dimensions.bottomSupportHeight - dimensions.minThickness)
            .translated(x: dimensions.wallThickness + dimensions.minMicrocontrollerX + (microcontroller.mainBody.x - microcontrollerWallHole) / 2, y: dimensions.maxY + dimensions.wallThickness, z: dimensions.minThickness + dimensions.bottomSupportHeight)
            
            let trrsWallHole: Double = 9
            
            Rectangle(x: dimensions.wallThickness, y: trrsWallHole)
                .extruded(height: dimensions.maxThickness + dimensions.bottomSupportHeight - dimensions.minThickness)
                .translated(x: dimensions.maxX, y: dimensions.minTrrsY, z: dimensions.minThickness + dimensions.bottomSupportHeight)
        }
        .subtracting {
            latches
        }
    }
    
    private var switchHolePolygons: any Geometry2D {
        Stack(.y, spacing: dimensions.spacingBetweenSwitchHole) {
            for _ in 0..<5 {
                Stack(.x, spacing: dimensions.spacingBetweenSwitchHole) {
                    for _ in 0..<6 {
                        Rectangle(dimensions.switchHoleSize)
                    }
                }
            }
        }
    }
    
    private var bounds: any Geometry2D {
        let minX = -dimensions.outerSpacing
        let minY = -dimensions.outerSpacing
        let maxSwitchX: Double = 6 * (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole)
        let maxX = maxSwitchX + microcontroller.mainBody.x + dimensions.outerSpacing
        let maxY = 5 * (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole) - dimensions.spacingBetweenSwitchHole + dimensions.outerSpacing
        
        return Polygon([
            Vector2D( // Bottom left
                x: minX,
                y: minY
            ),
            Vector2D( // Top left
                x: minX,
                y: maxY
            ),
            Vector2D( // Top right
                x: maxX,
                y: maxY
            ),
            Vector2D( // Middle-ish right
                x: maxX,
                y: maxY - dimensions.outerSpacing - microcontroller.mainBody.y - dimensions.outerSpacing - trrs.mainBody.x - dimensions.spacingBetweenSwitchHole - dimensions.outerSpacing
            ),
            Vector2D( // Middle-ish bottom
                x: maxSwitchX,
                y: minY
            )
        ])
    }
    
    private var microcontrollerPolygon: any Geometry2D {
        Stack(.y, alignment: .center) {
            Rectangle(microcontroller.mainBody.xy)
            Rectangle(x: microcontroller.usbWidth, y: microcontroller.usbOverhang)
        }
    }
    
    private var trrsPolygon: any Geometry2D {
        Stack(.x, alignment: .center) {
            Rectangle(x: trrs.mainBody.y, y: trrs.mainBody.x)
            Rectangle(x: trrs.openingOverhang, y: trrs.openingDiameter)
        }
    }
    
    private var latches: any Geometry3D {
        Union {
            latchAttachedTo(edge: .top)
                .translated(x: dimensions.minSwitchX + 20, y: dimensions.wallThickness)
            
            latchAttachedTo(edge: .top)
                .translated(x: (dimensions.maxSwitchX + dimensions.spacingBetweenSwitchHole - dimensions.minSwitchX) / 2, y: dimensions.wallThickness)
            
            latchAttachedTo(edge: .top)
                .translated(x: dimensions.maxSwitchX - 20, y: dimensions.wallThickness)
            
            latchAttachedTo(edge: .bottom)
                .translated(x: dimensions.minSwitchX + 20, y: dimensions.wallThickness + dimensions.maxY)
            
            latchAttachedTo(edge: .bottom)
                .translated(x: ((dimensions.maxX - dimensions.outerSpacing) - dimensions.minSwitchX) / 2, y: dimensions.wallThickness + dimensions.maxY)
            
            latchAttachedTo(edge: .bottom)
                .translated(x: dimensions.maxX - dimensions.outerSpacing - 20, y: dimensions.wallThickness + dimensions.maxY)
            
            latchAttachedTo(edge: .left)
                .translated(x: dimensions.wallThickness, y: dimensions.minSwitchY + 20)
            
            latchAttachedTo(edge: .left)
                .translated(x: dimensions.wallThickness, y: dimensions.maxSwitchY - 20)
            
            latchAttachedTo(edge: .right)
                .translated(x: dimensions.maxX, y: dimensions.maxY - 20)
        }
        .translated(z: dimensions.bottomSupportHeight + dimensions.minThickness)
    }
    
    private func latchAttachedTo(edge: Edge) -> any Geometry3D {
        let rotation: Angle = switch edge {
        case .bottom: .degrees(0)
        case .top: .degrees(180)
        case .right: .degrees(270)
        case .left: .degrees(90)
        }
        
        let width: Double = 1.5
        let height: Double = 2
        let maxDepth: Double = dimensions.wallThickness / 2
        
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

enum Edge {
    case top, right, bottom, left
}
