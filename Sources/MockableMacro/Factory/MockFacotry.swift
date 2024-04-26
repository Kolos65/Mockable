//
//  MockFacotry.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 28..
//

import SwiftSyntax

/// Factory to generate the mock service declaration.
///
/// Generates a class declaration that defines the mock implementation of the protocol.
enum MockFacotry: Factory {
    static func build(from requirements: Requirements) throws -> DeclSyntax {
        ClassDeclSyntax(
            modifiers: modifiers(requirements),
            name: .identifier(requirements.syntax.mockName),
            genericParameterClause: genericParameterClause(requirements),
            inheritanceClause: inheritanceClause(requirements),
            genericWhereClause: genericWhereClause(requirements),
            memberBlock: try MemberBlockSyntax {
                try MemberFactory.build(from: requirements)
                try ConformanceFactory.build(from: requirements)
                try EnumFactory.build(from: requirements)
                try BuilderFactory.build(from: requirements)
            }
        )
        .cast(DeclSyntax.self)
    }
}

// MARK: - Helpers

extension MockFacotry {
    private static func modifiers(_ requirements: Requirements) -> DeclModifierListSyntax {
        requirements.syntax.modifiers.trimmed + [DeclModifierSyntax(name: .keyword(.final))]
    }

    private static func inheritanceClause(_ requirements: Requirements) -> InheritanceClauseSyntax {
        InheritanceClauseSyntax {
            InheritedTypeSyntax(type: IdentifierTypeSyntax(
                name: requirements.syntax.name.trimmed
            ))
            InheritedTypeSyntax(type: IdentifierTypeSyntax(
                name: NS.MockableService
            ))
        }
    }

    private static func getAssociatedTypes(_ requirements: Requirements) -> [AssociatedTypeDeclSyntax] {
        requirements.syntax.memberBlock.members.compactMap {
            $0.decl.as(AssociatedTypeDeclSyntax.self)
        }
    }

    private static func genericParameterClause(_ requirements: Requirements) -> GenericParameterClauseSyntax? {
        let associatedTypes = getAssociatedTypes(requirements)
        guard !associatedTypes.isEmpty else { return nil }
        return .init {
            GenericParameterListSyntax {
                for name in associatedTypes.map(\.name.trimmed) {
                    GenericParameterSyntax(name: name)
                }
            }
        }
    }

    private static func genericWhereClause(_ requirements: Requirements) -> GenericWhereClauseSyntax? {
        let associatedTypes = getAssociatedTypes(requirements)
        guard !associatedTypes.isEmpty else { return nil }

        let inheritances = associatedTypes.filter { $0.inheritanceClause != nil }
        let whereClauses = associatedTypes.filter { $0.genericWhereClause != nil }

        guard !inheritances.isEmpty || !whereClauses.isEmpty else { return nil }

        let requirementList = GenericRequirementListSyntax {
            if let genericWhereClause = requirements.syntax.genericWhereClause {
                genericWhereClause.requirements
            }

            for type in whereClauses {
                if let genericWhereClause = type.genericWhereClause {
                    genericWhereClause.requirements
                }
            }

            for type in inheritances {
                if let inheritanceClause = type.inheritanceClause {
                    for inheritedType in inheritanceClause.inheritedTypes {
                        let requirement = ConformanceRequirementSyntax(
                            leftType: IdentifierTypeSyntax(name: type.name),
                            rightType: inheritedType.type
                        )
                        GenericRequirementSyntax(
                            requirement: .conformanceRequirement(requirement)
                        )
                    }
                }
            }
        }

        return .init(requirements: requirementList)
    }
}
