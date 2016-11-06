//
//  Hypertext.swift
//  Hypertext
//
//  Created by Sahand Nayebaziz on 10/29/16.
//  Copyright © 2016 Sahand Nayebaziz. All rights reserved.
//

public protocol Renderable: CustomStringConvertible {
    func render(indent: Int?, startingWithSpacesCount: Int) -> String
}

public extension Renderable {
    var description: String {
        return render()
    }

    func render(indent: Int? = nil) -> String {
        return render(indent: indent, startingWithSpacesCount: 0)
    }
}

extension CustomStringConvertible {
    public func render(indent: Int?, startingWithSpacesCount: Int) -> String {
        return String(repeating: " ", count: indent == nil ? 0 : startingWithSpacesCount) + String(describing: self)
    }
}

extension String: Renderable {}
extension Int: Renderable {}
extension Double: Renderable {}
extension Float: Renderable {}

extension Array: Renderable {
    public func render(indent: Int?, startingWithSpacesCount: Int) -> String {
        return self.reduce("") { renderedSoFar, item in
            guard let renderableItem = item as? Renderable else {
                print("Tried to render an item in an array that does not conform to Renderable.")
                return renderedSoFar
            }

            return renderedSoFar +
                (indent == nil || renderedSoFar == "" ? "" : "\n") +
                renderableItem.render(indent: indent, startingWithSpacesCount: startingWithSpacesCount)
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

    public func render(indent: Int?, startingWithSpacesCount: Int) -> String {
        let leadingSpaces = String(repeating: " ", count: startingWithSpacesCount)

        if isSelfClosing {
            return "\(leadingSpaces)<\(name)\(renderAttributes())/>"
        }

        guard let children = children else {
            return "\(leadingSpaces)<\(name)\(renderAttributes())></\(name)>"
        }

        guard let indent = indent else {
            return "<\(name)\(renderAttributes())>\(children.render())</\(name)>"
        }

        return [
            leadingSpaces, "<", name, renderAttributes(), ">\n",
            children.render(indent: indent, startingWithSpacesCount: startingWithSpacesCount + indent), "\n",
            leadingSpaces, "</", name, ">"
        ].joined()
    }

    private func renderAttributes() -> String {
        return attributes.keys.reduce("") { renderedSoFar, attributeKey in
            return "\(renderedSoFar) \(attributeKey)=\"\(attributes[attributeKey]!)\""
        }
    }
}
