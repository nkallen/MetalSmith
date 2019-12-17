//
//  HelloTriangle.swift
//  MetalSmithDemo macOS
//
//  Created by Nick Kallen on 12/17/19.
//  Copyright © 2019 Nick Kallen. All rights reserved.
//

import Foundation
import SwiftUI
import MetalKit
import MetalSmith
import MetalSmithUI

/// This demo showcases using vanilla metal with a MetalSmith MetalView class
struct HelloTriangle_Previews: PreviewProvider {
    static var previews: some View {
        let device = MTLCreateSystemDefaultDevice()
        let commandQueue = device?.makeCommandQueue()
        let library = device?.makeDefaultLibrary()

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = library?.makeFunction(name: "helloTriangleVertex")
        pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "helloTriangleFragment")
        let renderPipelineState = try? device?.makeRenderPipelineState(descriptor: pipelineDescriptor)

        let triangleVertices = [
            // 2D positions,          RGBA colors
            (simd_float2( 250, -250), simd_float4(1, 0, 0, 1)),
            (simd_float2(-250, -250), simd_float4(0, 1, 0, 1)),
            (simd_float2(   0,  250), simd_float4(0, 0, 1, 1)),
        ]

        return MetalView(device: device)
            .onDraw { drawable, renderPassDescriptor, size in
                if  let commandQueue = commandQueue,
                    let commandBuffer = commandQueue.makeCommandBuffer(),
                    let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
                    let renderPipelineState = renderPipelineState
                {

                    commandEncoder.setRenderPipelineState(renderPipelineState)
                    commandEncoder.setVertexBytes(triangleVertices, length: MemoryLayout<(simd_float2, simd_float4)>.stride * 3, index: 0)
                    var viewportSize = simd_uint2(UInt32(size.width), UInt32(size.height))
                    commandEncoder.setVertexBytes(&viewportSize, length: MemoryLayout<simd_uint2>.stride, index: 1)
                    commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 3)
                    commandEncoder.endEncoding()

                    commandBuffer.present(drawable)
                    commandBuffer.commit()
                }
        }
        .previewLayout(.sizeThatFits)
    }
}

