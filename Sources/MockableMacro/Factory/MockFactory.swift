//
//  MockFactory.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 28..
//

#if canImport(SwiftSyntax600) || swift(<6)
import SwiftSyntax
#else
@preconcurrency import SwiftSyntax
#endif

/// Factory to generate the mock service declaration.
///
/// Generates a class declaration that defines the mock implementation of the protocol.
enum MockFactory: Factory {
    static func build(from requirements: Requirements) throws -> DeclSyntax {
        let classDecl = ClassDeclSyntax(
            leadingTrivia: leadingTrivia(requirements),
            attributes: try attributes(requirements),
            modifiers: modifiers(requirements),
            classKeyword: classKeyword(requirements),
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
        return DeclSyntax(classDecl)
    }
}

// MARK: - Helpers

extension MockFactory {
    private static func leadingTrivia(_ requirements: Requirements) -> Trivia {
        requirements.syntax.leadingTrivia
    }

    private static let inheritedTypeMappings: [String: TokenSyntax] = [
        NS.NSObjectProtocol: NS.NSObject
    ]

    private static func attributes(_ requirements: Requirements) throws -> AttributeListSyntax {
        guard requirements.containsGenericExistentials else { return [] }
        return try AttributeListSyntax {
            // Runtime support for parametrized protocol types is only available from:
            try Availability.from(iOS: "16.0", macOS: "13.0", tvOS: "16.0", watchOS: "9.0")
        }
        .with(\.trailingTrivia, .newline)
    }

    private static func modifiers(_ requirements: Requirements) -> DeclModifierListSyntax {
        var modifiers = requirements.syntax.modifiers.trimmed
        if !requirements.isActor {
            modifiers.append(DeclModifierSyntax(name: .keyword(.final)))
        }
        return modifiers
    }

    private static func classKeyword(_ requirements: Requirements) -> TokenSyntax {
        requirements.isActor ? .keyword(.actor) : .keyword(.class)
    }

    private static func inheritanceClause(_ requirements: Requirements) -> InheritanceClauseSyntax {
        InheritanceClauseSyntax {
            inheritedTypeMappings(requirements)
            InheritedTypeSyntax(type: IdentifierTypeSyntax(
                name: requirements.syntax.name.trimmed
            ))
            InheritedTypeSyntax(
                type: MemberTypeSyntax(
                    baseType: IdentifierTypeSyntax(name: NS.Mockable),
                    name: NS.MockableService
                )
            )
        }
    }

    private static func inheritedTypeMappings(_ requirements: Requirements) -> InheritedTypeListSyntax {
        guard let inheritanceClause = requirements.syntax.inheritanceClause else { return [] }
        return InheritedTypeListSyntax {
            for inheritedType in inheritanceClause.inheritedTypes {
                if let type = inheritedType.type.as(IdentifierTypeSyntax.self),
                   let mapping = inheritedTypeMappings[type.name.trimmedDescription] {
                    InheritedTypeSyntax(type: IdentifierTypeSyntax(name: mapping))
                }
            }
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
