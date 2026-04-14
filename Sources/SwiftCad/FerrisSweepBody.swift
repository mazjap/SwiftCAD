import Cadova

//               _________
//         _____/ ┌─────┐ \________________
//   _____/ ┌─────┤     ├─────┬─────┐┌|  |┐\
//  / ┌─────┤     ├─────┤     |     ||    ||
//  | |     ├─────┤     ├─────┼─────┤|    ||
//  | ├─────┤     ├─────┤     |     |└────┘|
//  | |     ├─────┤     ├─────┼─────┤┌────┐|
//  | ├─────┤     ├─────┤     |     |└────┘|
//  | |     ├─────┘     └────┬┴────┬┴────┐ |
//  \ └─────┘                |     |     | |
//   \                       └─────┴─────┘ /
//    ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
// ┌─────┐
// |     | = A cherry mx keycap+switch
// └─────┘
// ┌────┐
// └────┘ = A TRRS female connector
//
// ┌|  |┐
// |    | = A microcontroller (presumably a promicro, but RP2040-zero or others will work)
// |    |
// └────┘

struct FerrisSweep: Shape3D {
    private let switchHoleSize: Double = 14
    private let spacingBetweenSwitchHole: Double = 5
    private let outerPadding: Double = 8
    
    // This is a rough estimation using my fingers when slightly curled (like when using a keyboard)
    let pinkyOffset = 0.0
    var ringOffset = 20.5
    var middleOffset = 29.5
    var pointerOffset = 20.5
    var otherOffset = 18.5
    
    private var columnVerticalOffsets: [Double] {
        [pinkyOffset, ringOffset, middleOffset, pointerOffset, otherOffset]
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
                    switchColumn(topLeft: Vector2D((switchHoleSize + spacingBetweenSwitchHole) * index, value))
                }
            
            switchShape(
                topLeft: Vector2D(
                    3.75 * (switchHoleSize + spacingBetweenSwitchHole),
                    otherOffset - 3 * (switchHoleSize + spacingBetweenSwitchHole)
                )
            )
            .rotated(.degrees(-10), around: .center)
            
            switchShape(
                topLeft: Vector2D(
                    4.8 * (switchHoleSize + spacingBetweenSwitchHole),
                    otherOffset - 3 * (switchHoleSize + spacingBetweenSwitchHole) - 6
                )
            )
            .rotated(.degrees(-20), around: .center)
        }
    }
    
    var outline: any Geometry2D {
        BezierPath(
            linesBetween: [
                Vector2D(switchOffsetForRowAt(index: 0) - outerPadding, pinkyOffset + outerPadding),
                Vector2D(switchOffsetForRowAt(index: 1) - outerPadding, ringOffset + outerPadding),
                Vector2D(switchOffsetForRowAt(index: 2) - outerPadding, middleOffset + outerPadding),
                Vector2D(switchOffsetForRowAt(index: 2) + switchHoleSize + outerPadding, middleOffset + outerPadding),
                Vector2D(switchOffsetForRowAt(index: 3) + switchHoleSize + outerPadding, pointerOffset + outerPadding),
                Vector2D(switchOffsetForRowAt(index: 4) + switchHoleSize + outerPadding, otherOffset + outerPadding)
            ] + []
        ).stroked(width: 1, style: .round)
    }
    
    private func switchShape(topLeft: Vector2D) -> any Geometry2D {
        BezierPath2D(linesBetween: [
            topLeft,
            Vector2D(x: topLeft.x + switchHoleSize, y: topLeft.y),
            Vector2D(x: topLeft.x + switchHoleSize, y: topLeft.y - switchHoleSize),
            Vector2D(x: topLeft.x, y: topLeft.y - switchHoleSize)
        ])
        .filled()
    }
    
    private func switchColumn(topLeft: Vector2D) -> any Geometry2D {
        Union(
            ([0, 1, 2] as [Double])
                .map {
                    switchShape(topLeft: Vector2D(topLeft.x, topLeft.y - (switchHoleSize + spacingBetweenSwitchHole) * $0))
                }
        )
    }
}

extension FerrisSweep {
    /// 0-indexed, left-most coordinate
    // →┌─────┐
    //  |     |
    //  └─────┘
    private func switchOffsetForRowAt(index: Int) -> Double {
        (switchHoleSize + spacingBetweenSwitchHole) * Double(index)
    }
    
    /// 0-indexed, top-most coordinate
    //  ↓
    //  ┌─────┐
    //  |     |
    //  └─────┘
    private func switchOffsetForColumnAt(index: Int, startingOffset: Double) -> Double {
        (switchHoleSize + spacingBetweenSwitchHole) * Double(index) + startingOffset
    }
    
    private func switchOffsetFor(row: Int, column: Int, startingVerticalOffset: Double) -> Vector2D {
        Vector2D(switchOffsetForRowAt(index: row), switchOffsetForColumnAt(index: column, startingOffset: startingVerticalOffset))
    }
}
