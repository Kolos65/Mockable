//
//  VariableConformances.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 16..
//

import SwiftSyntax
import SwiftSyntaxMacros

struct VariableConformances {

    // MARK: Private Properties

    private let protocolDeclaration: ProtocolDeclSyntax
    private let variables: [VariableDeclaration]

    // MARK: Init

    init(_ protocolDeclaration: ProtocolDeclSyntax, _ variables: [VariableDeclaration]) {
        self.protocolDeclaration = protocolDeclaration
        self.variables = variables
    }

    // MARK: Properties

    var members: [MemberBlockItemSyntax] {
        get throws {
            try variables.map { .init(decl: try implement($0)) }
        }
    }
}

// MARK: - Helpers

extension VariableConformances {
    private func implement(_ variable: VariableDeclaration) throws -> VariableDeclSyntax {
        let baseModifiers = protocolDeclaration.modifiers
        let modifiers = baseModifiers.isEmpty ? "" : baseModifiers.trimmedDescription.appending(" ")
        let declaration = """
        \(modifiers)var \(try variable.name): \(try variable.type.trimmedDescription) {
            \(try variable.getAccessor.trimmedDescription) {
                let member: Member = .\(try variable.getterEnumName)
                return \(try variable.isThrowing ? "try" : "try!") mocker.mock(member) { producer in
                    let producer = try cast(producer) as \(try variable.closureType)
                    return\(try variable.isThrowing ? " try" : "") producer()
                }
            }\(try setter(for: variable))
        }
        """
        return try .init("\(raw: declaration)")
    }

    private func setter(for variable: VariableDeclaration) throws -> String {
        guard let setterName = try variable.setterEnumName else { return "" }
        return """
        set {
            let member: Member = .\(setterName.trimmedDescription)(newValue: .value(newValue))
            mocker.addInvocation(for: member)
            mocker.performActions(for: member)
        }
        """
    }
}
