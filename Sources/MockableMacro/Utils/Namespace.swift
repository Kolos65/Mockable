//
//  Namespace.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2024. 03. 28..
//

#if canImport(SwiftSyntax600) || swift(<6)
import SwiftSyntax
#else
@preconcurrency import SwiftSyntax
#endif

// swiftlint:disable identifier_name
enum NS {
    static let MOCKING: TokenSyntax = "MOCKING"

    static let generic: TokenSyntax = "generic"
    static let value: TokenSyntax = "value"
    static let eraseToGenericValue: TokenSyntax = "eraseToGenericValue"
    static let newValue: TokenSyntax = "newValue"
    static let other: TokenSyntax = "other"
    static let match: TokenSyntax = "match"
    static let left: TokenSyntax = "left"
    static let right: TokenSyntax = "right"
    static let with: TokenSyntax = "with"
    static let reset: TokenSyntax = "reset"
    static let scopes: TokenSyntax = "scopes"
    static let all: TokenSyntax = "all"
    static let available: TokenSyntax = "available"
    static let deprecated: TokenSyntax = "deprecated"
    static let message: TokenSyntax = "message"
    static let kind: TokenSyntax = "kind"
    static let setKind: TokenSyntax = "setKind"
    static let any: TokenSyntax = "any"
    static let initializer: TokenSyntax = "init"
    static let member: TokenSyntax = "member"
    static let mock: TokenSyntax = "mock"
    static let mockThrowing: TokenSyntax = "mockThrowing"
    static let producer: TokenSyntax = "producer"
    static let cast: TokenSyntax = "cast"
    static let addInvocation: TokenSyntax = "addInvocation"
    static let performActions: TokenSyntax = "performActions"
    static let policy: TokenSyntax = "policy"
    static let error: TokenSyntax = "error"
    static let iOS: TokenSyntax = "iOS"
    static let macOS: TokenSyntax = "macOS"
    static let tvOS: TokenSyntax = "tvOS"
    static let watchOS: TokenSyntax = "watchOS"

    static let _given: TokenSyntax = "_given"
    static let _when: TokenSyntax = "_when"
    static let _verify: TokenSyntax = "_verify"
    static let _andSign: String = "&&"
    static let _init: TokenSyntax = "init"
    static let _star: TokenSyntax = "*"
    static let _for: TokenSyntax = "for"
    static let get_: String = "get_"
    static let set_: String = "set_"

    static let mocker: TokenSyntax = "mocker"

    static let Mockable: TokenSyntax = "Mockable"
    static let Mock: TokenSyntax = "Mock"
    static let MockableService: TokenSyntax = "MockableService"
    static let Bool: TokenSyntax = "Bool"
    static let GenericValue: String = "GenericValue"
    static let Mocker: TokenSyntax = "Mocker"
    static let Builder: TokenSyntax = "Builder"
    static let Member: TokenSyntax = "Member"
    static let Matchable: TokenSyntax = "Matchable"
    static let CaseIdentifiable: TokenSyntax = "CaseIdentifiable"
    static let ReturnBuilder: TokenSyntax = "ReturnBuilder"
    static let ActionBuilder: TokenSyntax = "ActionBuilder"
    static let VerifyBuilder: TokenSyntax = "VerifyBuilder"
    static let MockerScope: TokenSyntax = "MockerScope"
    static let MockerPolicy: TokenSyntax = "MockerPolicy"
    static let Set: TokenSyntax = "Set"
    static let Void: TokenSyntax = "Void"
    static let Actor: TokenSyntax = "Actor"
    static let Error: TokenSyntax = "Error"
    static let NSObjectProtocol: String = "NSObjectProtocol"
    static let NSObject: TokenSyntax = "NSObject"
    static let Sendable: TokenSyntax = "Sendable"

    static func Parameter(_ type: String) -> TokenSyntax { "Parameter<\(raw: type)>" }
    static func Param(suffix: String) -> TokenSyntax { "Param\(raw: suffix)" }
    static func Function(_ kind: BuilderKind) -> TokenSyntax { "Function\(raw: kind.name)" }
    static func ThrowingFunction(_ kind: BuilderKind) -> TokenSyntax { "ThrowingFunction\(raw: kind.name)" }
    static func Property(_ kind: BuilderKind) -> TokenSyntax { "Property\(raw: kind.name)" }
    static func ThrowingProperty(_ kind: BuilderKind) -> TokenSyntax { "ThrowingProperty\(raw: kind.name)" }
}
// swiftlint:enable identifier_name
