// Generated using MetalSmith Version
// DO NOT EDIT

import MetalKit
import MetalSmith


struct ColorsEncoder {
    struct ArgumentEncoder: MetalSmith.ArgumentEncoder {
        let commandEncoder: MTLComputeCommandEncoder
        let computePipelineState: MTLComputePipelineState

        func image(_ image: MTLTexture?) {
            commandEncoder.setTexture(image, index: 0)
        }

        func time(_ time: MTLBuffer?, offset: Int = 0) {
            commandEncoder.setBuffer(time, offset: offset, index: 0)
        }

        func time(_ time: UnsafeRawPointer, length: Int) {
            commandEncoder.setBytes(time, length: length, index: 0)
        }

        func time(_ time: UnsafeBufferPointer<Float>) {
            if let baseAddress = time.baseAddress {
                self.time(baseAddress, length: time.count * MemoryLayout<Float>.stride)
            }
        }

        func time(_ time: Array<Float>) {
            time.withUnsafeBufferPointer {
                self.time($0)
            }
        }

        func time(_ time: Float) {
            var time = time
            commandEncoder.setBytes(&time, length: MemoryLayout<Float>.stride, index: 0)
        }

        func dispatch(width: Int = 1, height: Int = 1, depth: Int = 1) {
            let threadsPerGrid = MTLSize(width: width, height: height, depth: depth)
            dispatch(threadsPerGrid)
        }

        func dispatch(_ threadsPerGrid: MTLSize) {
            let threadGroupWidth = computePipelineState.maxTotalThreadsPerThreadgroup
            let threadsPerThreadgroup = MTLSizeMake(threadGroupWidth, 1, 1)

            commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            commandEncoder.endEncoding()
        }
    }

    let computePipelineState: MTLComputePipelineState

    init?(library: MTLLibrary) {
        if let function = library.makeFunction(name: "colors"),
            let computePipelineState = try? library.device.makeComputePipelineState(function: function) {
            self.computePipelineState = computePipelineState
        } else {
            return nil
        }
    }

    func commandBuffer(_ commandBuffer: MTLCommandBuffer) -> ArgumentEncoder? {
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.setComputePipelineState(computePipelineState)
            return ArgumentEncoder(commandEncoder: commandEncoder, computePipelineState: computePipelineState)
        }
        return nil
    }
}
struct AddArraysEncoder {
    struct ArgumentEncoder: MetalSmith.ArgumentEncoder {
        let commandEncoder: MTLComputeCommandEncoder
        let computePipelineState: MTLComputePipelineState

        func inA(_ inA: MTLBuffer?, offset: Int = 0) {
            commandEncoder.setBuffer(inA, offset: offset, index: 0)
        }

        func inA(_ inA: UnsafeRawPointer, length: Int) {
            commandEncoder.setBytes(inA, length: length, index: 0)
        }

        func inA(_ inA: UnsafeBufferPointer<Float>) {
            if let baseAddress = inA.baseAddress {
                self.inA(baseAddress, length: inA.count * MemoryLayout<Float>.stride)
            }
        }

        func inA(_ inA: Array<Float>) {
            inA.withUnsafeBufferPointer {
                self.inA($0)
            }
        }

        func inA(_ inA: Float) {
            var inA = inA
            commandEncoder.setBytes(&inA, length: MemoryLayout<Float>.stride, index: 0)
        }

        func inB(_ inB: MTLBuffer?, offset: Int = 0) {
            commandEncoder.setBuffer(inB, offset: offset, index: 1)
        }

        func inB(_ inB: UnsafeRawPointer, length: Int) {
            commandEncoder.setBytes(inB, length: length, index: 1)
        }

        func inB(_ inB: UnsafeBufferPointer<Float>) {
            if let baseAddress = inB.baseAddress {
                self.inB(baseAddress, length: inB.count * MemoryLayout<Float>.stride)
            }
        }

        func inB(_ inB: Array<Float>) {
            inB.withUnsafeBufferPointer {
                self.inB($0)
            }
        }

        func inB(_ inB: Float) {
            var inB = inB
            commandEncoder.setBytes(&inB, length: MemoryLayout<Float>.stride, index: 1)
        }

        func result(_ result: MTLBuffer?, offset: Int = 0) {
            commandEncoder.setBuffer(result, offset: offset, index: 2)
        }

        func result(_ result: UnsafeRawPointer, length: Int) {
            commandEncoder.setBytes(result, length: length, index: 2)
        }

        func result(_ result: UnsafeBufferPointer<Float>) {
            if let baseAddress = result.baseAddress {
                self.result(baseAddress, length: result.count * MemoryLayout<Float>.stride)
            }
        }

        func result(_ result: Array<Float>) {
            result.withUnsafeBufferPointer {
                self.result($0)
            }
        }

        func result(_ result: Float) {
            var result = result
            commandEncoder.setBytes(&result, length: MemoryLayout<Float>.stride, index: 2)
        }

        func dispatch(width: Int = 1, height: Int = 1, depth: Int = 1) {
            let threadsPerGrid = MTLSize(width: width, height: height, depth: depth)
            dispatch(threadsPerGrid)
        }

        func dispatch(_ threadsPerGrid: MTLSize) {
            let threadGroupWidth = computePipelineState.maxTotalThreadsPerThreadgroup
            let threadsPerThreadgroup = MTLSizeMake(threadGroupWidth, 1, 1)

            commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            commandEncoder.endEncoding()
        }
    }

    let computePipelineState: MTLComputePipelineState

    init?(library: MTLLibrary) {
        if let function = library.makeFunction(name: "add_arrays"),
            let computePipelineState = try? library.device.makeComputePipelineState(function: function) {
            self.computePipelineState = computePipelineState
        } else {
            return nil
        }
    }

    func commandBuffer(_ commandBuffer: MTLCommandBuffer) -> ArgumentEncoder? {
        if let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            commandEncoder.setComputePipelineState(computePipelineState)
            return ArgumentEncoder(commandEncoder: commandEncoder, computePipelineState: computePipelineState)
        }
        return nil
    }
}
