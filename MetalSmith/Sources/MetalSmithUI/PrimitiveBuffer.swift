//
//  BufferView.swift
//  MetalSmithUI
//
//  Created by Nick Kallen on 12/11/19.
//  Copyright © 2019 Nick Kallen. All rights reserved.
//

import SwiftUI
import MetalKit

public protocol BufferView: View {
    associatedtype Element

    var buffer: UnsafeBufferPointer<Element> { get set }

    func copy() -> Self
}

public extension BufferView {
    func copy() -> Self {
        var result = self
        result.buffer = buffer.copy()
        return result
    }
}

@available(iOS 13.0, *)
public struct PrimitiveBuffer<T>: BufferView {
    public var buffer: UnsafeBufferPointer<T>

    init(_ buffer: UnsafeBufferPointer<T>) {
        self.buffer = buffer
    }

    init(_ buffer: MTLBuffer, of type: T.Type, count: Int) {
        let mutablePointer = buffer.contents().assumingMemoryBound(to: type)
        let buffer = UnsafeBufferPointer(start: mutablePointer, count: count)
        self.buffer = buffer
    }

    public var body: some View {
        return List {
            ForEach(0..<buffer.count) { i in
                return Text(String(describing: self.buffer[i]))
            }
        }
        .scaledToFit()
    }
}

public extension UnsafeBufferPointer {
    func copy() -> Self {
        let start = UnsafeMutablePointer<Element>.allocate(capacity: count)
        if let baseAddress = baseAddress {
            start.initialize(from: baseAddress, count: count)
        }
        return UnsafeBufferPointer(start: start, count: count)
    }
}

struct PrimitiveBuffer_Previews: PreviewProvider {
    static var array = [1,2,3]
    static let buffer = UnsafeBufferPointer(start: &array, count: array.count)

    static var previews: some View {
        return PrimitiveBuffer(buffer)
            .previewLayout(.sizeThatFits)
    }
}
