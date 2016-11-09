//
//  Hypertext.swift
//  Hypertext
//
//  Created by Sahand Nayebaziz on 10/29/16.
//  Copyright © 2016 Sahand Nayebaziz. All rights reserved.
//

public enum RenderMode {
    case minified, indented(spaces: Int)

    func addSpaces(to initialCount: Int) -> Int {
        switch self {
        case .minified:
            return initialCount
        case .indented(let spaces):
            return initialCount + spaces
        }
    }

    static func ==(left: RenderMode, right: RenderMode) -> Bool {
        switch (left, right) {
        case (.minified, .minified):
            return true
        case let (.indented(leftCount), .indented(rightCount)):
            return leftCount == rightCount
        default:
            return false
        }
    }
}

public protocol Renderable: CustomStringConvertible {
    func render() -> String
    func render(_ mode: RenderMode) -> String
}

protocol InternalRenderable: Renderable {
    func render(_ mode: RenderMode, startWithSpaces: Int) -> String
}

extension Renderable {
    public var description: String {
        return render(.minified)
    }

    public func render() -> String {
        return render(.minified)
    }
}

extension CustomStringConvertible {
    func render(_ mode: RenderMode, startWithSpaces count: Int) -> String {
        switch mode {
        case .minified:
            return String(describing: self)
        case .indented:
            return String(describing: self).indent(spaces: count)
        }
    }
}

extension InternalRenderable {
    public func render(_ mode: RenderMode) -> String {
        return render(mode, startWithSpaces: 0)
    }
}

class AnyInternalRenderable: InternalRenderable {
    let renderable: Renderable

    init(renderable: Renderable) {
        self.renderable = renderable
    }

    func render(_ mode: RenderMode, startWithSpaces count: Int) -> String {
        return renderable.render(mode)
    }

    static func make(from renderable: Renderable?) -> InternalRenderable? {
        guard let renderable = renderable else {
            return nil
        }

        if let internalRenderable = renderable as? InternalRenderable {
            return internalRenderable
        }

        return AnyInternalRenderable(renderable: renderable)
    }
}

extension String : InternalRenderable {}
extension Int    : InternalRenderable {}
extension Double : InternalRenderable {}
extension Float  : InternalRenderable {}

extension Array: InternalRenderable {
    func render(_ mode: RenderMode, startWithSpaces count: Int) -> String {
        return reduce("") { renderedSoFar, item in
            guard let renderableItem = AnyInternalRenderable.make(from: item as? Renderable) else {
                print("Tried to render an item in an array that does not conform to Renderable.")
                return renderedSoFar
            }

            return renderedSoFar +
                (mode == .minified || renderedSoFar == "" ? "" : "\n") +
                renderableItem.render(mode, startWithSpaces: count)
        }
    }
}

open class tag: InternalRenderable {
    open var isSelfClosing: Bool { return false }
    open var name: String { return String(describing: type(of: self)) }

    var children: InternalRenderable? = nil
    public var attributes: [String: String] = [:]

    public init(_ attributes: [String: String] = [:], setChildren: (() -> Renderable?) = { nil }) {
        self.attributes = attributes
        self.children   = AnyInternalRenderable.make(from: setChildren())
    }

    func render(_ mode: RenderMode, startWithSpaces count: Int) -> String {
        if isSelfClosing {
            return "<\(name)\(renderAttributes())/>"
        }

        guard let children = children else {
            return "<\(name)\(renderAttributes())></\(name)>"
        }

        let content = children.render(mode, startWithSpaces: mode.addSpaces(to: count))

        switch mode {
        case .minified:
            return "<\(name)\(renderAttributes())>\(content)</\(name)>"
        case .indented:
            let open = "<\(name)\(renderAttributes())>".indent(spaces: count)
            let close = "</\(name)>".indent(spaces: count)

            return "\(open)\n\(content)\n\(close)"
        }
    }

    private func renderAttributes() -> String {
        return attributes.keys.reduce("") { renderedSoFar, attributeKey in
            return "\(renderedSoFar) \(attributeKey)=\"\(attributes[attributeKey]!)\""
        }
    }
}
