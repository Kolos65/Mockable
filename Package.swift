// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let test = Context.environment["MOCKABLE_TEST"].flatMap(Bool.init) ?? false
let lint = Context.environment["MOCKABLE_LINT"].flatMap(Bool.init) ?? false
let doc = Context.environment["MOCKABLE_DOC"].flatMap(Bool.init) ?? false

func when<T>(_ condition: Bool, _ list: [T]) -> [T] { condition ? list : [] }

let devDependencies: [Package.Dependency] = when(test, [
    .package(url: "https://github.com/pointfreeco/swift-macro-testing", exact: "0.6.4")
]) + when(lint, [
    .package(url: "https://github.com/realm/SwiftLint", exact: "0.57.1"),
]) + when(doc, [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
])

let devPlugins: [Target.PluginUsage] = when(lint, [
    .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
])

let devTargets: [Target] = when(test, [
    .target(
        name: "TestingShared",
        dependencies: ["Mockable"],
        path: "Tests/TestingShared",
        swiftSettings: [
            .define("MOCKING"),
            .enableExperimentalFeature("StrictConcurrency"),
            .enableUpcomingFeature("ExistentialAny")
        ],
        plugins: devPlugins
    ),
    .testTarget(
        name: "MockableTests",
        dependencies: ["Mockable", "TestingShared"],
        swiftSettings: [
            .define("MOCKING"),
            .enableExperimentalFeature("StrictConcurrency"),
            .enableUpcomingFeature("ExistentialAny")
        ],
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
    ),
    .testTarget(
        name: "MockableTestingTests",
        dependencies: ["Mockable", "MockableTesting", "TestingShared"],
        swiftSettings: [
            .define("MOCKING"),
            .enableExperimentalFeature("StrictConcurrency"),
            .enableUpcomingFeature("ExistentialAny")
        ],
        plugins: devPlugins
    ),
])

let package = Package(
    name: "Mockable",
    platforms: [.macOS(.v12), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "Mockable",
            targets: ["Mockable"]
        ),
        .library(
            name: "MockableTesting",
            targets: ["MockableTesting"]
        ),
    ],
    dependencies: devDependencies + [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "509.0.0"..<"603.0.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", .upToNextMajor(from: "1.6.0"))
    ],
    targets: devTargets + [
        .target(
            name: "Mockable",
            dependencies: [
                "MockableMacro",
                .product(name: "IssueReporting", package: "xctest-dynamic-overlay")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ],
            plugins: devPlugins
        ),
        .macro(
            name: "MockableMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ],
            plugins: devPlugins
        ),
        .target(
            name: "MockableTesting",
            dependencies: [
                "Mockable",
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("ExistentialAny")
            ],
            plugins: devPlugins
        ),
    ],
    swiftLanguageVersions: [.v5, .version("6")]
)

