//
//  MetalEnvironment.swift
//  MetalSmithUI
//
//  Created by Nick Kallen on 12/14/19.
//  Copyright © 2019 Nick Kallen. All rights reserved.
//

import Foundation
import MetalKit
import SwiftUI
import MetalSmith

public class MetalEnvironment: ObservableObject {
    public let device: MTLDevice?
    @Published public var library: MTLLibrary?
    @Published public var commandQueue: MTLCommandQueue?

    #if os(OSX)
    var watcher: [FolderWatcher.Local]? = nil
    #endif

    public init(device: MTLDevice? = MTLCreateSystemDefaultDevice(), library: MTLLibrary? = nil, commandQueue: MTLCommandQueue? = nil) {
        self.device = device
        self.library = device?.makeDefaultLibrary()
        self.commandQueue = device?.makeCommandQueue()
    }

    #if os(OSX)
    public func watch(_ path: String) -> Self {
        return watch(Paths(path))
    }

    public func watch(_ paths: Paths) -> Self {
        let source = paths.filter { $0.isMetalSourceFile }
        let compiler = MetalCompiler()
        self.watcher = source.process() { result in
            if let sources = try? result.get(),
                let metallib = try? compiler.compileAndArchive(sources) {
                self.library = try? self.device?.makeLibrary(filepath: metallib.string)
            }
        }

        return self
    }
    #endif
}
