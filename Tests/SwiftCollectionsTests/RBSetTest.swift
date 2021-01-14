import XCTest
@testable import SwiftCollections

final class RBSetTests: XCTestCase {

    func testBase() throws {
        let bt = RBSet<Int>()
        XCTAssertEqual(bt.count, 0)
        let result = bt.insert(1)
        XCTAssertTrue(result.inserted)
        XCTAssertEqual(result.memberAfterInsert, 1)
        XCTAssertEqual(bt.count, 1)
        var values = [3, 5, 8, 9, 7, 6]
        let bt1 = try RBSet<Int>(values)
        var count = 0
        values.sort()
        for elements in zip(bt1, values) {
            XCTAssertEqual(elements.0, elements.1, "\(elements)")
            count += 1
        }
        XCTAssertEqual(count, values.count)
        XCTAssertEqual(bt1.count, values.count)
        XCTAssertEqual(bt1.debugDescription, "RBSet([3, 5, 6, 7, 8, 9])")
    }

    func testSorted() throws {
        var values = Array(0..<100)
        let bt = RBSet<Int>()
        for value in values {
            let result = bt.insert(value)
            XCTAssertTrue(result.inserted)
            XCTAssertEqual(result.memberAfterInsert, value)
            XCTAssertTrue(bt.contains(value))
        }
        var count = 0
        values.sort()
        _ = bt.check()
        for elements in zip(bt, values) {
            XCTAssertEqual(elements.0, elements.1, "\(elements)")
            count += 1
        }
        XCTAssertEqual(count, values.count)
        XCTAssertEqual(bt.count, values.count)
        _ = bt.check()

        for value in values {
            let result = bt.remove(value)
            XCTAssertEqual(result, value)
            XCTAssertNil(bt.remove(value), "\(value)")
            _ = bt.check()
            var inserted = bt.insert(result!)
            XCTAssertTrue(inserted.inserted)
            XCTAssertEqual(inserted.memberAfterInsert, value)
            XCTAssertTrue(bt.contains(value))
            XCTAssertEqual(bt.count, values.count)
            inserted = bt.insert(result!)
            XCTAssertFalse(inserted.inserted)
            XCTAssertEqual(inserted.memberAfterInsert, value)
            XCTAssertEqual(bt.count, values.count)
            _ = bt.check()
            count = 0
            for elements in zip(bt, values) {
                XCTAssertEqual(elements.0, elements.1, "\(elements)")
                count += 1
            }
            XCTAssertEqual(count, values.count)
            XCTAssertEqual(bt.count, values.count)
        }
        count = 0
        for elements in zip(bt, values) {
            XCTAssertEqual(elements.0, elements.1, "\(elements)")
            count += 1
        }
        XCTAssertEqual(count, values.count)
        XCTAssertEqual(bt.count, values.count)

        for value in values {
            let result = bt.remove(value)
            XCTAssertEqual(result!, value)
        }
        XCTAssertEqual(bt.count, 0)
        XCTAssertNil(bt.first)
        XCTAssertNil(bt.last)
    }

    func testReverse() throws {
        var values = Array(0..<100)
        let bt = RBSet<Int>()
        for value in values.reversed() {
            let result = bt.insert(value)
            XCTAssertTrue(result.inserted)
            XCTAssertEqual(result.memberAfterInsert, value)
            XCTAssertTrue(bt.contains(value))
        }
        var count = 0
        values.sort()
        for elements in zip(bt, values) {
            XCTAssertEqual(elements.0, elements.1, "\(elements)")
            count += 1
        }
        XCTAssertEqual(count, values.count)
        XCTAssertEqual(bt.count, values.count)
    }

    func testLong() throws {
        var values = [27, 12, 13, 15, 85, 47, 98, 51, 54, 91, 87, 25, 39,
                      58, 6, 21, 48, 96, 80, 49, 78, 84, 8, 67, 74, 22, 53,
                      38, 14, 86, 35, 61, 46, 40, 60, 50, 89, 42, 30, 16,
                      71, 65, 77, 95, 73, 2, 33, 70, 34, 97, 20, 63, 88, 64,
                      10, 26, 66, 0, 94, 41, 24, 37, 75, 7, 9, 92, 72, 62,
                      28, 69, 43, 19, 56, 52, 45, 93, 1, 32, 18, 17, 55, 59,
                      29, 36, 90, 23, 76, 99, 31, 57, 79, 82, 11, 3, 5, 83,
                      44, 81, 4, 68]
        let bt = RBSet<Int>()
        for value in values {
            let result = bt.insert(value)
            XCTAssertTrue(result.inserted)
            XCTAssertEqual(result.memberAfterInsert, value)
            XCTAssertTrue(bt.contains(value), "\(value)")
        }
        var count = 0
        values.sort()
        for elements in zip(bt, values) {
            XCTAssertEqual(elements.0, elements.1, "\(elements)")
            count += 1
        }
        XCTAssertEqual(count, values.count)
        XCTAssertEqual(bt.count, values.count)
    }

    func testDouble() throws {
        var values = [27, 12, 13, 15, 85, 47, 98, 51, 54, 91, 87, 25, 39,
                      58, 6, 21, 48, 96, 80, 49, 78, 84, 8, 67, 74, 22, 53,
                      38, 14, 86, 35, 61, 46, 40, 60, 50, 89, 42, 30, 16,
                      71, 65, 77, 95, 73, 2, 33, 70, 34, 97, 20, 63, 88, 64,
                      10, 26, 66, 0, 94, 41, 24, 37, 75, 7, 9, 92, 72, 62,
                      28, 69, 43, 19, 56, 52, 45, 93, 1, 32, 18, 17, 55, 59,
                      29, 36, 90, 23, 76, 99, 31, 57, 79, 82, 11, 3, 5, 83,
                      44, 81, 4, 68]
        let bt = RBSet<Int>()
        for value in values {
            var result = bt.insert(value)
            XCTAssertTrue(result.inserted)
            XCTAssertEqual(result.memberAfterInsert, value)
            XCTAssertTrue(bt.contains(value), "\(value)")
            result = bt.insert(value)
            XCTAssertFalse(result.inserted, "\(value)")
            XCTAssertEqual(result.memberAfterInsert, value)
        }
        var count = 0
        values.sort()
        for elements in zip(bt, values) {
            XCTAssertEqual(elements.0, elements.1, "\(elements)")
            count += 1
        }
        XCTAssertEqual(count, values.count)
        XCTAssertEqual(bt.count, values.count)
    }

    func testSubscript() throws {
        var values = [27, 12, 13, 15, 85, 47, 98, 51, 54, 91, 87, 25, 39,
                      58, 6, 21, 48, 96, 80, 49, 78, 84, 8, 67, 74, 22, 53,
                      38, 14, 86, 35, 61, 46, 40, 60, 50, 89, 42, 30, 16,
                      71, 65, 77, 95, 73, 2, 33, 70, 34, 97, 20, 63, 88, 64,
                      10, 26, 66, 0, 94, 41, 24, 37, 75, 7, 9, 92, 72, 62,
                      28, 69, 43, 19, 56, 52, 45, 93, 1, 32, 18, 17, 55, 59,
                      29, 36, 90, 23, 76, 99, 31, 57, 79, 82, 11, 3, 5, 83,
                      44, 81, 4, 68]
        let bt = RBSet<Int>()
        for value in values {
            var result = bt.insert(value)
            XCTAssertTrue(result.inserted)
            XCTAssertEqual(result.memberAfterInsert, value)
            XCTAssertTrue(bt.contains(value), "\(value)")
            result = bt.insert(value)
            XCTAssertFalse(result.inserted, "\(value)")
            XCTAssertEqual(result.memberAfterInsert, value)
        }
        var count = 0
        values.sort()
        for idx in values.indices {
            XCTAssertEqual(bt.get(idx: idx), values[idx], "\(idx)")
            count += 1
        }
        XCTAssertEqual(count, values.count)
        XCTAssertEqual(bt.count, values.count)
    }

    func testAddRemove() throws {
        for idx in 1...16 {
            let values = Array(1..<128*idx)
            let check = values.shuffled()
            let rbd = RBSet<Int>()
            for value in check {
                _ = rbd.insert(value)
            }
            // Checks the iterator
            for elements in zip(values, rbd) {
                XCTAssertEqual(elements.0, elements.1)
            }
            // Checks the index
            XCTAssertTrue(rbd.map({$0 > 0}).reduce(true, {$0 && $1}))
            let remove = values.shuffled()
            for value in remove {
                let result = rbd.remove(value)
                XCTAssertNotNil(result)
                XCTAssertEqual(result!, value)
            }
            rbd.removeAll()
        }
    }
}
