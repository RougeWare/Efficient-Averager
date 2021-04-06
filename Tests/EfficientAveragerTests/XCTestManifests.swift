import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Efficient_AveragerTests.allTests),
    ]
}
#endif
