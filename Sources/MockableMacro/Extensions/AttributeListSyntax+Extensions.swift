//
//  File.swift
//  Mockable
//
//  Created by Kolos Foltányi on 2025. 11. 16..
//

import SwiftSyntax

extension AttributeListSyntax {
    func filter(allowedNames: [String]) -> AttributeListSyntax {
        filter { element in
            switch element {
            case .attribute(let attributeSyntax):
                return attribute(attributeSyntax, matches: allowedNames)
            case .ifConfigDecl(let ifConfigDeclSyntax):
                return ifConfigDeclSyntax.clauses
                    .compactMap { $0.elements }
                    .allSatisfy { item in
                        guard case .attributes(let list) = item else { return false }
                        return list.allSatisfy {
                            guard case .attribute(let attr) = $0 else { return false }
                            return attribute(attr, matches: allowedNames)
                        }
                    }
            }
        }
    }

    private func attribute(_ attribute: AttributeSyntax, matches allowedNames: [String]) -> Bool {
        allowedNames.contains(attribute.attributeName.trimmedDescription)
    }
}
