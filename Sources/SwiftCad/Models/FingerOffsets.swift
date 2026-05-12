import Cadova

struct FingerOffsets {
    let pinky: Double = 0.0
    var ring: Double
    var middle: Double
    var pointer: Double
    
    var orderedOffsets: [Double] {
        NonThumbFinger.allCases.reversed().map(offset(for:))
    }
    
    func offset(for finger: NonThumbFinger) -> Double {
        switch finger {
        case .pinky: return pinky
        case .ring: return ring
        case .middle: return middle
        case .pointer: return pointer
        }
    }
    
    /// These are measured based on the height of your pinky. If the top of your pointer finger is 15mm above the tip of your pinky, use 15.0
    init(ring: Double, middle: Double, pointer: Double) {
        self.ring = ring
        self.middle = middle
        self.pointer = pointer
    }
    
    static let mine = FingerOffsets(ring: 20.5, middle: 29.5, pointer: 20.5)
}

enum NonThumbFinger: CaseIterable {
    case pointer
    case middle
    case ring
    case pinky
}
