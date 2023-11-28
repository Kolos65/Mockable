//
//  BuilderStructs.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 19..
//

import SwiftSyntax

struct BuilderStructs {

    // MARK: Inner Types

    private enum Builder {
        case `return`
        case action
        case verify

        var name: String {
            switch self {
            case .return:
                "ReturnBuilder"
            case .action:
                "ActionBuilder"
            case .verify:
                "VerifyBuilder"
            }
        }
    }

    // MARK: Private Properties

    private let protocolDeclaration: ProtocolDeclSyntax
    private let variables: [VariableDeclaration]
    private let functions: [FunctionDeclaration]

    // MARK: Init

    init(_ protocolDeclaration: ProtocolDeclSyntax,
         _ variables: [VariableDeclaration],
         _ functions: [FunctionDeclaration]) {
        self.protocolDeclaration = protocolDeclaration
        self.variables = variables
        self.functions = functions
    }

    // MARK: Properties

    var givenBuilder: MemberBlockItemSyntax {
        get throws {
            .init(decl: try structDeclaration(for: .return))
        }
    }

    var actionBuilder: MemberBlockItemSyntax {
        get throws {
            .init(decl: try structDeclaration(for: .action))
        }
    }

    var verifyBuilder: MemberBlockItemSyntax {
        get throws {
            .init(decl: try structDeclaration(for: .verify))
        }
    }
}

// MARK: - Helpers

extension BuilderStructs {
    private var modifier: String {
        guard !protocolDeclaration.modifiers.isEmpty else { return "" }
        return "\(protocolDeclaration.modifiers.trimmedDescription) "
    }

    private func structDeclaration(for kind: Builder) throws -> StructDeclSyntax {
        StructDeclSyntax(
            modifiers: protocolDeclaration.modifiers,
            name: .identifier(kind.name),
            inheritanceClause: .init(inheritedTypes: inheritedTypes(kind)),
            memberBlock: .init(stringLiteral: try memberBlock(kind: kind))
        )
    }

    private func inheritedTypes(_ kind: Builder) -> InheritedTypeListSyntax {
        let inheritedType = kind == .verify ? assertionBuilder : effectBuilder
        return .init { InheritedTypeSyntax(type: inheritedType) }
    }

    private var effectBuilder: IdentifierTypeSyntax {
        IdentifierTypeSyntax(name: .identifier("EffectBuilder"))
    }

    private var assertionBuilder: IdentifierTypeSyntax {
        IdentifierTypeSyntax(name: .identifier("AssertionBuilder"))
    }

    private var mockName: String {
        Constants.implementationPrefix + protocolDeclaration.name.trimmedDescription
    }

    private func memberBlock(kind: Builder) throws -> String {
        """
        {
        \(kind == .verify ? assertionMembers : effectMembers)
        \(try members(kind: kind))
        }
        """
    }

    private var effectMembers: String {
        """
        private let mocker: Mocker<\(mockName)>
        \(modifier)init(mocker: Mocker<\(mockName)>) {
            self.mocker = mocker
        }
        """
    }

    private var assertionMembers: String {
        """
        private let mocker: Mocker<\(mockName)>
        private let assertion: MockableAssertion
        \(modifier)init(mocker: Mocker<\(mockName)>, assertion: @escaping MockableAssertion) {
            self.mocker = mocker
            self.assertion = assertion
        }
        """
    }

    private func members(kind: Builder) throws -> String {
        let members = try variableMembers(kind: kind) + functionMembers(kind: kind)
        return members.joined(separator: "\n")
    }

    private func variableMembers(kind: Builder) throws -> [String] {
        try variables.map {
            let propType = try $0.trimmedType.trimmedDescription
            let propName = try $0.name
            let returnType = try builderReturnType(for: $0, kind: kind)
            let signature = if $0.isComputed || kind == .return {
                "\(modifier)var \(propName): \(returnType)"
            } else {
                "\(modifier)func \(propName)(newValue: Parameter<\(propType)> = .any) -> \(returnType)"
            }
            var setterParam = ""
            if let setterEnumName = try $0.setterEnumName, !$0.isComputed && kind != .return {
                setterParam = ", setKind: .\(setterEnumName)(newValue: newValue)"
            }
            let assertionParam = kind == .verify ? ", assertion: assertion" : ""
            return "\(signature) { .init(mocker, kind: .\(try $0.getterEnumName)\(setterParam)\(assertionParam)) }"
        }
    }

    private func functionMembers(kind: Builder) -> [String] {
        functions.map {
            let returnType = builderReturnType(for: $0, kind: kind)
            let parameterClause = $0.wrappedParameterClause?.trimmedDescription ?? "()"
            let genericParameters = if kind == .return {
                $0.syntax.genericParameterClause?.trimmedDescription ?? ""
            } else {
                $0.filteredGenericParameterClause?.trimmedDescription ?? ""
            }
            let whereClause: String? = if kind == .return {
                $0.syntax.genericWhereClause?.trimmedDescription
            } else {
                $0.filteredGenericWhereClause?.trimmedDescription
            }
            let components: [String?] = [
                "\(modifier)func",
                "\($0.name)\(genericParameters)\(parameterClause)",
                "->",
                returnType,
                whereClause
            ]
            let signature = components.compactMap { $0 }.joined(separator: " ")
            let assertionParam = kind == .verify ? ", assertion: assertion" : ""
            return "\(signature) { .init(mocker, kind: \(memberSpecifier(for: $0))\(assertionParam)) }"
        }
    }

    private func builderReturnType(for variable: VariableDeclaration, kind: Builder) throws -> String {
        let throwsPrefix = try variable.isThrowing ? "Throwing" : ""
        let propType = try variable.trimmedType.trimmedDescription
        let produceType = kind == .return ? ", \(try variable.closureType)" : ""
        let returnType = kind == .return ? ", \(propType)" : ""
        return if variable.isComputed {
            "\(throwsPrefix)Function\(kind.name)<\(mockName), \(kind.name)\(returnType)\(produceType)>"
        } else {
            "\(throwsPrefix)Property\(kind.name)<\(mockName), \(kind.name)\(returnType)>"
        }
    }

    private func builderReturnType(for function: FunctionDeclaration, kind: Builder) -> String {
        let throwsPrefix = function.isThrowing ? "Throwing" : ""
        let functionReturnType = function.returnType?.trimmedDescription ?? "Void"
        let produceType = kind == .return ? ", \(function.closureType)" : ""
        let returnType = kind == .return ? ", \(functionReturnType)" : ""
        return "\(throwsPrefix)Function\(kind.name)<\(mockName), \(kind.name)\(returnType)\(produceType)>"
    }

    private func memberSpecifier(for function: FunctionDeclaration) -> String {
        var memberParams = ""
        if let parameterClause = function.enumParameterClause {
            let paramList = zip(parameterClause.parameters, function.parameters)
                .map { enumParameter, functionParameter in
                    let paramName = enumParameter.firstName?.trimmedDescription.appending(": ") ?? ""
                    let isGeneric = function.containsGenericType(in: functionParameter)
                    let functionParamName = functionParameter.secondName ?? functionParameter.firstName
                    let paramValue = isGeneric
                        ? "\(functionParamName).eraseToGenericValue()"
                        : "\(functionParamName)"
                    return "\(paramName)\(paramValue)"
                }
                .joined(separator: ", ")
            memberParams = "(\(paramList))"
        }
        return ".\(function.enumName)\(memberParams)"
    }
}
