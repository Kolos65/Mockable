//
//  Caseable.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 2023. 12. 07..
//

import SwiftSyntax

/// Describes requirements that are representable by a `Member` enum case.
///
/// Requirements conforming to `Caseable` provide their case declarations and a
/// utility that helps creating member access expressions for a given case.
protocol Caseable {
    /// Returns the member enum represenatation of a syntax.
    ///
    /// For example a member like:
    /// ```
    /// func foo(param: String) -> Int
    /// ```
    /// would return the following case declaration:
    /// ```
    /// case foo(param: Parameter<String>)
    /// ```
    var caseDeclarations: [EnumCaseDeclSyntax] { get throws }

    /// Returns the initializer block that creates the enum case representation.
    ///
    /// For example a member like:
    /// ```
    /// func foo(param: String) -> Int
    /// ```
    /// would return the following initializer declaration if wrapParams is true:
    /// ```
    /// .m1_foo(param: .value(param))
    /// ```
    /// and:
    /// ```
    /// .m1_foo(param: param)
    /// ```
    /// if wrapParams is false.
    func caseSpecifier(wrapParams: Bool) throws -> ExprSyntax

    /// Returns the initializer block that creates the enum case representation.
    ///
    /// For example a member like:
    /// ```
    /// var prop: Int { get set }
    /// ```
    /// would return the following initializer declaration if wrapParams is true:
    /// ```
    /// .m1_set_name(newValue: .value(newValue))
    /// ```
    /// and:
    /// ```
    /// .m1_set_name(newValue: newValue)
    /// ```
    /// if wrapParams is false.
    func setterCaseSpecifier(wrapParams: Bool) throws -> ExprSyntax?
}
