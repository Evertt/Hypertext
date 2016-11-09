//
//  Hypertext.swift
//  Hypertext
//
//  Created by Sahand Nayebaziz on 10/29/16.
//  Copyright © 2016 Sahand Nayebaziz. All rights reserved.
//

public enum RenderMode {
    case minified, indented(spaces: Int)
}

public protocol Renderable: CustomStringConvertible {
    func render() -> String
    func render(_ mode: RenderMode) -> String
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
    public func render(_ mode: RenderMode) -> String {
        return String(describing: self)
    }
}

extension String: Renderable {}
extension Int: Renderable {}
extension Double: Renderable {}
extension Float: Renderable {}

extension Array: Renderable {
    public func render(_ mode: RenderMode) -> String {
        return reduce("") { renderedSoFar, item in
            guard let renderableItem = item as? Renderable else {
                print("Tried to render an item in an array that does not conform to Renderable.")
                return renderedSoFar
            }

            return renderedSoFar +
                (renderedSoFar == "" ? "" : "\n") +
                renderableItem.render(mode)
        }
    }
}

open class tag: Renderable {
    open var isSelfClosing: Bool { return false }
    open var name: String { return String(describing: type(of: self)) }

    public var children: Renderable? = nil
    public var attributes: [String: String] = [:]

    public init(_ attributes: [String: String] = [:], setChildren: (() -> Renderable?) = { nil }) {
        self.attributes = attributes
        self.children   = setChildren()
    }

    public func render(_ mode: RenderMode) -> String {
        if isSelfClosing {
            return "<\(name)\(renderAttributes())/>"
        }

        guard let content = children?.render(mode) else {
            return "<\(name)\(renderAttributes())></\(name)>"
        }

        switch mode {
        case .minified:
            return "<\(name)\(renderAttributes())>\(content)</\(name)>"
        case .indented(let spacesCount):
            let indentedContent = content.indent(spaces: spacesCount)
            return "<\(name)\(renderAttributes())>\n\(indentedContent)\n</\(name)>"
        }
    }

    private func renderAttributes() -> String {
        return attributes.keys.reduce("") { renderedSoFar, attributeKey in
            return "\(renderedSoFar) \(attributeKey)=\"\(attributes[attributeKey]!)\""
        }
    }
}
