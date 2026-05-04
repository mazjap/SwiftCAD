import Cadova

struct FingerOffsets {
    let pinky: Double = 0.0
    var ring: Double
    var middle: Double
    var pointer: Double
    
    var orderedOffsets: [Double] {
        [pinky, ring, middle, pointer]
    }
    
    /// These are measured based on the height of your pinky. If the top of your pointer finger is 15mm above the tip of your pinky, use 15.0
    init(ring: Double, middle: Double, pointer: Double) {
        self.ring = ring
        self.middle = middle
        self.pointer = pointer
    }
    
    static let mine = FingerOffsets(ring: 20.5, middle: 29.5, pointer: 20.5)
}
