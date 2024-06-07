//
//  Variable+Buildable.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 23..
//

import SwiftSyntax

// MARK: - VariableRequirement + Buildable

extension VariableRequirement: Buildable {
    func builder(
        of kind: BuilderKind,
        with modifiers: DeclModifierListSyntax,
        using mockType: IdentifierTypeSyntax
    ) throws -> DeclSyntax {
        if syntax.isComputed || kind == .return {
            return try variableDeclaration(of: kind, with: modifiers, using: mockType)
        } else {
            return try functionDeclaration(of: kind, with: modifiers, using: mockType)
        }
    }
}

// MARK: - Helpers

extension VariableRequirement {
    func variableDeclaration(
        of kind: BuilderKind,
        with modifiers: DeclModifierListSyntax,
        using mockType: IdentifierTypeSyntax
    ) throws -> DeclSyntax {
        let variableDecl = VariableDeclSyntax(
            attributes: syntax.attributes.trimmed.with(\.trailingTrivia, .newline),
            modifiers: modifiers,
            bindingSpecifier: .keyword(.var),
            bindings: try PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: try syntax.binding.pattern,
                    typeAnnotation: TypeAnnotationSyntax(
                        type: try returnType(for: kind, using: mockType)
                    ),
                    accessorBlock: AccessorBlockSyntax(
                        accessors: .getter(try body(for: kind))
                    )
                )
            }
        )
        return DeclSyntax(variableDecl)
    }

    private func functionDeclaration(
        of kind: BuilderKind,
        with modifiers: DeclModifierListSyntax,
        using mockType: IdentifierTypeSyntax
    ) throws -> DeclSyntax {
        let functionDecl = FunctionDeclSyntax(
            attributes: syntax.attributes.trimmed.with(\.trailingTrivia, .newline),
            modifiers: modifiers,
            name: try syntax.name,
            signature: try signature(for: kind, using: mockType),
            body: .init(statements: try body(for: kind))
        )
        return DeclSyntax(functionDecl)
    }

    private func signature(
        for kind: BuilderKind,
        using mockType: IdentifierTypeSyntax
    ) throws -> FunctionSignatureSyntax {
        let parameters = try FunctionParameterListSyntax {
            FunctionParameterSyntax(
                firstName: NS.newValue,
                type: IdentifierTypeSyntax(
                    name: NS.Parameter(try syntax.resolvedType.trimmedDescription)
                ),
                defaultValue: InitializerClauseSyntax(
                    value: MemberAccessExprSyntax(name: NS.any)
                )
            )
        }
        return FunctionSignatureSyntax(
            parameterClause: FunctionParameterClauseSyntax(parameters: parameters),
            returnClause: ReturnClauseSyntax(
                type: try returnType(for: kind, using: mockType)
            )
        )
    }

    private func returnType(
        for kind: BuilderKind,
        using mockType: IdentifierTypeSyntax
    ) throws -> IdentifierTypeSyntax {
        let name = if syntax.isComputed {
            try syntax.isThrowing ? NS.ThrowingFunction(kind) : NS.Function(kind)
        } else {
            try syntax.isThrowing ? NS.ThrowingProperty(kind) : NS.Property(kind)
        }

        let arguments = try GenericArgumentListSyntax {
            GenericArgumentSyntax(argument: mockType)
            GenericArgumentSyntax(argument: kind.type)
            if let returnType = try variableReturnType(for: kind) {
                returnType
            }
            if let produceType = try variableProduceType(for: kind) {
                produceType
            }
        }
        return IdentifierTypeSyntax(
            name: name,
            genericArgumentClause: .init(arguments: arguments)
        )
    }

    private func variableReturnType(for kind: BuilderKind) throws -> GenericArgumentSyntax? {
        guard kind == .return else { return nil }
        return GenericArgumentSyntax(argument: try syntax.resolvedType)
    }

    private func variableProduceType(for kind: BuilderKind) throws -> GenericArgumentSyntax? {
        guard kind == .return, syntax.isComputed else { return nil }
        return GenericArgumentSyntax(argument: try syntax.closureType)
    }

    private func body(for kind: BuilderKind) throws -> CodeBlockItemListSyntax {
        let arguments = try LabeledExprListSyntax {
            LabeledExprSyntax(
                expression: DeclReferenceExprSyntax(baseName: NS.mocker)
            )
            LabeledExprSyntax(
                label: NS.kind,
                colon: .colonToken(),
                expression: try caseSpecifier(wrapParams: false)
            )
            if kind != .return, let setterSpecifier = try setterCaseSpecifier(wrapParams: false) {
                LabeledExprSyntax(
                    label: NS.setKind,
                    colon: .colonToken(),
                    expression: setterSpecifier
                )
            }
            if kind == .verify {
                LabeledExprSyntax(
                    label: NS.assertion,
                    colon: .colonToken(),
                    expression: DeclReferenceExprSyntax(baseName: NS.assertion)
                )
            }
        }
        return CodeBlockItemListSyntax {
            FunctionCallExprSyntax(
                calledExpression: MemberAccessExprSyntax(name: NS._init),
                leftParen: .leftParenToken(),
                arguments: arguments,
                rightParen: .rightParenToken()
            )
        }
    }
}
