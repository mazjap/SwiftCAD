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

extension FerrisSweep {
    struct Dimensions {
        let switchHoleSize: Double = 14.1
        let spacingBetweenSwitchHole: Double = 5
        let minThickness: Double = 1.6
        let maxThickness: Double = 5.5
        let bottomSupportHeight: Double = 2
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
            self.thumbKeysXOffset = 3.6 * (switchHoleSize + spacingBetweenSwitchHole)
            
            self.microcontrollerMinX = otherMaxX + spacingBetweenSwitchHole
            self.microcontrollerMaxX = microcontrollerMinX + microcontroller.mainBody.x
            self.microcontrollerMaxY = otherMaxY
            self.microcontrollerMinY = microcontrollerMaxY - (microcontroller.usbOverhang + microcontroller.mainBody.y)
            
            self.trrsMaxX = microcontrollerMaxX
            self.trrsMinX = trrsMaxX - (trrs.mainBody.y + trrs.openingOverhang)
            self.trrsMaxY = microcontrollerMinY - spacingBetweenSwitchHole
            self.trrsMinY = trrsMaxY - (trrs.mainBody.x)
        }
    }
}

struct FerrisSweep: Shape3D {
    private let microcontroller: MicrocontrollerDimensions
    private let trrs: TrrsDimensions
    private let fingers: FingerOffsets
    private let dimensions: Dimensions
    
    init(microcontrollerDimensions: MicrocontrollerDimensions, trrsDimensions: TrrsDimensions, fingerOffsets: FingerOffsets) {
        self.microcontroller = microcontrollerDimensions
        self.trrs = trrsDimensions
        self.fingers = fingerOffsets
        self.dimensions = Dimensions(microcontroller: microcontrollerDimensions, trrs: trrsDimensions, fingers: fingerOffsets)
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
            .subtracting {
                columnBottomCutout
            }
    }
    
    private var switchHoles: any Geometry2D {
        Union {
            columnSwitchsShapes
            
            thumbClusterSwitchShapes
        }
    }
    
    private var columnSwitchsShapes: any Geometry2D {
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
    private var thumbClusterSwitchShapes: any Geometry2D {
        Rectangle(dimensions.switchHoleSize)
            .translated(x: dimensions.thumbKeysXOffset)
            .rotated(.degrees(-10), around: .center)
        
        Rectangle(dimensions.switchHoleSize)
            .translated(x: dimensions.thumbKeysXOffset + dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole, y: -5)
            .rotated(.degrees(-20), around: .center)
    }
    
    private var microcontrollerShape: any Geometry2D {
        Stack(.y, spacing: 0, alignment: .center) {
            Rectangle(x: microcontroller.mainBody.x, y: microcontroller.mainBody.y)
            
            Rectangle(x: microcontroller.usbWidth, y: microcontroller.usbOverhang)
        }
        .aligned(at: .bottom, .left)
    }
    
    private var trrsShape: any Geometry2D {
        Stack(.x, spacing: 0, alignment: .center) {
            Rectangle(x: trrs.mainBody.y, y: trrs.mainBody.x)
            
            Rectangle(x: trrs.openingOverhang, y: trrs.openingDiameter)
        }
        .aligned(at: .bottom, .left)
    }
    
    private var outline: any Geometry2D {
        let radius = dimensions.switchHoleSize / 2
        let hypotenuse = (radius * radius * 2).squareRoot()
        
        return BezierPath2D(startPoint: Vector2D(dimensions.pinkyMinX, dimensions.pinkyMinY))
            .addingLine(to: Vector2D(dimensions.pinkyMinX, dimensions.pinkyMaxY))
            .addingLine(to: Vector2D(dimensions.ringMinX, dimensions.ringMaxY))
            .addingLine(to: Vector2D(dimensions.middleMinX, dimensions.middleMaxY))
            .addingLine(to: Vector2D(dimensions.middleMaxX, dimensions.middleMaxY))
//            .addingLine(to: Vector2D(dimensions.pointerMaxX, dimensions.pointerMaxY)) // I think it looks a little better without the pointer finger vertex 🤷‍♂️
            .addingLine(to: Vector2D(dimensions.otherMaxX, dimensions.otherMaxY))
            // Microcontroller
            .addingLine(to: Vector2D(dimensions.microcontrollerMinX, dimensions.microcontrollerMaxY))
            .addingLine(to: Vector2D(dimensions.microcontrollerMaxX, dimensions.microcontrollerMaxY))
            .addingLine(to: Vector2D(dimensions.microcontrollerMaxX, dimensions.microcontrollerMinY))
            // TRRS
            .addingLine(to: Vector2D(dimensions.trrsMaxX, dimensions.trrsMaxY))
            .addingLine(to: Vector2D(dimensions.trrsMaxX, dimensions.trrsMinY))
            // Thank you precalc for teaching me trig haha 🙏
            .addingLine(to: Vector2D(dimensions.thumbKeysXOffset + dimensions.switchHoleSize * 1.5 + dimensions.spacingBetweenSwitchHole + cos(.degrees(45 - 20)) * hypotenuse, dimensions.switchHoleSize / 2 - 5 + sin(.degrees(45 - 20)) * hypotenuse))
            .addingLine(to: Vector2D(dimensions.thumbKeysXOffset + dimensions.switchHoleSize * 1.5 + dimensions.spacingBetweenSwitchHole + cos(.degrees(-45 - 20)) * hypotenuse, dimensions.switchHoleSize / 2 - 5 + sin(.degrees(-45 - 20)) * hypotenuse))
            .addingLine(to: Vector2D(dimensions.thumbKeysXOffset + dimensions.switchHoleSize * 1.5 + dimensions.spacingBetweenSwitchHole + cos(.degrees(-135 - 20)) * hypotenuse, dimensions.switchHoleSize / 2 - 5 + sin(.degrees(-135 - 20)) * hypotenuse))
            .addingLine(to: Vector2D(dimensions.thumbKeysXOffset + dimensions.switchHoleSize / 2 + cos(.degrees(-45 - 10)) * hypotenuse, dimensions.switchHoleSize / 2 + sin(.degrees(-45 - 10)) * hypotenuse))
            .addingLine(to: Vector2D(dimensions.thumbKeysXOffset + dimensions.switchHoleSize / 2 + cos(.degrees(-135 - 10)) * hypotenuse, dimensions.switchHoleSize / 2 + sin(.degrees(-135 - 10)) * hypotenuse))
            .addingLine(to: Vector2D(dimensions.pinkyMaxX, dimensions.pinkyMinY))
            .addingLine(to: Vector2D(dimensions.pinkyMinX, dimensions.pinkyMinY))
            .filled()
    }
    private var columnBottomCutout: any Geometry3D {
        Union {
            Stack(.x, spacing: dimensions.spacingBetweenSwitchHole) {
                for column in FerrisSweepColumn.allCases {
                    Rectangle(x: dimensions.switchHoleSize, y: dimensions.switchHoleSize * 3 + dimensions.spacingBetweenSwitchHole * 2 + dimensions.outerSpacing)
                        .translated(y: columnOffset(for: column) - dimensions.outerSpacing / 2)
                }
            }
            
            Rectangle(x: dimensions.switchHoleSize, y: dimensions.switchHoleSize + dimensions.outerSpacing)
                .translated(x: dimensions.thumbKeysXOffset, y: -dimensions.outerSpacing / 2)
                .rotated(.degrees(-10), around: .center)
            
            Rectangle(x: dimensions.switchHoleSize, y: dimensions.switchHoleSize + dimensions.outerSpacing)
                .translated(x: dimensions.thumbKeysXOffset + dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole, y: -5 - dimensions.outerSpacing / 2)
                .rotated(.degrees(-20), around: .center)
        }
        .extruded(height: dimensions.maxThickness - dimensions.minThickness)
    }
    
    private func columnOffset(for column: FerrisSweepColumn) -> Double {
        switch column {
        case let .finger(finger):
            fingers.offset(for: finger)
        case .other:
            dimensions.otherMinY
        }
    }
}
