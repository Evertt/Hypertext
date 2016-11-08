//
//  Hypertext.swift
//  Hypertext
//
//  Created by Sahand Nayebaziz on 10/29/16.
//  Copyright © 2016 Sahand Nayebaziz. All rights reserved.
//

public protocol Renderable: CustomStringConvertible {
    func render() -> String
    func render(indentingWithSpacesCount: Int?) -> String
}

public extension Renderable {
    var description: String {
        return render()
    }

    func render() -> String {
        return render(indentingWithSpacesCount: nil)
    }
}

extension CustomStringConvertible {
    public func render(indentingWithSpacesCount count: Int?) -> String {
        return String(describing: self).indent(withSpacesCount: count ?? 0)
    }
}

extension String: Renderable {}
extension Int: Renderable {}
extension Double: Renderable {}
extension Float: Renderable {}

extension Array: Renderable {
    public func render(indentingWithSpacesCount count: Int?) -> String {
        return reduce("") { renderedSoFar, item in
            guard let renderableItem = item as? Renderable else {
                print("Tried to render an item in an array that does not conform to Renderable.")
                return renderedSoFar
            }

            return renderedSoFar +
                (count == nil || renderedSoFar == "" ? "" : "\n") +
                renderableItem.render(indentingWithSpacesCount: count)
            }.indent(withSpacesCount: count ?? 0)
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

    public func render(indentingWithSpacesCount count: Int?) -> String {
        if isSelfClosing {
            return "<\(name)\(renderAttributes())/>"
        }

        guard let children = children else {
            return "<\(name)\(renderAttributes())></\(name)>"
        }

        var content = children
            .render(indentingWithSpacesCount: count)
            .indent(withSpacesCount: count ?? 0)

        if (count != nil) {
            content = "\n\(content)\n"
        }

        return "<\(name)\(renderAttributes())>\(content)</\(name)>"
    }

    private func renderAttributes() -> String {
        return attributes.keys.reduce("") { renderedSoFar, attributeKey in
            return "\(renderedSoFar) \(attributeKey)=\"\(attributes[attributeKey]!)\""
        }
    }
}
