//
//  ClassDeclaration.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 16..
//

import SwiftSyntax
import SwiftSyntaxMacros

struct ClassDeclaration {

    // MARK: Private Properties

    private let protocolDeclaration: ProtocolDeclSyntax
    private let associatedTypes: [AssociatedTypeDeclSyntax]

    // MARK: Init

    init(_ protocolDeclaration: ProtocolDeclSyntax) {
        self.protocolDeclaration = protocolDeclaration
        self.associatedTypes = protocolDeclaration.memberBlock.members
            .compactMap { $0.decl.as(AssociatedTypeDeclSyntax.self) }
    }

    // MARK: Properties

    var name: TokenSyntax {
        .identifier(Constants.implementationPrefix + protocolDeclaration.name.text)
    }

    var modifiers: DeclModifierListSyntax {
        protocolDeclaration.modifiers.trimmed + [DeclModifierSyntax(name: .keyword(.final))]
    }

    var leadingTrivia: Trivia {
        .init(stringLiteral: "#if \(Constants.compileCondition)\n")
    }

    var trailingTrivia: Trivia {
        .init(stringLiteral: "\n#endif")
    }

    var inheritanceClause: InheritanceClauseSyntax {
        .init {
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: protocolDeclaration.name.trimmed))
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier(Constants.baseProtocolName)))
        }
    }

    var genericParameterClause: GenericParameterClauseSyntax? {
        guard !associatedTypes.isEmpty else { return nil }
        return .init {
            GenericParameterListSyntax {
                for name in associatedTypes.map(\.name.trimmed) {
                    GenericParameterSyntax(name: name)
                }
            }
        }
    }

    var genericWhereClause: GenericWhereClauseSyntax? {
        guard !associatedTypes.isEmpty else { return nil }
        let inheritances = associatedTypes.filter { $0.inheritanceClause != nil }
        let whereClauses = associatedTypes.filter { $0.genericWhereClause != nil }
        guard !(inheritances.isEmpty && whereClauses.isEmpty) else { return nil }
        let requirementList = GenericRequirementListSyntax {
            if let genericWhereClause = protocolDeclaration.genericWhereClause {
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
                        GenericRequirementSyntax(requirement: .conformanceRequirement(
                            ConformanceRequirementSyntax(
                                leftType: IdentifierTypeSyntax(name: type.name),
                                rightType: inheritedType.type
                            )
                        ))
                    }
                }
            }
        }
        return .init(requirements: requirementList)
    }
}
