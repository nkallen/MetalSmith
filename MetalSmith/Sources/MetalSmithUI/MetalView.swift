//
//  MetalView.swift
//  MetalSmithUI
//
//  Created by Nick Kallen on 12/11/19.
//  Copyright © 2019 Nick Kallen. All rights reserved.
//

import SwiftUI
import MetalKit

#if os(iOS) || os(watchOS) || os(tvOS)
typealias Representable = UIViewRepresentable
#else // os(OSX)
typealias Representable = NSViewRepresentable
#endif

public struct MetalView: Representable {
    @EnvironmentObject var environment: MetalEnvironment
    let device: MTLDevice?
    //    @State var isPaused: Bool = false // FIXME https://medium.com/@chris.mash/avplayer-swiftui-part-2-player-controls-c28b721e7e27
    private var onDrawCallback: ((CAMetalDrawable, MTLRenderPassDescriptor, CGSize) -> Void)? = nil

    public init(device: MTLDevice? = nil) {
        self.device = device
    }

    #if os(iOS) || os(watchOS) || os(tvOS)
    public func makeUIView(context: Context) -> MTKView {
        let result = MTKView()
        result.device = self.device ?? environment.device
        result.delegate = context.coordinator
        result.isPaused = false
        return result
    }
    #else // os(OSX)
    public func makeNSView(context: Context) -> MTKView {
        let result = MTKView()
        result.device = environment.device
        result.delegate = context.coordinator
        result.isPaused = false
        return result
    }
    #endif

    #if os(iOS) || os(watchOS) || os(tvOS)
    public func updateUIView(_ mtkView: MTKView, context: Context) {
        context.coordinator.parent = self
    }
    #else // os(OSX)
    public func updateNSView(_ mtkView: MTKView, context: Context) {
        context.coordinator.parent = self
    }
    #endif

    public func makeCoordinator() -> MetalView.Coordinator {
        Coordinator(self)
    }
    
    public func onDraw(perform action: ((CAMetalDrawable, MTLRenderPassDescriptor, CGSize) -> Void)? = nil) -> some View {
        var result = self
        if let action = action {
            result.onDrawCallback = action
        }
        return result
    }
    
    public class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalView
        var size: CGSize?
        
        init(_ parent: MetalView) {
            self.parent = parent
        }
        
        public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            self.size = size
        }
        
        public func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable else { return }
            if let onDrawCallback = parent.onDrawCallback,
                let currentRenderPassDescriptor = view.currentRenderPassDescriptor,
                let size = size {
                onDrawCallback(drawable, currentRenderPassDescriptor, size)
            }
        }
    }
}
