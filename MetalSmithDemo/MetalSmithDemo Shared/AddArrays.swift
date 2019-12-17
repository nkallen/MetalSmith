//
//  AddArrays.swift
//  MetalSmithDemo
//
//  Created by Nick Kallen on 12/15/19.
//  Copyright © 2019 Nick Kallen. All rights reserved.
//

import Foundation
import MetalKit
import SwiftUI
import MetalSmith
import MetalSmithUI

struct AddArrays_Previews: PreviewProvider {
    static var previews: some View {
        let count       = 10
        let environment = MetalEnvironment()

        let inA: [Float] = Array(0..<count).map { Float($0) }
        let inB: [Float] = inA.map { $0 * 4 }

        let result = environment.device!.makeBuffer(length: MemoryLayout<Float>.stride * count, options: .storageModeShared)
        result?.label = "result"
        
        return Group {
            HStack {
                Buffer(inA)
                Buffer(inB)
                Buffer(result, of: Float.self, count: count).copy()
            }
            .previewDisplayName("Buffers before fn invocation")
            CommandBuffer() {
                AddArrays()
                    .inA(inA)
                    .inB(inB)
                    .result(result)
                    .dispatch(width: count)
                AddArrays()
                    .inA(result)
                    .inB(inB)
                    .result(result)
                    .dispatch(width: count)
            }
            Buffer(result, of: Float.self, count: count)
                .previewDisplayName("Result buffer afters")
        }
        .previewLayout(.sizeThatFits)
        .environmentObject(environment)
    }
}
