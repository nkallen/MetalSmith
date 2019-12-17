import Foundation
import Stencil
import PathKit
import StencilSwiftKit

/// Generic template that can be used for any of the Sourcery output variants
public protocol Template {
    /// Path to template
    var sourcePath: Path { get }

    /// Generate
    ///
    /// - Parameter types: List of types to generate.
    /// - Parameter arguments: List of template arguments.
    /// - Returns: Generated code.
    /// - Throws: `Throws` template errors
    func render(_ context: TemplateContext) throws -> String
}

final class StencilTemplate: StencilSwiftKit.StencilSwiftTemplate, Template {
    private(set) var sourcePath: Path = ""

    convenience init(path: Path) throws {
        self.init(templateString: try path.read(), environment: StencilTemplate.sourceryEnvironment(templatePath: path))
        sourcePath = path
    }

    convenience init(templateString: String) {
        self.init(templateString: templateString, environment: StencilTemplate.sourceryEnvironment())
    }

    func render(_ context: TemplateContext) throws -> String {
        do {
            return try super.render(context.stencilContext)
        } catch {
            throw "\(sourcePath): \(error)"
        }
    }

    private static func sourceryEnvironment(templatePath: Path? = nil) -> Stencil.Environment {
        let ext = Stencil.Extension()

        ext.registerStringFilters()

        ext.registerFilter("count", filter: count)
        ext.registerFilter("isEmpty", filter: isEmpty)
        ext.registerFilter("reversed", filter: reversed)
        ext.registerFilter("toArray", filter: toArray)

        ext.registerFilterWithArguments("sorted") { (array, propertyName: String) -> Any? in
            switch array {
            case let array as NSArray:
                let sortDescriptor = NSSortDescriptor(key: propertyName, ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
                return array.sortedArray(using: [sortDescriptor])
            default:
                return nil
            }
        }

        ext.registerFilterWithArguments("sortedDescending") { (array, propertyName: String) -> Any? in
            switch array {
            case let array as NSArray:
                let sortDescriptor = NSSortDescriptor(key: propertyName, ascending: false, selector: #selector(NSString.caseInsensitiveCompare))
                return array.sortedArray(using: [sortDescriptor])
            default:
                return nil
            }
        }

        var extensions = stencilSwiftEnvironment().extensions
        extensions.append(ext)
        let loader = templatePath.map({ FileSystemLoader(paths: [$0.parent()]) })
        return Environment(loader: loader, extensions: extensions, templateClass: StencilTemplate.self)
    }
}

extension Stencil.Extension {

    func registerStringFilters() {
//        let lowercase = FilterOr<String, TypeName>.make({ $0.lowercased() }, other: { $0.name.lowercased() })
//        registerFilter("lowercase", filter: lowercase)
//
//        let uppercase = FilterOr<String, TypeName>.make({ $0.uppercased() }, other: { $0.name.uppercased() })
//        registerFilter("uppercase", filter: uppercase)
//
//        let capitalise = FilterOr<String, TypeName>.make({ $0.capitalized }, other: { $0.name.capitalized })
//        registerFilter("capitalise", filter: capitalise)
    }

    func registerFilterWithTwoArguments<T, A, B>(_ name: String, filter: @escaping (T, A, B) throws -> Any?) {
        registerFilter(name) { (any, args) throws -> Any? in
            guard let type = any as? T else { return any }
            guard args.count == 2, let argA = args[0] as? A, let argB = args[1] as? B else {
                throw TemplateSyntaxError("'\(name)' filter takes two arguments: \(A.self) and \(B.self)")
            }
            return try filter(type, argA, argB)
        }
    }

    func registerFilterOrWithTwoArguments<T, Y, A, B>(_ name: String, filter: @escaping (T, A, B) throws -> Any?, other: @escaping (Y, A, B) throws -> Any?) {
        registerFilter(name) { (any, args) throws -> Any? in
            guard args.count == 2, let argA = args[0] as? A, let argB = args[1] as? B else {
                throw TemplateSyntaxError("'\(name)' filter takes two arguments: \(A.self) and \(B.self)")
            }
            if let type = any as? T {
                return try filter(type, argA, argB)
            } else if let type = any as? Y {
                return try other(type, argA, argB)
            } else {
                return any
            }
        }
    }

    func registerFilterWithArguments<A>(_ name: String, filter: @escaping (Any?, A) throws -> Any?) {
        registerFilter(name) { (any: Any?, args: [Any?]) throws -> Any? in
            guard args.count == 1, let arg = args.first as? A else {
                throw TemplateSyntaxError("'\(name)' filter takes a single \(A.self) argument")
            }
            return try filter(any, arg)
        }
    }

    func registerBoolFilterWithArguments<U, A>(_ name: String, filter: @escaping (U, A) -> Bool) {
        registerFilterWithArguments(name, filter: Filter.make(filter))
        registerFilterWithArguments("!\(name)", filter: Filter.make({ !filter($0, $1) }))
    }

    func registerBoolFilter<U>(_ name: String, filter: @escaping (U) -> Bool) {
        registerFilter(name, filter: Filter.make(filter))
        registerFilter("!\(name)", filter: Filter.make({ !filter($0) }))
    }

    func registerBoolFilterOrWithArguments<U, V, A>(_ name: String, filter: @escaping (U, A) -> Bool, other: @escaping (V, A) -> Bool) {
        registerFilterWithArguments(name, filter: FilterOr.make(filter, other: other))
        registerFilterWithArguments("!\(name)", filter: FilterOr.make({ !filter($0, $1) }, other: { !other($0, $1) }))
    }

    func registerBoolFilterOr<U, V>(_ name: String, filter: @escaping (U) -> Bool, other: @escaping (V) -> Bool) {
        registerFilter(name, filter: FilterOr.make(filter, other: other))
        registerFilter("!\(name)", filter: FilterOr.make({ !filter($0) }, other: { !other($0) }))
    }


}

private func toArray(_ value: Any?) -> Any? {
    switch value {
    case let array as NSArray:
        return array
    case .some(let something):
        return [something]
    default:
        return nil
    }
}

private func reversed(_ value: Any?) -> Any? {
    guard let array = value as? NSArray else {
        return value
    }
    return array.reversed()
}

private func count(_ value: Any?) -> Any? {
    guard let array = value as? NSArray else {
        return value
    }
    return array.count
}

private func isEmpty(_ value: Any?) -> Any? {
    guard let array = value as? NSArray else {
        return false
    }
    // swiftlint:disable:next empty_count
    return array.count == 0
}

private struct Filter<T> {
    static func make(_ filter: @escaping (T) -> Bool) -> (Any?) throws -> Any? {
        return { (any) throws -> Any? in
            switch any {
            case let type as T:
                return filter(type)

            case let array as NSArray:
                return array.compactMap { $0 as? T }.filter(filter)

            default:
                return any
            }
        }
    }

    static func make<U>(_ filter: @escaping (T) -> U?) -> (Any?) throws -> Any? {
        return { (any) throws -> Any? in
            switch any {
            case let type as T:
                return filter(type)

            case let array as NSArray:
                return array.compactMap { $0 as? T }.compactMap(filter)

            default:
                return any
            }
        }
    }

    static func make<A>(_ filter: @escaping (T, A) -> Bool) -> (Any?, A) throws -> Any? {
        return { (any, arg) throws -> Any? in
            switch any {
            case let type as T:
                return filter(type, arg)

            case let array as NSArray:
                return array.compactMap { $0 as? T }.filter { filter($0, arg) }

            default:
                return any
            }
        }
    }
}

private struct FilterOr<T, Y> {
    static func make(_ filter: @escaping (T) -> Bool, other: @escaping (Y) -> Bool) -> (Any?) throws -> Any? {
        return { (any) throws -> Any? in
            switch any {
            case let type as T:
                return filter(type)

            case let type as Y:
                return other(type)

            case let array as NSArray:
                if array.firstObject is T {
                    return array.compactMap { $0 as? T }.filter(filter)
                } else {
                    return array.compactMap { $0 as? Y }.filter(other)
                }

            default:
                return any
            }
        }
    }

    static func make<U>(_ filter: @escaping (T) -> U?, other: @escaping (Y) -> U?) -> (Any?) throws -> Any? {
        return { (any) throws -> Any? in
            switch any {
            case let type as T:
                return filter(type)

            case let type as Y:
                return other(type)

            case let array as NSArray:
                if array.firstObject is T {
                    return array.compactMap { $0 as? T }.compactMap(filter)
                } else {
                    return array.compactMap { $0 as? Y }.compactMap(other)
                }

            default:
                return any
            }
        }
    }

    static func make<A>(_ filter: @escaping (T, A) -> Bool, other: @escaping (Y, A) -> Bool) -> (Any?, A) throws -> Any? {
        return { (any, arg) throws -> Any? in
            switch any {
            case let type as T:
                return filter(type, arg)

            case let type as Y:
                return other(type, arg)

            case let array as NSArray:
                if array.firstObject is T {
                    return array.compactMap { $0 as? T }.filter({ filter($0, arg) })
                } else {
                    return array.compactMap { $0 as? Y }.filter({ other($0, arg) })
                }

            default:
                return any
            }
        }
    }
}

extension String: Error {}
