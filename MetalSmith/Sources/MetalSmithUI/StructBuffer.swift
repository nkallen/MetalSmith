//
//  BufferView.swift
//  MetalSmithUI
//
//  Created by Nick Kallen on 12/11/19.
//  Copyright © 2019 Nick Kallen. All rights reserved.
//

import SwiftUI
import MetalKit

public protocol Reflectable {}

fileprivate extension Reflectable {
    subscript(checkedMirrorDescendant key: String) -> Any {
        return Mirror(reflecting: self).descendant(key)!
    }
}

public struct StructBuffer<T: Reflectable>: BufferView {
    public var buffer: UnsafeBufferPointer<T>

    init(_ buffer: UnsafeBufferPointer<T>) {
        self.buffer = buffer
    }

    public var body: some View {
        let prototype = buffer[0]
        let mirror = Mirror(reflecting: prototype)
        var keyPaths: [String:AnyKeyPath] = [:]
        for case let (key?, _) in mirror.children {
            keyPaths[key] = \T.[checkedMirrorDescendant: key] as PartialKeyPath
        }

        let header = HStack {
            ForEach(Array(keyPaths.keys), id: \.self) { item in
                Text(item)
            }
        }

        return List {
            Section(header: header) {
                ForEach(0..<buffer.count) { (i: Int) -> AnyView in
                    let item = self.buffer[i]

                    return AnyView(HStack {
                        ForEach(Array(keyPaths.values), id: \.self) { keyPath in
                            Text(String(describing: item[keyPath: keyPath]!))

                        }
                    })
                }
            }
        }
        .scaledToFit()
    }
}

struct StructBuffer_Previews: PreviewProvider {
    struct Struct: Reflectable {
        let foo: Float
        let bar: Float
    }

    static var array = [Struct(foo: 1.0, bar: 3.0), Struct(foo: 3.0, bar: 5.0), Struct(foo: 4.0, bar: 5.0)]
    static let buffer = UnsafeBufferPointer(start: &array, count: array.count)

    static var previews: some View {
        return StructBuffer(buffer)
            .previewLayout(.sizeThatFits)
    }
}
