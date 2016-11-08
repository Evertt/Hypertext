import Foundation

public extension String {
    func indent(withSpacesCount count: Int) -> String {
        let indentation = String(repeating: " ", count: count)
        
        return components(separatedBy: "\n")
            .map { line in indentation + line }
            .joined(separator: "\n")
    }
}
