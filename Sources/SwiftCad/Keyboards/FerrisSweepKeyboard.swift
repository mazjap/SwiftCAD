import Cadova

//             ________
//        ____/ ┌────┐ \_____________
//   ____/ ┌────┤    ├────┬────┐┌| |┐\
//  / ┌────┤    ├────┤    |    ||   ||
//  | |    ├────┤    ├────┼────┤|   ||
//  | ├────┤    ├────┤    |    |└───┘|
//  | |    ├────┤    ├────┼────┤┌───┐|
//  | ├────┤    ├────┤    |    |└───┘|
//  | |    ├────┘    └───┬┴───┬┴───┐ |
//  \ └────┘             |    |    | |
//   \                   └────┴────┘ /
//    ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
// ┌────┐
// |    | = A cherry mx keycap+switch
// └────┘
// ┌───┐
// └───┘ = A TRRS female connector
//
// ┌| |┐
// |   | = A microcontroller (I'm using a promicro, but RP2040-zero or others will work)
// |   |
// └───┘

enum FerrisSweepColumn: CaseIterable {
    case finger(NonThumbFinger)
    case other
    
    static let allCases: [FerrisSweepColumn] = NonThumbFinger.allCases.reversed().map(FerrisSweepColumn.finger) + [.other]
}

struct FerrisSweepDimensions: KeyboardDimensions {
    let switchHoleSize: Double = 14.1
    let spacingBetweenSwitchHole: Double = 5
    let minThickness: Double = 1.6
    let maxThickness: Double = 5.5
    let bottomSupportHeight: Double = 3.5
    let wallThickness: Double = 3
    
    let outerSpacing: Double
    
    let pinkyMinX: Double,   pinkyMaxX: Double,   pinkyMinY: Double,   pinkyMaxY: Double
    let ringMinX: Double,    ringMaxX: Double,    ringMinY: Double,    ringMaxY: Double
    let middleMinX: Double,  middleMaxX: Double,  middleMinY: Double,  middleMaxY: Double
    let pointerMinX: Double, pointerMaxX: Double, pointerMinY: Double, pointerMaxY: Double
    let otherMinX: Double,   otherMaxX: Double,   otherMinY: Double,   otherMaxY: Double
    
    let columnVerticalOffsets: [Double]
    let thumbKeysXOffset: Double
    
    let microcontrollerMinX: Double, microcontrollerMaxX: Double, microcontrollerMinY: Double, microcontrollerMaxY: Double
    let trrsMinX: Double, trrsMaxX: Double, trrsMinY: Double, trrsMaxY: Double
    
    let maxX: Double
    
    init(microcontroller: MicrocontrollerDimensions, trrs: TrrsDimensions, fingers: FingerOffsets) {
        self.outerSpacing = spacingBetweenSwitchHole / 2
        
        let colHeight = 3 * switchHoleSize + 2 * spacingBetweenSwitchHole
        
        self.pinkyMinX = 0
        self.pinkyMaxX = pinkyMinX + switchHoleSize
        self.pinkyMinY = fingers.pinky
        self.pinkyMaxY = pinkyMinY + colHeight
        
        self.ringMinX = pinkyMaxX + spacingBetweenSwitchHole
        self.ringMaxX = ringMinX + switchHoleSize
        self.ringMinY = fingers.ring
        self.ringMaxY = ringMinY + colHeight
        
        self.middleMinX = ringMaxX + spacingBetweenSwitchHole
        self.middleMaxX = middleMinX + switchHoleSize
        self.middleMinY = fingers.middle
        self.middleMaxY = middleMinY + colHeight
        
        self.pointerMinX = middleMaxX + spacingBetweenSwitchHole
        self.pointerMaxX = pointerMinX + switchHoleSize
        self.pointerMinY = fingers.pointer
        self.pointerMaxY = pointerMinY + colHeight
        
        self.otherMinX = pointerMaxX + spacingBetweenSwitchHole
        self.otherMaxX = otherMinX + switchHoleSize
        self.otherMinY = fingers.pointer - 2
        self.otherMaxY = otherMinY + colHeight
        
        self.columnVerticalOffsets = fingers.orderedOffsets + [otherMinY]
        self.thumbKeysXOffset = 3.8 * (switchHoleSize + spacingBetweenSwitchHole)
        
        self.microcontrollerMinX = otherMaxX + spacingBetweenSwitchHole
        self.microcontrollerMaxX = microcontrollerMinX + microcontroller.mainBody.x
        self.microcontrollerMaxY = otherMaxY
        self.microcontrollerMinY = microcontrollerMaxY - (microcontroller.usbOverhang + microcontroller.mainBody.y)
        
        self.trrsMaxX = microcontrollerMaxX
        self.trrsMinX = trrsMaxX - (trrs.mainBody.y + trrs.openingOverhang)
        self.trrsMaxY = microcontrollerMinY - spacingBetweenSwitchHole
        self.trrsMinY = trrsMaxY - (trrs.mainBody.x)
        
        self.maxX = microcontrollerMaxX + outerSpacing
    }
}

fileprivate protocol FerrisSweep: Keyboard<FerrisSweepDimensions> {
    var fingers: FingerOffsets { get }
}

extension Rectangle {
    static func from(properties props: RectangleProperties) -> any Geometry2D {
        Rectangle(props.size)
            .translated(x: props.offset.x, y: props.offset.y)
            .rotated(props.rotation, around: .center)
    }
}

struct RectangleProperties { // Thank you precalc for teaching me trig haha 🙏
    let offset: Vector2D
    let rotation: Angle
    let size: Double // I don't want to consider an oval right now 😅 So circles only for now haha
    
    private var hypotenuse: Double {
        let radius = size / 2
        return (radius * radius * 2).squareRoot()
    }
    
    var topRight: Vector2D { // Q1, pre-rotation
        Vector2D(offset.x + size / 2 + cos(.degrees(45) + rotation) * hypotenuse, offset.y + size / 2 + sin(.degrees(45) + rotation) * hypotenuse)
    }
    
    var topLeft: Vector2D { // Q2, pre-rotation
        Vector2D(offset.x + size / 2 + cos(.degrees(135) + rotation) * hypotenuse, offset.y + size / 2 + sin(.degrees(135) + rotation) * hypotenuse)
    }
    
    var bottomRight: Vector2D { // Q4, pre-rotation
        Vector2D(offset.x + size / 2 + cos(.degrees(-45) + rotation) * hypotenuse, offset.y + size / 2 + sin(.degrees(-45) + rotation) * hypotenuse)
    }
    
    var bottomLeft: Vector2D { // Q3, pre-rotation
        Vector2D(offset.x + size / 2 + cos(.degrees(-135) + rotation) * hypotenuse, offset.y + size / 2 + sin(.degrees(-135) + rotation) * hypotenuse)
    }
}

extension FerrisSweep {
    var latches: any Geometry3D {
        Union {
            let bottomMidPoint = Vector2D(dimensions.switchHoleSize, -dimensions.outerSpacing)
                .point(alongLineTo: Vector2D(firstThumbSwitchHole.bottomLeft.x, firstThumbSwitchHole.bottomLeft.y - dimensions.outerSpacing), at: 0.5)
            
            latchAttachedTo(edge: .top)
                .rotated(.degrees(-4.5), around: .z) // TODO: - Fix hardcoded angle
                .translated(x: bottomMidPoint.x, y: bottomMidPoint.y)
            
            latchAttachedTo(edge: .left)
                .translated(x: -dimensions.outerSpacing, y: dimensions.pinkyMaxY / 2)
            
            latchAttachedTo(edge: .right)
                .translated(x: dimensions.maxX, y: dimensions.microcontrollerMinY + dimensions.outerSpacing)
            
            latchAttachedTo(edge: .bottom)
                .translated(x: dimensions.switchHoleSize * 2.5 + dimensions.spacingBetweenSwitchHole * 2, y: dimensions.middleMaxY + dimensions.outerSpacing)
        }
        .translated(z: dimensions.bottomSupportHeight + dimensions.minThickness)
    }
    
    fileprivate var firstThumbSwitchHole: RectangleProperties {
        RectangleProperties(
            offset: Vector2D(x: dimensions.thumbKeysXOffset, y: -6),
            rotation: .degrees(-10),
            size: dimensions.switchHoleSize
        )
    }
    
    fileprivate var secondThumbSwitchHole: RectangleProperties {
        RectangleProperties(
            offset: Vector2D(x: dimensions.thumbKeysXOffset + (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole) * 1.05, y: -12),
            rotation: .degrees(-20),
            size: dimensions.switchHoleSize
        )
    }
    
    fileprivate var switchHoles: any Geometry2D {
        Union {
            columnSwitchsShapes
            
            thumbClusterSwitchShapes
        }
    }
    
    fileprivate var columnSwitchsShapes: any Geometry2D {
        Stack(.x, spacing: dimensions.spacingBetweenSwitchHole) {
            for offset in dimensions.columnVerticalOffsets {
                Stack(.y, spacing: dimensions.spacingBetweenSwitchHole) {
                    for _ in 1...3 {
                        Rectangle(dimensions.switchHoleSize)
                    }
                }
                .translated(y: offset)
            }
        }
    }
    
    @GeometryBuilder2D
    fileprivate var thumbClusterSwitchShapes: any Geometry2D {
        Rectangle.from(properties: firstThumbSwitchHole)
        
        Rectangle.from(properties: secondThumbSwitchHole)
    }
    
    fileprivate var microcontrollerShape: any Geometry2D {
        Stack(.y, spacing: 0, alignment: .center) {
            Rectangle(x: microcontroller.mainBody.x, y: microcontroller.mainBody.y)
            
            Rectangle(x: microcontroller.usbWidth, y: microcontroller.usbOverhang)
        }
        .aligned(at: .bottom, .left)
    }
    
    fileprivate var trrsShape: any Geometry2D {
        Stack(.x, spacing: 0, alignment: .center) {
            Rectangle(x: trrs.mainBody.y, y: trrs.mainBody.x)
            
            Rectangle(x: trrs.openingOverhang, y: trrs.openingDiameter)
        }
        .aligned(at: .bottom, .left)
    }
    
    func isPointLeftOfLine(lineStart: Vector2D, lineEnd: Vector2D, point: Vector2D) -> Bool {
        return (lineEnd.x - lineStart.x) * (point.y - lineStart.y) - (lineEnd.y - lineStart.y) * (point.x - lineStart.x) > 0
    }
    
    fileprivate var outline: any Geometry2D {
        var path = BezierPath2D(startPoint: Vector2D(dimensions.pinkyMinX, dimensions.pinkyMinY))
            .addingLine(to: Vector2D(dimensions.pinkyMinX, dimensions.pinkyMaxY))
            .addingLine(to: Vector2D(dimensions.ringMinX, dimensions.ringMaxY))
            .addingLine(to: Vector2D(dimensions.middleMinX, dimensions.middleMaxY))
            .addingLine(to: Vector2D(dimensions.middleMaxX, dimensions.middleMaxY))
        
        if isPointLeftOfLine(lineStart: Vector2D(x: dimensions.middleMaxX, y: dimensions.middleMaxY), lineEnd: Vector2D(x: dimensions.otherMaxX, y: dimensions.otherMaxY), point: Vector2D(x: dimensions.pointerMaxX, y: dimensions.pointerMaxY)) {
            path = path.addingLine(to: Vector2D(dimensions.pointerMaxX, dimensions.pointerMaxY))
        }
        
        return path
            .addingLine(to: Vector2D(dimensions.otherMaxX, dimensions.otherMaxY))
            // Microcontroller
            .addingLine(to: Vector2D(dimensions.microcontrollerMinX, dimensions.microcontrollerMaxY))
            .addingLine(to: Vector2D(dimensions.microcontrollerMaxX, dimensions.microcontrollerMaxY))
            .addingLine(to: Vector2D(dimensions.microcontrollerMaxX, dimensions.microcontrollerMinY))
            // TRRS
            .addingLine(to: Vector2D(dimensions.trrsMaxX, dimensions.trrsMaxY))
            .addingLine(to: Vector2D(dimensions.trrsMaxX, dimensions.trrsMinY))
            // Thumb Cluster
            .addingLine(to: secondThumbSwitchHole.topRight)
            .addingLine(to: secondThumbSwitchHole.bottomRight)
            .addingLine(to: secondThumbSwitchHole.bottomLeft)
            .addingLine(to: firstThumbSwitchHole.bottomRight)
            .addingLine(to: firstThumbSwitchHole.bottomLeft)
            // Back to start
            .addingLine(to: Vector2D(dimensions.pinkyMaxX, dimensions.pinkyMinY))
            .addingLine(to: Vector2D(dimensions.pinkyMinX, dimensions.pinkyMinY))
            .filled()
    }
    
    fileprivate var columnBottomCutout: any Geometry3D {
        Union {
            Stack(.x, spacing: dimensions.spacingBetweenSwitchHole) {
                for column in FerrisSweepColumn.allCases {
                    Rectangle(x: dimensions.switchHoleSize, y: dimensions.switchHoleSize * 3 + dimensions.spacingBetweenSwitchHole * 2 + dimensions.outerSpacing)
                        .translated(y: columnOffset(for: column) - dimensions.outerSpacing / 2)
                }
            }
            
            Rectangle(x: dimensions.switchHoleSize, y: dimensions.switchHoleSize + dimensions.outerSpacing)
                .translated(x: firstThumbSwitchHole.offset.x, y: firstThumbSwitchHole.offset.y - dimensions.outerSpacing / 2)
                .rotated(firstThumbSwitchHole.rotation, around: .center)
            
            Rectangle(x: dimensions.switchHoleSize, y: dimensions.switchHoleSize + dimensions.outerSpacing)
                .translated(x: secondThumbSwitchHole.offset.x, y: secondThumbSwitchHole.offset.y - dimensions.outerSpacing / 2)
                .rotated(secondThumbSwitchHole.rotation, around: .center)
        }
        .extruded(height: dimensions.maxThickness - dimensions.minThickness)
    }
    
    fileprivate func columnOffset(for column: FerrisSweepColumn) -> Double {
        switch column {
        case let .finger(finger):
            fingers.offset(for: finger)
        case .other:
            dimensions.otherMinY
        }
    }
}

struct FerrisSweepPlate: FerrisSweep {
    let microcontroller: MicrocontrollerDimensions
    let trrs: TrrsDimensions
    let fingers: FingerOffsets
    let dimensions: FerrisSweepDimensions
    
    init(microcontrollerDimensions: MicrocontrollerDimensions, trrsDimensions: TrrsDimensions, fingerOffsets: FingerOffsets) {
        self.microcontroller = microcontrollerDimensions
        self.trrs = trrsDimensions
        self.fingers = fingerOffsets
        self.dimensions = FerrisSweepDimensions(microcontroller: microcontrollerDimensions, trrs: trrsDimensions, fingers: fingerOffsets)
    }
    
    var body: any Geometry3D {
        outline
            .offset(amount: dimensions.outerSpacing, style: .round)
            .subtracting {
                switchHoles
                
                microcontrollerShape
                    .translated(x: dimensions.microcontrollerMinX, y: dimensions.microcontrollerMinY + dimensions.outerSpacing)
                
                trrsShape
                    .translated(x: dimensions.trrsMinX + dimensions.outerSpacing, y: dimensions.trrsMinY)
            }
            .extruded(height: dimensions.maxThickness)
            .adding {
                Rectangle(x: microcontroller.mainBody.x, y: 1.5)
                    .extruded(height: dimensions.maxThickness - microcontroller.mainBody.z)
                    .translated(x: dimensions.microcontrollerMinX, y: dimensions.microcontrollerMinY + dimensions.outerSpacing, z: 0)
                
                Rectangle(x: microcontroller.usbWidth, y: microcontroller.usbOverhang)
                    .extruded(height: dimensions.maxThickness - 0.4)
                    .translated(x: dimensions.microcontrollerMinX + (microcontroller.mainBody.x - microcontroller.usbWidth) / 2, y: dimensions.microcontrollerMaxY + dimensions.outerSpacing - microcontroller.usbOverhang, z: 0)
                
                Rectangle(x: 1.5, y: trrs.mainBody.x / 2)
                    .extruded(height: 1)
                    .translated(x: dimensions.trrsMinX + dimensions.outerSpacing, y: dimensions.trrsMinY + (trrs.mainBody.x / 4), z: 0)
                
                Rectangle(x: trrs.openingOverhang, y: trrs.mainBody.x)
                    .extruded(height: (trrs.mainBody.z - trrs.openingDiameter) / 2 + 1)
                    .translated(x: dimensions.maxX - trrs.openingOverhang, y: dimensions.trrsMinY, z: 0)
            }
            .subtracting {
                columnBottomCutout
            }
            .subtracting {
                deadSpaceCutoutUnderFingers
                    .extruded(height: dimensions.maxThickness - dimensions.minThickness)
            }
            .translated(z: dimensions.bottomSupportHeight + dimensions.minThickness)
            .adding {
                latches
            }
    }
    
    private var deadSpaceCutoutUnderFingers: any Geometry2D {
        BezierPath(startPoint: Vector2D(dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole, -dimensions.outerSpacing / 2))
            .addingLine(to: Vector2D(firstThumbSwitchHole.bottomLeft.x - dimensions.spacingBetweenSwitchHole, firstThumbSwitchHole.bottomLeft.y - dimensions.outerSpacing / 2))
            .addingLine(to: Vector2D(firstThumbSwitchHole.topLeft.x - dimensions.spacingBetweenSwitchHole, dimensions.pointerMinY - dimensions.spacingBetweenSwitchHole))
            .addingLine(to: Vector2D(dimensions.middleMaxX, dimensions.pointerMinY - dimensions.spacingBetweenSwitchHole))
            .addingLine(to: Vector2D(dimensions.middleMaxX, dimensions.middleMinY - dimensions.spacingBetweenSwitchHole))
            .addingLine(to: Vector2D(dimensions.middleMinX, dimensions.middleMinY - dimensions.spacingBetweenSwitchHole))
            .addingLine(to: Vector2D(dimensions.middleMinX, dimensions.ringMinY - dimensions.spacingBetweenSwitchHole))
            .addingLine(to: Vector2D(dimensions.ringMinX, dimensions.ringMinY - dimensions.spacingBetweenSwitchHole))
            .filled()
    }
}

struct FerrisSweepCase: FerrisSweep {
    let microcontroller: MicrocontrollerDimensions
    let trrs: TrrsDimensions
    let fingers: FingerOffsets
    let dimensions: FerrisSweepDimensions
    
    init(microcontrollerDimensions: MicrocontrollerDimensions, trrsDimensions: TrrsDimensions, fingerOffsets: FingerOffsets) {
        self.microcontroller = microcontrollerDimensions
        self.trrs = trrsDimensions
        self.fingers = fingerOffsets
        self.dimensions = FerrisSweepDimensions(microcontroller: microcontrollerDimensions, trrs: trrsDimensions, fingers: fingerOffsets)
    }
    
    var body: any Geometry3D {
        let border = outline.offset(amount: dimensions.outerSpacing, style: .round)
        Union {
            // Bottom plate
            border.fillingHoles()
                .extruded(height: dimensions.minThickness + dimensions.bottomSupportHeight)
                .subtracting {
                    // Where the keyboard plate rests
                    border.fillingHoles()
                        .offset(amount: -1.5, style: .square)
                        .extruded(height: dimensions.bottomSupportHeight)
                        .translated(z: dimensions.minThickness)
                }
            
            // Key supports
            Stack(.x, spacing: dimensions.switchHoleSize) {
                for columnOffset in dimensions.columnVerticalOffsets.dropLast() {
                    Stack(.y, spacing: dimensions.switchHoleSize) {
                        for _ in 1..<3 {
                            Rectangle(x: dimensions.spacingBetweenSwitchHole, y: dimensions.spacingBetweenSwitchHole)
                        }
                    }
                    .translated(y: columnOffset)
                }
            }
            .extruded(height: dimensions.bottomSupportHeight + dimensions.minThickness)
            .translated(x: dimensions.switchHoleSize, y: dimensions.switchHoleSize)
            
            // Case wall
            let filletRadius = dimensions.wallThickness / 2
            
            border
                .stroked(width: dimensions.wallThickness, alignment: .outside, style: .round)
                .extruded(height: dimensions.minThickness + dimensions.bottomSupportHeight + dimensions.maxThickness, topEdge: .fillet(radius: filletRadius))
            
            border
                .stroked(width: filletRadius, alignment: .outside, style: .round)
                .extruded(height: dimensions.minThickness + dimensions.bottomSupportHeight + dimensions.maxThickness)
        }
        .subtracting {
            let microcontrollerWallHole: Double = 13
            
            Rectangle(
                x: microcontrollerWallHole,
                y: dimensions.wallThickness
            )
            .extruded(height: dimensions.maxThickness)
            .translated(x: dimensions.microcontrollerMinX + (microcontroller.mainBody.x - microcontrollerWallHole) / 2, y: dimensions.microcontrollerMaxY + dimensions.outerSpacing, z: dimensions.minThickness + dimensions.bottomSupportHeight)
        }
        .subtracting {
            let trrsWallHole: Double = 9
            
            Rectangle(x: dimensions.wallThickness, y: trrsWallHole)
                .extruded(height: dimensions.maxThickness + dimensions.bottomSupportHeight - dimensions.minThickness)
                .translated(x: dimensions.maxX, y: dimensions.trrsMinY - (trrsWallHole - trrs.mainBody.x) / 2, z: dimensions.minThickness + dimensions.bottomSupportHeight)
        }
        .subtracting {
            latches
        }
    }
}
