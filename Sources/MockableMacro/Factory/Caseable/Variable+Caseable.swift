//
//  Variable+Caseable.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 10..
//

import SwiftSyntax

// MARK: - VariableRequirement + Caseable

extension VariableRequirement: Caseable {
    var caseDeclarations: [EnumCaseDeclSyntax] {
        get throws {
            [try getterEnumCaseDeclaration, try setterEnumCaseDeclaration].compactMap { $0 }
        }
    }

    func caseSpecifier(wrapParams: Bool) throws -> ExprSyntax {
        ExprSyntax(MemberAccessExprSyntax(name: try getterEnumName))
    }

    func setterCaseSpecifier(wrapParams: Bool) throws -> ExprSyntax? {
        guard let setterName = try setterEnumName else { return nil }
        let functionCallExpr = FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(name: setterName),
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                LabeledExprSyntax(
                    label: NS.newValue,
                    colon: .colonToken(),
                    expression: wrapParams ? wrappedSetterParameters : setterParameters
                )
            },
            rightParen: .rightParenToken()
        )
        return ExprSyntax(functionCallExpr)
    }
}

// MARK: - Helpers

extension VariableRequirement {
    private func enumName(prefix: String = "") throws -> TokenSyntax {
        .identifier("m\(String(index + 1))_\(prefix)\(try syntax.name)")
    }

    private var getterEnumName: TokenSyntax {
        get throws {
            syntax.isComputed ? try enumName() : try enumName(prefix: NS.get_)
        }
    }

    private var setterEnumName: TokenSyntax? {
        get throws {
            syntax.isComputed ? nil : try enumName(prefix: NS.set_)
        }
    }

    private var setterParameters: ExprSyntax {
        ExprSyntax(DeclReferenceExprSyntax(baseName: NS.newValue))
    }

    private var wrappedSetterParameters: ExprSyntax {
        let functionCallExpr = FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(name: NS.value),
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                LabeledExprSyntax(expression: DeclReferenceExprSyntax(baseName: NS.newValue))
            },
            rightParen: .rightParenToken()
        )
        return ExprSyntax(functionCallExpr)
    }

    private var getterEnumCaseDeclaration: EnumCaseDeclSyntax {
        get throws {
            let getterCase = EnumCaseElementSyntax(name: try getterEnumName)
            let elements: EnumCaseElementListSyntax = .init(arrayLiteral: getterCase)
            return EnumCaseDeclSyntax(elements: elements)
        }
    }

    private var setterEnumCaseDeclaration: EnumCaseDeclSyntax? {
        get throws {
            guard let setterName = try setterEnumName else { return nil }
            let setterCase = EnumCaseElementSyntax(
                name: setterName,
                parameterClause: try setterEnumParameterClause
            )
            let elements: EnumCaseElementListSyntax = .init(arrayLiteral: setterCase)
            return EnumCaseDeclSyntax(elements: elements)
        }
    }

    private var wrappedType: IdentifierTypeSyntax {
        get throws {
            let baseType = try syntax.resolvedType.trimmedDescription
            return IdentifierTypeSyntax(name: NS.Parameter(baseType))
        }
    }

    private var setterEnumParameterClause: EnumCaseParameterClauseSyntax? {
        get throws {
            guard !syntax.isComputed else { return nil }
            let parameter = EnumCaseParameterSyntax(
                firstName: NS.newValue,
                colon: .colonToken(),
                type: try wrappedType
            )
            return EnumCaseParameterClauseSyntax(
                parameters: EnumCaseParameterListSyntax([parameter])
            )
        }
    }
}
