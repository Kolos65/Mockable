import XCTest
import Mockable

private typealias Error = Int

@Mockable
private protocol ShadowedErrorTypealiasService {
    func throwingMethod() throws
}

final class ErrorShadowingCompileTests: XCTestCase {
    func test_shadowed_error_typealias_allows_macro_expansion() {
        _ = MockShadowedErrorTypealiasService()
    }
}
