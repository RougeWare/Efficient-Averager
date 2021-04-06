//
//  Averager.swift
//  Efficient Averager
//
//  Created by Ben Leggiero on 2019-03-31.
//  BH-0-PD
// https://github.com/BlueHuskyStudios/Licenses/blob/master/Licenses/BH-0-PD.txt
//

import Foundation



/// Averager is made by Blue Husky Studios, under the BH-0-PD license.
/// https://github.com/BlueHuskyStudios/Licenses/blob/master/Licenses/BH-0-PD.txt
///
/// Averages very many numbers while using only 128 bits of memory (one floating-point and one integer), to store the
/// average information. This also allows for a more accurate result than adding all and dividing by the number of
/// inputs. The downside is that you sacrifice speed, but rigorous testing of this speed loss has not yet been performed
///
/// @license BH-0-PD to Blue Husky Studios, ©2019
/// @author Ben Leggiero
/// @since 2019-03-31
/// @version 1.1.0
public struct Averager<Number: BinaryFloatingPoint> {
    
    ///  Holds the current average value
    public private(set) var currentAverage: Number = 0
    
    /// Remembers the number of times we've averaged this, to ensure proportional division.
    public private(set) var timesAveraged: UInt = 0
    
    /// Creates a new `Averager`. Of course, the current average and number of times averaged are both set to `0`
    init() {
        currentAverage = 0
        timesAveraged = 0
    }
    
    
    /// Creates a new `Averager`. The current average is set to the given number and number of times averaged is set to `1`
    ///
    /// - Parameter startingNumber: the number to start with
    init(startingNumber: Number) {
        currentAverage = startingNumber
        timesAveraged = 1
    }
}



// MARK: - Functionality

public extension Averager {
    
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
    /// - Author: Ben Leggiero
    /// - Since: 2019-03-31
    /// - Version: 1.0.0
    ///
    @discardableResult
    mutating func average(_ numbers: Number...) -> Averager<Number> {
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
    /// - Author: Ben Leggiero
    /// - Since: 2019-03-31
    /// - Version: 1.0.0
    @discardableResult
    mutating func average(_ numbers: [Number]) -> Averager<Number> {
        numbers.forEach { average($0) }
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
    /// - Author: Ben Leggiero
    /// - Since: 2019-03-31
    /// - Version: 1.0.0
    @discardableResult
    mutating func average(_ number: Number) -> Averager<Number> {
        currentAverage = ((currentAverage * Number(timesAveraged)) + number) / Number(timesAveraged + 1)
        timesAveraged += 1
        return self
    }
    
    
    /// Resets this averager to a state before any number has been averaged
    mutating func clear() -> Averager<Number> {
        currentAverage = 0.0
        timesAveraged = 0
        return self
    }
}



/// Mutates the averager on the left-hand side so that the number on the right-hand side is averaged into it
///
/// - Parameters:
///   - lhs: The averager to mutate
///   - rhs: The number to add to the average
public func << <Number>(lhs: inout Averager<Number>, rhs: Number) {
    lhs.average(rhs)
}
