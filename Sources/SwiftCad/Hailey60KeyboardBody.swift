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
    private let thickness: Double = 1.6
    
    private let microcontroller: MicrocontrollerDimensions
    private let trrs: TrrsDimensions
    
    init(microcontrollerDimensions: MicrocontrollerDimensions, trrsDimensions: TrrsDimensions) {
        self.microcontroller = microcontrollerDimensions
        self.trrs = trrsDimensions
    }
    
    var body: any Geometry3D {
        Stack(.x, spacing: spacingBetweenSwitchHole, alignment: .top) {
            switchHolePolygons
            
            Stack(.y, spacing: outerSpacing, alignment: .right) {
                trrsPolygon
                
                microcontrollerPolygon
            }
        }
        .measuringBounds { holes, bounds in
            Rectangle(bounds.size)
                .aligned(at: .top)
                .offset(amount: outerSpacing, style: .square)
                .subtracting {
                    holes
                }
        }
        .aligned(at: .bottom, .left)
        .subtracting {
            // Subtract triangle from TRRS to bottom-right most key switch
            BezierPath2D(linesBetween: [
                Vector2D((switchHoleSize + spacingBetweenSwitchHole) * 6 + microcontroller.mainBody.x + outerSpacing * 2, (switchHoleSize + spacingBetweenSwitchHole) * 5 - spacingBetweenSwitchHole - outerSpacing - microcontroller.mainBody.y - 6),
                Vector2D((switchHoleSize + spacingBetweenSwitchHole) * 6 + microcontroller.mainBody.x + outerSpacing * 2, 0),
                Vector2D((switchHoleSize + spacingBetweenSwitchHole) * 6 - spacingBetweenSwitchHole + outerSpacing * 2, 0)
            ])
            .filled()
        }
        .extruded(height: thickness)
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
    
    private var microcontrollerPolygon: any Geometry2D {
        
        Rectangle(microcontroller.mainBody.xy)
    }
    
    private var trrsPolygon: any Geometry2D {
        Stack(.x, alignment: .center) {
            Rectangle(x: trrs.mainBody.y, y: trrs.mainBody.x)
            Rectangle(x: trrs.openingOverhang, y: trrs.openingDiameter)
        }
    }
}
