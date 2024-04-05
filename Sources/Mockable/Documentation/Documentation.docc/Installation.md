# Installation

Learn how to install **Mockable** and integrate into your targets.

## Overview

**Mockable** can be installed using Swift Package Manager.

It provides two library products:
* **Mockable**: Core library containing the [`@Mockable`](https://kolos65.github.io/Mockable/documentation/mockable/mockable()) macro. Add **Mockable** to all targets that contain protocols you want to mock. **Mockable** does not depend on the `XCTest` framework so it can be added to any target.
* **MockableTest**: Testing utilities that depend on the `XCTest` framework. Add **MockableTest** to all of your test targets where you want to use mocked services for testing.

> **MockableTest** contains utilities that use the `XCTest` framework so it will only link with test targets. 

> **MockableTest** also makes **Mockable** available so you only need to add **MockableTest** to your test targets.

## Add **Mockable** using Xcode
1. Open your Xcode project.
2. Navigate to the **File** menu and select **Add Package Dependencies...**
3. Enter the following URL: **`https://github.com/Kolos65/Mockable`**
4. Specify the version you want to use and click **Add Package**.
5. In the **Choose Package Products** popup:
    * Select your main target for **`Mockable`**
    * Select your test target for **`MockableTest`**
6. Click **Add Package**

> If you have multiple targets or multiple test targets:
> Navigate to each target's **General** settings and add the appropriate Mockable library under the **Frameworks and Libraries** settings.

### Using a Package.swift manifest:
If you have SPM modules or you want to test an SPM package, add **Mockable** as a package dependency in the manifest file.

In you target definitions add the **Mockable** product to your main target and the **MockableTest** product to your test target.
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
                .product(name: "MockableTest", package: "Mockable")
            ]
        )
    ]
)
```

### Using XcodeGen:
Add Mockable to the `packages` definition and the appropriate products to the `targets` definition.
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
        product: MockableTest
        
```
