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
            return ArrayTypeSyntax(element: type).cast(TypeSyntax.self)
        }

        return type.cast(TypeSyntax.self)
    }
}
