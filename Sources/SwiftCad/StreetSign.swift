import Cadova

enum StreetSuffix: String {
    case street = "St"
    case avenue = "Ave"
    case boulevard = "Blvd"
    case road = "Rd"
    case way = "Way"
    case lane = "Ln"
    case drive = "Dr"
}

struct StreetSign: Shape3D {
    let text: String
    var suffix: StreetSuffix = .street
    
    private let textToStrokeVerticalSpacing: Double = 12
    private let textToStrokeHorizontalSpacing: Double = 16
    private let strokeToBorderSpacing: Double = 8
    
    var body: any Geometry3D {
        Stack(.x, spacing: 14, alignment: .top) {
            streetNameShape
            
            suffixTextShape
        }
        .measuringBounds { geometry, boundingBox in
            Stack(.z, alignment: .center) {
                baseShape(size: boundingBox.size)
                    .extruded(height: 3)
                    .withMaterial(.plain(.green))
                
                Union {
                    geometry
                        .aligned(at: .center)
                    
                    outerStroke(size: boundingBox.size)
                        .stroked(width: 2.15, alignment: .inside, style: .round)
                        .aligned(at: .center)
                }
                .extruded(height: 1.5)
                .withMaterial(.plain(.white))
            }
        }
    }
    
    private func baseShape(size: Vector2D) -> any Geometry2D {
        Rectangle(x: size.x + textToStrokeHorizontalSpacing + strokeToBorderSpacing, y: size.y + textToStrokeVerticalSpacing + strokeToBorderSpacing)
            .rounded(radius: 5)
    }
    
    private func outerStroke(size: Vector2D) -> any Geometry2D {
        Rectangle(x: size.x + textToStrokeHorizontalSpacing, y: size.y + textToStrokeVerticalSpacing)
            .rounded(radius: 5)
    }
    
    private var streetNameShape: any Geometry2D {
        Text(text)
            .withFontSize(34)
    }
    
    private var suffixTextShape: any Geometry2D {
        Text(suffix.rawValue)
            .withFontSize(20)
    }
}
