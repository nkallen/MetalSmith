import Foundation
import PathKit
import Commander
import Logging
import MetalSmith

struct Output {
    let path: Path

    var isDirectory: Bool {
        guard path.exists else {
            return path.lastComponentWithoutExtension == path.lastComponent || path.string.hasSuffix("/")
        }
        return path.isDirectory
    }

    init(dict: [String: Any], relativePath: Path) throws {
        guard let path = dict["path"] as? String else {
            throw Configuration.Error.invalidOutput(message: "No path provided.")
        }

        self.path = Path(path, relativeTo: relativePath)
    }

    init(_ path: Path) {
        self.path = path
    }

}

struct Configuration {
    enum Error: Swift.Error, CustomStringConvertible {
        case invalidFormat(message: String)
        case invalidSources(message: String)
        case invalidTemplates(message: String)
        case invalidOutput(message: String)
        case invalidPaths(message: String)

        var description: String {
            switch self {
            case .invalidFormat(let message):
                return "Invalid config file format. \(message)"
            case .invalidSources(let message):
                return "Invalid sources. \(message)"
            case .invalidTemplates(let message):
                return "Invalid templates. \(message)"
            case .invalidOutput(let message):
                return "Invalid output. \(message)"
            case .invalidPaths(let message):
                return "\(message)"
            }
        }
    }

    let sources: Paths
    let templates: Paths
    let outputPath: Path
    let args: [String:NSObject]
    let constants: [String:NSObject]

    init(sources: Paths, templates: Paths, outputPath: Path, args: [String: NSObject], constants: [String: NSObject]) {
        self.sources = sources
        self.templates = templates
        self.outputPath = outputPath
        self.args = args
        self.constants = constants
    }
}
