//
//  UncheckedBox.swift
//
//
//  Created by Jalal Al-Awqati on 30.04.26.
//

final class UncheckedBox<T>: @unchecked Sendable {
    let value: T
    init(_ value: T) { self.value = value }
}
