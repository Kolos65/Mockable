//
//  TokenFinder.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2023. 11. 20..
//

import SwiftSyntax

class TokenFinder: SyntaxVisitor {
    var match: (TokenSyntax) -> Bool
    init(match: @escaping (TokenSyntax) -> Bool) {
        self.match = match
        super.init(viewMode: .sourceAccurate)
    }
    override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind {
        match(token) ? .skipChildren : .visitChildren
    }
}
