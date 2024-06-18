//
//  ConformanceFactory.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 23..
//

import SwiftSyntax

/// Factory to generate mock conformances of requirements.
///
/// Returns a member block item list that includes a mock implementation for every requirement.
enum ConformanceFactory: Factory {
    static func build(from requirements: Requirements) throws -> MemberBlockItemListSyntax {
        try MemberBlockItemListSyntax {
            try inits(requirements)
            try functions(requirements)
            try variables(requirements)
        }
    }
}

// MARK: - Helpers

extension ConformanceFactory {
    private static func variables(_ requirements: Requirements) throws -> MemberBlockItemListSyntax {
        try MemberBlockItemListSyntax {
            for variable in requirements.variables {
                MemberBlockItemSyntax(
                    decl: try variable.implement(with: requirements.modifiers)
                )
            }
        }
    }

    private static func functions(_ requirements: Requirements) throws -> MemberBlockItemListSyntax {
        try MemberBlockItemListSyntax {
            for function in requirements.functions {
                MemberBlockItemSyntax(
                    decl: try function.implement(with: requirements.modifiers)
                )
            }
        }
    }

    private static func inits(_ requirements: Requirements) throws -> MemberBlockItemListSyntax {
        try MemberBlockItemListSyntax {
            for initializer in requirements.initializers {
                MemberBlockItemSyntax(
                    decl: try initializer.implement(with: requirements.modifiers)
                )
            }
        }
    }
}
