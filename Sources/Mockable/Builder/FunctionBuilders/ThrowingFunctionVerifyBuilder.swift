//
//  ThrowingFunctionVerifyBuilder.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 22..
//

/// A builder for verifying the number of times a throwing function was called.
///
/// This builder is typically used within the context of a higher-level builder (e.g., a `VerifyBuilder`)
/// to verify the expected number of invocations for a throwing function of a mock service.
public typealias ThrowingFunctionVerifyBuilder<T: MockableService, ParentBuilder: Builder<T>>
    = FunctionVerifyBuilder<T, ParentBuilder>
