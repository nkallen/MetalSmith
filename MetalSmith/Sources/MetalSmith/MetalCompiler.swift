import Foundation
import Logging
import PathKit

typealias CompilationResult = [Path]

let log = Logger(label: "com.nk.MetalSmith")

public class MetalCompiler {
    let cachesPath: Path
    #if os(iOS) || os(watchOS) || os(tvOS)
    let sdk = "iphoneos"
    #elseif os(OSX)
    let sdk = "macosx"
    #endif

    public init(cachesPath: Path = Path.cachesDir(sourcePath: Path("MetalSmith"))) {
        self.cachesPath = cachesPath
    }

    public func compileAndArchive(_ sources: [Path]) throws -> Path? {
        var previousUpdate = 0
        var accumulator = 0
        let step = sources.count / 10 // every 10%
        let airs = try sources.parallelMap({ try compile($0) }) { _ in
            if accumulator > previousUpdate + step {
                previousUpdate = accumulator
                let percentage = accumulator * 100 / sources.count
                log.info("Scanning sources... \(percentage)% (\(sources.count) files)")
            }
            accumulator += 1
        }
        return try archive(airs)
    }

    public func compile(_ in: Path) throws -> Path {
        let out = cachesPath + Path("\(`in`.lastComponentWithoutExtension).air")
        guard out.exists else {
            log.info("Initial compilation of \(`in`.string).")
            _ = shell("xcrun -sdk \(sdk) metal -c \"\(`in`.string)\" -o \"\(out.string)\"")
            return out
        }

        if let inDate = `in`[.modificationDate] as? Date,
            let outDate = out[.modificationDate] as? Date,
            outDate < inDate {
            log.info("Re-compiling \(`in`.string).")
            _ = shell("xcrun -sdk \(sdk) metal -c \"\(`in`.string)\" -o \"\(out.string)\"")
        } else {
            log.info("Compiled version of \(`in`.string) is already up-to-date; skipping compilation.")
        }
        return out
    }

    private var defeatCache = 0 // device.makeLibrary() has an internal cache, so we cannot re-use filenames

    public func archive(_ files: [Path]) throws -> Path? {
        guard !files.isEmpty else { return nil }

        let start = CFAbsoluteTimeGetCurrent()
        if defeatCache > 0 {
            let old = cachesPath + Path("default\(defeatCache-1).metallib")
            if old.exists {
                try old.delete()
            }
        }
        let out = cachesPath + Path("default\(defeatCache).metallib")
        _ = shell("xcrun -sdk \(sdk) metal \(files.map({ $0.string }).joined(separator: " ")) -o \(out.string)")
        log.info("Archive: \(CFAbsoluteTimeGetCurrent() - start)")
        defeatCache += 1
        return out
    }

    private func topPaths(from paths: [Path]) -> [Path] {
        var top: [(Path, [Path])] = []
        paths.forEach { path in
            // See if its already contained by the topDirectories
            guard top.first(where: { (_, children) -> Bool in
                return children.contains(path)
            }) == nil else { return }

            if path.isDirectory {
                top.append((path, (try? path.recursiveChildren()) ?? []))
            } else {
                let dir = path.parent()
                let children = (try? dir.recursiveChildren()) ?? []
                if children.contains(path) {
                    top.append((dir, children))
                } else {
                    top.append((path, []))
                }
            }
        }

        return top.map { $0.0 }
    }
}

fileprivate func shell(_ command: String) -> String {
    #if os(OSX)
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

    return output
    #else
    return "Not sure how to shell out in a Catalyst app"
    #endif
}
