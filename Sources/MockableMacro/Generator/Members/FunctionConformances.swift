//
//  FunctionConformances.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 16..
//

import SwiftSyntax
import SwiftSyntaxMacros

struct FunctionConformances {

    // MARK: Private Properties

    private let protocolDeclaration: ProtocolDeclSyntax
    private let functions: [FunctionDeclaration]

    // MARK: Init

    init(_ protocolDeclaration: ProtocolDeclSyntax, _ functions: [FunctionDeclaration]) {
        self.protocolDeclaration = protocolDeclaration
        self.functions = functions
    }

    // MARK: Properties

    var members: [MemberBlockItemSyntax] {
        get throws {
            try functions.map { .init(decl: try implement($0)) }
        }
    }
}

// MARK: - Helpers

extension FunctionConformances {
    private func implement(_ function: FunctionDeclaration) throws -> FunctionDeclSyntax {
        var attributes = function.syntax.attributes.trimmed
        attributes.trailingTrivia = .newline
        var decl = FunctionDeclSyntax(
            attributes: attributes,
            modifiers: protocolDeclaration.modifiers.trimmed,
            funcKeyword: function.syntax.funcKeyword.trimmed,
            name: function.syntax.name.trimmed,
            genericParameterClause: function.syntax.genericParameterClause?.trimmed,
            signature: function.syntax.signature.trimmed,
            genericWhereClause: function.syntax.genericWhereClause?.trimmed
        )
        decl.modifiers = protocolDeclaration.modifiers
        for parameter in decl.signature.parameterClause.parameters {
            guard parameter.type.as(FunctionTypeSyntax.self) == nil else {
                throw MockableMacroError.nonEscapingFunctionParameter
            }
        }
        decl.body = .init(statements: .init(stringLiteral: body(for: function)))
        return decl
    }

    private func body(for function: FunctionDeclaration) -> String {
        let names = function.syntax.signature.parameterClause.parameters.map { $0.secondName ?? $0.firstName }
        let paramList = names.map(\.trimmedDescription).joined(separator: ", ")
        return """
        \(memberSpecifier(for: function))
        \(function.isVoid ? "" : "return ")\(function.isThrowing ? "try" : "try!") mocker.mock(member) { producer in
            let producer = try cast(producer) as \(function.closureType)
            return \(function.isThrowing ? "try " : "")producer(\(paramList))
        }
        """
    }

    private func memberSpecifier(for function: FunctionDeclaration) -> String {
        var memberParams = ""
        if let parameterClause = function.enumParameterClause {
            let paramList = zip(parameterClause.parameters, function.parameters)
                .map { enumParameter, functionParameter in
                    let paramName = enumParameter.firstName?.trimmedDescription.appending(": ") ?? ""
                    let isGeneric = function.containsGenericType(in: functionParameter)
                    let functionParamName = functionParameter.secondName ?? functionParameter.firstName
                    let paramValue = isGeneric ? ".generic(\(functionParamName))" : ".value(\(functionParamName))"
                    return "\(paramName)\(paramValue)"
                }
                .joined(separator: ", ")
            memberParams = "(\(paramList))"
        }
        return "let member: Member = .\(function.enumName)\(memberParams)"
    }
}
