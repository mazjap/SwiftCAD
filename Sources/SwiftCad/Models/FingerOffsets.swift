import Cadova

struct FingerOffsets {
    let pinky: Double = 0.0
    var ring: Double
    var middle: Double
    var pointer: Double
    
    var orderedOffsets: [Double] {
        [pinky, ring, middle, pointer]
    }
    
    init(ring: Double = 20.5, middle: Double = 29.5, pointer: Double = 20.5) {
        self.ring = ring
        self.middle = middle
        self.pointer = pointer
    }
}
