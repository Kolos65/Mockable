//
//  MockableMacroWarning.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2024. 12. 01..
//

import SwiftSyntax
import SwiftDiagnostics

public enum MockableMacroWarning {
    case versionMismatch
}

// MARK: - DiagnosticMessage

extension MockableMacroWarning: DiagnosticMessage {
    public var message: String {
        switch self {
        case .versionMismatch: """
        Your SwiftSyntax version is pinned to \(swiftSyntaxVersion).x.x by some of your dependencies. \
        Using a lower SwiftSyntax version than your Swift version may lead to issues when using Mockable.
        """
        }
    }
    public var diagnosticID: MessageID {
        switch self {
        case .versionMismatch: MessageID(domain: "Mockable", id: "MockableMacroWarning.versionMismatch")
        }
    }
    public var severity: DiagnosticSeverity { .warning }
}

// MARK: - Helpers

extension MockableMacroWarning {
    private var swiftSyntaxVersion: String {
        #if canImport(SwiftSyntax600)
        ">600"
        #elseif canImport(SwiftSyntax510)
        "510"
        #elseif canImport(SwiftSyntax509)
        "509"
        #else
        "<unknown>"
        #endif
    }
}
