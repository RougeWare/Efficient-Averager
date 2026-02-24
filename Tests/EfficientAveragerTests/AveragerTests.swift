//
//  AveragerTests.swift
//  EfficientAverager
//
//  Validates the arithmetic correctness, protocol-synthesised behaviour, and concrete-type invariants of
//  `ProactiveAverager` and `SummingAverager`.
//
//  Test organisation reflects the architectural layering of the library:
//    1. `AveragerProtocol` synthesised defaults — correctness is a protocol concern.
//    2. `ProactiveAverager`-specific invariants — running-average storage strategy.
//    3. `SummingAverager`-specific invariants — deferred-division storage strategy.
//    4. The `<<` infix operator.
//    5. Cross-implementation consistency — both strategies must agree on the mean.
//
//  Created by Ky directing Claude 4.6 Sonnet.
//  In the public domain via The Fair License
//  https://opensource.org/license/fair
//

import Foundation
import Testing

import EfficientAverager



// MARK: - Tolerance

/// The acceptable floating-point deviation for equality comparisons throughout
/// this test suite. Sized to accommodate rounding across both averaging strategies
/// without masking genuine arithmetic divergence.
private let ε: Double = 1e-10



// MARK: - AveragerProtocol Synthesised Behaviour

/// Validates the behaviour synthesised by `AveragerProtocol`'s default
/// implementations — `currentAverageOrNil`, `clear()`, the variadic overload,
/// and the array-from-forEach fallback.
///
/// Because these defaults live on the protocol, correctness is verified once
/// against `SummingAverager` (which does not override them beyond `average(_:Number)`)
/// rather than redundantly across every conformer.
@Suite("AveragerProtocol — Synthesised Defaults")
struct AveragerProtocolSynthesisTests {
    
    // MARK: currentAverageOrNil
    
    /// `currentAverageOrNil` should return `nil` before any value is contributed,
    /// providing a safe query path for callers who cannot distinguish a zero mean
    /// from an uninitialised averager.
    @Test("currentAverageOrNil is nil before any averaging")
    func currentAverageOrNilWhenEmpty() {
        let averager = SummingAverager<Double>()
        #expect(averager.currentAverageOrNil == nil)
    }
    
    /// Once at least one value has been contributed, `currentAverageOrNil` must
    /// surface the current mean.
    @Test("currentAverageOrNil returns the mean after averaging")
    func currentAverageOrNilWhenPopulated() {
        var averager = SummingAverager<Double>()
        averager.average(42.0)
        #expect(averager.currentAverageOrNil == 42.0)
    }
    
    /// `clear()` reinitialises via `self = .init()`, so `timesAveraged` returns
    /// to zero and `currentAverageOrNil` must revert to `nil`.
    @Test("currentAverageOrNil reverts to nil after clear()")
    func currentAverageOrNilAfterClear() {
        var averager = SummingAverager<Double>()
        averager.average(5.0)
        averager.clear()
        #expect(averager.currentAverageOrNil == nil)
    }
    
    // MARK: clear()
    
    /// `clear()` delegates to `self = .init()`, so the post-condition must be
    /// identical to a freshly constructed instance.
    @Test("clear() produces a state equivalent to default init")
    func clearMatchesDefaultInit() {
        var averager = SummingAverager<Double>()
        averager.average([10.0, 20.0, 30.0])
        averager.clear()
        
        let fresh = SummingAverager<Double>()
        #expect(averager == fresh)
        #expect(averager.timesAveraged == 0)
    }
    
    /// Averaging after `clear()` must behave identically to a fresh instance —
    /// no residual state from the previous session should survive.
    @Test("Averager is fully functional after clear()")
    func averagingAfterClear() {
        var averager = SummingAverager<Double>()
        averager.average([100.0, 200.0])
        averager.clear()
        averager.average([3.0, 9.0])
        #expect(abs(averager.currentAverage - 6.0) < ε)
        #expect(averager.timesAveraged == 2)
    }
    
    // MARK: Variadic overload
    
    /// The variadic overload is synthesised to delegate to `average(_ numbers: [Number])`.
    /// Its result must therefore match the array overload for identical input.
    @Test("Variadic average delegates correctly to the array overload")
    func variadicDelegatesToArray() {
        var variadic = SummingAverager<Double>()
        var array    = SummingAverager<Double>()
        
        variadic.average(1.0, 2.0, 3.0, 4.0, 5.0)
        array.average([1.0, 2.0, 3.0, 4.0, 5.0])
        
        #expect(variadic == array)
    }
    
    // MARK: Array overload — forEach fallback
    
    /// When a conformer doesn't override `average(_ numbers: [Number])`, the
    /// synthesis iterates via `forEach` and accumulates by calling the single-value
    /// overload. The result must be arithmetically identical to element-wise submission.
    ///
    /// `SummingAverager` *does* override the array overload for efficiency, so
    /// this test targets it via the variadic path, which always uses the synthesis.
    @Test("Protocol-synthesised array path matches element-wise submission")
    func synthesisedArrayPathMatchesElementWise() {
        var synthesised  = SummingAverager<Double>()   // variadic → synthesis
        var elementWise  = SummingAverager<Double>()
        
        synthesised.average(10.0, 20.0, 30.0)
        for n in [10.0, 20.0, 30.0] { elementWise.average(n) }
        
        #expect(synthesised == elementWise)
    }
    
    // MARK: Empty input
    
    /// An empty variadic call maps to an empty array, which must be a strict no-op.
    /// This exercises the `guard !numbers.isEmpty` in implementations and the
    /// synthesised forEach (which simply doesn't iterate).
    @Test("Empty array submission is a strict no-op")
    func emptyArrayIsNoOp() {
        var averager = SummingAverager<Double>()
        averager.average(7.0)
        let snapshot = averager
        
        averager.average([Double]())
        #expect(averager == snapshot)
    }
}



// MARK: - ProactiveAverager

/// Validates invariants unique to `ProactiveAverager`: its initialisation
/// contract and the correctness of the running-average formula it maintains
/// across both the single-value and array code paths.
///
/// Protocol-synthesised behaviour (`currentAverageOrNil`, `clear()`, variadic)
/// is covered in `AveragerProtocolSynthesisTests` and is not repeated here.
@Suite("ProactiveAverager")
struct ProactiveAveragerTests {
    
    // MARK: Initialisation
    
    /// A default-initialised `ProactiveAverager` must store a zero average and
    /// a zero count — the neutral element for subsequent averaging operations.
    @Test("Default init: zero average, zero count")
    func defaultInit() {
        let averager = ProactiveAverager<Double>()
        #expect(averager.currentAverage == 0)
        #expect(averager.timesAveraged  == 0)
    }
    
    /// `init(startingNumber:)` seeds the stored average with the given value and
    /// sets `timesAveraged` to 1, so the next value is weighted equally against it.
    @Test("startingNumber init: seeds average and count correctly")
    func startingNumberInit() {
        let averager = ProactiveAverager<Double>(startingNumber: 42)
        #expect(averager.currentAverage == 42)
        #expect(averager.timesAveraged  == 1)
    }
    
    // MARK: Running-average correctness
    
    /// The running-average formula `((current × n) + new) / (n + 1)` must
    /// produce the correct mean after a single contribution into a fresh averager.
    @Test("Single value into empty averager yields that value")
    func singleValue() {
        var averager = ProactiveAverager<Double>()
        averager.average(7.0)
        #expect(averager.currentAverage == 7.0)
        #expect(averager.timesAveraged  == 1)
    }
    
    /// Validates the weighting formula across a sequence of distinct values,
    /// confirming the denominator advances correctly at each step.
    @Test("Sequential single values converge to the correct mean")
    func sequentialValues() {
        var averager = ProactiveAverager<Double>()
        
        averager.average(10.0)
        averager.average(20.0)
        #expect(abs(averager.currentAverage - 15.0) < ε)
        #expect(averager.timesAveraged == 2)
        
        averager.average(30.0)
        #expect(abs(averager.currentAverage - 20.0) < ε)
        #expect(averager.timesAveraged == 3)
    }
    
    /// The array overload recomputes `currentAverage` in a single step using
    /// the batch sum. Its result must match element-wise submission.
    @Test("Array overload matches element-wise submission")
    func arrayMatchesElementWise() {
        var batch     = ProactiveAverager<Double>()
        var stepwise  = ProactiveAverager<Double>()
        
        batch.average([1.0, 2.0, 3.0, 4.0, 5.0])
        for n in [1.0, 2.0, 3.0, 4.0, 5.0] { stepwise.average(n) }
        
        #expect(abs(batch.currentAverage - stepwise.currentAverage) < ε)
        #expect(batch.timesAveraged == stepwise.timesAveraged)
    }
    
    // MARK: Chaining
    
    /// The fluent interface must accumulate correctly across mixed call forms.
    @Test("Chained calls produce the correct cumulative mean")
    func chaining() {
        var averager = ProactiveAverager<Double>()
        averager.average(1.0, 2.0, 3.0)
        averager.average([4.0, 5.0])
        averager.average(6.0)
        // (1 + 2 + 3 + 4 + 5 + 6) / 6 = 3.5
        #expect(abs(averager.currentAverage - 3.5) < ε)
        #expect(averager.timesAveraged == 6)
    }
    
    // MARK: Edge cases
    
    /// Negative and mixed-sign inputs exercise the cancellation path of the
    /// running-average formula.
    @Test("Mixed-sign values cancel correctly")
    func mixedSignValues() {
        var averager = ProactiveAverager<Double>()
        averager.average([-5.0, 5.0])
        #expect(abs(averager.currentAverage - 0.0) < ε)
    }
    
    /// Confirms the generic constraint isn't inadvertently `Double`-specific.
    @Test("Works correctly with Float type parameter")
    func floatTypeParameter() {
        var averager = ProactiveAverager<Float>()
        averager.average(1.0, 3.0)
        #expect(abs(averager.currentAverage - 2.0) < Float(1e-6))
    }
}



// MARK: - SummingAverager

/// Validates invariants unique to `SummingAverager`: its initialisation contract,
/// the deferred-division `currentAverage` computation (including the mathematically
/// correct NaN-when-empty behaviour), and its protocol conformances.
///
/// Protocol-synthesised behaviour is covered in `AveragerProtocolSynthesisTests`.
@Suite("SummingAverager")
struct SummingAveragerTests {
    
    // MARK: Initialisation
    
    /// A default-initialised `SummingAverager` must store a zero sum and a zero
    /// count — the identity state from which any averaging sequence can begin.
    @Test("Default init: zero sum, zero count")
    func defaultInit() {
        let averager = SummingAverager<Double>()
        #expect(averager.currentSum     == 0)
        #expect(averager.timesAveraged  == 0)
    }
    
    /// `init(startingNumber:)` seeds `currentSum` with the given value so that
    /// a subsequent query for `currentAverage` returns that value immediately.
    @Test("startingNumber init: seeds sum and count correctly")
    func startingNumberInit() {
        let averager = SummingAverager<Double>(startingNumber: 8)
        #expect(averager.currentSum    == 8)
        #expect(averager.timesAveraged == 1)
        #expect(averager.currentAverage == 8)
    }
    
    // MARK: currentAverage — deferred-division contract
    
    /// Dividing zero contributions produces a mathematically undefined mean.
    /// `SummingAverager` correctly returns NaN rather than an arbitrary sentinel,
    /// consistent with IEEE 754 and the established literature on the arithmetic
    /// mean of the empty set. Callers who need a defined result should prefer
    /// `currentAverageOrNil`.
    @Test("currentAverage is NaN when no values have been averaged")
    func currentAverageIsNaNWhenEmpty() {
        let averager = SummingAverager<Double>()
        #expect(averager.currentAverage.isNaN)
    }
    
    /// Validates the deferred `sum / count` computation across a known sequence.
    @Test("currentAverage reflects the correct mean after averaging")
    func currentAverageBasic() {
        var averager = SummingAverager<Double>()
        averager.average([10.0, 20.0, 30.0])
        // 60 / 3 = 20
        #expect(abs(averager.currentAverage - 20.0) < ε)
    }
    
    // MARK: Single-value path
    
    /// The single-value overload must increment both `currentSum` and `timesAveraged`
    /// atomically, leaving the averager in a consistent state.
    @Test("Single-value average increments sum and count correctly")
    func singleValue() {
        var averager = SummingAverager<Double>()
        averager.average(7.0)
        #expect(averager.currentSum    == 7.0)
        #expect(averager.timesAveraged == 1)
        #expect(averager.currentAverage == 7.0)
    }
    
    // MARK: Array overload — override correctness
    
    /// `SummingAverager` overrides the protocol's `average(_ numbers: [Number])`
    /// default to sum the batch in one pass rather than via `forEach`. This test
    /// confirms the override is arithmetically equivalent to the element-wise path.
    @Test("Array overload override is equivalent to element-wise submission")
    func arrayOverrideMatchesElementWise() {
        var batch     = SummingAverager<Double>()
        var stepwise  = SummingAverager<Double>()
        
        batch.average([1.0, 2.0, 3.0, 4.0, 5.0])
        for n in [1.0, 2.0, 3.0, 4.0, 5.0] { stepwise.average(n) }
        
        #expect(batch == stepwise)
    }
    
    // MARK: Protocol conformances
    
    /// Two averagers with identical sums and counts must compare equal, regardless
    /// of insertion order — commutativity of addition guarantees this for the sum.
    @Test("Equatable: same sum and count are equal")
    func equatable() {
        var a = SummingAverager<Double>()
        var b = SummingAverager<Double>()
        a.average([1.0, 2.0, 3.0])
        b.average([3.0, 2.0, 1.0])
        #expect(a == b)
    }
    
    /// Averagers with differing sums must not compare equal.
    @Test("Equatable: different sums are not equal")
    func notEqual() {
        var a = SummingAverager<Double>()
        var b = SummingAverager<Double>()
        a.average(1.0)
        b.average(2.0)
        #expect(a != b)
    }
    
    /// Equal values must hash identically — the fundamental hash/equality contract.
    @Test("Hashable: equal averagers produce the same hash")
    func hashable() {
        var a = SummingAverager<Double>()
        var b = SummingAverager<Double>()
        a.average(5.0)
        b.average(5.0)
        #expect(a.hashValue == b.hashValue)
    }
    
    /// Confirms `Hashable` works correctly in collection contexts by verifying
    /// that a `Set` deduplicates two logically equal instances.
    @Test("Hashable: Set correctly deduplicates equal averagers")
    func hashableInSet() {
        var a = SummingAverager<Double>()
        var b = SummingAverager<Double>()
        a.average(10.0)
        b.average(10.0)
        let set: Set<SummingAverager<Double>> = [a, b]
        #expect(set.count == 1)
    }
    
    /// `Comparable` is ordered by `currentAverage`, so an averager with a lower
    /// mean must compare less-than one with a higher mean.
    @Test("Comparable: lower average is less-than higher average")
    func comparable() {
        var low  = SummingAverager<Double>()
        var high = SummingAverager<Double>()
        low.average(1.0)
        high.average(100.0)
        #expect(low < high)
        #expect(!(high < low))
    }
    
    /// A `Codable` round-trip through JSON must produce a value equal to the
    /// original — the minimal soundness guarantee for persistence and transport.
    @Test("Codable: encodes and decodes to an equal value")
    func codable() throws {
        var original = SummingAverager<Double>()
        original.average([1.0, 2.0, 3.0])
        
        let data    = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SummingAverager<Double>.self, from: data)
        
        #expect(original == decoded)
        #expect(abs(decoded.currentAverage - 2.0) < ε)
    }
    
    // MARK: Edge cases
    
    /// Validates sign handling: positive and negative values of equal magnitude
    /// must cancel to a zero mean.
    @Test("Mixed-sign values cancel correctly")
    func mixedSignValues() {
        var averager = SummingAverager<Double>()
        averager.average([-3.0, -1.0, 1.0, 3.0])
        #expect(abs(averager.currentAverage - 0.0) < ε)
    }
    
    /// Confirms the generic constraint isn't inadvertently `Double`-specific.
    @Test("Works correctly with Float type parameter")
    func floatTypeParameter() {
        var averager = SummingAverager<Float>()
        averager.average([2.0, 4.0])
        #expect(abs(averager.currentAverage - 3.0) < Float(1e-6))
    }
}



// MARK: - << Operator

/// Validates the `<<` infix operator, which provides a concise mutation syntax
/// for averaging a single value into a conforming averager.
@Suite("<< Operator")
struct OperatorTests {
    
    /// A single `<<` application must produce the same state as calling
    /// `average(_ number:)` directly with the same value.
    @Test("<< is equivalent to average(_:Number) for a single value")
    func operatorEquivalentToAverageCall() {
        var operatorAverager = SummingAverager<Double>()
        var methodAverager   = SummingAverager<Double>()
        
        operatorAverager << 42.0
        methodAverager.average(42.0)
        
        #expect(operatorAverager == methodAverager)
    }
    
    /// Multiple sequential `<<` applications must accumulate identically to
    /// multiple `average(_:Number)` calls.
    @Test("<< accumulates correctly across multiple applications")
    func operatorAccumulates() {
        var averager = SummingAverager<Double>()
        averager << 10.0
        averager << 20.0
        averager << 30.0
        // (10 + 20 + 30) / 3 = 20
        #expect(abs(averager.currentAverage - 20.0) < ε)
        #expect(averager.timesAveraged == 3)
    }
    
    /// Confirms the operator works with `ProactiveAverager`, exercising the
    /// generic constraint `Averager: AveragerProtocol`.
    @Test("<< works correctly with ProactiveAverager")
    func operatorWithProactiveAverager() {
        var averager = ProactiveAverager<Double>()
        averager << 4.0
        averager << 8.0
        #expect(abs(averager.currentAverage - 6.0) < ε)
    }
}



// MARK: - Cross-Implementation Consistency

/// Validates that `ProactiveAverager` and `SummingAverager` agree on the
/// arithmetic mean for identical inputs. This is the highest-value suite in
/// the file: it enforces the `AveragerProtocol` contract at the semantic level
/// — that the averaging *strategy* is an implementation detail, not an
/// observable difference.
@Suite("Cross-Implementation Consistency")
struct CrossImplementationTests {
    
    /// Both strategies must produce the same mean for a simple known sequence.
    @Test("Both averagers agree on the mean for a basic input set")
    func agreementOnBasicInputs() {
        let values = [1.0, 2.0, 3.0, 7.0, 11.0, 42.0]
        
        var proactive = ProactiveAverager<Double>()
        var summing   = SummingAverager<Double>()
        
        proactive.average(values)
        summing.average(values)
        
        #expect(abs(proactive.currentAverage - summing.currentAverage) < ε)
    }
    
    /// Incrementally contributed values exercise both strategies over a larger
    /// range, confirming convergence on the expected mean of 1…100.
    @Test("Both averagers converge to the same mean over 100 incremental values")
    func agreementOverLargeIncremental() {
        var proactive = ProactiveAverager<Double>()
        var summing   = SummingAverager<Double>()
        
        for value in stride(from: 1.0, through: 100.0, by: 1.0) {
            proactive.average(value)
            summing.average(value)
        }
        
        // Sum of 1…100 = 5050, mean = 50.5
        #expect(abs(proactive.currentAverage - 50.5) < ε)
        #expect(abs(summing.currentAverage   - 50.5) < ε)
        #expect(abs(proactive.currentAverage - summing.currentAverage) < ε)
    }
    
    /// Both strategies must count contributions identically.
    @Test("Both averagers agree on timesAveraged")
    func agreementOnCount() {
        let values = [10.0, 20.0, 30.0]
        
        var proactive = ProactiveAverager<Double>()
        var summing   = SummingAverager<Double>()
        
        proactive.average(values)
        summing.average(values)
        
        #expect(proactive.timesAveraged == summing.timesAveraged)
    }
    
    /// Mixed-call-form submission — single values, arrays, and variadic — must
    /// produce the same mean across both strategies.
    @Test("Both averagers agree across mixed call forms")
    func agreementAcrossMixedCallForms() {
        var proactive = ProactiveAverager<Double>()
        var summing   = SummingAverager<Double>()
        
        proactive.average(1.0)
        summing  .average(1.0)
        proactive.average([2.0, 3.0])
        summing  .average([2.0, 3.0])
        proactive.average(4.0, 5.0)
        summing  .average(4.0, 5.0)
        
        #expect(abs(proactive.currentAverage - summing.currentAverage) < ε)
        #expect(proactive.timesAveraged == summing.timesAveraged)
    }
}
