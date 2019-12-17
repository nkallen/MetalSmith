import Foundation
import PathKit
import Commander
import Logging
import MetalKit
import MetalSmith

let log = Logger(label: "com.nk.MetalSmith")

extension Path: ArgumentConvertible {
    /// :nodoc:
    public init(parser: ArgumentParser) throws {
        if let path = parser.shift() {
            self.init(path)
        } else {
            throw ArgumentError.missingValue(argument: nil)
        }
    }
}

private enum Validators {
    static func isReadable(path: Path) -> Path {
        if !path.isReadable {
            log.error("'\(path)' does not exist or is not readable.")
            exit(.invalidePath)
        }

        return path
    }

    static func isFileOrDirectory(path: Path) -> Path {
        _ = isReadable(path: path)

        if !(path.isDirectory || path.isFile) {
            log.error("'\(path)' isn't a directory or proper file.")
            exit(.invalidePath)
        }

        return path
    }

    static func isWritable(path: Path) -> Path {
        if path.exists && !path.isWritable {
            log.error("'\(path)' isn't writable.")
            exit(.invalidePath)
        }
        return path
    }
}

extension Configuration {
    func validate() {
        _ = sources.allPaths.map(Validators.isReadable(path:))
        _ = templates.allPaths.map(Validators.isReadable(path:))
        guard !templates.isEmpty else {
            log.error("No templates provided.")
            exit(.invalidConfig)
        }
        _ = outputPath.map(Validators.isWritable(path:))
    }
}

enum ExitCode: Int32 {
    case invalidePath = 1
    case invalidConfig
    case other
}

private func exit(_ code: ExitCode) -> Never {
    exit(code.rawValue)
}

command(
    Flag("watch", flag: "w", description: "Watch template for changes and regenerate as needed."),
    VariadicOption<Path>("sources", description: "Path to metal sources. File or Directory."),
    VariadicOption<Path>("templates", description: "Path to templates. File or Directory."),
    Option<Path>("output", "", description: "Path to output. File or Directory. Default is current path."),
    VariadicOption<String>("args", description: "Custom values to pass to templates (--args arg1=value,arg2)."),
    VariadicOption<String>("constants", description: "Default values for metal function constants (--constants c1=value,...).")
) { watcherEnabled, sources, templates, output, args, consts in
    do {
        let configuration: Configuration
        let args = args.joined(separator: ",")
        let consts = consts.joined(separator: ",")
        let arguments = AnnotationsParser.parse(line: args)
        let constants = AnnotationsParser.parse(line: consts)
        configuration = Configuration(sources: Paths(include: sources).filter { $0.isMetalSourceFile },
                                      templates: Paths(include: templates).filter { $0.isTemplateFile },
                                      outputPath: output.string.isEmpty ? "." : output,
                                      args: arguments,
                                      constants: constants)

        configuration.validate()

        let start = CFAbsoluteTimeGetCurrent()
        let generator = MetalSmithGenerator(
            device: MTLCreateSystemDefaultDevice()!,
            watcherEnabled: watcherEnabled,
            arguments: configuration.args,
            constants: configuration.constants)
        if let keepAlive = try generator.processFiles(
            configuration.sources,
            usingTemplates: configuration.templates,
            outputPath: configuration.outputPath) {
            RunLoop.current.run()
            _ = keepAlive
        } else {
            log.info("Processing time \(CFAbsoluteTimeGetCurrent() - start) seconds")
        }
    } catch {
        log.error("\(error)")
        exit(.other)
    }
}.run(MetalSmithGenerator.version)
