import MetalKit

public extension MTLDevice {
    func makeTexture(width: Int, height: Int, pixelFormat: MTLPixelFormat = .bgra8Unorm, usage: MTLTextureUsage = [.shaderRead]) -> MTLTexture? {
        let descriptor         = MTLTextureDescriptor()
        descriptor.width       = width
        descriptor.height      = height
        descriptor.pixelFormat = pixelFormat
        descriptor.usage       = usage
        print(usage)

        return self.makeTexture(descriptor: descriptor)
    }
}
