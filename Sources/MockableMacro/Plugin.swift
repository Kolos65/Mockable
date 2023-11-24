//
//  MockableMacroPlugin.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 14..
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MockableMacro.self
    ]
}
