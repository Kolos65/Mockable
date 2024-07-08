//
//  VariableDeclSyntax+Extensions.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 10..
//

import SwiftSyntax

extension VariableDeclSyntax {
    var name: TokenSyntax {
        get throws {
            .identifier(try binding.pattern.trimmedDescription)
        }
    }

    var isComputed: Bool { setAccessor == nil }

    var isThrowing: Bool {
        get throws {
            #if canImport(SwiftSyntax600)
            try getAccessor.effectSpecifiers?.throwsClause?.throwsSpecifier != nil
            #else
            try getAccessor.effectSpecifiers?.throwsSpecifier != nil
            #endif
        }
    }

    var resolvedType: TypeSyntax {
        get throws {
            let type = try type
            if let type = type.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
                return type.wrappedType
            }
            return type
        }
    }

    var type: TypeSyntax {
        get throws {
            guard let typeAnnotation = try binding.typeAnnotation else {
                throw MockableMacroError.invalidVariableRequirement
            }
            return typeAnnotation.type.trimmed
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

    var closureType: FunctionTypeSyntax {
        get throws {
            #if canImport(SwiftSyntax600)
            let effectSpecifiers = TypeEffectSpecifiersSyntax(
                throwsClause: try isThrowing ? .init(throwsSpecifier: .keyword(.throws)) : nil
            )
            #else
            let effectSpecifiers = TypeEffectSpecifiersSyntax(
                throwsSpecifier: try isThrowing ? .keyword(.throws) : nil
            )
            #endif
            return FunctionTypeSyntax(
                parameters: TupleTypeElementListSyntax(),
                effectSpecifiers: effectSpecifiers,
                returnClause: .init(type: try resolvedType)
            )
        }
    }

    var binding: PatternBindingSyntax {
        get throws {
            guard let binding = bindings.first else {
                throw MockableMacroError.invalidVariableRequirement
            }
            return binding
        }
    }
}

// MARK: - Helpers

extension VariableDeclSyntax {
    private var accessors: AccessorDeclListSyntax {
        get throws {
            guard let accessorBlock = try binding.accessorBlock,
                  case .accessors(let accessorList) = accessorBlock.accessors else {
                throw MockableMacroError.invalidVariableRequirement
            }
            return accessorList
        }
    }
}

#if canImport(SwiftSyntax600)
extension VariableDeclSyntax {
    var errorType: TypeSyntax? {
        get throws { try getAccessor.effectSpecifiers?.throwsClause?.type }
    }
}
#endif
