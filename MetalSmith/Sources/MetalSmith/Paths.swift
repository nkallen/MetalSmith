import Foundation

public struct Paths {
    public typealias Filter = ((Path) -> Bool)

    public let include: [Path]
    public let exclude: [Path]
    public let allPaths: [Path]

    private var filter: Filter? = nil

    public var isEmpty: Bool {
        return allPaths.isEmpty
    }

    public init(_ include: String) {
        self.init(include: [Path(include)], exclude: [])
    }

    public init(include: [Path], exclude: [Path] = []) {
        self.include = include
        self.exclude = exclude

        let include = self.include.flatMap { $0.allPaths }
        let exclude = self.exclude.flatMap { $0.allPaths }

        self.allPaths = Array(Set(include).subtracting(Set(exclude))).sorted()
    }

    public func filter(_ filter: @escaping Filter) -> Self {
        var result = self
        result.filter = filter
        return result
    }
}

#if os(OSX)
public extension Paths {
    typealias ProcessCallback = (Result<[Path], Error>) -> Void
    typealias ProcessOnceCallBack = ([Path]) throws -> Void
    typealias WatchCallBack = ([FolderWatcher.Event]) -> Void

    func process(_ callback: @escaping ProcessCallback) -> [FolderWatcher.Local] {
        func processAndHandleErrors() {
            do {
                try processOnce() {
                    callback(.success($0))
                }
            } catch {
                callback(.failure(error))
            }
        }
        processAndHandleErrors()
        return watch() { _ in
            processAndHandleErrors()
        }
    }

    func watch(_ onEvent: @escaping WatchCallBack) -> [FolderWatcher.Local] {
        let sourceWatchers = topPaths(from: allPaths).map { watchPath -> FolderWatcher.Local in
            return FolderWatcher.Local(path: watchPath.string) { events in
                var eventPaths = events
                    .filter { $0.flag.contains(.isFile) && !$0.flag.contains(.xattrsModified) }
                if let filter = self.filter {
                    eventPaths = eventPaths.filter { filter(Path($0.path)) }
                }
                if !eventPaths.isEmpty {
                    onEvent(eventPaths)
                }
            }
        }

        return sourceWatchers
    }

    func processOnce(_ callback: ProcessOnceCallBack) throws {
        let startScan = CFAbsoluteTimeGetCurrent()
        log.info("Scanning sources...")

        var allResults: [Path] = []

        let excludeSet = Set(exclude
            .map { $0.isDirectory ? try? $0.recursiveChildren() : [$0] }
            .compactMap({ $0 }).flatMap({ $0 }))

        for from in include {
            let fileList = from.isDirectory ? try from.recursiveChildren() : [from]
            var sources = fileList
                .filter { $0.exists }
                .filter {
                    return !excludeSet.contains($0)
            }
            if let filter = self.filter {
                sources = sources.filter { filter($0) }
            }
            allResults.append(contentsOf: sources)
        }

        log.info("Process all files: \(CFAbsoluteTimeGetCurrent() - startScan). \(allResults.count) files found.")

        if !allResults.isEmpty {
            try callback(allResults)
        }
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
#endif
