import Cadova

struct SwitchContainer: Shape3D {
    private let dimension = 82.0
    private let wallThickness = 3.0
    private let switchHoleSize = 14.1
    private let spacingBetweenSwitchHole = 5.0
    private let isFrame: Bool
    private let extraLidPadding = 0.8
    private let minThickness = 1.6
    
    init(isFrame: Bool) {
        self.isFrame = isFrame
    }
    
    var body: any Geometry3D {
        Union {
            if isFrame {
                frame
            } else {
                lid
            }
        }
    }
    
    var frame: any Geometry3D {
        Stack(.z) {
            base.offset(amount: wallThickness, style: .round)
                .extruded(height: wallThickness)
            
            base.stroked(width: wallThickness, alignment: .outside, style: .round)
                .extruded(height: dimension)
        }
    }
    
    var lid: any Geometry3D {
        Stack(.z, alignment: .center) {
            base.offset(amount: wallThickness * 2 + extraLidPadding / 2, style: .round)
                .subtracting {
                    Stack(.x, spacing: spacingBetweenSwitchHole) {
                        for _ in 1...3 {
                            Stack(.y, spacing: spacingBetweenSwitchHole) {
                                for _ in 1...3 {
                                    Rectangle(switchHoleSize)
                                }
                            }
                        }
                    }
                    .translated(x: (dimension - (switchHoleSize * 3 + spacingBetweenSwitchHole * 2)) / 2, y: (dimension - (switchHoleSize * 3 + spacingBetweenSwitchHole * 2)) / 2)
                }
                .extruded(height: wallThickness)
            
            base.offset(amount: wallThickness + extraLidPadding / 2, style: .round)
                .stroked(width: wallThickness, alignment: .outside, style: .round)
                .extruded(height: dimension / 12)
        }
        .subtracting {
            Stack(.x, spacing: spacingBetweenSwitchHole) {
                for _ in 1...3 {
                    Rectangle(x: switchHoleSize, y: 3 * (switchHoleSize + spacingBetweenSwitchHole))
                }
            }
            .extruded(height: wallThickness - minThickness)
            .aligned(at: .centerXY)
            .translated(z: minThickness)
        }
    }
    
    private var base: any Geometry2D {
        Rectangle(dimension)
    }
}
