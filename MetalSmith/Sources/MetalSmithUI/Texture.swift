//
//  BufferView.swift
//  MetalSmithUI
//
//  Created by Nick Kallen on 12/11/19.
//  Copyright © 2019 Nick Kallen. All rights reserved.
//

import SwiftUI
import MetalKit

fileprivate let textData: [Float] = [
    0.0, 1.0,
    1.0, 1.0,
    0.0, 0.0,
    1.0, 0.0
]

fileprivate let scaleX: Float = 1.0
fileprivate let scaleY: Float = 1.0

fileprivate let vertexData: [Float] = [
    -scaleX, -scaleY, 0.0, 1.0,
    scaleX, -scaleY, 0.0, 1.0,
    -scaleX, scaleY, 0.0, 1.0,
    scaleX, scaleY, 0.0, 1.0
]

var i = 0

public struct Texture: View {
    @EnvironmentObject var environment: MetalEnvironment
    var texture: MTLTexture?
    var onDrawCallback: ((CGSize) -> CommandBuffer)? = nil

    let pipelineState: MTLRenderPipelineState?
    let buffers: (MTLBuffer, MTLBuffer)?

    public init(_ texture: MTLTexture?) {
        self.texture = texture

        let device = texture?.device
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        let library = try? device?.makeLibrary(source: Texture.passthroughMetal, options: nil)
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertexPassThrough")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentPassThrough")
        self.pipelineState = try? device?.makeRenderPipelineState(descriptor: pipelineDescriptor)

        if let vertexCoordBuffer = device?.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<Float>.size),
            let textCoordBuffer = device?.makeBuffer(bytes: textData, length: textData.count * MemoryLayout<Float>.size) {
            self.buffers = (vertexCoordBuffer, textCoordBuffer)
        } else {
            self.buffers = nil
        }
    }

    public func onDraw(perform action: ((CGSize) -> CommandBuffer)? = nil) -> some View {
        var result = self
        if let action = action {
            result.onDrawCallback = action
        }
        return result
    }



    public var body: some View {
        return MetalView()
            .onDraw { drawable, renderPassDescriptor, size in
                if let commandBuffer = self.environment.commandQueue?.makeCommandBuffer(),
                    let pipelineState = self.pipelineState,
                    let buffers = self.buffers {
                    let (vertexCoordBuffer, textCoordBuffer) = buffers

                    if let cb = self.onDrawCallback {
                        let commandBuffer = cb(size)
                        commandBuffer.encode(environment: self.environment)
                    }

                    if let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {

                        commandEncoder.setRenderPipelineState(pipelineState)
                        commandEncoder.setVertexBuffer(vertexCoordBuffer, offset: 0, index: 0)
                        commandEncoder.setVertexBuffer(textCoordBuffer, offset: 0, index: 1)
                        commandEncoder.setFragmentTexture(self.texture, index: 0)
                        commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
                        commandEncoder.endEncoding()

                        commandBuffer.present(drawable)
                    }
                    commandBuffer.commit()
                }
        }
    }
}

struct Texture_Previews: PreviewProvider {
    static var previews: some View {
        let environment        = MetalEnvironment()
        let descriptor         = MTLTextureDescriptor()
        descriptor.width       = 480
        descriptor.height      = 640
        descriptor.pixelFormat = .bgra8Unorm
        descriptor.usage       = [.shaderRead, .shaderWrite]
        let texture            = environment.device?.makeTexture(descriptor: descriptor)

        return Texture(texture)
            .previewLayout(.sizeThatFits)
            .environmentObject(environment)
    }
}
