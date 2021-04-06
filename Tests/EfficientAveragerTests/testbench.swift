import XCTest
import EfficientAverager

final class Testbench: XCTestCase {
    
    func testExample() {
        var a = Averager<Double>(startingNumber: 13)
        XCTAssertEqual(1, a.timesAveraged)
        XCTAssertEqual(13, a.currentAverageOrNil)
        XCTAssertEqual(   13.0 , a.currentAverage)
        a.average(3)
        XCTAssertEqual(    8.0 , a.currentAverage)
        a.average(5, 12, 8, 7.3)
        XCTAssertEqual(   8.05 , a.currentAverage, accuracy: 0.001)
        
        var b = Averager<Double>()
        XCTAssertEqual(b.currentAverage, 0)
        XCTAssertEqual(b.timesAveraged, 0)
        XCTAssertNil(b.currentAverageOrNil)
        XCTAssertEqual(    0.0 , b.currentAverage)
        b.average(13)
        XCTAssertEqual(   13.0 , b.currentAverage)
        b.average(55, 712.197, 18, 99)
        XCTAssertEqual(179.439 , b.currentAverage, accuracy: 0.001)
        
        var c = Averager<Double>()
        XCTAssertEqual(c.currentAverage, 0)
        XCTAssertEqual(c.timesAveraged, 0)
        XCTAssertNil(c.currentAverageOrNil)
        c.average(-2147483648, 2147483647, 2147483647, -2147483648)
        XCTAssertEqual(   -0.5 , c.currentAverage)
        
        XCTAssertEqual(      6 , a.timesAveraged)
        XCTAssertEqual(      5 , b.timesAveraged)
        XCTAssertEqual(      4 , c.timesAveraged)
        
        
        c.clear()
        XCTAssertEqual(c.currentAverage, 0)
        XCTAssertEqual(c.timesAveraged, 0)
        XCTAssertNil(c.currentAverageOrNil)
    }

    static let allTests = [
        ("testExample", testExample),
    ]
}
