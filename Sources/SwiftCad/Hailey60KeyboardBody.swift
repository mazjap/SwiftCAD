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

struct Hailey60KeyboardBody: Shape3D {
    private let switchHoleSize: Double = 14
    private let spacingBetweenSwitchHole: Double = 5
    private let outerSpacing: Double = 2.5
    private let minThickness: Double = 1.6
    private let maxThickness: Double = 5.5
    
    private let microcontroller: MicrocontrollerDimensions
    private let trrs: TrrsDimensions
    
    init(microcontrollerDimensions: MicrocontrollerDimensions, trrsDimensions: TrrsDimensions) {
        self.microcontroller = microcontrollerDimensions
        self.trrs = trrsDimensions
    }
    
    var body: any Geometry3D {
        Union {
            bounds
                .extruded(height: maxThickness)
                .aligned(at: .top)
                .subtracting {
                    switchHolePolygons
                        .extruded(height: minThickness)
                        .aligned(at: .top, .left, .front)
                }
                .aligned(at: .left, .front)
                .subtracting {
                    microcontrollerPolygon
                        .extruded(height: microcontroller.mainBody.z)
                        .aligned(at: .top, .left, .back)
                        .translated(
                            x: 6 * (switchHoleSize + spacingBetweenSwitchHole) + outerSpacing,
                            y: 5 * (switchHoleSize + spacingBetweenSwitchHole)
                        )
                }
                .subtracting {
                    trrsPolygon
                        .extruded(height: trrs.mainBody.z)
                        .aligned(at: .top, .left, .front)
                        .translated(
                            x: 6 * (switchHoleSize + spacingBetweenSwitchHole) + outerSpacing + microcontroller.mainBody.x - trrs.mainBody.y - trrs.openingOverhang + outerSpacing,
                            y: 5 * (switchHoleSize + spacingBetweenSwitchHole) - microcontroller.mainBody.y - microcontroller.usbOverhang - trrs.mainBody.x - spacingBetweenSwitchHole
                        )
                }
        }
    }
    
    private var switchHolePolygons: any Geometry2D {
        Stack(.y, spacing: spacingBetweenSwitchHole) {
            for _ in 0..<5 {
                Stack(.x, spacing: spacingBetweenSwitchHole) {
                    for _ in 0..<6 {
                        Rectangle(switchHoleSize)
                    }
                }
            }
        }
    }
    
    private var bounds: any Geometry2D {
        let minX = -outerSpacing
        let minY = -outerSpacing
        let maxSwitchX: Double = 6 * (switchHoleSize + spacingBetweenSwitchHole)
        let maxX = maxSwitchX + microcontroller.mainBody.x + outerSpacing
        let maxY = 5 * (switchHoleSize + spacingBetweenSwitchHole) - spacingBetweenSwitchHole + outerSpacing
        
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
                y: maxY - outerSpacing - microcontroller.mainBody.y - outerSpacing - trrs.mainBody.x - spacingBetweenSwitchHole - outerSpacing
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
            Rectangle(x: (microcontroller.mainBody.x + microcontroller.usbWidth) / 2, y: microcontroller.usbOverhang)
        }
    }
    
    private var trrsPolygon: any Geometry2D {
        Stack(.x, alignment: .center) {
            Rectangle(x: trrs.mainBody.y, y: trrs.mainBody.x)
            Rectangle(x: trrs.openingOverhang, y: trrs.openingDiameter)
        }
    }
}
