//
//  CommandBuffer.swift
//  MetalSmithUI
//
//  Created by Nick Kallen on 12/11/19.
//  Copyright © 2019 Nick Kallen. All rights reserved.
//

import SwiftUI
import MetalKit

public protocol EncodesCommands {
    func encode(commandBuffer: MTLCommandBuffer, library: MTLLibrary)
}

public protocol CommandEncoder: View, EncodesCommands {
    var threadsPerGrid: MTLSize? { get set }
}

public extension CommandEncoder {
    func dispatch(width: Int = 1, height: Int = 1, depth: Int = 1) -> Self {
        var result = self
        result.threadsPerGrid = MTLSize(width: width, height: height, depth: depth)
        return result
    }
}

@_functionBuilder
public struct CommandBufferBuilder {
    public static func buildBlock<C: CommandEncoder>(_ encoder: C) -> C {
        return encoder
    }

    public static func buildBlock<C1: CommandEncoder, C2: CommandEncoder>(_ e1: C1, _ e2: C2) -> TupleView<(C1, C2)> {
        return TupleView((e1, e2))
    }
}

public struct CommandBuffer: View {
    @EnvironmentObject var environment: MetalEnvironment
    let items: [AnyView]
    let encoders: [EncodesCommands]

    public init<CE: CommandEncoder>(@CommandBufferBuilder content: @escaping () -> CE) {
        let encoder = content()
        self.items = [AnyView(encoder)]
        self.encoders = [encoder]
    }

    public init<C1: CommandEncoder, C2: CommandEncoder>(@CommandBufferBuilder content: @escaping () -> TupleView<(C1, C2)>) {
        let (e1, e2) = content().value
        self.items = [AnyView(e1), AnyView(e2)]
        self.encoders = [e1, e2]
    }

    public var body: some View {
        encode(environment: environment)

        return view
    }

    var view: some View {
        return List(0..<items.count) { i in
            self.items[i]
        }
        .scaledToFit()
        .previewDisplayName("Command Buffer")
    }

    func encode(environment: MetalEnvironment) {
        if let commandBuffer = environment.commandQueue?.makeCommandBuffer(),
            let library = environment.library {
            for encoder in encoders {
                encoder.encode(commandBuffer: commandBuffer, library: library)
            }
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
    }

    var completionCallbacks: [() -> Void] = []

    func onCompleted(perform action: (() -> Void)? = nil) -> some View {
        var result = self
        if let action = action {
            result.completionCallbacks.append(action)
        }
        return result
    }
}
