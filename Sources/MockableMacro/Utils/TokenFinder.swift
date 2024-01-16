//
//  TokenFinder.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2023. 11. 20..
//

import SwiftSyntax

class TokenVisitor: SyntaxVisitor {
    var match: (TokenSyntax) -> Bool
    init(match: @escaping (TokenSyntax) -> Bool) {
        self.match = match
        super.init(viewMode: .sourceAccurate)
    }
    override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind {
        match(token) ? .skipChildren : .visitChildren
    }
}

enum TokenFinder {
    static func find(
        in syntax: some SyntaxProtocol,
        matching matcher: @escaping (TokenSyntax) -> Bool
    ) -> TokenSyntax? {
        var result: TokenSyntax?
        let visitor = TokenVisitor {
            let match = matcher($0)
            if match, result == nil {
                result = $0
            }
            return result != nil
        }
        visitor.walk(syntax)
        return result
    }
}
