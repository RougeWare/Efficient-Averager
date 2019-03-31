//
//  Averager.swift
//  Swift array extend performance test
//
//  Created by Ben Leggiero on 3/31/19.
//  Copyright © 2019 Ben Leggiero. All rights reserved.
//

import Foundation



///
/// Averager is made by and copyrighted to Blue Husky Studios, ©2019 BH-0-PD.
/// https://github.com/BlueHuskyStudios/Licenses/blob/master/Licenses/BH-0-PD.txt
///
/// Averages very many numbers while using only 128 bits of memory (one floating-point and one integer), to store the
/// average information. This also allows for a more accurate result than adding all and dividing by the number of
/// inputs. The downside is that you sacrifice speed, but rigorous testing of this speed loss has not yet been performed
///
/// @license BH-0-PD to Blue Husky Studios, ©2019
/// @author Ben Leggiero
/// @since 2019-03-31
/// @version 1.0.0
///
public struct Averager<Number: BinaryFloatingPoint> {
    ///  Holds the current average. If startingNumber is specified, it is used. Else, this is 0 ///
    public private(set) var currentAverage: Number = 0.0
    
    ///
    /// Remembers the number of times we've averaged this, to ensure proportional division. If startingNumber is
    /// specified, this is 1. Else, it is 0.
    ///
    public private(set) var timesAveraged: Int = 0
    
    ///
    /// Creates a new Averager. Of course, the current average and number of times averaged are both set to 0
    ///
    init() {
        currentAverage = 0.0
        timesAveraged = 0
    }
    
    ///
    /// Creates a new Averager. The current average is set to the given number and number of times averaged is set to 1
    ///
    /// @param startingNumber the number to start with.
    ///
    init(startingNumber: Number) {
        currentAverage = startingNumber
        timesAveraged = 1
    }
    
    
    ///
    /// Adds the given numbers to the average. Any number of arguments can be given.
    ///
    /// - Parameter d: one or more numbers to average.
    ///
    /// - Returns: a copy of this, so calls can be chained. For example:
    /// `averager.average(1, 2, 3).average(123, 654)`
    ///
    /// - Author: Ben Leggiero
    /// - Since: 2019-03-31
    /// - Version: 1.0.0
    ///
    @discardableResult
    mutating func average(_ numbers: Number...) -> Averager<Number> {
        return average(numbers)
    }
    
    
    ///
    /// Adds the given numbers to the average. Any number of arguments can be given.
    ///
    /// - Parameter d: one or more numbers to average.
    ///
    /// - Returns: a copy of this, so calls can be chained. For example:
    /// `averager.average(arrayOfNumbers).average(123, 654)`
    ///
    /// - Author: Ben Leggiero
    /// - Since: 2019-03-31
    /// - Version: 1.0.0
    ///
    @discardableResult
    mutating func average(_ numbers: [Number]) -> Averager<Number> {
        numbers.forEach { average($0) }
        return self
    }
    
    
    ///
    /// Adds the given number to the average.
    ///
    /// - Parameter d: one number to average.
    ///
    /// - Returns: a copy of this, so calls can be chained. For example: `averager.average(myNumber).average(123)`
    ///
    /// - Author: Ben Leggiero
    /// - Since: 2019-03-31
    /// - Version: 1.0.0
    ///
    @discardableResult
    mutating func average(_ number: Number) -> Averager<Number> {
        currentAverage = ((currentAverage * Number(timesAveraged)) + number) / Number(timesAveraged + 1)
        timesAveraged += 1
        return self
    }
    
    
    ///
    /// Returns the number of times this has been averaged
    ///
    /// @return the number of times this has been averaged, as an integer
    ///
    /// @author Kyli Rouge
    /// @since 2017-01-08
    /// @version 1.0.0
    ///
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
func << <Number>(lhs: inout Averager<Number>, rhs: Number) {
    lhs.average(rhs)
}
