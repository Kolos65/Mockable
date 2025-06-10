//
//  GenericArgumentSyntax+Extensions.swift
//  Mockable
//
//  Created by Scott Hoyt on 10/06/2025.
//

import SwiftSyntax

#if canImport(SwiftSyntax601)
// The purpose of this initializer is to silence deprecation warnings by the using the new API when
// built against SwiftSyntax >= 601.0.0
extension GenericArgumentSyntax {
    init(argument: any TypeSyntaxProtocol) {
        self.init(argument: Argument(argument))
    }
}
#endif
