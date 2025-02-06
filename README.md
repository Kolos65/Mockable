
<p>
<img width="300" src="https://github.com/Kolos65/Mockable/assets/26504214/4e19e4fc-8453-4320-a061-e672dcc95023" alt="@Mockable"/>
</p>

**Mockable** is a [Swift macro](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/) driven testing framework that provides automatic mock implementations for your protocols. It offers an intuitive **declarative syntax** that simplifies the process of mocking services in unit tests. The generated mock implementations can be excluded from release builds using compile conditions. 

## Table of Contents
- [Sponsorship](#Sponsorship)
- [Documentation](#Documentation)
- [Installation](#Installation)
- [Configuration](#Configuration)
- [Usage](#Usage)
  - [Example](#Example)
  - [Syntax](#Syntax)
  - [Parameters](#Parameters)
  - [Given](#Given)
  - [When](#When)
  - [Verify](#Verify)
  - [Relaxed Mode](#Relaxed-Mode)
  - [Non-equatable Types](#Working-with-non-equatable-Types)
- [Supported Features](#Supported-Features)
- [Limitations](#Limitations)
- [Contribution](#Contribution)
- [License](#License)

## Sponsorship

I'm working on **Mockable** as a fun side project. I believe in the power of open source, and I'm thrilled to share it with you. If **Mockable** saves you time and you’d like to show your appreciation, I would be incredibly grateful for your support.

<a href="https://www.buymeacoffee.com/kolos"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a beer&emoji=🍺&slug=kolos&button_colour=FF5F5F&font_colour=ffffff&font_family=Arial&outline_colour=000000&coffee_colour=FFDD00" /></a>

## Documentation

Read **Mockable**'s [documentation](https://kolos65.github.io/Mockable/documentation/mockable) for detailed installation and configuration guides as well as usage examples.

## Installation

The library can be installed using Swift Package Manager.

Add the **Mockable** target to all targets that contain protocols you want to mock. **Mockable** does not depend on the `XCTest` framework so it can be added to any target.

Read the [installation guide](https://kolos65.github.io/Mockable/documentation/mockable/installation/) of the documentation for more details on how to integrate **Mockable** with your project.

## Configuration

Since `@Mockable` is a [peer macro](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes/#attached), 
the generated code will always be at the same scope as the protocol it is attached to. 

To solve this, the macro expansion is enclosed in a pre-defined compile-time flag called **`MOCKING`** that can be leveraged to exclude generated mock implementations from release builds.

> ⚠️ Since the **`MOCKING`** flag is not defined in your project by default, you won't be able to use mock implementations unless you configure it.

### When using framework modules or a non-modular project:
Define the flag in your target's build settings for debug build configuration(s):
1. Open your **Xcode project**.
2. Go to your target's **Build Settings**.
3. Find **Swift Compiler - Custom Flags**.
4. Add the **MOCKING** flag under the debug configuration(s).

### When using SPM modules or testing a package:
In your module's package manifest under the target definition, you can define the **`MOCKING`** compile-time condition if the build configuration is set to **`debug`**:
```swift
.target(
    ...
    swiftSettings: [
        .define("MOCKING", .when(configuration: .debug))
    ]
)
```

### When using [XcodeGen](https://github.com/yonaskolb/XcodeGen):
Define the flag in your **XcodeGen** specification:
```yml
settings:
  ...
  configs:
    debug:
      SWIFT_ACTIVE_COMPILATION_CONDITIONS: MOCKING
```

### When using [Tuist](https://tuist.io/):

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

Read the [configuration guide](https://kolos65.github.io/Mockable/documentation/mockable/configuration/) of the documentation for more details on how to setup the **`MOCKING`** flag in your project.

## Usage

### Example

Given a protocol annotated with the `@Mockable` macro:
```swift
import Mockable

@Mockable
protocol ProductService {
    var url: URL? { get set }
    func fetch(for id: UUID) async throws -> Product
    func checkout(with product: Product) throws
}
```
A mock implementation named `MockProductService` will be generated, that can be used in unit tests like:
```swift
import Mockable

lazy var productService = MockProductService()
lazy var cartService = CartServiceImpl(productService: productService)

func testCartService() async throws {
    let mockURL = URL(string: "apple.com")
    let mockError: ProductError = .notFound
    let mockProduct = Product(name: "iPhone 15 Pro")

    given(productService)
        .fetch(for: .any).willReturn(mockProduct)
        .checkout(with: .any).willThrow(mockError)

    try await cartService.checkout(with: mockProduct, using: mockURL)

    verify(productService)
        .fetch(for: .value(mockProduct.id)).called(.atLeastOnce)
        .checkout(with: .value(mockProduct)).called(.once)
        .url(newValue: .value(mockURL)).setCalled(.once)
}
```

### Syntax

**Mockable** has a declarative syntax that utilizes builders to construct `given`, `when`, and `verify` clauses. 
When constructing any of these clauses, you always follow the same syntax: 

`clause type`(`service`).`function builder`.`behavior builder`

In the following example where we use the previously introduced product service:
```swift
let id = UUID()
let error: ProductError = .notFound

given(productService).fetch(for: .value(id)).willThrow(error)
```
We specify the following:
* **`given`**: we want to register **return values**
* **`(productService)`**: we specify what mockable service we want to register return values for
* **`.fetch(for: .value(id))`**: we want to mock the `fetch(for:)` method and constrain our behavior on calls with matching `id` parameters
* **`.willThrow(error)`**: if `fetch(for:)` is called with the specified parameter value, we want an **error** to be thrown

### Parameters

Function builders have **all parameters** from the original requirement but **encapsulate them** within the [`Parameter<Value>`](https://kolos65.github.io/Mockable/documentation/mockable/parameter) type. 
When constructing mockable clauses, you have to **specify parameter conditions** for every parameter of a function. There are three available options:

* **`.any`**: Matches every call to the specified function, disregarding the actual parameter values.
* **`.value(Value)`**: Matches to calls with an identical value in the specified parameter.
* **`.matching((Value) -> Bool)`**: Uses the provided closure to filter functions calls.

> Computed properties have no parameters, but mutable properties get a `(newValue:)` parameter in function builders that can be used 
to constraint functionality on property assignment with a match condition. These `newValue` conditions will only effect the `performOnGet`, `performOnSet`, `getCalled` and `setCalled`
clauses but will have no effect on return clauses.

Here are examples of using different parameter conditions:

```swift
// throw an error when `fetch(for:)` is called with `id`
given(productService).fetch(for: .value(id)).willThrow(error)

// print "Ouch!" if product service is called with a product named "iPhone 15 Pro"
when(productService)
  .checkout(with: .matching { $0.name == "iPhone 15 Pro" })
  .perform { print("Ouch!") }

// assert if the fetch(for:) was called exactly once regardless of what id parameter it was called with
verify(productService).fetch(for: .any).called(.once)
```

### Given

Return values can be specified using a `given(_ service:)` clause. There are three return builders available:
* [`willReturn(_ value:)`](https://kolos65.github.io/Mockable/documentation/mockable/functionreturnbuilder/willreturn(_:)): Will store the given return value and use it to mock subsequent calls.
* [`willThrow(_ error:)`](https://kolos65.github.io/Mockable/documentation/mockable/throwingfunctionreturnbuilder/willthrow(_:)): Will store the given error and throw it in subsequent calls. Only available for throwing functions and properties.
* [`willProduce(_ producer)`](https://kolos65.github.io/Mockable/documentation/mockable/throwingfunctionreturnbuilder/willproduce(_:)): Will use the provided closure for mocking. The closure has the same signature as the mocked function, so for example a function that takes an integer returns a string and can throw will accept a closure of type `(Int) throws -> String`.

The provided return values are used up in FIFO order and the last one is always kept for any further calls. Here are examples of using return clauses:
```swift
// Throw an error for the first call and then return 'product' for every other call
given(productService)
    .fetch(for: .any).willThrow(error)
    .fetch(for: .any).willReturn(product)

// Throw an error if the id parameter ends with a 0, return a product otherwise
given(productService)
    .fetch(for: .any).willProduce { id in
        if id.uuidString.last == "0" {
            throw error
        } else {
            return product
        }
    }
```

### When

Side effects can be added using `when(_ service:)` clauses. There are three kind of side effects:
* [`perform(_ action)`](https://kolos65.github.io/Mockable/documentation/mockable/functionactionbuilder/perform(_:)): Will register an operation to perform on invocations of the mocked function.
* [`performOnGet(_ action:)`](https://kolos65.github.io/Mockable/documentation/mockable/propertyactionbuilder/performonget(_:)): Available for mutable properties only, will perform the provided operation on property access.
* [`performOnSet(_ action:)`](https://kolos65.github.io/Mockable/documentation/mockable/propertyactionbuilder/performonset(_:)): Available for mutable properties only, will perform the provided operation on property assignment.

Some examples of using side effects are:
```swift
// log calls to fetch(for:)
when(productService).fetch(for: .any).perform {
    print("fetch(for:) was called")
}

// log when url is accessed
when(productService).url().performOnGet {
    print("url accessed")
}

// log when url is set to nil
when(productService).url(newValue: .value(nil)).performOnSet {
    print("url set to nil")
}
```

### Verify
You can verify invocations of your mock service using the `verify(_ service:)` clause.

> **Mockable** supports both *XCTest* and *Swift Testing* by using Pointfree's [swift-issue-reporting](https://github.com/pointfreeco/swift-issue-reporting) to dynamically report test failures with the appropriate test framework.

There are three kind of verifications:
* [`called(_:)`](https://kolos65.github.io/Mockable/documentation/mockable/functionverifybuilder/called(_:fileid:filepath:line:column:)): Asserts invocation count based on the given value.
* [`getCalled(_:)`](https://kolos65.github.io/Mockable/documentation/mockable/propertyverifybuilder/getcalled(_:fileid:filepath:line:column:)): Available for mutable properties only, asserts property access count.
* [`setCalled(_:)`](https://kolos65.github.io/Mockable/documentation/mockable/propertyverifybuilder/setcalled(_:fileid:filepath:line:column:)): Available for mutable properties only, asserts property assignment count.

Here are some example assertions:
```swift
verify(productService)
    // assert fetch(for:) was called between 1 and 5 times
    .fetch(for: .any).called(.from(1, to: 5))
    // assert checkout(with:) was called between exactly 10 times
    .checkout(with: .any).called(10)
    // assert url property was accessed at least 2 times
    .url().getCalled(.moreOrEqual(to: 2))
    // assert url property was never set to nil
    .url(newValue: .value(nil)).setCalled(.never)
```

If you are testing asynchronous code and cannot write sync assertions you can use the async counterparts of the above verifications:
* [`calledEventually(_:before:)`](https://kolos65.github.io/Mockable/documentation/mockable/functionverifybuilder/calledeventually(_:before:fileid:filepath:line:column:)): Wait until timeout or invocation count satisfied.
* [`getCalledEventually(_:before:)`](https://kolos65.github.io/Mockable/documentation/mockable/propertyverifybuilder/getcalledeventually(_:before:fileid:filepath:line:column:)): Wait until timeout or property access count satisfied.
* [`setSalledEventually(_:before:)`](https://kolos65.github.io/Mockable/documentation/mockable/propertyverifybuilder/setcalledeventually(_:before:fileid:filepath:line:column:)): Wait until timeout or property assignment count satisfied.

Here are some examples of async verifications:
```swift
await verify(productService)
    // assert fetch(for:) was called between 1 and 5 times before default timeout (1 second)
    .fetch(for: .any).calledEventually(.from(1, to: 5))
    // assert checkout(with:) was called between exactly 10 times before 3 seconds
    .checkout(with: .any).calledEventually(10, before: .seconds(3))
    // assert url property was accessed at least 2 times before default timeout (1 second)
    .url().getCalledEventually(.moreOrEqual(to: 2))
    // assert url property was set to nil once
    .url(newValue: .value(nil)).setCalledEventually(.once)
```

### Relaxed Mode
By default, you must specify a return value for all requirements; otherwise, a fatal error will be thrown. The reason for this is to aid in the discovery (and thus the verification) of every called function when writing unit tests. 

However, it is common to prefer avoiding this strict default behavior in favor of a more relaxed setting, where, 
for example, void or optional return values do not need explicit `given` registration.

Use [`MockerPolicy`](https://kolos65.github.io/Mockable/documentation/mockable/mockerpolicy) (which is an [option set](https://developer.apple.com/documentation/swift/optionset)) to implicitly mock:
* only one kind of return value: `.relaxedMocked`
* construct a custom set of policies: `[.relaxedVoid, .relaxedOptional]`
* or opt for a fully relaxed mode: `.relaxed`.

You have two options to override the default strict behavior of the library:
* at **mock implementation level** you can override the mocker policy for each individual mock implementation in the initializer: 
    ```swift
    let relaxedMock = MockService(policy: [.relaxedOptional, .relaxedVoid])
    ```
* at **project level** you can set a custom default policy to use in every scenario by changing the default property of **MockerPolicy**: 
    ```swift
    MockerPolicy.default = .relaxedVoid
    ```

The `.relaxedMocked` policy in combination with the [`Mocked`](https://kolos65.github.io/Mockable/documentation/mockable/mocked) protocol can be used to set an implicit return value for custom (or even built in) types:
```swift
struct Car {
    var name: String
    var seats: Int
}

extension Car: Mocked {
    static var mock: Car {
        Car(name: "Mock Car", seats: 4)
    }

    // Defaults to [mock] but we can 
    // provide a custom array of cars:
    static var mocks: [Car] {
        [
            Car(name: "Mock Car 1", seats: 4),
            Car(name: "Mock Car 2", seats: 4)
        ]
    }
}

@Mockable
protocol CarService {
    func getCar() -> Car
    func getCars() -> [Car]
}

func testCarService() {
    func test() {
        let mock = MockCarService(policy: .relaxedMocked)
        // Implictly mocked without a given registration:
        let car = mock.getCar()
        let cars = mock.getCars()
    }
}
```

> ⚠️ Relaxed mode will not work with generic return values as the type system is unable to locate the appropriate generic overload.

### Working with non-equatable Types
**Mockable** uses a [`Matcher`](https://kolos65.github.io/Mockable/documentation/mockable/matcher) internally to compare parameters. 
By default the matcher is able to compare any custom type that conforms to `Equatable` (except when used in a generic function).
In special cases, when you
* have non-equatable parameter types
* need testing specific equality logic for a custom type
* have generic functions that are used with custom concrete types

you can register your custom types with the `Matcher.register()` functions.
Here is how to do it:
```swift
// register an equatable type to the matcher because we use it in a generic function
Matcher.register(SomeEquatableType.self)

// register a non-equatable type to the matcher
Matcher.register(Product.self, match: { $0.name == $1.name })

// register a meta-type to the matcher
Matcher.register(HomeViewController.Type.self)

// remove all previously registered custom types
Matcher.reset()
```
If you see an error during tests like:
> No comparator found for type "SomeType". All non-equatable types must be registered using Matcher.register(_).

Remember to add the noted type to your `Matcher` using the `register()` function.

## Supported Features

- [x] **Zero-boilerplate** mock generation</br>
- [x] **Exclude** mock implementations **from production** target</br>
- [x] Protocols with **associated types**</br>
- [x] Protocols with **constrained associated types**</br>
- [x] **Init** requirements</br>
- [x] **Generic function parameters** and **return values**</br>
- [x] Generic functions with **where clauses**</br>
- [x] Computed and mutable **property requirements**</br>
- [x] **@escaping closure** parameters</br>
- [x] **Implicitly unwrapped** optionals</br>
- [x] **throwing, rethrowing and async** requirements</br>
- [x] Custom **non-equatable** types

## Limitations

- [ ] **Static Requirements**: Static members cannot be used on protocols and are not supported.</br>
- [ ] **Protocol Inheritance**: Due to limitations of the macro system, inherited protocol requirements won't be implemented.</br>
- [ ] **Return Type Overloads**: Requirements with overloaded return types are not supported in favour of supporting generic return types.
- [ ] **Rethrows functions**: Rethrowing function requirements are always implemented with non-throwing functions.</br>
- [ ] **Non-escaping function parameters**: Non-escaping closure parameters cannot be stored and are not supported.</br>
- [ ] **Subscripts** are not supported (yet).</br>
- [ ] **Operators** are not supported (yet).</br>

## Contribution

If you encounter any issues with the project or have suggestions for improvement, please feel free to open an issue. I value your feedback and am committed to making this project as robust and user-friendly as possible.

The package manifest is set up to only contain test targets and test dependencies if an environment variable named `MOCKABLE_DEV` is set to true. This is done to prevent the overly zealous Swift Package Manager from downloading test dependencies and plugins, such as `swift-macro-testing` or `SwiftLint`, when someone uses **Mockable** as a package dependency.

To open the package with Xcode in "development mode", you need the `MOCKABLE_DEV=true` environment variable to be set. Use `Scripts/open.sh` to open the project (or copy its contents into your terminal) to be able to run tests and lint your code when contributing.

## License

**Mockable** is made available under the MIT License. Please see the [LICENSE](https://raw.githubusercontent.com/Kolos65/Mockable/main/LICENSE) file for more details.

