// Generated using MetalSmith Version
// DO NOT EDIT

import MetalKit
import MetalSmith
import SwiftUI
import MetalSmithUI


struct Colors: CommandEncoder {
    var threadsPerGrid: MTLSize?

    var set_image: ((ColorsEncoder.ArgumentEncoder) -> Void)? = nil
    var view_image: AnyView? = nil
    var set_time: ((ColorsEncoder.ArgumentEncoder) -> Void)? = nil
    var view_time: AnyView? = nil

    func image(_ image: MTLTexture?) -> Self {
        var __result = self
        __result.set_image = { argumentEncoder in
            argumentEncoder.image(image)
        }
        __result.view_image = AnyView(MiniTexture(image))
        return __result
    }

    func time(_ time: MTLBuffer?, offset: Int = 0) -> Self {
        var __result = self
        __result.set_time = { argumentEncoder in
            argumentEncoder.time(time, offset: offset)
        }
        __result.view_time = AnyView(MiniBuffer(time))
        return __result
    }

    func time(_ time: UnsafeRawPointer, length: Int) -> Self {
        var __result = self
        __result.set_time = { argumentEncoder in
            argumentEncoder.time(time, length: length)
        }
        let start = time.bindMemory(to: Float.self, capacity: length)
        let buffer = UnsafeBufferPointer(start: start, count: length / MemoryLayout<Float>.stride)
        let array = Array(buffer)
        __result.view_time = AnyView(Text(String(describing: array)))
        return __result
    }

    func time(_ time: UnsafeBufferPointer<Float>) -> Self {
        var __result = self
        __result.set_time = { argumentEncoder in
            argumentEncoder.time(time)
        }
        let array = Array(time)
        __result.view_time = AnyView(Text(String(describing: array)))
        return __result
    }

    func time(_ time: Array<Float>) -> Self {
        var __result = self
        __result.set_time = { argumentEncoder in
            argumentEncoder.time(time)
        }
        __result.view_time = AnyView(Text(String(describing: time)))
        return __result
    }

    func time(_ time: Float) -> Self {
        var __result = self
        __result.set_time = { argumentEncoder in
            argumentEncoder.time(time)
        }
        __result.view_time = AnyView(Text("\(time)"))
        return __result
    }

    var body: some View {
        HStack {
            Text("colors")
            Spacer()
            view_image
            view_time
        }
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

struct AddArrays: CommandEncoder {
    var threadsPerGrid: MTLSize?

    var set_inA: ((AddArraysEncoder.ArgumentEncoder) -> Void)? = nil
    var view_inA: AnyView? = nil
    var set_inB: ((AddArraysEncoder.ArgumentEncoder) -> Void)? = nil
    var view_inB: AnyView? = nil
    var set_result: ((AddArraysEncoder.ArgumentEncoder) -> Void)? = nil
    var view_result: AnyView? = nil

    func inA(_ inA: MTLBuffer?, offset: Int = 0) -> Self {
        var __result = self
        __result.set_inA = { argumentEncoder in
            argumentEncoder.inA(inA, offset: offset)
        }
        __result.view_inA = AnyView(MiniBuffer(inA))
        return __result
    }

    func inA(_ inA: UnsafeRawPointer, length: Int) -> Self {
        var __result = self
        __result.set_inA = { argumentEncoder in
            argumentEncoder.inA(inA, length: length)
        }
        let start = inA.bindMemory(to: Float.self, capacity: length)
        let buffer = UnsafeBufferPointer(start: start, count: length / MemoryLayout<Float>.stride)
        let array = Array(buffer)
        __result.view_inA = AnyView(Text(String(describing: array)))
        return __result
    }

    func inA(_ inA: UnsafeBufferPointer<Float>) -> Self {
        var __result = self
        __result.set_inA = { argumentEncoder in
            argumentEncoder.inA(inA)
        }
        let array = Array(inA)
        __result.view_inA = AnyView(Text(String(describing: array)))
        return __result
    }

    func inA(_ inA: Array<Float>) -> Self {
        var __result = self
        __result.set_inA = { argumentEncoder in
            argumentEncoder.inA(inA)
        }
        __result.view_inA = AnyView(Text(String(describing: inA)))
        return __result
    }

    func inA(_ inA: Float) -> Self {
        var __result = self
        __result.set_inA = { argumentEncoder in
            argumentEncoder.inA(inA)
        }
        __result.view_inA = AnyView(Text("\(inA)"))
        return __result
    }

    func inB(_ inB: MTLBuffer?, offset: Int = 0) -> Self {
        var __result = self
        __result.set_inB = { argumentEncoder in
            argumentEncoder.inB(inB, offset: offset)
        }
        __result.view_inB = AnyView(MiniBuffer(inB))
        return __result
    }

    func inB(_ inB: UnsafeRawPointer, length: Int) -> Self {
        var __result = self
        __result.set_inB = { argumentEncoder in
            argumentEncoder.inB(inB, length: length)
        }
        let start = inB.bindMemory(to: Float.self, capacity: length)
        let buffer = UnsafeBufferPointer(start: start, count: length / MemoryLayout<Float>.stride)
        let array = Array(buffer)
        __result.view_inB = AnyView(Text(String(describing: array)))
        return __result
    }

    func inB(_ inB: UnsafeBufferPointer<Float>) -> Self {
        var __result = self
        __result.set_inB = { argumentEncoder in
            argumentEncoder.inB(inB)
        }
        let array = Array(inB)
        __result.view_inB = AnyView(Text(String(describing: array)))
        return __result
    }

    func inB(_ inB: Array<Float>) -> Self {
        var __result = self
        __result.set_inB = { argumentEncoder in
            argumentEncoder.inB(inB)
        }
        __result.view_inB = AnyView(Text(String(describing: inB)))
        return __result
    }

    func inB(_ inB: Float) -> Self {
        var __result = self
        __result.set_inB = { argumentEncoder in
            argumentEncoder.inB(inB)
        }
        __result.view_inB = AnyView(Text("\(inB)"))
        return __result
    }

    func result(_ result: MTLBuffer?, offset: Int = 0) -> Self {
        var __result = self
        __result.set_result = { argumentEncoder in
            argumentEncoder.result(result, offset: offset)
        }
        __result.view_result = AnyView(MiniBuffer(result))
        return __result
    }

    func result(_ result: UnsafeRawPointer, length: Int) -> Self {
        var __result = self
        __result.set_result = { argumentEncoder in
            argumentEncoder.result(result, length: length)
        }
        let start = result.bindMemory(to: Float.self, capacity: length)
        let buffer = UnsafeBufferPointer(start: start, count: length / MemoryLayout<Float>.stride)
        let array = Array(buffer)
        __result.view_result = AnyView(Text(String(describing: array)))
        return __result
    }

    func result(_ result: UnsafeBufferPointer<Float>) -> Self {
        var __result = self
        __result.set_result = { argumentEncoder in
            argumentEncoder.result(result)
        }
        let array = Array(result)
        __result.view_result = AnyView(Text(String(describing: array)))
        return __result
    }

    func result(_ result: Array<Float>) -> Self {
        var __result = self
        __result.set_result = { argumentEncoder in
            argumentEncoder.result(result)
        }
        __result.view_result = AnyView(Text(String(describing: result)))
        return __result
    }

    func result(_ result: Float) -> Self {
        var __result = self
        __result.set_result = { argumentEncoder in
            argumentEncoder.result(result)
        }
        __result.view_result = AnyView(Text("\(result)"))
        return __result
    }

    var body: some View {
        HStack {
            Text("add_arrays")
            Spacer()
            view_inA
            view_inB
            view_result
        }
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

