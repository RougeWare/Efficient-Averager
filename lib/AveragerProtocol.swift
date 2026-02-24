//
//  AveragerProtocol.swift
//  EfficientAverager
//
//  Created by Ky on 2026-02-24.
//

import Foundation



/// Finds the arithmetic mean (the average) of arbitrarily many numbers
public protocol AveragerProtocol {
    associatedtype Number: BinaryFloatingPoint
    
    
    
    /// Remembers the number of times we've averaged this, to ensure proportional division.
    var timesAveraged: UInt { get }
    
    /// The current mean of all averaged numbers
    var currentAverage: Number { get }
    
    /// If any numbers have been averaged, this returns the current average. Else, if no numbers have yet been averaged, this returns `nil`
    var currentAverageOrNil: Number? { get }
    
    
    /// Creates a new averager. Of course, the current average and number of times averaged are both set to `0`
    init()
    
    /// Creates a new averager. The current average is set to the given number and number of times averaged is set to `1`
    ///
    /// - Parameter startingNumber: the number to start with
    init(startingNumber: Number)
    
    
    /// Adds the given numbers to the average. Any number of arguments can be given.
    ///
    /// This function returns this object, so calls can be chained. For example:
    /// ```
    /// averager.average(1, 2, 3).average(arrayOfNumbers)
    /// ```
    ///
    /// - Parameter numbers: One or more numbers to average
    ///
    /// - Returns: This averager
    @discardableResult
    mutating func average(_ numbers: Number...) -> Self
    
    
    /// Adds the given numbers to the average. Any number of arguments can be given.
    ///
    /// This function returns this object, so calls can be chained. For example:
    /// ```
    /// averager.average(1, 2, 3).average(arrayOfNumbers)
    /// ```
    ///
    /// - Parameter numbers: One or more numbers to average
    ///
    /// - Returns: This averager
    @discardableResult
    mutating func average(_ numbers: [Number]) -> Self
    
    
    /// Adds the given number to the average.
    ///
    /// This function returns this object, so calls can be chained. For example:
    /// ```
    /// averager.average(1, 2, 3).average(arrayOfNumbers).average(123)
    /// ```
    ///
    /// - Parameter number: One number to average
    ///
    /// - Returns: This averager
    @discardableResult
    mutating func average(_ number: Number) -> Self
    
    
    /// Resets this averager to a state before any number has been averaged
    @discardableResult
    mutating func clear() -> Self
}



// MARK: - Synthesis

public extension AveragerProtocol {
    
    var currentAverageOrNil: Number? {
        timesAveraged > 0
            ? currentAverage
            : nil
    }
    
    
    @discardableResult
    mutating func average(_ numbers: Number...) -> Self {
        return average(numbers)
    }
    
    
    @discardableResult
    mutating func average(_ numbers: [Number]) -> Self {
        numbers.forEach { average($0) }
        return self
    }
    
    
    @available(*, deprecated, message: "Please provide numbers to average.")
    @inline(__always)
    @discardableResult
    mutating func average() -> Self {
        return self
    }
    
    
    @discardableResult
    mutating func clear() -> Self {
        self = .init()
        return self
    }
}


/// Mutates the averager on the left-hand side so that the number on the right-hand side is averaged into it
///
/// - Parameters:
///   - lhs: The averager to mutate
///   - rhs: The number to add to the average
public func << <Averager, Number>(lhs: inout Averager, rhs: Number)
where Averager: AveragerProtocol,
      Averager.Number == Number,
      Number: BinaryFloatingPoint
{
    lhs.average(rhs)
}
