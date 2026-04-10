import Cadova
import Foundation

struct EasterEggOrnament: Shape3D {
    private var eggShape: any Geometry<D2> {
        Import(svg: URL(filePath: "SwiftCad_SwiftCad.bundle/Contents/Resources/src/egg.svg"))
            .scaled(0.4)
    }
    
    var body: any Geometry3D {
        Union {
            Ring(innerRadius: 1.5, thickness: 1.5)
                .translated(y: 1.5)
                .extruded(height: 3)
            
            Union {
                eggShape
                    .stroked(width: 2, alignment: .inside, style: .square)
                    .extruded(height: 4)
                
                
                Union {
                    Intersection {
                        eggShape
                        
                        InterpolatingCurve(through: (0...44).map { Vector2D(x: Double($0), y: 48 + sin(Double($0) * 0.9)) })
                            .stroked(width: 2)
                    }
                    
                    for i in 0...10 {
                        let fraction = Double(i) / 10
                        let x = fraction * 44 + 2.8
                        let y = 38.5
                        
                        Intersection {
                            eggShape
                            
                            Circle(diameter: 2)
                                .translated(x: x, y: y)
                        }
                    }
                    
                    Intersection {
                        eggShape
                        
                        InterpolatingCurve(through: (0...44).map { Vector2D(x: Double($0), y: 29 + sin(Double($0) * 1.2)) })
                            .stroked(width: 2)
                    }
                    
                        
                    for i in 0...10 {
                        let fraction = Double(i) / 10
                        let x = fraction * 44 + 2.6
                        let y = 19.5
                        
                        Intersection {
                            eggShape
                            
                            Circle(diameter: 2)
                                .translated(x: x, y: y)
                        }
                    }
                    
                    Intersection {
                        eggShape
                        
                        InterpolatingCurve(through: (0...44).map { Vector2D(x: Double($0) + 2.4, y: 10 + sin(Double($0) * 0.7)) })
                            .stroked(width: 2)
                    }
                }
                .extruded(height: 3.5)
                
                eggShape
                    .extruded(height: 2)
            }
            .aligned(at: .bottom, .centerX, .maxY)
        }
    }
}
