//
//  TypeSyntax+Extensions.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 20..
//

import SwiftSyntax

extension FunctionParameterSyntax {
    public var resolvedTypeName: String {
        let type = if let type = type.as(AttributedTypeSyntax.self) {
            type.baseType
        } else {
            type
        }

        guard ellipsis == nil else {
            return "[\(type.trimmedDescription)]"
        }

        return type.trimmedDescription
    }
}
