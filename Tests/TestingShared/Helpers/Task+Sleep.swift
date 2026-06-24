//
//  Task+Sleep.swift
//
//
//  Created by Kolos Foltanyi on 2024. 04. 07..
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: TimeInterval) async throws {
        try await sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
