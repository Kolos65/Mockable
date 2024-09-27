# Installation

Learn how to install **Mockable** and integrate into your targets.

## Overview

**Mockable** can be installed using Swift Package Manager.

Add the **Mockable** target to all targets that contain protocols you want to mock. **Mockable** does not depend on the `XCTest` framework so it can be added to any target.

## Add **Mockable** using Xcode
1. Open your Xcode project.
2. Navigate to the **File** menu and select **Add Package Dependencies...**
3. Enter the following URL: **`https://github.com/Kolos65/Mockable`**
4. Specify the version you want to use and click **Add Package**.
6. Click **Add Package**

> If you have multiple targets or multiple test targets:
> Navigate to each target's **General** settings and add Mockable under the **Frameworks and Libraries** settings.

### Using a Package.swift manifest:
If you have SPM modules or you want to test an SPM package, add **Mockable** as a package dependency in the manifest file.

In you target definitions add the **Mockable** product to your main and test targets.
```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/Kolos65/Mockable", from: "0.0.1"),
    ],
    targets: [
        .target(
            ...
            dependencies: [
                .product(name: "Mockable", package: "Mockable")
            ]
        ),
        .testTarget(
            ...
            dependencies: [
                .product(name: "Mockable", package: "Mockable")
            ]
        )
    ]
)
```

### Using XcodeGen:
Add Mockable to the `packages` definition and the `targets` definition.
```yaml
packages:
  Mockable:
    url: https://github.com/Kolos65/Mockable
    from: "0.0.1"

targets:
  MyApp:
    ...
    dependencies:
      - package: Mockable
        product: Mockable
  MyAppUnitTests:
    ...
    dependencies:
      - package: Mockable
        product: Mockable
        
```
