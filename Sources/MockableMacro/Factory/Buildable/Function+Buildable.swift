//
//  Function+Buildable.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 23..
//

import SwiftSyntax

// MARK: - FunctionRequirement + Buildable

extension FunctionRequirement: Buildable {
    func builder(
        of kind: BuilderKind,
        with modifiers: DeclModifierListSyntax,
        using mockType: IdentifierTypeSyntax
    ) throws -> DeclSyntax {
        let decl = FunctionDeclSyntax(
            attributes: syntax.attributes.trimmed.with(\.trailingTrivia, .newline),
            modifiers: modifiers,
            name: syntax.name.trimmed,
            genericParameterClause: genericParameterClause(for: kind),
            signature: signature(for: kind, using: mockType),
            genericWhereClause: genericWhereClause(for: kind),
            body: try body(for: kind)
        )
        return DeclSyntax(decl)
    }
}

// MARK: - Helpers

extension FunctionRequirement {
    private func genericParameterClause(for kind: BuilderKind) -> GenericParameterClauseSyntax? {
        switch kind {
        case .return: syntax.genericParameterClause
        case .action: filteredGenericParameterClause
        case .verify: filteredGenericParameterClause
        }
    }

    private func genericWhereClause(for kind: BuilderKind) -> GenericWhereClauseSyntax? {
        switch kind {
        case .return: syntax.genericWhereClause
        case .action: filteredGenericWhereClause
        case .verify: filteredGenericWhereClause
        }
    }

    private func signature(
        for kind: BuilderKind,
        using mockType: IdentifierTypeSyntax
    ) -> FunctionSignatureSyntax {
        FunctionSignatureSyntax(
            parameterClause: parameterClause,
            returnClause: returnClause(for: kind, using: mockType)
        )
    }

    private var parameterClause: FunctionParameterClauseSyntax {
        let parameters = FunctionParameterListSyntax {
            for parameter in syntax.signature.parameterClause.parameters {
                FunctionParameterSyntax(
                    firstName: parameter.firstName,
                    secondName: parameter.secondName,
                    type: IdentifierTypeSyntax(name: NS.Parameter(parameter.resolvedType.description))
                )
            }
        }
        return FunctionParameterClauseSyntax(parameters: parameters)
    }

    private func returnClause(
        for kind: BuilderKind,
        using mockType: IdentifierTypeSyntax
    ) -> ReturnClauseSyntax {
        let name = syntax.isThrowing ? NS.ThrowingFunction(kind) : NS.Function(kind)
        let arguments = GenericArgumentListSyntax {
            GenericArgumentSyntax(argument: mockType)
            GenericArgumentSyntax(argument: kind.type)
            if let returnType = functionReturnType(for: kind) {
                returnType
            }
            if syntax.isThrowing && kind == .return {
                // TODO: Get Error Type
                GenericArgumentSyntax(argument: IdentifierTypeSyntax(name: "Error"))
            }
            if let produceType = functionProduceType(for: kind) {
                produceType
            }
        }
        return ReturnClauseSyntax(
            type: IdentifierTypeSyntax(
                name: name,
                genericArgumentClause: .init(arguments: arguments)
            )
        )
    }

    private func functionReturnType(for kind: BuilderKind) -> GenericArgumentSyntax? {
        guard kind == .return else { return nil }
        guard let returnClause = syntax.signature.returnClause else {
            let voidType = IdentifierTypeSyntax(name: NS.Void)
            return GenericArgumentSyntax(argument: voidType)
        }
        return GenericArgumentSyntax(argument: returnClause.type)
    }

    private func functionProduceType(for kind: BuilderKind) -> GenericArgumentSyntax? {
        guard kind == .return else { return nil }
        return GenericArgumentSyntax(argument: syntax.closureType)
    }

    private func body(for kind: BuilderKind) throws -> CodeBlockSyntax {
        let arguments = try LabeledExprListSyntax {
            LabeledExprSyntax(
                expression: DeclReferenceExprSyntax(baseName: NS.mocker)
            )
            LabeledExprSyntax(
                label: NS.kind,
                colon: .colonToken(),
                expression: try caseSpecifier(wrapParams: false)
            )
            if kind == .verify {
                LabeledExprSyntax(
                    label: NS.assertion,
                    colon: .colonToken(),
                    expression: DeclReferenceExprSyntax(baseName: NS.assertion)
                )
            }
        }
        let statements = CodeBlockItemListSyntax {
            FunctionCallExprSyntax(
                calledExpression: MemberAccessExprSyntax(name: NS.initializer),
                leftParen: .leftParenToken(),
                arguments: arguments,
                rightParen: .rightParenToken()
            )
        }
        return .init(statements: statements)
    }

    /// Returns the function's generic parameter clause with return only generics filtered out.
    /// If a generic parameter is only used in the return clause of a function, it will not
    /// be part of the returned generic parameter clause.
    private var filteredGenericParameterClause: GenericParameterClauseSyntax? {
        guard let generics = syntax.genericParameterClause else { return nil }
        var parameters = generics.parameters.filter { generic in
            hasParameter(containing: generic.name.trimmedDescription)
        }
        if let lastIndex = parameters.indices.last {
            parameters[lastIndex] = parameters[lastIndex].with(\.trailingComma, nil)
        }
        return parameters.isEmpty ? nil : .init(parameters: parameters)
    }

    /// Returns the function's generic where clause with return only generics filtered out.
    /// If a generic parameter is only used in the return clause of a function, it will not
    /// be part of the returned generic where clause.
    private var filteredGenericWhereClause: GenericWhereClauseSyntax? {
        guard let generics = syntax.genericWhereClause else { return nil }
        var requirements = generics.requirements.filter { requirement in
            switch requirement.requirement {
            case .conformanceRequirement(let conformance):
                return hasParameter(containing: conformance.leftType.trimmedDescription)
            case .sameTypeRequirement(let sameType):
                return hasParameter(containing: sameType.leftType.trimmedDescription)
            default:
                return false
            }
        }
        if let lastIndex = requirements.indices.last {
            var last = requirements[lastIndex]
            last.trailingComma = nil
            requirements[lastIndex] = last
        }
        let whereClause = GenericWhereClauseSyntax(requirements: requirements)
            .with(\.trailingTrivia, .space)
        return requirements.isEmpty ? nil : whereClause
    }

    private func hasParameter(containing identifier: String) -> Bool {
        nil != TokenFinder.find(in: syntax.signature.parameterClause) {
            $0.tokenKind == .identifier(identifier)
        }
    }
}
