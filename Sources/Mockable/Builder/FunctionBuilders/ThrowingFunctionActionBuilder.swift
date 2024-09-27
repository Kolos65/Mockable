//
//  ThrowingFunctionActionBuilder.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 22..
//

/// A builder for specifying actions to be performed when mocking a throwing function.
///
/// This builder is used within the context of a higher-level builder (e.g., an `ActionBuilder`)
/// to specify a desired action to perform when a particular throwing function of a mock service is called.
public typealias ThrowingFunctionActionBuilder<T: MockableService, ParentBuilder: Builder<T>>
    = FunctionActionBuilder<T, ParentBuilder>
