//
//  EnumFactory.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 12..
//

import SwiftSyntax

/// Factory to generate the `Member` enum.
///
/// Generates an enum that represents the given requirements as an enum case.
/// The enum declaration also contains the implementation of the `match(_:)` function.
enum EnumFactory: Factory {
    static func build(from requirements: Requirements) throws -> EnumDeclSyntax {
        EnumDeclSyntax(
            modifiers: requirements.syntax.modifiers,
            name: NS.Member,
            inheritanceClause: inheritanceClause,
            memberBlock: MemberBlockSyntax(members: try members(requirements))
        )
    }
}

// MARK: - Helpers

extension EnumFactory {
    private static var inheritanceClause: InheritanceClauseSyntax {
        InheritanceClauseSyntax {
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: NS.Matchable))
            InheritedTypeSyntax(type: IdentifierTypeSyntax(name: NS.CaseIdentifiable))
        }
    }

    private static func members(_ requirements: Requirements) throws -> MemberBlockItemListSyntax {
        try MemberBlockItemListSyntax {
            for enumCase in try enumCaseDeclarations(requirements) {
                enumCase
            }
            try matcherFunction(requirements)
        }
    }

    private static func enumCaseDeclarations(_ requirements: Requirements) throws -> [EnumCaseDeclSyntax] {
        var cases = [EnumCaseDeclSyntax]()
        for variable in requirements.variables {
            cases += try variable.caseDeclarations
        }
        for function in requirements.functions {
            cases += try function.caseDeclarations
        }
        return cases
    }

    private static func matcherFunction(_ requirements: Requirements) throws -> MemberBlockItemSyntax {
        let param = FunctionParameterSyntax(
            firstName: .wildcardToken(),
            secondName: NS.other,
            type: IdentifierTypeSyntax(name: NS.Member)
        )
        let returnType = IdentifierTypeSyntax(name: NS.Bool)
        let signature = FunctionSignatureSyntax(
            parameterClause: .init(parameters: [param]),
            returnClause: .init(type: returnType)
        )
        let statement = try CodeBlockItemListSyntax {
            try matcherSwitch(requirements)
        }
        let decl = FunctionDeclSyntax(
            modifiers: requirements.syntax.modifiers,
            name: NS.match,
            signature: signature,
            body: .init(statements: statement)
        )
        return .init(decl: decl)
    }

    private static func matcherSwitch(_ requirements: Requirements) throws -> ExprSyntax {
        let subject = TupleExprSyntax {
            LabeledExprListSyntax {
                LabeledExprSyntax(
                    expression: DeclReferenceExprSyntax(baseName: .keyword(.self))
                )
                LabeledExprSyntax(
                    expression: DeclReferenceExprSyntax(baseName: NS.other)
                )
            }
        }

        let cases = try enumCaseDeclarations(requirements)

        return try SwitchExprSyntax(subject: subject) {
            try SwitchCaseListSyntax {
                for caseDeclaration in cases {
                    try matcherCase(for: caseDeclaration)
                }
                if cases.count > 1 {
                    defaultCase
                }
            }
        }
        .cast(ExprSyntax.self)
    }

    private static var defaultCase: SwitchCaseSyntax {
        let label = SwitchDefaultLabelSyntax()
        let returnStmt = ReturnStmtSyntax(
            expression: BooleanLiteralExprSyntax(false)
        ).cast(StmtSyntax.self)

        return SwitchCaseSyntax(
            label: .default(label),
            statements: CodeBlockItemListSyntax { returnStmt }
        )
    }

    private static func matcherCase(for enumDeclaration: EnumCaseDeclSyntax) throws -> SwitchCaseSyntax {
        guard let enumCase = enumDeclaration.elements.first else {
            throw MockableMacroError.invalidDerivedEnumCase
        }
        let switchCaseLabel = try SwitchCaseLabelSyntax {
            SwitchCaseItemSyntax(
                pattern: ExpressionPatternSyntax(
                    expression: try matcherCaseExpr(for: enumCase)
                )
            )
        }
        let statements = CodeBlockItemListSyntax {
            matcherCaseBody(for: enumCase)
        }
        return SwitchCaseSyntax(
            label: .case(switchCaseLabel),
            statements: statements
        )
    }

    private static func matcherCaseExpr(for enumCase: EnumCaseElementSyntax) throws -> TupleExprSyntax {
        let parameters = enumCase.parameterClause?.parameters ?? []
        let leftCase = matcherCaseSide(enumCase.name, parameters, prefix: NS.left)
        let rightCase = matcherCaseSide(enumCase.name, parameters, prefix: NS.right)

        return TupleExprSyntax {
            LabeledExprListSyntax {
                LabeledExprSyntax(expression: leftCase)
                LabeledExprSyntax(expression: rightCase)
            }
        }
    }

    private static func matcherCaseSide(
        _ name: TokenSyntax,
        _ parameters: EnumCaseParameterListSyntax,
        prefix: TokenSyntax
    ) -> ExprSyntax {
        let memberAccess = MemberAccessExprSyntax(
            declName: DeclReferenceExprSyntax(baseName: name)
        )

        guard !parameters.isEmpty else {
            return memberAccess.cast(ExprSyntax.self)
        }

        return FunctionCallExprSyntax(
            calledExpression: memberAccess,
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                for (index, parameter) in parameters.enumerated() {
                    LabeledExprSyntax(
                        label: parameter.firstName,
                        colon: parameter.firstName != nil ? .colonToken() : nil,
                        expression: parameterExpression(for: parameter, at: index, prefix: prefix)
                    )
                }
            },
            rightParen: .rightParenToken()
        )
        .cast(ExprSyntax.self)
    }

    private static func parameterExpression(
        for param: EnumCaseParameterSyntax,
        at index: Int,
        prefix: TokenSyntax
    ) -> PatternExprSyntax {
        return PatternExprSyntax(
            pattern: ValueBindingPatternSyntax(
                bindingSpecifier: .keyword(.let),
                pattern: IdentifierPatternSyntax(
                    identifier: parameterName(param, index: index, prefix: prefix)
                )
            )
        )
    }

    private static func parameterName(
        _ param: EnumCaseParameterSyntax,
        index: Int,
        prefix: TokenSyntax
    ) -> TokenSyntax {
        let patternId = param.firstName ?? NS.Param(suffix: String(index + 1))
        let name = prefix.description + patternId.trimmed.description.capitalizedFirstLetter
        return .identifier(name)
    }

    private static func matcherCaseBody(for enumCase: EnumCaseElementSyntax) -> StmtSyntax {
        let parameters = enumCase.parameterClause?.parameters ?? []

        guard !parameters.isEmpty else {
            let returnStmt = ReturnStmtSyntax(expression: BooleanLiteralExprSyntax(true))
            return returnStmt.cast(StmtSyntax.self)
        }

        let leftNames = parameters.enumerated().map { index, element in
            parameterName(element, index: index, prefix: NS.left)
        }
        let rightNames = parameters.enumerated().map { index, element in
            parameterName(element, index: index, prefix: NS.right)
        }

        var expression: ExprSyntax!
        for (leftName, rightName) in zip(leftNames, rightNames) {
            guard expression != nil else {
                expression = matchCall(leftName, rightName)
                continue
            }
            expression = InfixOperatorExprSyntax(
                leftOperand: expression,
                operator: BinaryOperatorExprSyntax(operator: .binaryOperator(NS._andSign)),
                rightOperand: matchCall(leftName, rightName)
            )
            .cast(ExprSyntax.self)
        }
        return ReturnStmtSyntax(expression: expression).cast(StmtSyntax.self)
    }

    private static func matchCall(_ leftName: TokenSyntax, _ rightName: TokenSyntax) -> ExprSyntax {
        FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(baseName: leftName),
                declName: DeclReferenceExprSyntax(baseName: NS.match)
            ),
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                LabeledExprSyntax(
                    expression: DeclReferenceExprSyntax(baseName: rightName)
                )
            },
            rightParen: .rightParenToken()
        )
        .cast(ExprSyntax.self)
    }
}
