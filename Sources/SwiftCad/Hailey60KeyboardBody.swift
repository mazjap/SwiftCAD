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
            self.wallThickness = outerSpacing / 2
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
        if frame {
            frameGeometry
        } else {
            caseGeometry
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
            .translated(x: dimensions.outerSpacing / 2, y: dimensions.outerSpacing / 2, z: dimensions.minThickness + dimensions.bottomSupportHeight)
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
            
            bounds.stroked(width: dimensions.outerSpacing / 2, alignment: .outside, style: .round)
                .extruded(height: dimensions.minThickness + dimensions.bottomSupportHeight + dimensions.maxThickness)
        }
        .aligned(at: .bottom, .left, .front)
        .subtracting {
            let microcontrollerWallHole: Double = 13
            
            Rectangle(
                x: microcontrollerWallHole,
                y: dimensions.outerSpacing / 2
            )
            .extruded(height: dimensions.maxThickness + dimensions.bottomSupportHeight - dimensions.minThickness)
            .translated(x: dimensions.wallThickness + dimensions.minMicrocontrollerX + (microcontroller.mainBody.x - microcontrollerWallHole) / 2, y: dimensions.maxY + dimensions.outerSpacing / 2, z: dimensions.minThickness + dimensions.bottomSupportHeight)
            
            let trrsWallHole: Double = 9
            
            Rectangle(x: dimensions.wallThickness, y: trrsWallHole)
                .extruded(height: dimensions.maxThickness + dimensions.bottomSupportHeight - dimensions.minThickness)
                .translated(x: dimensions.maxX - dimensions.wallThickness, y: dimensions.wallThickness + dimensions.minTrrsY + dimensions.wallThickness / 2 - abs(trrs.openingDiameter - trrsWallHole) / 2, z: dimensions.minThickness + dimensions.bottomSupportHeight)
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
}
