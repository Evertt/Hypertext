import Foundation

public extension String {
    func indent(spaces: Int) -> String {
        let indentation = String(repeating: " ", count: spaces)

        return components(separatedBy: "\n")
            .map { line in indentation + line }
            .joined(separator: "\n")
    }
}
