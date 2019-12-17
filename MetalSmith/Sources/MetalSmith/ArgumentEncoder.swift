import Foundation
import MetalKit

public protocol ArgumentEncoder {
    var commandEncoder: MTLComputeCommandEncoder { get }
    var computePipelineState: MTLComputePipelineState { get }

    func dispatch(width: Int, height: Int, depth: Int)
    func dispatch(_ threadsPerGrid: MTLSize)
}
