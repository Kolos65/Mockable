//
//  VariableDeclaration.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2023. 11. 17..
//

import SwiftSyntax

struct VariableDeclaration {

    // MARK: Private Properties

    private let index: Int

    // MARK: Properties

    let syntax: VariableDeclSyntax

    // MARK: Init

    init(index: Int, syntax: VariableDeclSyntax) {
        self.index = index
        self.syntax = syntax
    }

    // MARK: Properties

    var indexSuffix: String { String(index + 1) }

    var name: String { get throws { try binding.pattern.trimmedDescription } }

    var isComputed: Bool { setAccessor == nil }

    var isThrowing: Bool {
        get throws { try getAccessor.effectSpecifiers?.throwsSpecifier != nil }
    }

    var type: TypeSyntax {
        get throws {
            guard let typeAnnotation = try binding.typeAnnotation else {
                throw MockableMacroError.invalidVariableRequirement
            }
            return typeAnnotation.type.trimmed
        }
    }

    var trimmedType: TypeSyntax {
        get throws {
            let type = try type
            if let type = type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
                return type.wrappedType
            }
            return type
        }
    }

    var getAccessor: AccessorDeclSyntax {
        get throws {
            let getAccessor = try accessors.first { $0.accessorSpecifier.tokenKind == .keyword(.get) }
            guard let getAccessor else { throw MockableMacroError.invalidVariableRequirement }
            return getAccessor
        }
    }

    var setAccessor: AccessorDeclSyntax? {
        try? accessors.first { $0.accessorSpecifier.tokenKind == .keyword(.set) }
    }
}

// MARK: - Enum Helpers

extension VariableDeclaration {
    var getterEnumName: TokenSyntax {
        get throws {
            isComputed ? try enumName() : try enumName(prefix: "get_")
        }
    }

    var setterEnumName: TokenSyntax? {
        get throws {
            isComputed ? nil : try enumName(prefix: "set_")
        }
    }

    var getterEnumCaseDeclaration: EnumCaseDeclSyntax {
        get throws {
            let getterCase = EnumCaseElementSyntax(name: try getterEnumName)
            let elements: EnumCaseElementListSyntax = .init(arrayLiteral: getterCase)
            return EnumCaseDeclSyntax(elements: elements)
        }
    }

    var setterEnumCaseDeclaration: EnumCaseDeclSyntax? {
        get throws {
            guard let setterName = try setterEnumName else { return nil }
            let setterCase = EnumCaseElementSyntax(
                name: setterName,
                parameterClause: try setterEnumParameterClause
            )
            let elements: EnumCaseElementListSyntax = .init(arrayLiteral: setterCase)
            return EnumCaseDeclSyntax(elements: elements)
        }
    }

    var setterEnumParameterClause: EnumCaseParameterClauseSyntax? {
        get throws {
            guard !isComputed else { return nil }
            let parameter = EnumCaseParameterSyntax(
                firstName: .identifier("newValue"),
                colon: .colonToken(),
                type: try wrappedType
            )
            return .init(parameters: .init(arrayLiteral: parameter))
        }
    }

    var closureType: String {
        get throws {
            let throwsModifier = try isThrowing ? "throws " : ""
            return "() \(throwsModifier)-> \(try trimmedType.trimmedDescription)"
        }
    }
}

// MARK: - Helpers

extension VariableDeclaration {
    private var binding: PatternBindingSyntax {
        get throws {
            guard let binding = syntax.bindings.first else {
                throw MockableMacroError.invalidVariableRequirement
            }
            return binding
        }
    }

    private var accessors: AccessorDeclListSyntax {
        get throws {
            guard let accessorBlock = try binding.accessorBlock,
                  case .accessors(let accessorList) = accessorBlock.accessors else {
                throw MockableMacroError.invalidVariableRequirement
            }
            return accessorList
        }
    }

    private var wrappedType: TypeSyntax {
        get throws {
            let description = try trimmedType.trimmedDescription
            let typeName = "\(Constants.parameterWrapperName)<\(description)>"
            return .init(stringLiteral: typeName)
        }
    }

    private func enumName(prefix: String = "") throws -> TokenSyntax {
        .identifier("m\(indexSuffix)_\(prefix)\(try name)")
    }
}
