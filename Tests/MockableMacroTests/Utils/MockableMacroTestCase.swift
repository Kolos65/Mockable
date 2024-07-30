//
//  MockableMacroTestCase.swift
//
//
//  Created by Kolos Foltanyi on 2023. 11. 21..
//

import Foundation
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import MacroTesting
import XCTest

#if canImport(MockableMacro)
import MockableMacro
#endif

class MockableMacroTestCase: XCTestCase {
    override func invokeTest() {
        #if canImport(MockableMacro)
        withMacroTesting(record: false, macros: ["Mockable": MockableMacro.self]) {
            super.invokeTest()
        }
        #else
        fatalError("Macro tests can only be run on the host platform!")
        #endif
    }
}
