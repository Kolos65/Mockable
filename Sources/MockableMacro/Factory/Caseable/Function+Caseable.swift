//
//  Function+Caseable.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2023. 12. 07..
//

import SwiftSyntax
import Foundation

// MARK: - FunctionRequirement + Caseable

extension FunctionRequirement: Caseable {
    var caseDeclarations: [EnumCaseDeclSyntax] {
        get throws {
            let enumCase = EnumCaseElementSyntax(
                name: caseExpression.declName.baseName,
                parameterClause: enumParameterClause
            )
            let elements: EnumCaseElementListSyntax = .init(arrayLiteral: enumCase)
            return [EnumCaseDeclSyntax(elements: elements)]
        }
    }

    func caseSpecifier(wrapParams: Bool) throws -> ExprSyntax {
        guard let parameters = parameters(wrap: wrapParams) else {
            return ExprSyntax(caseExpression)
        }
        let functionCallExpr = FunctionCallExprSyntax(
            calledExpression: caseExpression,
            leftParen: .leftParenToken(),
            arguments: parameters,
            rightParen: .rightParenToken()
        )
        return ExprSyntax(functionCallExpr)
    }

    func setterCaseSpecifier(wrapParams: Bool) -> ExprSyntax? { nil }
}

// MARK: - Helpers

extension FunctionRequirement {
    private var caseExpression: MemberAccessExprSyntax {
        let indexPrefix = String(index + 1)
        let specialEnclosingCharacters: CharacterSet = ["`"]
        let caseName = syntax.name.trimmedDescription.trimmingCharacters(in: specialEnclosingCharacters)
        return MemberAccessExprSyntax(
            name: .identifier("m\(indexPrefix)_\(caseName)")
        )
    }

    private func parameters(wrap: Bool) -> LabeledExprListSyntax? {
        guard let parameterClause = enumParameterClause else { return nil }
        let functionParameters = syntax.signature.parameterClause.parameters
        let zippedParameters = zip(parameterClause.parameters, functionParameters)
        let enumeratedParameters = zippedParameters.enumerated()
        let lastIndex = enumeratedParameters.map(\.offset).last
        return LabeledExprListSyntax {
            for (index, element) in enumeratedParameters {
                let (enumParameter, functionParameter) = element
                let hasComma = index != lastIndex && lastIndex != 0
                let hasColon = enumParameter.firstName != nil
                LabeledExprSyntax(
                    label: enumParameter.firstName,
                    colon: hasColon ? .colonToken() : nil,
                    expression: parameterExpression(
                        for: functionParameter,
                        wrapParams: wrap
                    ),
                    trailingComma: hasComma ? .commaToken() : nil
                )
            }
        }
    }

    private var enumParameterClause: EnumCaseParameterClauseSyntax? {
        guard !syntax.signature.parameterClause.parameters.isEmpty else { return nil }
        let enumParameters: EnumCaseParameterListSyntax = .init {
            for parameter in syntax.signature.parameterClause.parameters {
                let firstName = parameter.firstName.tokenKind == .wildcard
                    ? nil : parameter.firstName.trimmed
                EnumCaseParameterSyntax(
                    firstName: firstName,
                    colon: firstName == nil ? nil : .colonToken(),
                    type: wrappedType(for: parameter)
                )
            }
        }
        return .init(parameters: enumParameters)
    }

    private func wrappedType(for parameter: FunctionParameterSyntax) -> IdentifierTypeSyntax {
        let type = parameter.resolvedType().description
        let isGeneric = syntax.containsGenericType(in: parameter)
        let identifier = isGeneric ? NS.GenericValue : type
        return IdentifierTypeSyntax(name: NS.Parameter(identifier))
    }

    private func parameterExpression(for functionParameter: FunctionParameterSyntax, wrapParams: Bool) -> ExprSyntax {
        if wrapParams {
            wrappedParameterExpression(for: functionParameter)
        } else {
            parameterExpression(for: functionParameter)
        }
    }

    private func wrappedParameterExpression(for functionParameter: FunctionParameterSyntax) -> ExprSyntax {
        let isGeneric = syntax.containsGenericType(in: functionParameter)
        let functionParamName = functionParameter.secondName ?? functionParameter.firstName
        let functionCallExpr = FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(name: isGeneric ? NS.generic : NS.value),
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                LabeledExprSyntax(expression: DeclReferenceExprSyntax(baseName: functionParamName))
            },
            rightParen: .rightParenToken()
        )
        return ExprSyntax(functionCallExpr)
    }

    private func parameterExpression(for functionParameter: FunctionParameterSyntax) -> ExprSyntax {
        let isGeneric = syntax.containsGenericType(in: functionParameter)
        let functionParamName = functionParameter.secondName ?? functionParameter.firstName
        if isGeneric {
            return ExprSyntax(
                FunctionCallExprSyntax(
                    calledExpression: MemberAccessExprSyntax(
                        base: DeclReferenceExprSyntax(baseName: functionParamName),
                        name: NS.eraseToGenericValue
                    ),
                    leftParen: .leftParenToken(),
                    arguments: [],
                    rightParen: .rightParenToken()
                )
            )
        } else {
            return ExprSyntax(
                DeclReferenceExprSyntax(baseName: functionParamName)
            )
        }
    }
}
