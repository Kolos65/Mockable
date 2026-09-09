// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let test = Context.environment["MOCKABLE_TEST"].flatMap(Bool.init) ?? false
let lint = Context.environment["MOCKABLE_LINT"].flatMap(Bool.init) ?? false
let doc = Context.environment["MOCKABLE_DOC"].flatMap(Bool.init) ?? false

func when<T>(_ condition: Bool, _ list: [T]) -> [T] { condition ? list : [] }

// The split prescribed by xctest-dynamic-overlay's README. The two URLs each declare an
// `IssueReporting` target and cannot coexist in one graph, and the ecosystem only moves to the
// new one from Swift 6.4 on.
#if compiler(>=6.4)
let issueReportingPackage: Package.Dependency = .package(
    url: "https://github.com/pointfreeco/swift-issue-reporting", from: "2.1.0"
)
let issueReportingProduct: Target.Dependency = .product(
    name: "IssueReporting", package: "swift-issue-reporting"
)
#else
let issueReportingPackage: Package.Dependency = .package(
    url: "https://github.com/pointfreeco/xctest-dynamic-overlay", "1.13.0"..<"2.0.0"
)
let issueReportingProduct: Target.Dependency = .product(
    name: "IssueReporting", package: "xctest-dynamic-overlay"
)
#endif

let devDependencies: [Package.Dependency] = when(test, [
    .package(url: "https://github.com/pointfreeco/swift-macro-testing", exact: "0.7.0")
]) + when(lint, [
    .package(url: "https://github.com/realm/SwiftLint", exact: "0.57.1"),
]) + when(doc, [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
])

let devPlugins: [Target.PluginUsage] = when(lint, [
    .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
])

let devTargets: [Target] = when(test, [
    .testTarget(
        name: "MockableTests",
        dependencies: ["Mockable"],
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
    )
])

let package = Package(
    name: "Mockable",
    platforms: [.macOS(.v12), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "Mockable",
            targets: ["Mockable"]
        )
    ],
    dependencies: devDependencies + [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "509.0.0"..<"605.0.0"),
        issueReportingPackage
    ],
    targets: devTargets + [
        .target(
            name: "Mockable",
            dependencies: [
                "MockableMacro",
                issueReportingProduct
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
        )
    ],
    swiftLanguageModes: [.v6]
)

