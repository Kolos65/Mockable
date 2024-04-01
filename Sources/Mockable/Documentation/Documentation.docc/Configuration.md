# Configuration

Learn how to configure build settings so generated mock implementations are excluded from release builds.

## Overview

Since `@Mockable` is a peer macro the generated code will always be at the same scope as the protocol it is attached to. From **Mockable**'s perspective this is unfortunate as we don't want to include our generated mock implementations in the release bundle.

To solve this, the macro expansion is enclosed in a pre-defined compile-time flag called **`MOCKING`** that can be leveraged to exclude generated mock implementations from release builds:
```swift
#if MOCKING
public final class MockService: Service, Mockable {
    // generated code...
}
#endif
```

> Since the **`MOCKING`** flag is not defined in your project by default, you won't be able to use mock implementations unless you configure it.

There are many ways to define the flag depending on how your project is set up or what tool you use for build setting generation. Below you can find how to define the `MOCKING` flag in three common scenarios.

## Define the flag using Xcode
If your porject relies on Xcode build settings, define the flag in your target's build settings for debug build configuration(s):
1. Open your **Xcode project**.
2. Go to your target's **Build Settings**.
3. Find **Swift Compiler - Custom Flags**.
4. Add the **MOCKING** flag under the debug build configuration(s).
5. Repeat these steps for all of your targets where you want to use the `@Mockable` macro.

## Using a Package.swift manifest
If you are using SPM modules or working with a package, define the **`MOCKING`** compile-time condition in your package manifest. Using a `.when(configuration:)` build setting condition you can define the flag only if the build configuration is set to `debug`.
```swift
.target(
    ...
    swiftSettings: [
        .define("MOCKING", .when(configuration: .debug))
    ]
)
```

## Using XcodeGen
If you use XcodeGen to generate you project, you can define the `MOCKING` flag in your yaml file under the `configs` definition.  
```yml
settings:
  ...
  configs:
    debug:
      SWIFT_ACTIVE_COMPILATION_CONDITIONS: MOCKING
```

## Using [Tuist](https://tuist.io/):

If you use Tuist, you can define the `MOCKING` flag in your target's settings under `configurations`.  
```swift
.target(
    ...
    settings: .settings(
        configurations: [
            .debug(
                name: .debug, 
                settings: [
                    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) MOCKING"
                ]
            )
        ]
    )
)
```

## Summary

By defining the `MOCKING` condition in the debug build configuration you ensured that generated mock implementations are excluded from release builds and kept available for your unit tests that use the debug configuration to build tested targets. 
