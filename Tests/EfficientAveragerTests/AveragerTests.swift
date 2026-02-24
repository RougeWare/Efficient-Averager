//
//  AveragerTests.swift
//  EfficientAverager
//
//  Tests the contracts of `AveragerProtocol` and its concrete implementations.
//
//  Test organization:
//    1. `ReferenceAverager`: a minimal conformer used to test synthesized protocol behavior
//    2. `ProactiveAverager`: all contracts
//    3. `SummingAverager`: all contracts
//    4. The `<<` infix operator
//    5. Cross-implementation consistency: all three types must agree on the mean
//
//  Created by Ky directing Claude 4.6 Sonnet.
//  In the public domain via The Fair License
//  https://opensource.org/license/fair
//

import Foundation
import Testing

import EfficientAverager



// MARK: - Helpers

private extension BinaryFloatingPoint {
    
    /// Returns `true` if this value is within `tolerance` of `expected`.
    func isApproximately(_ expected: Self, within tolerance: Self = .ε) -> Bool {
        abs(self - expected) < tolerance
    }
    
    
    /// How close two floating-point values need to be to count as equal in these tests.
    @inline(__always)
    static var ε: Self { 1e-10 }
}



// MARK: - Reference Implementation

/// A minimal `AveragerProtocol` conformer used to test the protocol's synthesized behavior.
///
/// It stores every value it receives and recomputes the mean from the full list on each read, so `currentAverage` is always as accurate as possible. That makes it a reliable reference to check the production types against.
///
/// Only the minimal requirements (`currentAverage`, `timesAveraged`, `init()`, `init(startingNumber:)`, and `average(_ number:)`) are implemented here. `currentAverageOrNil`, `clear()`, the variadic overload, and the array overload are all left to `AveragerProtocol` to synthesize.
private struct ReferenceAverager<Number: BinaryFloatingPoint>: AveragerProtocol {
    
    
    private var values: [Number] = []
    
    
    var timesAveraged: UInt { UInt(values.count) }
    
    
    var currentAverage: Number {
        guard !values.isEmpty else { return .nan }
        return values.reduce(0, +) / Number(values.count)
    }
    
    
    init() {}
    
    
    init(startingNumber: Number) {
        values = [startingNumber]
    }
    
    
    @discardableResult
    mutating func average(_ number: Number) -> Self {
        values.append(number)
        return self
    }
}



// MARK: - AveragerProtocol Synthesis

/// Tests for the behavior that `AveragerProtocol` synthesizes for any conformer. Uses `ReferenceAverager` because it only implements the bare minimum, so everything under test here is guaranteed to come from the protocol.
@Suite("`AveragerProtocol` Synthesis (via `ReferenceAverager`)")
struct AveragerProtocolSynthesisTests {
    
    
    // MARK: init
    
    @Test("`init()`: zero average, zero count")
    func defaultInit() {
        let averager = ReferenceAverager<Double>()
        #expect(averager.currentAverage.isNaN)
        #expect(averager.timesAveraged == 0)
    }
    
    
    @Test("`init(startingNumber:)`: seeds average and count correctly")
    func startingNumberInit() {
        let averager = ReferenceAverager<Double>(startingNumber: 42)
        #expect(averager.currentAverage.isApproximately(42))
        #expect(averager.timesAveraged == 1)
    }
    
    
    // MARK: currentAverageOrNil
    
    @Test("`currentAverageOrNil` is nil before any averaging")
    func currentAverageOrNilWhenEmpty() {
        let averager = ReferenceAverager<Double>()
        #expect(averager.currentAverageOrNil == nil)
    }
    
    
    @Test("`currentAverageOrNil` returns the mean after averaging")
    func currentAverageOrNilWhenPopulated() {
        var averager = ReferenceAverager<Double>()
        averager.average(42)
        #expect(averager.currentAverageOrNil?.isApproximately(42) == true)
    }
    
    
    @Test("`currentAverageOrNil` reverts to nil after `clear()`")
    func currentAverageOrNilAfterClear() {
        var averager = ReferenceAverager<Double>()
        averager.average(5)
        averager.clear()
        #expect(averager.currentAverageOrNil == nil)
    }
    
    
    // MARK: clear()
    
    @Test("`clear()` resets to a blank state")
    func clearResetsState() {
        var averager = ReferenceAverager<Double>()
        averager.average([10, 20, 30])
        averager.clear()
        #expect(averager.currentAverage.isNaN)
        #expect(averager.timesAveraged == 0)
    }
    
    
    @Test("Averaging works correctly after `clear()`")
    func averagingAfterClear() {
        var averager = ReferenceAverager<Double>()
        averager.average([100, 200])
        averager.clear()
        averager.average([3, 9])
        // (3 + 9) / 2 = 6
        #expect(averager.currentAverage.isApproximately(6))
        #expect(averager.timesAveraged == 2)
    }
    
    
    // MARK: Variadic overload
    
    @Test("Variadic `average` produces the correct result")
    func variadicAveraging() {
        var averager = ReferenceAverager<Double>()
        averager.average(2, 4, 6)
        // (2 + 4 + 6) / 3 = 4
        #expect(averager.currentAverage.isApproximately(4))
        #expect(averager.timesAveraged == 3)
    }
    
    
    @Test("Variadic `average` matches element-wise averaging")
    func variadicMatchesElementWise() {
        var variadic  = ReferenceAverager<Double>()
        var elementWise = ReferenceAverager<Double>()
        
        variadic.average(1, 2, 3, 4, 5)
        elementWise.average(1)
        elementWise.average(2)
        elementWise.average(3)
        elementWise.average(4)
        elementWise.average(5)
        
        #expect(variadic.currentAverage.isApproximately(elementWise.currentAverage))
        #expect(variadic.timesAveraged == elementWise.timesAveraged)
    }
    
    
    // MARK: Array overload
    
    @Test("Array `average` produces the correct result")
    func arrayAveraging() {
        var averager = ReferenceAverager<Double>()
        averager.average([1, 2, 3, 4, 5])
        // (1 + 2 + 3 + 4 + 5) / 5 = 3
        #expect(averager.currentAverage.isApproximately(3))
        #expect(averager.timesAveraged == 5)
    }
    
    
    @Test("Array `average` matches element-wise averaging")
    func arrayMatchesElementWise() {
        var array     = ReferenceAverager<Double>()
        var elementWise = ReferenceAverager<Double>()
        
        array.average([10, 20, 30])
        elementWise.average(10)
        elementWise.average(20)
        elementWise.average(30)
        
        #expect(array.currentAverage.isApproximately(elementWise.currentAverage))
        #expect(array.timesAveraged == elementWise.timesAveraged)
    }
    
    
    @Test("Empty array is a no-op")
    func emptyArrayIsNoOp() {
        var averager = ReferenceAverager<Double>()
        averager.average(7)
        let snapshotAverage  = averager.currentAverage
        let snapshotCount    = averager.timesAveraged
        
        averager.average([Double]())
        
        #expect(averager.currentAverage.isApproximately(snapshotAverage))
        #expect(averager.timesAveraged == snapshotCount)
    }
    
    
    // MARK: Deprecated no-arg overload
    
    @Test("No-arg `average()` is a no-op")
    func noArgAverageIsNoOp() {
        var averager = ReferenceAverager<Double>()
        averager.average(7)
        let snapshotAverage  = averager.currentAverage
        let snapshotCount    = averager.timesAveraged
        
        averager.average()
        
        #expect(averager.currentAverage.isApproximately(snapshotAverage))
        #expect(averager.timesAveraged == snapshotCount)
    }
    
    
    // MARK: Chaining
    
    @Test("Chained calls produce the correct cumulative mean")
    func chaining() {
        var averager = ReferenceAverager<Double>()
        averager.average(1, 2, 3)
        averager.average([4, 5])
        averager.average(6)
        // (1 + 2 + 3 + 4 + 5 + 6) / 6 = 3.5
        #expect(averager.currentAverage.isApproximately(3.5))
        #expect(averager.timesAveraged == 6)
    }
}



// MARK: - ProactiveAverager

@Suite("`ProactiveAverager`")
struct ProactiveAveragerTests {
    
    
    // MARK: init
    
    @Test("`init()`: zero average, zero count")
    func defaultInit() {
        let averager = ProactiveAverager<Double>()
        #expect(averager.currentAverage == 0)
        #expect(averager.timesAveraged  == 0)
    }
    
    
    @Test("`init(startingNumber:)`: seeds average and count correctly")
    func startingNumberInit() {
        let averager = ProactiveAverager<Double>(startingNumber: 42)
        #expect(averager.currentAverage.isApproximately(42))
        #expect(averager.timesAveraged == 1)
    }
    
    
    // MARK: currentAverageOrNil
    
    @Test("`currentAverageOrNil` is nil before any averaging")
    func currentAverageOrNilWhenEmpty() {
        let averager = ProactiveAverager<Double>()
        #expect(averager.currentAverageOrNil == nil)
    }
    
    
    @Test("`currentAverageOrNil` returns the mean after averaging")
    func currentAverageOrNilWhenPopulated() {
        var averager = ProactiveAverager<Double>()
        averager.average(42)
        #expect(averager.currentAverageOrNil?.isApproximately(42) == true)
    }
    
    
    @Test("`currentAverageOrNil` reverts to nil after `clear()`")
    func currentAverageOrNilAfterClear() {
        var averager = ProactiveAverager<Double>()
        averager.average(5)
        averager.clear()
        #expect(averager.currentAverageOrNil == nil)
    }
    
    
    // MARK: clear()
    
    @Test("`clear()` resets to a blank state")
    func clearResetsState() {
        var averager = ProactiveAverager<Double>()
        averager.average([10, 20, 30])
        averager.clear()
        #expect(averager.currentAverage == 0)
        #expect(averager.timesAveraged  == 0)
    }
    
    
    @Test("Averaging works correctly after `clear()`")
    func averagingAfterClear() {
        var averager = ProactiveAverager<Double>()
        averager.average([100, 200])
        averager.clear()
        averager.average([3, 9])
        // (3 + 9) / 2 = 6
        #expect(averager.currentAverage.isApproximately(6))
        #expect(averager.timesAveraged == 2)
    }
    
    
    // MARK: Single-value averaging
    
    @Test("Single value into empty averager yields that value")
    func singleValue() {
        var averager = ProactiveAverager<Double>()
        averager.average(7)
        #expect(averager.currentAverage.isApproximately(7))
        #expect(averager.timesAveraged == 1)
    }
    
    
    @Test("Sequential single values converge to the correct mean")
    func sequentialValues() {
        var averager = ProactiveAverager<Double>()
        
        averager.average(10)
        averager.average(20)
        // (10 + 20) / 2 = 15
        #expect(averager.currentAverage.isApproximately(15))
        #expect(averager.timesAveraged == 2)
        
        averager.average(30)
        // (10 + 20 + 30) / 3 = 20
        #expect(averager.currentAverage.isApproximately(20))
        #expect(averager.timesAveraged == 3)
    }
    
    
    // MARK: Array averaging
    
    @Test("Array averaging matches element-wise averaging")
    func arrayMatchesElementWise() {
        var batch     = ProactiveAverager<Double>()
        var stepwise  = ProactiveAverager<Double>()
        
        batch.average([1, 2, 3, 4, 5])
        stepwise.average(1)
        stepwise.average(2)
        stepwise.average(3)
        stepwise.average(4)
        stepwise.average(5)
        
        #expect(batch.currentAverage.isApproximately(stepwise.currentAverage))
        #expect(batch.timesAveraged == stepwise.timesAveraged)
    }
    
    
    @Test("Empty array is a no-op")
    func emptyArrayIsNoOp() {
        var averager = ProactiveAverager<Double>()
        averager.average(7)
        let snapshotAverage  = averager.currentAverage
        let snapshotCount    = averager.timesAveraged
        
        averager.average([Double]())
        
        #expect(averager.currentAverage.isApproximately(snapshotAverage))
        #expect(averager.timesAveraged == snapshotCount)
    }
    
    
    // MARK: Variadic averaging
    
    @Test("Variadic `average` produces the correct result")
    func variadicAveraging() {
        var averager = ProactiveAverager<Double>()
        averager.average(2, 4, 6)
        // (2 + 4 + 6) / 3 = 4
        #expect(averager.currentAverage.isApproximately(4))
        #expect(averager.timesAveraged == 3)
    }
    
    
    // MARK: Chaining
    
    @Test("Chained calls produce the correct cumulative mean")
    func chaining() {
        var averager = ProactiveAverager<Double>()
        averager.average(1, 2, 3)
        averager.average([4, 5])
        averager.average(6)
        // (1 + 2 + 3 + 4 + 5 + 6) / 6 = 3.5
        #expect(averager.currentAverage.isApproximately(3.5))
        #expect(averager.timesAveraged == 6)
    }
    
    
    // MARK: Edge cases
    
    @Test("Mixed-sign values cancel correctly")
    func mixedSignValues() {
        var averager = ProactiveAverager<Double>()
        averager.average([-5, 5])
        #expect(averager.currentAverage.isApproximately(0))
    }
    
    
    @Test("Works correctly with `Float` type parameter")
    func floatTypeParameter() {
        var averager = ProactiveAverager<Float>()
        averager.average(1, 3)
        #expect(averager.currentAverage.isApproximately(2))
    }
}



// MARK: - SummingAverager

@Suite("`SummingAverager`")
struct SummingAveragerTests {
    
    
    // MARK: init
    
    @Test("`init()`: zero sum, zero count")
    func defaultInit() {
        let averager = SummingAverager<Double>()
        #expect(averager.currentSum    == 0)
        #expect(averager.timesAveraged == 0)
    }
    
    
    @Test("`init(startingNumber:)`: seeds sum and count correctly")
    func startingNumberInit() {
        let averager = SummingAverager<Double>(startingNumber: 8)
        #expect(averager.currentSum     == 8)
        #expect(averager.timesAveraged  == 1)
        #expect(averager.currentAverage.isApproximately(8))
    }
    
    
    // MARK: currentAverage
    
    /// With no values contributed, `currentAverage` is NaN. This is the mathematically correct result for the mean of the empty set. Use `currentAverageOrNil` if you need a defined value.
    @Test("`currentAverage` is NaN when no values have been averaged")
    func currentAverageIsNaNWhenEmpty() {
        let averager = SummingAverager<Double>()
        #expect(averager.currentAverage.isNaN)
    }
    
    
    @Test("`currentAverage` reflects the correct mean after averaging")
    func currentAverageBasic() {
        var averager = SummingAverager<Double>()
        averager.average([10, 20, 30])
        // (10 + 20 + 30) / 3 = 20
        #expect(averager.currentAverage.isApproximately(20))
    }
    
    
    // MARK: currentAverageOrNil
    
    @Test("`currentAverageOrNil` is nil before any averaging")
    func currentAverageOrNilWhenEmpty() {
        let averager = SummingAverager<Double>()
        #expect(averager.currentAverageOrNil == nil)
    }
    
    
    @Test("`currentAverageOrNil` returns the mean after averaging")
    func currentAverageOrNilWhenPopulated() {
        var averager = SummingAverager<Double>()
        averager.average(42)
        #expect(averager.currentAverageOrNil?.isApproximately(42) == true)
    }
    
    
    @Test("`currentAverageOrNil` reverts to nil after `clear()`")
    func currentAverageOrNilAfterClear() {
        var averager = SummingAverager<Double>()
        averager.average(5)
        averager.clear()
        #expect(averager.currentAverageOrNil == nil)
    }
    
    
    // MARK: clear()
    
    @Test("`clear()` resets to a blank state")
    func clearResetsState() {
        var averager = SummingAverager<Double>()
        averager.average([10, 20, 30])
        averager.clear()
        
        let fresh = SummingAverager<Double>()
        #expect(averager == fresh)
        #expect(averager.timesAveraged == 0)
    }
    
    
    @Test("Averaging works correctly after `clear()`")
    func averagingAfterClear() {
        var averager = SummingAverager<Double>()
        averager.average([100, 200])
        averager.clear()
        averager.average([3, 9])
        // (3 + 9) / 2 = 6
        #expect(averager.currentAverage.isApproximately(6))
        #expect(averager.timesAveraged == 2)
    }
    
    
    // MARK: Single-value averaging
    
    @Test("Single-value average increments sum and count correctly")
    func singleValue() {
        var averager = SummingAverager<Double>()
        averager.average(7)
        #expect(averager.currentSum     == 7)
        #expect(averager.timesAveraged  == 1)
        #expect(averager.currentAverage.isApproximately(7))
    }
    
    
    // MARK: Array averaging
    
    @Test("Array averaging matches element-wise averaging")
    func arrayMatchesElementWise() {
        var batch     = SummingAverager<Double>()
        var stepwise  = SummingAverager<Double>()
        
        batch.average([1, 2, 3, 4, 5])
        stepwise.average(1)
        stepwise.average(2)
        stepwise.average(3)
        stepwise.average(4)
        stepwise.average(5)
        
        #expect(batch == stepwise)
    }
    
    
    @Test("Empty array is a no-op")
    func emptyArrayIsNoOp() {
        var averager = SummingAverager<Double>()
        averager.average(7)
        let snapshot = averager
        
        averager.average([Double]())
        #expect(averager == snapshot)
    }
    
    
    // MARK: Variadic averaging
    
    @Test("Variadic `average` produces the correct result")
    func variadicAveraging() {
        var averager = SummingAverager<Double>()
        averager.average(2, 4, 6)
        // (2 + 4 + 6) / 3 = 4
        #expect(averager.currentAverage.isApproximately(4))
        #expect(averager.timesAveraged == 3)
    }
    
    
    // MARK: Chaining
    
    @Test("Chained calls accumulate correctly")
    func chaining() {
        var averager = SummingAverager<Double>()
        averager.average([1, 2])
        averager.average(3)
        // (1 + 2 + 3) / 3 = 2
        #expect(averager.currentAverage.isApproximately(2))
        #expect(averager.timesAveraged == 3)
    }
    
    
    // MARK: Conformances
    
    /// Two averagers with the same sum and count must be equal, regardless of the order values were added.
    @Test("`Equatable`: same sum and count are equal")
    func equatable() {
        var a = SummingAverager<Double>()
        var b = SummingAverager<Double>()
        a.average([1, 2, 3])
        b.average([3, 2, 1])
        #expect(a == b)
    }
    
    
    @Test("`Equatable`: different sums are not equal")
    func notEqual() {
        var a = SummingAverager<Double>()
        var b = SummingAverager<Double>()
        a.average(1)
        b.average(2)
        #expect(a != b)
    }
    
    
    @Test("`Hashable`: equal averagers produce the same hash")
    func hashable() {
        var a = SummingAverager<Double>()
        var b = SummingAverager<Double>()
        a.average(5)
        b.average(5)
        #expect(a.hashValue == b.hashValue)
    }
    
    
    @Test("`Hashable`: `Set` correctly deduplicates equal averagers")
    func hashableInSet() {
        var a = SummingAverager<Double>()
        var b = SummingAverager<Double>()
        a.average(10)
        b.average(10)
        let set: Set<SummingAverager<Double>> = [a, b]
        #expect(set.count == 1)
    }
    
    
    /// `Comparable` orders by `currentAverage`.
    @Test("`Comparable`: lower average is less-than higher average")
    func comparable() {
        var low  = SummingAverager<Double>()
        var high = SummingAverager<Double>()
        low.average(1)
        high.average(100)
        #expect(low < high)
        #expect(!(high < low))
    }
    
    
    @Test("`Codable`: encodes and decodes to an equal value")
    func codable() throws {
        var original = SummingAverager<Double>()
        original.average([1, 2, 3])
        
        let data    = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SummingAverager<Double>.self, from: data)
        
        #expect(original == decoded)
        #expect(decoded.currentAverage.isApproximately(2))
    }
    
    
    // MARK: Edge cases
    
    @Test("Mixed-sign values cancel correctly")
    func mixedSignValues() {
        var averager = SummingAverager<Double>()
        averager.average([-3, -1, 1, 3])
        #expect(averager.currentAverage.isApproximately(0))
    }
    
    
    @Test("Works correctly with `Float` type parameter")
    func floatTypeParameter() {
        var averager = SummingAverager<Float>()
        averager.average([2, 4])
        #expect(averager.currentAverage.isApproximately(3))
    }
}



// MARK: - << Operator

@Suite("`<<` Operator")
struct OperatorTests {
    
    @Test("`<<` is equivalent to `average(_:)` for a single value")
    func operatorEquivalentToAverageCall() {
        var a = SummingAverager<Double>()
        var b = SummingAverager<Double>()
        
        a << 42
        b.average(42)
        
        #expect(a == b)
    }
    
    
    @Test("`<<` accumulates correctly across multiple applications")
    func operatorAccumulates() {
        var averager = SummingAverager<Double>()
        averager << 10
        averager << 20
        averager << 30
        // (10 + 20 + 30) / 3 = 20
        #expect(averager.currentAverage.isApproximately(20))
        #expect(averager.timesAveraged == 3)
    }
    
    
    @Test("`<<` works correctly with `ProactiveAverager`")
    func operatorWithProactiveAverager() {
        var averager = ProactiveAverager<Double>()
        averager << 4
        averager << 8
        // (4 + 8) / 2 = 6
        #expect(averager.currentAverage.isApproximately(6))
    }
}



// MARK: - Cross-Implementation Consistency

/// Verifies that all three averager types agree on the arithmetic mean for identical inputs. The choice of type should be an invisible implementation detail to callers.
@Suite("Cross-Implementation Consistency")
struct CrossImplementationTests {
    
    @Test("All three averagers agree on the mean for a basic input set")
    func agreementOnBasicInputs() {
        let values: [Double] = [1, 2, 3, 7, 11, 42]
        
        var proactive  = ProactiveAverager<Double>()
        var summing    = SummingAverager<Double>()
        var reference  = ReferenceAverager<Double>()
        
        proactive.average(values)
        summing.average(values)
        reference.average(values)
        
        #expect(proactive.currentAverage.isApproximately(reference.currentAverage))
        #expect(summing.currentAverage.isApproximately(reference.currentAverage))
    }
    
    
    @Test("All three averagers converge to the same mean over 100 incremental values")
    func agreementOverLargeIncremental() {
        var proactive  = ProactiveAverager<Double>()
        var summing    = SummingAverager<Double>()
        var reference  = ReferenceAverager<Double>()
        
        for value: Double in stride(from: 1, through: 100, by: 1) {
            proactive.average(value)
            summing.average(value)
            reference.average(value)
        }
        
        // Sum of 1...100 = 5050, mean = 50.5
        #expect(proactive.currentAverage.isApproximately(50.5))
        #expect(summing.currentAverage.isApproximately(50.5))
        #expect(reference.currentAverage.isApproximately(50.5))
    }
    
    
    @Test("All three averagers agree on `timesAveraged`")
    func agreementOnCount() {
        let values: [Double] = [10, 20, 30]
        
        var proactive  = ProactiveAverager<Double>()
        var summing    = SummingAverager<Double>()
        var reference  = ReferenceAverager<Double>()
        
        proactive.average(values)
        summing.average(values)
        reference.average(values)
        
        #expect(proactive.timesAveraged == reference.timesAveraged)
        #expect(summing.timesAveraged   == reference.timesAveraged)
    }
    
    
    @Test("All three averagers agree across mixed call forms")
    func agreementAcrossMixedCallForms() {
        var proactive  = ProactiveAverager<Double>()
        var summing    = SummingAverager<Double>()
        var reference  = ReferenceAverager<Double>()
        
        proactive.average(1)
        summing  .average(1)
        reference.average(1)
        
        proactive.average([2, 3])
        summing  .average([2, 3])
        reference.average([2, 3])
        
        proactive.average(4, 5)
        summing  .average(4, 5)
        reference.average(4, 5)
        
        #expect(proactive.currentAverage.isApproximately(reference.currentAverage))
        #expect(summing.currentAverage.isApproximately(reference.currentAverage))
        #expect(proactive.timesAveraged == reference.timesAveraged)
        #expect(summing.timesAveraged   == reference.timesAveraged)
    }
}
