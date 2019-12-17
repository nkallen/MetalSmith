//
//  Mini.swift
//  
//
//  Created by Nick Kallen on 12/17/19.
//  Copyright © 2019 Nick Kallen. All rights reserved.
//

import Foundation
import SwiftUI
import MetalKit

public struct MiniBuffer: View {
    let buffer: MTLBuffer?

    public init(_ buffer: MTLBuffer?) {
        self.buffer = buffer
    }

    public var body: some View {
        if let buffer = buffer {
            return Text(buffer.label ?? "\(String(format: "%02X", buffer.contents().hashValue)) \(buffer.length) bytes")
        } else {
            return Text("Nil Buffer")
        }
    }
}

public struct MiniTexture: View {
    let texture: MTLTexture?

    public init(_ texture: MTLTexture?) {
        self.texture = texture
    }

    public var body: some View {
        if let texture = texture {
            return Text(texture.label ?? "Texture \(texture.width)x\(texture.height)")
        } else {
            return Text("Nil Texture")
        }
    }
}
