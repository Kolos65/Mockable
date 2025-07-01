//
//  DeclModifierListSyntax+Extensions.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 27/09/2024.
//

import SwiftSyntax

extension DeclModifierListSyntax {
    func filtered(keywords: Set<Keyword>) -> DeclModifierListSyntax {
        filter { modifier in
            guard case .keyword(let keyword) = modifier.name.tokenKind else { return false }
            return keywords.contains(keyword)
        }
    }

    func firstIndex(of keyword: Keyword) -> SyntaxChildrenIndex? {
        firstIndex { modifier in
            guard case .keyword(let k) = modifier.name.tokenKind else { return false }
            return k == keyword
        }
    }

    mutating func remove(keyword: Keyword) {
        guard let index = firstIndex(of: keyword) else {
            return
        }

        remove(at: index)
    }

    func appending(_ other: DeclModifierListSyntax) -> DeclModifierListSyntax {
        self + Array(other)
    }
}
