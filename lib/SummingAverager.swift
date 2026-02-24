//
//  SummingAverager.swift
//  Efficient Averager
//
//  Created by Ky on 2026-02-24.
//  In the public domain via The Fair License
//  https://opensource.org/license/fair
//

import Foundation



/// Computes the arithmetic mean of arbitrarily many numbers
public typealias Averager = SummingAverager



/// Computes the arithmetic mean of arbitrarily many numbers while using only two fields of memory (one floating-point fields and one integer), to store the average over time. This also allows for encapsulated, resumable averaging operations.
/// The downside is the same as summing an array of numbers: If the sum gets too big, it may become unusably inaccurate or overflow.
///
/// `SummingAverager` is made by Ky, in the public domain.
/// https://opensource.org/license/fair
public struct SummingAverager<Number: BinaryFloatingPoint>: AveragerProtocol {
    
    /// The current sum of all averaged value
    public private(set) var currentSum: Number = 0
    
    public private(set) var timesAveraged: UInt = 0
    
    /// Creates a new `SummingAverager`. Of course, the current average and number of times averaged are both set to `0`
    public init() {
        currentSum = 0
        timesAveraged = 0
    }
    
    
    /// Creates a new `SummingAverager`. The current average is set to the given number and number of times averaged is set to `1`
    ///
    /// - Parameter startingNumber: the number to start with
    public init(startingNumber: Number) {
        currentSum = startingNumber
        timesAveraged = 1
    }
}



// MARK: - Functionality

public extension SummingAverager {
    
    var currentAverage: Number {
        currentSum / .init(timesAveraged)
    }
    
    
    @discardableResult
    mutating func average(_ number: Number) -> SummingAverager<Number> {
        currentSum += number
        timesAveraged += 1
        return self
    }
}



// MARK: - Conformances

extension SummingAverager: Codable where Number: Codable {}
extension SummingAverager: Equatable {}
extension SummingAverager: Hashable {}
extension SummingAverager: Sendable where Number: Sendable {}



extension SummingAverager: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.currentAverage < rhs.currentAverage
    }
}
