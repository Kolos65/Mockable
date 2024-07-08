//
//  Variable+Mockable.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 23..
//

import SwiftSyntax

// MARK: - VariableRequirement + Mockable

extension VariableRequirement: Mockable {
    func implement(with modifiers: DeclModifierListSyntax) throws -> DeclSyntax {
        let variableDecl = VariableDeclSyntax(
            attributes: syntax.attributes.trimmed.with(\.trailingTrivia, .newline),
            modifiers: declarationModifiers(extending: modifiers),
            bindingSpecifier: .keyword(.var),
            bindings: try PatternBindingListSyntax {
                try syntax.binding.with(\.accessorBlock, accessorBlock)
            }
        )
        return DeclSyntax(variableDecl)
    }
}

// MARK: - Helpers

extension VariableRequirement {
    private func declarationModifiers(extending modifiers: DeclModifierListSyntax) -> DeclModifierListSyntax {
        let filtered = syntax.modifiers.filtered(keywords: [.nonisolated])
        return modifiers.trimmed.appending(filtered.trimmed)
    }

    private var accessorBlock: AccessorBlockSyntax {
        get throws {
            AccessorBlockSyntax(accessors: .accessors(try accessorDeclList))
        }
    }

    private var accessorDeclList: AccessorDeclListSyntax {
        get throws {
            try AccessorDeclListSyntax {
                try getterDecl
                if let setterDecl = try setterDecl {
                    setterDecl
                }
            }
        }
    }

    private var getterDecl: AccessorDeclSyntax {
        get throws {
            let caseSpecifier = try caseSpecifier(wrapParams: true)
            let mockerCall = try mockerCall
            let body = CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    memberDeclaration(caseSpecifier)
                    ReturnStmtSyntax(expression: mockerCall)
                }
            )
            return try syntax.getAccessor.with(\.body, body)
        }
    }

    private var setterDecl: AccessorDeclSyntax? {
        get throws {
            guard let caseSpecifier = try setterCaseSpecifier(wrapParams: true),
                  let setAccessor = syntax.setAccessor else { return nil }
            let body = CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    memberDeclaration(caseSpecifier)
                    mockerCall(memberName: NS.addInvocation)
                    mockerCall(memberName: NS.performActions)
                }
            )
            return setAccessor.with(\.body, body)
        }
    }

    private var mockerCall: ExprSyntax {
        get throws {
            let call = FunctionCallExprSyntax(
                calledExpression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(baseName: NS.mocker),
                    declName: DeclReferenceExprSyntax(
                        baseName: try syntax.isThrowing ? NS.mockThrowing : NS.mock
                    )
                ),
                leftParen: .leftParenToken(),
                arguments: try LabeledExprListSyntax {
                    LabeledExprSyntax(
                        expression: DeclReferenceExprSyntax(baseName: NS.member)
                    )
                    if let errorTypeExpression = try errorTypeExpression {
                        errorTypeExpression
                    }
                },
                rightParen: .rightParenToken(),
                trailingClosure: try mockerClosure
            )
            return if try syntax.isThrowing {
                ExprSyntax(TryExprSyntax(expression: call))
            } else {
                ExprSyntax(call)
            }
        }
    }

    private var errorTypeExpression: LabeledExprSyntax? {
        get throws {
            #if canImport(SwiftSyntax600)
            guard let type = try syntax.errorType else { return nil }
            return LabeledExprSyntax(
                label: NS.error,
                colon: .colonToken(),
                expression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(baseName: .identifier(type.trimmedDescription)),
                    declName: DeclReferenceExprSyntax(baseName: .keyword(.`self`))
                )
            )
            #else
            return nil
            #endif
        }
    }

    private func memberDeclaration(_ caseSpecifier: ExprSyntax) -> VariableDeclSyntax {
        VariableDeclSyntax(bindingSpecifier: .keyword(.let)) {
            PatternBindingListSyntax {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: NS.member),
                    typeAnnotation: TypeAnnotationSyntax(
                        type: IdentifierTypeSyntax(name: NS.Member)
                    ),
                    initializer: InitializerClauseSyntax(value: caseSpecifier)
                )
            }
        }
    }

    private var mockerClosure: ClosureExprSyntax {
        get throws {
            ClosureExprSyntax(
                signature: mockerClosureSignature,
                statements: try CodeBlockItemListSyntax {
                    try producerDeclaration
                    try producerCall
                }
            )
        }
    }

    private var mockerClosureSignature: ClosureSignatureSyntax {
        let paramList = ClosureShorthandParameterListSyntax {
            ClosureShorthandParameterSyntax(name: NS.producer)
        }
        return ClosureSignatureSyntax(parameterClause: .simpleInput(paramList))
    }

    private var producerDeclaration: VariableDeclSyntax {
        get throws {
            VariableDeclSyntax(
                bindingSpecifier: .keyword(.let),
                bindings: try PatternBindingListSyntax {
                    PatternBindingSyntax(
                        pattern: IdentifierPatternSyntax(identifier: NS.producer),
                        initializer: InitializerClauseSyntax(value: try producerCast)
                    )
                }
            )
        }
    }

    private var producerCast: TryExprSyntax {
        get throws {
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
                    type: try syntax.closureType
                )
            )
        }
    }

    private var producerCall: ReturnStmtSyntax {
        get throws {
            let producerCallExpr = FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(baseName: NS.producer),
                leftParen: .leftParenToken(),
                arguments: [],
                rightParen: .rightParenToken()
            )

            let producerCall = ExprSyntax(producerCallExpr)
            let tryProducerCall = ExprSyntax(TryExprSyntax(expression: producerCall))

            return ReturnStmtSyntax(expression: try syntax.isThrowing ? tryProducerCall : producerCall)
        }
    }

    private func mockerCall(memberName: TokenSyntax) -> FunctionCallExprSyntax {
        FunctionCallExprSyntax(
            calledExpression: MemberAccessExprSyntax(
                base: DeclReferenceExprSyntax(baseName: NS.mocker),
                name: memberName
            ),
            leftParen: .leftParenToken(),
            arguments: LabeledExprListSyntax {
                LabeledExprSyntax(
                    label: NS._for,
                    colon: .colonToken(),
                    expression: DeclReferenceExprSyntax(baseName: NS.member)
                )
            },
            rightParen: .rightParenToken()
        )
    }
}
