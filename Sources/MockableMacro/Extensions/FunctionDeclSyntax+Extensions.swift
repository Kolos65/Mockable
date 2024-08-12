//
//  FunctionDeclSyntax+Extensions.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 23..
//

import SwiftSyntax

extension FunctionDeclSyntax {
    var isVoid: Bool {
        signature.returnClause == nil
    }

    var isThrowing: Bool {
        signature.effectSpecifiers?.throwsSpecifier?.tokenKind == .keyword(.throws)
    }

    var closureType: FunctionTypeSyntax {
        let params = signature.parameterClause.parameters
            .map { $0.resolvedType(for: .parameter) }

        return FunctionTypeSyntax(
            parameters: TupleTypeElementListSyntax {
                for param in params {
                    TupleTypeElementSyntax(type: param)
                }
            },
            effectSpecifiers: .init(
                throwsSpecifier: isThrowing ? .keyword(.throws) : nil
            ),
            returnClause: signature.returnClause ?? .init(type: IdentifierTypeSyntax(name: NS.Void))
        )
    }

    func containsGenericType(in functionParameter: FunctionParameterSyntax) -> Bool {
        let genericParameters = genericParameterClause?.parameters ?? []
        guard !genericParameters.isEmpty else { return false }
        let generics = genericParameters.map(\.name.trimmedDescription)
        return nil != TokenFinder.find(in: functionParameter.type) {
            guard case .identifier(let name) = $0.tokenKind else { return false }
            return generics.contains(name)
        }
    }
}
