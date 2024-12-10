//
//  ReturnValue.swift
//  Mockable
//
//  Created by Kolos Foltanyi on 2023. 11. 13..
//

/// An enumeration representing different types of return values for mocked functions.
///
/// - `return(Any)`: A concrete value to be returned.
/// - `throw(Error)`: An error to be thrown.
/// - `produce(Any)`: A value producer to be invoked.
public enum ReturnValue {
    /// A case representing a concrete value to be returned.
    case `return`(Any)

    /// A case representing an error to be thrown.
    case `throw`(any Error)

    /// A case representing a value producer to be invoked.
    case produce(Any)
}

/// An error thrown when type erased producers cannot be casted to their original closure type.
public enum ProducerCastError: Error {
    case typeMismatch
}

/// Casts the given producer to the specified type.
///
/// This function is used to cast the producer to a specific type when using the `.produce` case
/// in the `ReturnValue` enum.
///
/// - Parameter producer: The producer to be cast.
/// - Returns: The casted producer of type `P`.
public func cast<P>(_ producer: Any) throws -> P {
    guard let producer = producer as? P else {
        throw ProducerCastError.typeMismatch
    }
    return producer
}
