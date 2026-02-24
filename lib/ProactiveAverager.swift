//
//  ProactiveAverager.swift
//  Efficient Averager
//
//  Created by Ky on 2019-03-31.
//  In the public domain via The Fair License
//  https://opensource.org/license/fair
//

import Foundation



/// Computes the arithmetic mean of arbitrarily many numbers while using only two fields of memory (one floating-point field and one integer), to store the average over time. This also allows for encapsulated, resumable averaging operations.
/// The downside is that if you sum too-many or too-large numbers, it may become unusably inaccurate or overflow.
///
/// Technically, this differs from ``SummingAverager`` because this stores the current average and the number of times averaged, and uses those to calculate & store the average when you average another number.
///
/// `ProactiveAverager` is made by Ky, in the public domain.
/// https://opensource.org/license/fair
public struct ProactiveAverager<Number: BinaryFloatingPoint>: AveragerProtocol {
    
    ///  Holds the current average value
    public private(set) var currentAverage: Number = 0
    
    /// Remembers the number of times we've averaged this, to ensure proportional division.
    public private(set) var timesAveraged: UInt = 0
    
    
    /// Creates a new `ProactiveAverager`. Of course, the current average and number of times averaged are both set to `0`
    public init() {
        currentAverage = 0
        timesAveraged = 0
    }
    
    
    /// Creates a new `ProactiveAverager`. The current average is set to the given number and number of times averaged is set to `1`
    ///
    /// - Parameter startingNumber: the number to start with
    public init(startingNumber: Number) {
        currentAverage = startingNumber
        timesAveraged = 1
    }
}



// MARK: - Functionality

public extension ProactiveAverager {
    
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
    ///
    /// - Author: Ky
    /// - Since: 2019-03-31
    /// - Version: 1.0.0
    @discardableResult
    mutating func average(_ numbers: Number...) -> ProactiveAverager<Number> {
        return average(numbers)
    }
    
    
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
    ///
    /// - Author: Ky
    /// - Since: 2019-03-31
    /// - Version: 2.0.0
    @discardableResult
    mutating func average(_ numbers: [Number]) -> ProactiveAverager<Number> {
        guard !numbers.isEmpty else { return self }
        let newTimesAveraged = timesAveraged + .init(numbers.count)
        let sumOfNewNumbers = numbers.reduce(into: 0, +=)
        
        currentAverage = ((currentAverage * Number(timesAveraged)) + sumOfNewNumbers) / Number(newTimesAveraged)
        timesAveraged = newTimesAveraged
        return self
    }
    
    
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
    ///
    /// - Author: Ky
    /// - Since: 2019-03-31
    /// - Version: 1.0.0
    @discardableResult
    mutating func average(_ number: Number) -> ProactiveAverager<Number> {
        currentAverage = ((currentAverage * Number(timesAveraged)) + number) / Number(timesAveraged + 1)
        timesAveraged += 1
        return self
    }
    
    
    /// Resets this averager to a state before any number has been averaged
    @discardableResult
    mutating func clear() -> ProactiveAverager<Number> {
        currentAverage = 0.0
        timesAveraged = 0
        return self
    }
}



public extension ProactiveAverager {
    
    /// If any numbers have been averaged, this returns the current average. Else, if no numbers have yet been averaged, this returns `nil`
    var currentAverageOrNil: Number? {
        timesAveraged > 0
            ? currentAverage
            : nil
    }
}
