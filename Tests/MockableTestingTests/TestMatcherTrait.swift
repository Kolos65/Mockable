#if swift(>=6)
import Testing
import Mockable
@testable import TestingShared
@testable import MockableTesting

/// One of these tests will invert if the matcher instance is the same.
@Suite(.matcher({ matcher in
    matcher.reset()
    matcher.register(Product.self, match: { lhs, rhs in
        lhs.id == rhs.id
    })
}))
struct TestMatcherTrait {

    @Test("Product update is matched")
    func update() async throws {
        print("Test 1 - Matcher: \(Unmanaged.passUnretained(Matcher.current).toOpaque())")
        let expected = [Product.test]
        let service = MockTestService<String>()

        given(service)
            .update(products: .any)
            .willReturn(5)

        _ = service.update(products: expected)

        verify(service)
            .update(products: .value(expected))
            .called(.once)
    }

    @Test("Product update match is changed within task")
    func upsetMatcher() async throws {
        print("Test 2 - Matcher: \(Unmanaged.passUnretained(Matcher.current).toOpaque())")
        Matcher.reset()
        Matcher.register(Product.self, match: { lhs, rhs in
            // Invert the matcher, to break it on this test.
            lhs.id != rhs.id
        })

        let expected = [Product.test]
        let service = MockTestService<String>()

        given(service)
            .update(products: .any)
            .willReturn(5)

        _ = service.update(products: expected)

        withKnownIssue("We expect the UUID match to fail.") {
            verify(service)
                .update(products: .value(expected))
                .called(.once)
        }
    }
}
#endif
