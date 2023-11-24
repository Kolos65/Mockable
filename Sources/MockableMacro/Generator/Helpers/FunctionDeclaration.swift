//
//  FunctionDeclaration.swift
//  
//
//  Created by Kolos Foltanyi on 2023. 11. 17..
//

import SwiftSyntax

struct FunctionDeclaration {

    // MARK: Private Properties

    private let index: Int

    // MARK: Properties

    let syntax: FunctionDeclSyntax

    // MARK: Init

    init(index: Int, syntax: FunctionDeclSyntax) {
        self.index = index
        self.syntax = syntax
    }

    // MARK: Properties

    var indexSuffix: String {
        String(index + 1)
    }
    var name: String {
        syntax.name.trimmedDescription
    }
    var genericParameters: [GenericParameterSyntax] {
        Array(syntax.genericParameterClause?.parameters ?? [])
    }
    var parameters: [FunctionParameterSyntax] {
        Array(syntax.signature.parameterClause.parameters)
    }
    var effectSpecifiers: FunctionEffectSpecifiersSyntax? {
        syntax.signature.effectSpecifiers
    }
    var returnType: TypeSyntax? {
        syntax.signature.returnClause?.type
    }
    var isVoid: Bool {
        syntax.signature.returnClause == nil
    }
    var isThrowing: Bool {
        syntax.signature.effectSpecifiers?.throwsSpecifier?.tokenKind == .keyword(.throws)
    }
}

// MARK: - Enum Helpers

extension FunctionDeclaration {
    var enumName: TokenSyntax {
        .identifier("m\(indexSuffix)_\(name)")
    }

    var enumCaseDeclaration: EnumCaseDeclSyntax {
        get throws {
            let enumCase = EnumCaseElementSyntax(
                name: enumName,
                parameterClause: enumParameterClause
            )
            let elements: EnumCaseElementListSyntax = .init(arrayLiteral: enumCase)
            return EnumCaseDeclSyntax(elements: elements)
        }
    }

    var enumParameterClause: EnumCaseParameterClauseSyntax? {
        guard !parameters.isEmpty else { return nil }
        let enumParameters: EnumCaseParameterListSyntax = .init {
            for parameter in parameters {
                let firstName = enumParameterName(for: parameter)
                EnumCaseParameterSyntax(
                    firstName: firstName,
                    colon: firstName == nil ? nil : .colonToken(),
                    type: wrappedType(for: parameter)
                )
            }
        }
        return .init(parameters: enumParameters)
    }

    func wrappedType(for parameter: FunctionParameterSyntax) -> TypeSyntax {
        let type = parameter.resolvedTypeName
        let isGeneric = containsGenericType(in: parameter)
        let identifier = isGeneric ? Constants.genericParameterWrapper : type
        return .init(stringLiteral: "\(Constants.parameterWrapperName)<\(identifier)>")
    }
}

// MARK: - Builder helpers

extension FunctionDeclaration {
    var wrappedParameterClause: FunctionParameterClauseSyntax? {
        guard !parameters.isEmpty else { return nil }
        return .init(parameters: .init(itemsBuilder: {
            for parameter in parameters {
                FunctionParameterSyntax(
                    firstName: parameter.firstName,
                    secondName: parameter.secondName,
                    type: IdentifierTypeSyntax(name: .identifier("Parameter<\(parameter.resolvedTypeName)>"))
                )
            }
        }))
    }

    /// Only contains generic parameters that are used in the parameter clause
    var filteredGenericParameterClause: GenericParameterClauseSyntax? {
        guard let generics = syntax.genericParameterClause else { return nil }
        var parameters = generics.parameters.filter { generic in
            hasParameter(containing: generic.name.trimmedDescription)
        }
        if let lastIndex = parameters.indices.last {
            var last = parameters[lastIndex]
            last.trailingComma = nil
            parameters[lastIndex] = last
        }
        return parameters.isEmpty ? nil : .init(parameters: parameters)
    }

    /// Only contains requirements that are used in the parameter clause
    var filteredGenericWhereClause: GenericWhereClauseSyntax? {
        guard let generics = syntax.genericWhereClause else { return nil }
        var requirements = generics.requirements.filter { requirement in
            switch requirement.requirement {
            case .conformanceRequirement(let conformance):
                return hasParameter(containing: conformance.leftType.trimmedDescription)
            case .sameTypeRequirement(let sameType):
                return hasParameter(containing: sameType.leftType.trimmedDescription)
            default:
                return false
            }
        }
        if let lastIndex = requirements.indices.last {
            var last = requirements[lastIndex]
            last.trailingComma = nil
            requirements[lastIndex] = last
        }
        var whereClause = GenericWhereClauseSyntax(requirements: requirements)
        whereClause.whereKeyword.trailingTrivia = .space
        return requirements.isEmpty ? nil : whereClause
    }

    var closureType: String {
        let params = syntax.signature.parameterClause.parameters
            .map(\.resolvedTypeName)
            .joined(separator: ", ")
        let returnType = syntax.signature.returnClause?.type.trimmedDescription ?? "Void"
        let throwsSpecifier = isThrowing ? "throws " : ""
        return "(\(params)) \(throwsSpecifier)-> \(returnType)"
    }

    func containsGenericType(in functionParameter: FunctionParameterSyntax) -> Bool {
        guard !genericParameters.isEmpty else { return false }
        var found = false
        let generics = genericParameters.map(\.name.trimmedDescription)
        let tokenFinder = TokenFinder {
            guard case .identifier(let name) = $0.tokenKind else { return false }
            found = found || generics.contains(name)
            return found
        }
        tokenFinder.walk(functionParameter.type)
        return found
    }
}

// MARK: - Helpers

extension FunctionDeclaration {
    private func hasParameter(containing identifier: String) -> Bool {
        var found = false
        let identifier: TokenKind = .identifier(identifier)
        let tokenFinder = TokenFinder {
            guard !found else { return true }
            found = found || $0.tokenKind == identifier
            return found
        }
        tokenFinder.walk(syntax.signature.parameterClause)
        return found
    }

    private func enumParameterName(for parameter: FunctionParameterSyntax) -> TokenSyntax? {
        guard parameter.firstName.tokenKind != .wildcard else { return nil }
        return parameter.firstName.trimmed
    }
}
