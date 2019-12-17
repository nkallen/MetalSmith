import Foundation
import PathKit

fileprivate let queue: DispatchQueue = DispatchQueue(label: "com.nk.MetalSmith.PathObserver")

/**
 The main problem with using DispatchSource.makeFileSystemObjectSource is that it's not recursive.
 We could create path observers recursively but we must verify that it has adequate performance.
 OTOH, at least it works with MacOS Catalyst.
 */

public class PathObserver {
    private let path: Path
    public var source: DispatchSourceFileSystemObject?

    public init?(path: Path) {
        guard path.exists else { return nil }

        self.path = path
    }

    public func start(closure: @escaping () -> Void) {
        let nsString = (path.string as NSString)
        let fileSystemRepresentation = nsString.fileSystemRepresentation
        let fileDescriptor = open(fileSystemRepresentation, O_EVTONLY)

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: .write,
            queue: queue
        )

        source.setEventHandler(handler: closure)
        source.activate()
        self.source = source
    }
}
