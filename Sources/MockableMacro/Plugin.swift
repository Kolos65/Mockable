//
//  MockableMacroPlugin.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2023. 11. 14..
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        MockableMacro.self
    ]
}
