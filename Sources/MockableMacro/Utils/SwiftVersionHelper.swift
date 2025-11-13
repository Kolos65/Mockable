//
//  File.swift
//  Mockable
//
//  Created by Kolos Foltányi on 2025. 11. 13..
//

import SwiftSyntax

enum SwiftVersionRequirement: TokenSyntax {
    case swift_6_1 = "6.1"
}

enum SwiftVersionHelper {
    static func condition(
        minimumVersion: SwiftVersionRequirement,
        gte latest: IfConfigClauseSyntax.Elements,
        else fallback: IfConfigClauseSyntax.Elements
    ) -> IfConfigDeclSyntax {
        IfConfigDeclSyntax(
            clauses: IfConfigClauseListSyntax {
                IfConfigClauseSyntax(
                    poundKeyword: .poundIfToken(),
                    condition: FunctionCallExprSyntax(
                        calledExpression: DeclReferenceExprSyntax(baseName: NS.swift),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax {
                            LabeledExprSyntax(
                                expression: PrefixOperatorExprSyntax(
                                    operator: .prefixOperator(NS._gte),
                                    expression: FloatLiteralExprSyntax(literal: minimumVersion.rawValue)
                                )
                            )
                        },
                        rightParen: .rightParenToken(),
                        additionalTrailingClosures: MultipleTrailingClosureElementListSyntax()
                    ),
                    elements: latest
                )
                IfConfigClauseSyntax(
                    poundKeyword: .poundElseToken(),
                    elements: fallback
                )
            },
            poundEndif: .poundEndifToken()
        )
    }
}
