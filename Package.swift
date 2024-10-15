// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let isDev = Context.environment["MOCKABLE_DEV"].flatMap(Bool.init) ?? false

func ifDev<T>(add list: [T]) -> [T] { isDev ? list : [] }

let devDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.5.2"),
    .package(url: "https://github.com/realm/SwiftLint", exact: "0.55.1"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
]

let devPlugins: [Target.PluginUsage] = [
    .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
]

let devTargets: [Target] = [
    .testTarget(
        name: "MockableTests",
        dependencies: ["Mockable"],
        swiftSettings: [.define("MOCKING")],
        plugins: devPlugins
    ),
    .testTarget(
        name: "MockableMacroTests",
        dependencies: [
            "MockableMacro",
            .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            .product(name: "MacroTesting", package: "swift-macro-testing"),
        ],
        swiftSettings: [.define("MOCKING")]
    )
]

let package = Package(
    name: "Mockable",
    platforms: [.macOS(.v12), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "Mockable",
            targets: ["Mockable"]
        )
    ],
    dependencies: ifDev(add: devDependencies) + [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "509.0.0"..<"511.0.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", .upToNextMajor(from: "1.4.1"))
    ],
    targets: ifDev(add: devTargets) + [
        .target(
            name: "Mockable",
            dependencies: [
                "MockableMacro",
                .product(name: "IssueReporting", package: "xctest-dynamic-overlay")
            ],
            plugins: ifDev(add: devPlugins)
        ),
        .macro(
            name: "MockableMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            plugins: ifDev(add: devPlugins)
        )
    ]
)
