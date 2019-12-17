import Foundation
import PathKit
import Commander
import Logging
import MetalKit
import MetalSmith

#if os(OSX)
class MetalSmithGenerator {
    public static let version: String = "Version"
    public static let generationMarker: String = "// Generated using MetalSmith"
    public static let generationHeader = "\(MetalSmithGenerator.generationMarker) \(MetalSmithGenerator.version)\n"
        + "// DO NOT EDIT\n\n"

    fileprivate let watcherEnabled: Bool
    fileprivate let arguments: [String: NSObject]
    fileprivate let constants: [String: NSObject]

    fileprivate var status = ""
    fileprivate var templatesPaths = Paths(include: [])
    fileprivate var outputPath = Path("")
    fileprivate let prune: Bool

    fileprivate let compiler = MetalCompiler()

    // content annotated with file annotations per file path to write it to
    fileprivate var fileAnnotatedContent: [Path: [String]] = [:]

    fileprivate let device: MTLDevice

    init(device: MTLDevice, watcherEnabled: Bool = false, prune: Bool = false, arguments: [String: NSObject] = [:], constants: [String: NSObject] = [:]) {
        self.device = device
        self.watcherEnabled = watcherEnabled
        self.arguments = arguments
        self.constants = constants
        self.prune = prune
    }

    func processFiles(_ sources: Paths, usingTemplates templatesPaths: Paths, outputPath: Path) throws -> [FolderWatcher.Local]? {
        self.templatesPaths = templatesPaths
        self.outputPath = outputPath

        @discardableResult func doit(sources: [Path]) throws -> ParsingResult {
            if let metallib = try compiler.compileAndArchive(sources) {
                let parsing = try self.parse(from: metallib, constants: self.constants)
                try self.generate(templatePaths: templatesPaths, outputPath: outputPath, parsingResult: parsing)
                return parsing
            } else {
                return Functions(functions: [])
            }
        }

        var result: ParsingResult!

        try sources.processOnce() { sources in
            result = try doit(sources: sources)
        }

        if !watcherEnabled {
            return nil
        }

        let sourceWatcher = sources.watch() { _ in
            do {
                try sources.processOnce() { sources in
                    result = try doit(sources: sources)
                }
            } catch {
                log.error("\(error)")
            }
        }

        let templateWatcher = templatesPaths.watch() { _ in
            do {
                log.info("Template(s) changed.")
                try self.generate(templatePaths: templatesPaths, outputPath: outputPath, parsingResult: result)
            } catch {
                log.error("\(error)")
            }
        }

        return sourceWatcher + templateWatcher
    }

    fileprivate func templates(from: Paths) throws -> [Template] {
        return try from.allPaths.filter { $0.isTemplateFile }.compactMap {
            return try StencilTemplate(path: $0)
        }
    }

}

// MARK: - Parsing

extension MetalSmithGenerator {
    typealias ParsingResult = Functions

    fileprivate func parse(from filepath: Path, constants: [String: NSObject] = [:]) throws -> ParsingResult {
        let library = try device.makeLibrary(filepath: filepath.string)
        var functions = [Function]()

        for functionName in library.functionNames {
            guard let mtlFunction = library.makeFunction(name: functionName) else {
                throw MTLLibraryError(.functionNotFound)
            }

            var mtlConstants = [MTLFunctionConstant]()
            let  constantValues = MTLFunctionConstantValues()
            for (_, const) in mtlFunction.functionConstantsDictionary {
                mtlConstants.append(const)
                var val = constants[const.name]
                constantValues.setConstantValue(&val, type: const.type, withName: const.name)
            }

            let specialized = try library.makeFunction(name: functionName, constantValues: constantValues)

            try functions.append(Function(specialized, constants: mtlConstants))
        }
        return Functions(functions: functions)
    }
}

// MARK: - Generation
extension MetalSmithGenerator {

    fileprivate func generate(templatePaths: Paths, outputPath: Path, parsingResult: ParsingResult) throws {
        let generationStart = CFAbsoluteTimeGetCurrent()

        log.info("Loading templates...")
        let allTemplates = try templates(from: templatePaths)
        log.info("Loaded \(allTemplates.count) templates.")
        log.info("\tLoading took \(CFAbsoluteTimeGetCurrent() - generationStart)")

        log.info("Generating code...")
        status = ""

        try allTemplates.forEach { template in
            let result = try generate(template, forParsingResult: parsingResult, outputPath: outputPath)
            let outputPath = outputPath + generatedPath(for: template.sourcePath)
            try self.output(result: result, to: outputPath)
        }

        try fileAnnotatedContent.forEach { (path, contents) in
            try self.output(result: contents.joined(separator: "\n"), to: path)
        }

        log.info("\tGeneration took \(CFAbsoluteTimeGetCurrent() - generationStart)")
        log.info("Finished.")
    }

    private func output(result: String, to outputPath: Path) throws {
        var result = result
        if !result.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if outputPath.extension == "swift" {
                result = MetalSmithGenerator.generationHeader + result
            }
            if !outputPath.parent().exists {
                try outputPath.parent().mkpath()
            }
            try writeIfChanged(result, to: outputPath)
        } else {
            if prune && outputPath.exists {
                log.info("Removing \(outputPath) as it is empty.")
                do { try outputPath.delete() } catch { log.error("\(error)") }
            } else {
                log.info("Skipping \(outputPath) as it is empty.")
            }
        }
    }

    private func generate(_ template: Template, forParsingResult parsingResult: ParsingResult, outputPath: Path) throws -> String {
        guard watcherEnabled else {
            let generationStart = CFAbsoluteTimeGetCurrent()
            let result = try Generator.generate(parsingResult, template: template, arguments: self.arguments)
            log.info("\tGenerating \(template.sourcePath.lastComponent) took \(CFAbsoluteTimeGetCurrent() - generationStart)")

            return try processRanges(in: parsingResult, result: result, outputPath: outputPath)
        }

        var result: String = ""
        do {
            result = try Generator.generate(parsingResult, template: template, arguments: self.arguments)
        } catch {
            log.error("\(error)")
            result = "\(error)"
        }

        return try processRanges(in: parsingResult, result: result, outputPath: outputPath)
    }

    private func processRanges(in parsingResult: ParsingResult, result: String, outputPath: Path) throws -> String {
        let start = CFAbsoluteTimeGetCurrent()
        defer {
            log.info("\t\tProcessing Ranges took \(CFAbsoluteTimeGetCurrent() - start)")
        }
        var result = result
        result = processFileRanges(for: parsingResult, in: result, outputPath: outputPath)
        return TemplateAnnotationsParser.removingEmptyAnnotations(from: result)
    }

    private func processFileRanges(`for` parsingResult: ParsingResult, in contents: String, outputPath: Path) -> String {
        let files = TemplateAnnotationsParser.parseAnnotations("file", contents: contents, aggregate: true)

        files
            .annotatedRanges
            .map { ($0, $1) }
            .forEach({ (filePath, ranges) in
                let generatedBody = ranges.map { contents.bridge().substring(with: $0.range) }.joined(separator: "\n")
                let path = outputPath + (Path(filePath).extension == nil ? "\(filePath).generated.swift" : filePath)
                var fileContents = fileAnnotatedContent[path] ?? []
                fileContents.append(generatedBody)
                fileAnnotatedContent[path] = fileContents
            })
        return files.contents
    }

    fileprivate func writeIfChanged(_ content: String, to path: Path) throws {
        guard path.exists else {
            return try path.write(content)
        }

        let existing = try path.read(.utf8)
        if existing != content {
            try path.write(content)
        }
    }

    private func indent(toInsert: String, indentation: String) -> String {
        guard indentation.isEmpty == false else {
            return toInsert
        }
        let lines = toInsert.components(separatedBy: "\n")
        return lines.enumerated()
            .map { index, line in
                guard !line.isEmpty else {
                    return line
                }

                return index == lines.count - 1 ? line : indentation + line
        }
        .joined(separator: "\n")
    }

    internal func generatedPath(`for` templatePath: Path) -> Path {
        return Path("\(templatePath.lastComponentWithoutExtension).generated.swift")
    }
}
#endif

#if os(OSX)
public enum Generator {
    public static func generate(_ functions: Functions, template: Template, arguments: [String: NSObject] = [:]) throws -> String {
        log.info("Rendering template \(template.sourcePath)")
        return try template.render(TemplateContext(functions: functions, arguments: arguments))
    }
}
#endif
