import SwiftSyntax

extension AttributeListSyntax {
    func contains(_ name: String) -> Bool {
        trimmed.contains { element in
            guard case .attribute(let attribute) = element else {
                return false
            }

            return attribute.attributeName.as(IdentifierTypeSyntax.self)?.description == name
        }
    }
}
