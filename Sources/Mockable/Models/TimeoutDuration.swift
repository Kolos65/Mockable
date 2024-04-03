//
//  TimeoutDuration.swift
//  Mockable
//
//
//  Created by Nayanda Haberty on 3/4/24.
//

import Foundation

/// An enumeration representing a duration of time.
public enum TimeoutDuration {

    /// A TimeoutDuration representing a given number of seconds.
    case seconds(Double)

    /// A TimeoutDuration representing a given number of miliseconds.
    case miliseconds(UInt)

    /// Converts the duration to TimeInterval.
    public var duration: TimeInterval {
        switch self {
        case .seconds(let value): value
        case .miliseconds(let value): TimeInterval(value) / 1000
        }
    }
}

// MARK: - ExpressibleByFloatLiteral

extension TimeoutDuration: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .seconds(value)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension TimeoutDuration: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .seconds(Double(value))
    }
}
