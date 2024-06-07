//
//  FunctionParameterSyntax+Extensions.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2023. 11. 20..
//

import SwiftSyntax

extension FunctionParameterSyntax {
    var resolvedType: TypeSyntax {
        let type = if let type = type.as(AttributedTypeSyntax.self) {
            type.baseType
        } else {
            type
        }

        guard ellipsis == nil else {
            return TypeSyntax(ArrayTypeSyntax(element: type))
        }

        return TypeSyntax(type)
    }
}
