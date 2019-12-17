// Generated using SwiftMetal Version
// DO NOT EDIT

import MetalKit
import MetalSmith
import SwiftUI
import MetalSmithUI


struct AddArrays: CommandEncoder {
    var threadsPerGrid: MTLSize?

    var set_inA: ((AddArraysEncoder.ArgumentEncoder) -> Void)? = nil
    var set_inB: ((AddArraysEncoder.ArgumentEncoder) -> Void)? = nil
    var set_result: ((AddArraysEncoder.ArgumentEncoder) -> Void)? = nil

    func inA(_ inA: MTLBuffer?, offset: Int = 0) -> Self {
        var __result = self
        __result.set_inA = { argumentEncoder in
            argumentEncoder.inA(inA, offset: offset)
        }
        return __result
    }

    func inA(_ inA: UnsafeRawPointer, length: Int) -> Self {
        var __result = self
        __result.set_inA = { argumentEncoder in
            argumentEncoder.inA(inA, length: length)
        }
        return __result
    }

    func inA(_ inA: Float) -> Self {
        var __result = self
        __result.set_inA = { argumentEncoder in
            argumentEncoder.inA(inA)
        }
        return __result
    }

    func inB(_ inB: MTLBuffer?, offset: Int = 0) -> Self {
        var __result = self
        __result.set_inB = { argumentEncoder in
            argumentEncoder.inB(inB, offset: offset)
        }
        return __result
    }

    func inB(_ inB: UnsafeRawPointer, length: Int) -> Self {
        var __result = self
        __result.set_inB = { argumentEncoder in
            argumentEncoder.inB(inB, length: length)
        }
        return __result
    }

    func inB(_ inB: Float) -> Self {
        var __result = self
        __result.set_inB = { argumentEncoder in
            argumentEncoder.inB(inB)
        }
        return __result
    }

    func result(_ result: MTLBuffer?, offset: Int = 0) -> Self {
        var __result = self
        __result.set_result = { argumentEncoder in
            argumentEncoder.result(result, offset: offset)
        }
        return __result
    }

    func result(_ result: UnsafeRawPointer, length: Int) -> Self {
        var __result = self
        __result.set_result = { argumentEncoder in
            argumentEncoder.result(result, length: length)
        }
        return __result
    }

    func result(_ result: Float) -> Self {
        var __result = self
        __result.set_result = { argumentEncoder in
            argumentEncoder.result(result)
        }
        return __result
    }

    var body: some View {
        Text("add_arrays")
    }

    func encode(commandBuffer: MTLCommandBuffer, library: MTLLibrary) {
        let encoder = AddArraysEncoder(library: library)
        if let arguments = encoder?.commandBuffer(commandBuffer) {
            set_inA?(arguments)
            set_inB?(arguments)
            set_result?(arguments)
            arguments.dispatch(threadsPerGrid!)
        }
    }
}

struct Colors: CommandEncoder {
    var threadsPerGrid: MTLSize?

    var set_image: ((ColorsEncoder.ArgumentEncoder) -> Void)? = nil
    var set_time: ((ColorsEncoder.ArgumentEncoder) -> Void)? = nil

    func image(_ image: MTLTexture?) -> Self {
        var __result = self
        __result.set_image = { argumentEncoder in
            argumentEncoder.image(image)
        }
        return __result
    }

    func time(_ time: MTLBuffer?, offset: Int = 0) -> Self {
        var __result = self
        __result.set_time = { argumentEncoder in
            argumentEncoder.time(time, offset: offset)
        }
        return __result
    }

    func time(_ time: UnsafeRawPointer, length: Int) -> Self {
        var __result = self
        __result.set_time = { argumentEncoder in
            argumentEncoder.time(time, length: length)
        }
        return __result
    }

    func time(_ time: Float) -> Self {
        var __result = self
        __result.set_time = { argumentEncoder in
            argumentEncoder.time(time)
        }
        return __result
    }

    var body: some View {
        Text("colors")
    }

    func encode(commandBuffer: MTLCommandBuffer, library: MTLLibrary) {
        let encoder = ColorsEncoder(library: library)
        if let arguments = encoder?.commandBuffer(commandBuffer) {
            set_image?(arguments)
            set_time?(arguments)
            arguments.dispatch(threadsPerGrid!)
        }
    }
}

