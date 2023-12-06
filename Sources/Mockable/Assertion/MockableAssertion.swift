//
//  MockableAssertion.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 23..
//

/// Typealias for assertion block.
///
/// The XCTest implementation of assertions is only available
/// from the `MockableTest` target. Import `MockableTest` in your test target and use its:
/// * `given(_ service:)`
/// * `when(_ service:)`
/// * `verify(_ service:)`
///
/// clauses for testing.
public typealias MockableAssertion = (@autoclosure () -> Bool, @autoclosure () -> String, StaticString, UInt) -> Void
