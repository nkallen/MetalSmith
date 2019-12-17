import Foundation
import PathKit

extension Path {
    public var isMetalSourceFile: Bool {
        return !self.isDirectory && self.extension == "metal"
    }

    public var isMetalLibFile: Bool {
        return !self.isDirectory && self.extension == "metallib"
    }
}

//
//  Path+Extensions.swift
//  Sourcery
//
//  Created by Krunoslav Zaher on 1/6/17.
//  Copyright © 2017 Pixle. All rights reserved.
//

public typealias Path = PathKit.Path

extension Path {
    /// - returns: The `.cachesDirectory` search path in the user domain, as a `Path`.
    public static var defaultBaseCachePath: Path {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        let path = paths[0]
        return Path(path)
    }

    /// - parameter _basePath: The value of the `--cachePath` command line parameter, if any.
    /// - note: This function does not consider the `--disableCache` command line parameter.
    ///         It is considered programmer error to call this function when `--disableCache` is specified.
    public static func cachesDir(sourcePath: Path, basePath: Path? = nil, createIfMissing: Bool = true) -> Path {
        let basePath = basePath ?? defaultBaseCachePath
        let path = basePath + "MetalSmith" + sourcePath.lastComponent
        if !path.exists && createIfMissing {
            // swiftlint:disable:next force_try
            try! FileManager.default.createDirectory(at: path.url, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }

    public var isTemplateFile: Bool {
        return self.extension == "stencil" ||
            self.extension == "swifttemplate" ||
            self.extension == "ejs"
    }

    public var isSwiftSourceFile: Bool {
        return !self.isDirectory && self.extension == "swift"
    }

    public func hasExtension(as string: String) -> Bool {
        let extensionString = ".\(string)."
        return self.string.contains(extensionString)
    }

    public init(_ string: String, relativeTo relativePath: Path) {
        var path = Path(string)
        if !path.isAbsolute {
            path = (relativePath + path).absolute()
        }
        self.init(path.string)
    }

    public var allPaths: [Path] {
        if isDirectory {
            return (try? recursiveChildren()) ?? []
        } else {
            return [self]
        }
    }

    func attributes() throws -> [FileAttributeKey : Any] {
        return try FileManager.default.attributesOfItem(atPath: self.string)
    }

    subscript(attribute: FileAttributeKey) -> Any? {
        do {
            let attrs = try attributes()
            return attrs[attribute]
        } catch {
            return nil
        }
    }
}
