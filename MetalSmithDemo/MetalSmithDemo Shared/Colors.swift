//
//  Colors.swift
//  MetalSmithUI
//
//  Created by Nick Kallen on 12/12/19.
//  Copyright © 2019 Nick Kallen. All rights reserved.
//

import SwiftUI
import MetalKit
import MetalSmithUI
import MetalSmith

struct Colors_Previews: PreviewProvider {
    static var previews: some View {
        let environment = MetalEnvironment()
        let image       = environment.device?.makeTexture(width: 480, height: 640, usage: .shaderWrite)

        var clock: Float = 1.0
        return Group {
            /// One invocation of a command buffer; the texture it modifies is displayed below it.
            CommandBuffer() {
                Colors()
                    .time(0.0)
                    .image(image)
                    .dispatch(width: 480, height: 640)
            }
            Texture(image)

            /// A looping invocation of a command buffer, (driven by a MTKView). Click the PLAY
            /// button in the preview canvas to see it animate!
            Texture(image)
                .onDraw { _ in
                    clock += 0.01
                    return CommandBuffer {
                        Colors()
                            .time(clock)
                            .image(image)
                            .dispatch(width: 480, height: 640)
                    }
            }
        }
        .environmentObject(environment)
        .previewLayout(.sizeThatFits)
    }
}
