//
//  MemberEnum.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 17..
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

struct MemberEnum {

    // MARK: Private Properties

    private let protocolDeclaration: ProtocolDeclSyntax
    private var functions: [FunctionDeclaration]
    private var variables: [VariableDeclaration]

    // MARK: Init

    init(_ protocolDeclaration: ProtocolDeclSyntax, _ members: MemberDeclarations) {
        self.protocolDeclaration = protocolDeclaration
        self.variables = members.variables
        self.functions = members.functions
    }

    // MARK: Properties

    var memberBlockItem: MemberBlockItemSyntax {
        get throws {
            .init(decl: try enumDeclaration)
        }
    }
}

// MARK: - Helpers

extension MemberEnum {
    private var enumDeclaration: EnumDeclSyntax {
        get throws {
            .init(
                modifiers: modifiers,
                name: name,
                inheritanceClause: inheritanceClause,
                memberBlock: .init(members: try memberBlockItemList)
            )
        }
    }

    private var modifiers: DeclModifierListSyntax {
        protocolDeclaration.modifiers
    }

    private var name: TokenSyntax {
        .identifier("Member")
    }

    private var inheritanceClause: InheritanceClauseSyntax {
        .init {
            InheritedTypeSyntax(
                type: IdentifierTypeSyntax(name: .identifier("Matchable"))
            )
            InheritedTypeSyntax(
                type: IdentifierTypeSyntax(name: .identifier("CaseIdentifiable"))
            )
        }
    }

    private var memberBlockItemList: MemberBlockItemListSyntax {
        get throws {
            try .init {
                for enumCase in try enumCaseDeclarations {
                    enumCase
                }
                try matcherDeclaration
            }
        }
    }
}

// MARK: - Enum Cases

extension MemberEnum {
    private var enumCaseDeclarations: [EnumCaseDeclSyntax] {
        get throws {
            var cases = [EnumCaseDeclSyntax]()
            for variable in variables {
                cases.append(try variable.getterEnumCaseDeclaration)
                if let setterEnumCaseDeclaration = try variable.setterEnumCaseDeclaration {
                    cases.append(setterEnumCaseDeclaration)
                }
            }
            for function in functions {
                cases.append(try function.enumCaseDeclaration)
            }
            return cases
        }
    }
}

// MARK: - Match Function

extension MemberEnum {
    private var matcherDeclaration: MemberBlockItemSyntax {
        get throws {
            let param = FunctionParameterSyntax(
                firstName: .wildcardToken(),
                secondName: .identifier("other"),
                type: IdentifierTypeSyntax(name: .identifier("Member"))
            )
            let returnType = IdentifierTypeSyntax(name: .identifier("Bool"))
            let signature = FunctionSignatureSyntax(
                parameterClause: .init(parameters: [param]),
                returnClause: .init(type: returnType)
            )
            let statement = CodeBlockItemListSyntax(arrayLiteral: try matcherImplementation)
            let decl = FunctionDeclSyntax(
                modifiers: protocolDeclaration.modifiers,
                name: .identifier("match"),
                signature: signature,
                body: .init(statements: statement)
            )
            return .init(decl: decl)
        }
    }

    private var matcherImplementation: CodeBlockItemSyntax {
        get throws {
            var caseDeclarations = try enumCaseDeclarations
                .map { try matcher(for: $0) }
            let defaultCase = caseDeclarations.count < 2 ? "" : """
            default:
                return false
            """
            caseDeclarations.append(defaultCase)
            let cases = caseDeclarations.joined(separator: "\n")
            return .init(stringLiteral: """
            switch (self, other) {
            \(cases)
            }
            """)
        }
    }

    private func matcher(for enumDeclaration: EnumCaseDeclSyntax) throws -> String {
        guard let element = enumDeclaration.elements.first else {
            throw MockableMacroError.invalidDerivedEnumCase
        }
        let name = element.name.trimmedDescription
        let (leftParams, leftNames) = matcherCaseParameters(
            element.parameterClause,
            prefix: "left"
        )
        let (rightParams, rightNames) = matcherCaseParameters(
            element.parameterClause,
            prefix: "right"
        )
        return """
        case (.\(name)\(leftParams), .\(name)\(rightParams)):
            \(matcherCaseBody(leftNames: leftNames, rightNames: rightNames))
        """
    }

    private func matcherCaseBody(leftNames: [String], rightNames: [String]) -> String {
        guard !leftNames.isEmpty else { return "return true" }
        let comparisons = zip(leftNames, rightNames).map { leftName, rightName in
            "\(leftName).match(\(rightName))"
        }
        return "return \(comparisons.joined(separator: " && "))"
    }

    private func matcherCaseParameters(_ paramClause: EnumCaseParameterClauseSyntax?,
                                       prefix: String) -> (paramDecl: String, names: [String]) {
        guard let paramClause else { return ("", []) }
        var paramDecl = [String]()
        var names = [String]()
        for (index, param) in paramClause.parameters.enumerated() {
            if let firstName = param.firstName {
                let name = "\(prefix)\(firstName.trimmedDescription.capitalizedFirstLetter)"
                paramDecl.append("\(firstName.trimmedDescription): let \(name)")
                names.append(name)
            } else {
                let name = "\(prefix)Param\(index + 1)"
                paramDecl.append("let \(name)")
                names.append(name)
            }
        }
        let decl = "(\(paramDecl.joined(separator: ", ")))"
        return (decl, names)
    }
}
