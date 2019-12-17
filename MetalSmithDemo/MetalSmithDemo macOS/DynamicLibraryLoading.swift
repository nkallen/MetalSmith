//
//  ContentView.swift
//  Livecode
//
//  Created by Nick Kallen on 12/14/19.
//  Copyright © 2019 Nick Kallen. All rights reserved.
//

import SwiftUI
import MetalSmithUI
import MetalSmith

fileprivate var watch: [FolderWatcher.Local]? = nil

struct DynamicLibraryLoading: View {
    @EnvironmentObject var environment: MetalEnvironment

    var body: some View {
        let image = environment.device?.makeTexture(width: 480, height: 640, usage: [.shaderRead, .shaderWrite])
        var clock: Float = 1.0

        return Group {
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
        .previewLayout(.sizeThatFits)

    }
}

struct DynamicLibraryLoading_Previews: PreviewProvider {
    static var previews: some View {
        var environment = MetalEnvironment()
        if let srcroot = ProcessInfo.processInfo.environment["SRCROOT"] {
            environment = environment.watch(srcroot)
        }

        return DynamicLibraryLoading()
            .environmentObject(environment)
    }
}
