//
//  Availability.swift
//  MockableMacro
//
//  Created by Kolos Foltanyi on 30/07/2024.
//

import SwiftSyntax

enum AvailabilityVersionParseError: Error {
    case invalidVersionString
}

enum Availability {
    static func from(iOS: String, macOS: String, tvOS: String, watchOS: String) throws -> AttributeSyntax {
        let arguments = try AvailabilityArgumentListSyntax {
            try availability(platform: NS.iOS, version: iOS)
            try availability(platform: NS.macOS, version: macOS)
            try availability(platform: NS.tvOS, version: tvOS)
            try availability(platform: NS.watchOS, version: watchOS)
            AvailabilityArgumentSyntax(argument: .token(.binaryOperator("*")))
        }

        return AttributeSyntax(
            attributeName: IdentifierTypeSyntax(name: NS.available),
            leftParen: .leftParenToken(),
            arguments: .availability(arguments),
            rightParen: .rightParenToken()
        )
    }

    private static func availability(platform: TokenSyntax, version: String) throws -> AvailabilityArgumentSyntax {
        let version = version.split(separator: ".").map(String.init)

        guard let major = version.first else {
            throw AvailabilityVersionParseError.invalidVersionString
        }
        let components = version.dropFirst().compactMap {
            return VersionComponentSyntax(number: .integerLiteral($0))
        }

        let versionSyntax = PlatformVersionSyntax(
            platform: platform,
            version: .init(
                major: .integerLiteral(major),
                components: .init(components)
            )
        )

        return AvailabilityArgumentSyntax(argument: .availabilityVersionRestriction(versionSyntax))
    }
}
