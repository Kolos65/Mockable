//
//  Timeout.swift
//  Mockable
//
//
//  Created by Nayanda Haberty on 3/4/24.
//

import Foundation

/// An enumeration representing timeout condition during verification.
public enum Timeout {

    case miliseconds(UInt)
    case seconds(UInt)

    @inlinable public var timeInterval: TimeInterval {
        switch self {
        case .miliseconds(let uInt):
            return TimeInterval(uInt) / 1000
        case .seconds(let uInt):
            return TimeInterval(uInt)
        }
    }
}

extension Timeout: ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = UInt

    @inlinable public init(integerLiteral value: UInt) {
        self = .seconds(value)
    }
}
