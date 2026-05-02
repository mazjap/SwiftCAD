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

extension FerrisSweep {
    struct Dimensions {
        let switchHoleSize: Double = 14.1
        let spacingBetweenSwitchHole: Double = 5
        let minThickness: Double = 1.6
        let maxThickness: Double = 5.5
        let bottomSupportHeight: Double = 2.0
        
        let outerSpacing: Double
        let wallThickness: Double = 3
        
        init(microcontroller: MicrocontrollerDimensions, trrs: TrrsDimensions, fingers: FingerOffsets) {
            self.outerSpacing = spacingBetweenSwitchHole / 2
        }
    }
}

struct FerrisSweep: Shape3D {
    private let microcontroller: MicrocontrollerDimensions
    private let trrs: TrrsDimensions
    private let fingers: FingerOffsets
    private let dimensions: Dimensions
    
    private var extraColOffset: Double {
        fingers.pointer - 2
    }
    
    init(microcontrollerDimensions: MicrocontrollerDimensions, trrsDimensions: TrrsDimensions, fingerOffsets: FingerOffsets) {
        self.microcontroller = microcontrollerDimensions
        self.trrs = trrsDimensions
        self.fingers = fingerOffsets
        self.dimensions = Dimensions(microcontroller: microcontrollerDimensions, trrs: trrsDimensions, fingers: fingerOffsets)
    }
    
    private var columnVerticalOffsets: [Double] {
        [fingers.pinky, fingers.ring, fingers.middle, fingers.pointer, extraColOffset]
    }
    
    var body: any Geometry3D {
        Union {
            switchHoles
            
            outline
        }
        .extruded(height: 2)
    }
    
    var switchHoles: any Geometry2D {
        Union {
            columnVerticalOffsets.enumerated()
                .map { (Double($0), $1) }
                .map { (index, value) in
                    switchColumn(topLeft: Vector2D((dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole) * index, value))
                }
            
            switchShape(
                topLeft: Vector2D(
                    3.75 * (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole),
                    extraColOffset - 3 * (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole)
                )
            )
            .rotated(.degrees(-10), around: .center)
            
            switchShape(
                topLeft: Vector2D(
                    4.8 * (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole),
                    extraColOffset - 3 * (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole) - 6
                )
            )
            .rotated(.degrees(-20), around: .center)
        }
    }
    
    var outline: any Geometry2D {
        BezierPath(
            linesBetween: [
                Vector2D(switchOffsetForRowAt(index: 0) - dimensions.outerSpacing, fingers.pinky + dimensions.outerSpacing),
                Vector2D(switchOffsetForRowAt(index: 1) - dimensions.outerSpacing, fingers.ring + dimensions.outerSpacing),
                Vector2D(switchOffsetForRowAt(index: 2) - dimensions.outerSpacing, fingers.middle + dimensions.outerSpacing),
                Vector2D(switchOffsetForRowAt(index: 2) + dimensions.switchHoleSize + dimensions.outerSpacing, fingers.middle + dimensions.outerSpacing),
                Vector2D(switchOffsetForRowAt(index: 3) + dimensions.switchHoleSize + dimensions.outerSpacing, fingers.pointer + dimensions.outerSpacing),
                Vector2D(switchOffsetForRowAt(index: 4) + dimensions.switchHoleSize + dimensions.outerSpacing, extraColOffset + dimensions.outerSpacing)
            ] + []
        ).stroked(width: 1, style: .round)
    }
    
    private func switchShape(topLeft: Vector2D) -> any Geometry2D {
        BezierPath2D(linesBetween: [
            topLeft,
            Vector2D(x: topLeft.x + dimensions.switchHoleSize, y: topLeft.y),
            Vector2D(x: topLeft.x + dimensions.switchHoleSize, y: topLeft.y - dimensions.switchHoleSize),
            Vector2D(x: topLeft.x, y: topLeft.y - dimensions.switchHoleSize)
        ])
        .filled()
    }
    
    private func switchColumn(topLeft: Vector2D) -> any Geometry2D {
        Union(
            ([0, 1, 2] as [Double])
                .map {
                    switchShape(topLeft: Vector2D(topLeft.x, topLeft.y - (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole) * $0))
                }
        )
    }
}

extension FerrisSweep {
    /// 0-indexed, left-most coordinate
    // →┌────┐
    //  |    |
    //  └────┘
    private func switchOffsetForRowAt(index: Int) -> Double {
        (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole) * Double(index)
    }
    
    /// 0-indexed, top-most coordinate
    //  ↓
    //  ┌────┐
    //  |    |
    //  └────┘
    private func switchOffsetForColumnAt(index: Int, startingOffset: Double) -> Double {
        (dimensions.switchHoleSize + dimensions.spacingBetweenSwitchHole) * Double(index) + startingOffset
    }
    
    private func switchOffsetFor(row: Int, column: Int, startingVerticalOffset: Double) -> Vector2D {
        Vector2D(switchOffsetForRowAt(index: row), switchOffsetForColumnAt(index: column, startingOffset: startingVerticalOffset))
    }
}
