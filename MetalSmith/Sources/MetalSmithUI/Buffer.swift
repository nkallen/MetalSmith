//
//  BufferView.swift
//  MetalSmithUI
//
//  Created by Nick Kallen on 12/11/19.
//  Copyright © 2019 Nick Kallen. All rights reserved.
//

import SwiftUI
import MetalKit

public func Buffer<T: Reflectable>(_ buffer: UnsafeBufferPointer<T>) -> StructBuffer<T> {
    return StructBuffer(buffer)
}

public func Buffer<T>(_ buffer: Array<T>) -> PrimitiveBuffer<T> {
    return buffer.withUnsafeBufferPointer {
        PrimitiveBuffer($0)
    }
}

public func Buffer<T>(_ buffer: UnsafeBufferPointer<T>) -> PrimitiveBuffer<T> {
    return PrimitiveBuffer(buffer)
}

public func Buffer<T: Reflectable>(_ buffer: Array<T>) -> StructBuffer<T> {
    return buffer.withUnsafeBufferPointer {
        return StructBuffer($0)
    }
}

public func Buffer<T>(_ buffer: MTLBuffer?, of type: T.Type, count: Int) -> some BufferView {
    let bufferPointer: UnsafeBufferPointer<T>
    if let buffer = buffer {
        let mutablePointer = buffer.contents().assumingMemoryBound(to: type)
        bufferPointer = UnsafeBufferPointer(start: mutablePointer, count: count)
    } else {
        bufferPointer = UnsafeBufferPointer<T>(start: UnsafeMutablePointer<T>.allocate(capacity: 0), count: 0)
    }

    return Buffer(bufferPointer)
}

public func Buffer<T: Reflectable>(_ buffer: MTLBuffer?, of type: T.Type, count: Int) -> some BufferView {
    let bufferPointer: UnsafeBufferPointer<T>
    if let buffer = buffer {
        let mutablePointer = buffer.contents().assumingMemoryBound(to: type)
        bufferPointer = UnsafeBufferPointer(start: mutablePointer, count: count)
    } else {
        bufferPointer = UnsafeBufferPointer<T>(start: UnsafeMutablePointer<T>.allocate(capacity: 0), count: 0)
    }

    return Buffer(bufferPointer)
}

struct Buffer_Previews: PreviewProvider {
    struct Struct: Reflectable {
        let foo: Float
        let bar: Float
    }

    static var previews: some View {
        let device       = MTLCreateSystemDefaultDevice()!

        let count = 3
        var structArray = [Struct(foo: 1.0, bar: 3.0), Struct(foo: 3.0, bar: 5.0), Struct(foo: 4.0, bar: 5.0)]
        var primitiveArray: [Float] = [1,2,3]
        let structBuffer = UnsafeBufferPointer(start: &structArray, count: structArray.count)
        let primitiveBuffer = UnsafeBufferPointer(start: &primitiveArray, count: primitiveArray.count)
        let structMtlBuffer = device.makeBuffer(length: MemoryLayout<Struct>.stride * count, options: .storageModeShared)!
        let primitiveMtlBuffer = device.makeBuffer(length: MemoryLayout<Float>.stride * count, options: .storageModeShared)!

        return Group {
            Buffer(structBuffer)
                .previewLayout(.sizeThatFits)
            Buffer(primitiveBuffer)
                .previewLayout(.sizeThatFits)
            Buffer(primitiveMtlBuffer, of: Float.self, count: count)
                .previewLayout(.sizeThatFits)
            Buffer(structMtlBuffer, of: Struct.self, count: count)
                .previewLayout(.sizeThatFits)
        }
    }
}
