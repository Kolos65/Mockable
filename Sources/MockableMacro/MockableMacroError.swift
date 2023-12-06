//
//  MockableMacroError.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2023. 11. 24..
//

public enum MockableMacroError: Error, CustomStringConvertible {
    case notAProtocol
    case invalidVariableRequirement
    case invalidDerivedEnumCase
    case nonEscapingFunctionParameter
    case subscriptsNotSupported
    case operatorsNotSupported
    case staticMembersNotSupported

    public var description: String {
        switch self {
        case .notAProtocol:
            return "@Mockable can only be applied to protocols."
        case .invalidVariableRequirement:
            return "Invalid variable requirement. Missing type annotation or accessor block."
        case .invalidDerivedEnumCase:
            return "Unexpected error during generating an enum representation of this protocol."
        case .nonEscapingFunctionParameter:
            return """
            Non-escaping function parameters are not supported by @Mockable. \
            Add @escaping to all function parameters to resolve this issue.
            """
        case .subscriptsNotSupported:
            return "Subscript requirements are not supported by @Mockable."
        case .operatorsNotSupported:
            return "Operator requirements are not supported by @Mockable."
        case .staticMembersNotSupported:
            return "Static member requirements are not supported by @Mockable."
        }
    }
}
