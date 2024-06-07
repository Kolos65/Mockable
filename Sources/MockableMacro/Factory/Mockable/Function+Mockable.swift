//
//  Function+Mockable.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 23..
//

import SwiftSyntax

// MARK: - FunctionRequirement + Mockable

extension FunctionRequirement: Mockable {
    func implement(with modifiers: DeclModifierListSyntax) throws -> DeclSyntax {
        let decl = FunctionDeclSyntax(
            attributes: syntax.attributes.trimmed.with(\.trailingTrivia, .newline),
            modifiers: modifiers,
            funcKeyword: syntax.funcKeyword.trimmed,
            name: syntax.name.trimmed,
            genericParameterClause: syntax.genericParameterClause?.trimmed,
            signature: syntax.signature.trimmed,
            genericWhereClause: syntax.genericWhereClause?.trimmed,
            body: .init(statements: try body)
        )
        for parameter in decl.signature.parameterClause.parameters {
            guard parameter.type.as(FunctionTypeSyntax.self) == nil else {
                throw MockableMacroError.nonEscapingFunctionParameter
            }
        }
        return DeclSyntax(decl)
    }
}

// MARK: - Helpers

extension FunctionRequirement {
    private var body: CodeBlockItemListSyntax {
        get throws {
            try CodeBlockItemListSyntax {
                try memberDeclaration
                if syntax.isVoid {
                    mockerCall
                } else {
                    returnStatement
                }
            }
        }
    }

    private var memberDeclaration: DeclSyntax {
        get throws {
            let variableDecl = try VariableDeclSyntax(bindingSpecifier: .keyword(.let)) {
                try PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: NS.member),
                        typeAnnotation: TypeAnnotationSyntax(
                            type: IdentifierTypeSyntax(name: NS.Member)
                        ),
                        initializer: InitializerClauseSyntax(
                            value: try caseSpecifier(wrapParams: true)
                        )
                    )
                }
            }
            return DeclSyntax(variableDecl)
        }
    }

    private var returnStatement: StmtSyntax {
        StmtSyntax(ReturnStmtSyntax(expression: mockerCall))
    }

    private var mockerCall: ExprSyntax {
        let call = FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(baseName: NS.mocker),
                declName: DeclReferenceExprSyntax(
                    baseName: syntax.isThrowing ? NS.mockThrowing : NS.mock
                )
            ),
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                LabeledExprSyntax(
                    expression: DeclReferenceExprSyntax(baseName: NS.member)
                )
            },
            rightParen: .rightParenToken(),
            trailingClosure: mockerClosure
        )
        return if syntax.isThrowing {
            ExprSyntax(TryExprSyntax(expression: call))
        } else {
            ExprSyntax(call)
        }
    }

    private var mockerClosure: ClosureExprSyntax {
        ClosureExprSyntax(
            signature: mockerClosureSignature,
            statements: CodeBlockItemListSyntax {
                producerDeclaration
                producerCall
            }
        )
    }

    private var mockerClosureSignature: ClosureSignatureSyntax {
        let paramList = ClosureShorthandParameterListSyntax {
            ClosureShorthandParameterSyntax(name: NS.producer)
        }
        return ClosureSignatureSyntax(parameterClause: .simpleInput(paramList))
    }

    private var producerDeclaration: VariableDeclSyntax {
        VariableDeclSyntax(
            bindingSpecifier: .keyword(.let),
            bindings: PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: NS.producer),
                    initializer: InitializerClauseSyntax(value: producerCast)
                )
            }
        )
    }

    private var producerCast: TryExprSyntax {
        TryExprSyntax(
            expression: AsExprSyntax(
                expression: FunctionCallExprSyntax(
                    calledExpression: DeclReferenceExprSyntax(baseName: NS.cast),
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax {
                        LabeledExprSyntax(
                            expression: DeclReferenceExprSyntax(baseName: NS.producer)
                        )
                    },
                    rightParen: .rightParenToken()
                ),
                type: syntax.closureType
            )
        )
    }

    private var producerCall: ReturnStmtSyntax {
        let producerCallExpr = FunctionCallExprSyntax(
            calledExpression: DeclReferenceExprSyntax(baseName: NS.producer),
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                for parameter in syntax.signature.parameterClause.parameters {
                    LabeledExprSyntax(
                        expression: DeclReferenceExprSyntax(
                            baseName: parameter.secondName?.trimmed ?? parameter.firstName.trimmed
                        )
                    )
                }
            },
            rightParen: .rightParenToken()
        )
        let producerCall = ExprSyntax(producerCallExpr)
        let tryProducerCall = ExprSyntax(TryExprSyntax(expression: producerCall))

        return ReturnStmtSyntax(expression: syntax.isThrowing ? tryProducerCall : producerCall)
    }
}
