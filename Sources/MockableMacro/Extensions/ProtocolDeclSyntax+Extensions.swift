//
//  ProtocolDeclSyntax+Extensions.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 23..
//

import SwiftSyntax

extension ProtocolDeclSyntax {
    var mockName: String {
        argument(for: NS.ArgumentCustomName) ?? NS.Mock.trimmedDescription + name.trimmedDescription
    }

    var mockType: IdentifierTypeSyntax {
        IdentifierTypeSyntax(name: .identifier(mockName))
    }

    private func argument(for token: TokenSyntax) -> String? {
        guard let attribute = self.attributes.first?.as(AttributeSyntax.self),
              let argument = attribute.arguments?.as(LabeledExprListSyntax.self)?.first,
              argument.label?.text == token.text,
              let segment = argument.expression.as(StringLiteralExprSyntax.self)?.segments.first,
              case .stringSegment(let value) = segment
        else { return nil }

        return value.trimmedDescription
    }
}
