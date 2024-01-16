//
//  MemberFactory.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 23..
//

import SwiftSyntax

/// Factory to generate custom members.
///
/// Generates custom members (ex.: default init, reset function, etc...)
/// for the mock implementation.
enum MemberFactory: Factory {
    static func build(from requirements: Requirements) throws -> MemberBlockItemListSyntax {
        MemberBlockItemListSyntax {
            mocker(requirements)
            given(requirements)
            when(requirements)
            verify(requirements)
            reset(requirements)
            if let defaultInit = defaultInit(requirements) {
                defaultInit
            }
        }
    }
}

// MARK: - Helpers

extension MemberFactory {
    private static func defaultInit(_ requirements: Requirements) -> MemberBlockItemSyntax? {
        let hasDefault = requirements.initializers.contains {
            $0.syntax.signature.effectSpecifiers == nil
            && $0.syntax.signature.parameterClause.parameters.isEmpty
            && $0.syntax.optionalMark == nil
            && $0.syntax.genericWhereClause == nil
            && $0.syntax.genericParameterClause == nil
        }
        guard !hasDefault else { return nil }
        let defaultInit = InitializerDeclSyntax(
            modifiers: requirements.syntax.modifiers.trimmed,
            signature: .init(parameterClause: .init(parameters: [])),
            body: .init(statements: [])
        )
        return .init(decl: defaultInit)
    }

    private static func mocker(_ requirements: Requirements) -> VariableDeclSyntax {
        VariableDeclSyntax(
            modifiers: [DeclModifierSyntax(name: .keyword(.private))],
            bindingSpecifier: .keyword(.var)
        ) {
            PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: NS.mocker),
                initializer: InitializerClauseSyntax(
                    value: FunctionCallExprSyntax(
                        calledExpression: GenericSpecializationExprSyntax(
                            expression: DeclReferenceExprSyntax(baseName: NS.Mocker),
                            genericArgumentClause: GenericArgumentClauseSyntax(
                                arguments: GenericArgumentListSyntax {
                                    GenericArgumentSyntax(argument: requirements.syntax.mockType)
                                }
                            )
                        ),
                        leftParen: .leftParenToken(),
                        arguments: [],
                        rightParen: .rightParenToken()
                    )
                )
            )
        }
    }

    private static func given(_ requirements: Requirements) -> FunctionDeclSyntax {
        FunctionDeclSyntax(
            attributes: unavailableAttribute(message: Messages.givenMessage),
            modifiers: requirements.syntax.modifiers,
            name: NS.given,
            signature: .init(
                parameterClause: FunctionParameterClauseSyntax(parameters: []),
                returnClause: ReturnClauseSyntax(
                    type: IdentifierTypeSyntax(name: NS.ReturnBuilder)
                )
            ),
            body: builderInit(arguments: [mockerArgument])
        )
    }
    private static func when(_ requirements: Requirements) -> FunctionDeclSyntax {
        FunctionDeclSyntax(
            attributes: unavailableAttribute(message: Messages.whenMessage),
            modifiers: requirements.syntax.modifiers,
            name: NS.when,
            signature: .init(
                parameterClause: FunctionParameterClauseSyntax(parameters: []),
                returnClause: ReturnClauseSyntax(
                    type: IdentifierTypeSyntax(name: NS.ActionBuilder)
                )
            ),
            body: builderInit(arguments: [mockerArgument])
        )
    }
    private static func verify(_ requirements: Requirements) -> FunctionDeclSyntax {
        FunctionDeclSyntax(
            attributes: unavailableAttribute(message: Messages.verifyMessage),
            modifiers: requirements.syntax.modifiers,
            name: NS.verify,
            signature: .init(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: [assertionParameter]
                ),
                returnClause: ReturnClauseSyntax(
                    type: IdentifierTypeSyntax(name: NS.VerifyBuilder)
                )
            ),
            body: builderInit(arguments: [
                mockerArgument.with(\.trailingComma, .commaToken()),
                assertionArgument
            ])
        )
    }
    private static func reset(_ requirements: Requirements) -> FunctionDeclSyntax {
        FunctionDeclSyntax(
            modifiers: requirements.syntax.modifiers,
            name: NS.reset,
            signature: .init(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: [scopesParameter]
                )
            ),
            body: resetCall
        )
    }

    private static func builderInit(arguments: LabeledExprListSyntax) -> CodeBlockSyntax {
        CodeBlockSyntax(
            statements: CodeBlockItemListSyntax {
                FunctionCallExprSyntax(
                    calledExpression: MemberAccessExprSyntax(name: NS._init),
                    leftParen: .leftParenToken(),
                    arguments: arguments,
                    rightParen: .rightParenToken()
                )
            }
        )
    }

    private static var mockerArgument: LabeledExprSyntax {
        LabeledExprSyntax(
            label: NS.mocker,
            colon: .colonToken(),
            expression: DeclReferenceExprSyntax(baseName: NS.mocker)
        )
    }

    private static var assertionArgument: LabeledExprSyntax {
        LabeledExprSyntax(
            label: NS.assertion,
            colon: .colonToken(),
            expression: DeclReferenceExprSyntax(baseName: NS.assertion)
        )
    }

    private static var assertionParameter: FunctionParameterSyntax {
        FunctionParameterSyntax(
            firstName: NS.with,
            secondName: NS.assertion,
            type: AttributedTypeSyntax(
                attributes: [.attribute(.escaping)],
                baseType: IdentifierTypeSyntax(name: NS.MockableAssertion)
            )
        )
    }

    private static var scopesParameter: FunctionParameterSyntax {
        FunctionParameterSyntax(
            firstName: .wildcardToken(),
            secondName: NS.scopes,
            type: IdentifierTypeSyntax(
                name: NS.Set,
                genericArgumentClause: GenericArgumentClauseSyntax(
                    arguments: GenericArgumentListSyntax {
                        GenericArgumentSyntax(
                            argument: IdentifierTypeSyntax(
                                name: NS.MockerScope
                            )
                        )
                    }
                )
            ),
            defaultValue: InitializerClauseSyntax(
                value: MemberAccessExprSyntax(name: NS.all)
            )
        )
    }

    private static var resetCall: CodeBlockSyntax {
        CodeBlockSyntax(
            statements: CodeBlockItemListSyntax {
                FunctionCallExprSyntax(
                    calledExpression: MemberAccessExprSyntax(
                        base: DeclReferenceExprSyntax(baseName: NS.mocker),
                        name: NS.reset
                    ),
                    leftParen: .leftParenToken(),
                    arguments: [
                        LabeledExprSyntax(
                            label: NS.scopes,
                            colon: .colonToken(),
                            expression: DeclReferenceExprSyntax(baseName: NS.scopes)
                        )
                    ],
                    rightParen: .rightParenToken()
                )
            }
        )
    }

    private static func unavailableAttribute(message: String) -> AttributeListSyntax {
        let arguments = AvailabilityArgumentListSyntax {
            AvailabilityArgumentSyntax(argument: .token(NS._star))
            AvailabilityArgumentSyntax(argument: .token(NS.deprecated))
            AvailabilityArgumentSyntax(argument: .availabilityLabeledArgument(
                AvailabilityLabeledArgumentSyntax(
                    label: NS.message,
                    value: .string(SimpleStringLiteralExprSyntax(
                        openingQuote: .stringQuoteToken(),
                        segments: SimpleStringLiteralSegmentListSyntax {
                            StringSegmentSyntax(content: .identifier(message))
                        },
                        closingQuote: .stringQuoteToken()
                    ))
                )
            ))
        }
        let attribute = AttributeSyntax(
            attributeName: IdentifierTypeSyntax(name: NS.available),
            leftParen: .leftParenToken(),
            arguments: .availability(arguments),
            rightParen: .rightParenToken(),
            trailingTrivia: .newline
        )
        return AttributeListSyntax { attribute }
    }
}
