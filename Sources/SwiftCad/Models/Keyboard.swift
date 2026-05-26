import Cadova

protocol Keyboard<Dimensions>: Shape3D {
    associatedtype Dimensions
    var dimensions: Dimensions { get }
    var microcontroller: MicrocontrollerDimensions { get }
    var trrs: TrrsDimensions { get }
}
