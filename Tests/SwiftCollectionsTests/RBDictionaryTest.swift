import XCTest
@testable import SwiftCollections

final class RBDictionaryTests: XCTestCase {

    func testBase() throws {
        let bt = RBDictionary<Int, Int>()
        XCTAssertEqual(bt.count, 0)
        let result = bt.insert((1, 1))
        XCTAssertTrue(result.inserted)
        XCTAssertEqual(result.memberAfterInsert.key, 1)
        XCTAssertEqual(bt.count, 1)
        let values = [3: 3, 5: 5, 8: 8, 9: 9, 7: 7, 6: 6]
        let bt1 = RBDictionary<Int, Int>(values)
        let dict = Dictionary<Int, Int>(uniqueKeysWithValues: bt1.map{($0.key, $0.value)})
        XCTAssertEqual(dict, values)
        var count = 0
        var keys = Array(values.keys)
        keys.sort()
        for elements in zip(bt1, keys) {
            XCTAssertEqual(elements.0.key, elements.1, "\(elements)")
            XCTAssertEqual(elements.0.value, elements.1, "\(elements)")
            count += 1
        }
        XCTAssertEqual(count, values.count)
        XCTAssertEqual(bt1.count, values.count)
        XCTAssertEqual(bt1.debugDescription, "RBDictionary([3: 3, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9])")
        let bt2: RBDictionary<Int, Int> = [3: 3, 5: 5, 8: 8, 9: 9, 7: 7, 6: 6]
        XCTAssertEqual(bt1, bt2)
        let bt3 = RBDictionary<Int, Int>([3: 3, 5: 5, 8: 8, 9: 9, 7: 7, 6: 6])
        XCTAssertEqual(bt1, bt3)
    }

    func testSorted() throws {
        var values = Array(0..<100)
        let bt = RBDictionary<Int, Int>()
        for value in values {
            let result = bt.insert((value, value))
            XCTAssertTrue(result.inserted)
            XCTAssertEqual(result.memberAfterInsert.key, value)
            XCTAssertEqual(result.memberAfterInsert.value, value)
            XCTAssertTrue(bt.contains(value))
        }
        var count = 0
        values.sort()
        _ = bt.check()
        for elements in zip(bt, values) {
            XCTAssertEqual(elements.0.key, elements.1, "\(elements)")
            XCTAssertEqual(elements.0.value, elements.1, "\(elements)")
            count += 1
        }
        XCTAssertEqual(count, values.count)
        XCTAssertEqual(bt.count, values.count)
        _ = bt.check()

        for value in values {
            var result = bt.remove(value)
            XCTAssertEqual(result!.key, value)
            XCTAssertNil(bt.remove(value), "\(value)")
            _ = bt.check()
            var inserted = bt.insert(result!)
            XCTAssertTrue(inserted.inserted)
            XCTAssertEqual(inserted.memberAfterInsert.key, value)
            XCTAssertTrue(bt.contains(value))
            XCTAssertEqual(bt.count, values.count)
            inserted = bt.insert(result!)
            XCTAssertFalse(inserted.inserted)
            XCTAssertEqual(inserted.memberAfterInsert.key, value)
            XCTAssertEqual(bt.count, values.count)
            _ = bt.check()
            result = bt.remove(value)
            XCTAssertEqual(result!.key, value)
            XCTAssertNil(bt.remove(value), "\(value)")
            bt[value] = value
            count = 0
            for elements in zip(bt, values) {
                XCTAssertEqual(elements.0.key, elements.1, "\(elements)")
                count += 1
            }
            XCTAssertEqual(count, values.count)
            XCTAssertEqual(bt.count, values.count)
        }
        count = 0
        for elements in zip(bt, values) {
            XCTAssertEqual(elements.0.key, elements.1, "\(elements)")
            count += 1
        }
        XCTAssertEqual(count, values.count)
        XCTAssertEqual(bt.count, values.count)

        for value in values {
            let result = bt.remove(value)
            XCTAssertEqual(result!.key, value)
        }
        XCTAssertEqual(bt.count, 0)
        XCTAssertNil(bt.first)
        XCTAssertNil(bt.last)
    }

    func testReverse() throws {
        var values = Array(0..<100)
        let bt = RBDictionary<Int, Int>()
        for value in values.reversed() {
            let result = bt.insert((value, value))
            XCTAssertTrue(result.inserted)
            XCTAssertEqual(result.memberAfterInsert.key, value)
            XCTAssertTrue(bt.contains(value))
        }
        var count = 0
        values.sort()
        for elements in zip(bt, values) {
            XCTAssertEqual(elements.0.key, elements.1, "\(elements)")
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
        let bt = RBDictionary<Int, Int>()
        for value in values {
            bt[value] = value
            let result = bt.insert((value, value))
            XCTAssertFalse(result.inserted)
            XCTAssertEqual(result.memberAfterInsert.key, value)
            XCTAssertEqual(result.memberAfterInsert.value, value)
            XCTAssertTrue(bt.contains(value), "\(value)")
        }
        var count = 0
        values.sort()
        for elements in zip(bt, values) {
            XCTAssertEqual(elements.0.key, elements.1, "\(elements)")
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
        let bt = RBDictionary<Int, Int>()
        for value in values {
            var result = bt.insert((value, value))
            XCTAssertTrue(result.inserted)
            XCTAssertEqual(result.memberAfterInsert.key, value)
            XCTAssertTrue(bt.contains(value), "\(value)")
            result = bt.insert((value, value))
            XCTAssertFalse(result.inserted, "\(value)")
            XCTAssertEqual(result.memberAfterInsert.key, value)
        }
        var count = 0
        values.sort()
        for elements in zip(bt, values) {
            XCTAssertEqual(elements.0.key, elements.1, "\(elements)")
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
        let bt = RBDictionary<Int, Int>()
        for value in values {
            var result = bt.insert((value, value))
            XCTAssertTrue(result.inserted)
            XCTAssertEqual(result.memberAfterInsert.key, value)
            XCTAssertTrue(bt.contains(value), "\(value)")
            result = bt.insert((value, value))
            XCTAssertFalse(result.inserted, "\(value)")
            XCTAssertEqual(result.memberAfterInsert.key, value)
        }
        var count = 0
        values.sort()
        for idx in values.indices {
            XCTAssertEqual(bt[idx], values[idx], "\(idx)")
            count += 1
        }
        XCTAssertEqual(count, values.count)
        XCTAssertEqual(bt.count, values.count)
    }

    func testIndex() throws {
        var values = Array(0..<100)
        values.shuffle()
        let rbd = RBDictionary<Int, Double>()
        try rbd.insert(values.map{($0, Double.random(in: 0.1..<1.0))})
        XCTAssertEqual(rbd.count, values.count)
        var result = rbd.map({Double($0.key)*$0.value}).reduce(0.0, {$0 + $1})
        XCTAssertTrue(result > 0.0)
        XCTAssertEqual(rbd.count, values.count)
        var idx = rbd.startIndex
        var count = 0
        var accum = 0.0
        while idx != rbd.endIndex {
            XCTAssertEqual(rbd[idx].key, count)
            XCTAssertEqual(rbd.count, values.count)
            accum += Double(rbd[idx].key) * rbd[idx].value
            count += 1
            idx = rbd.index(after: idx)
        }
        XCTAssertEqual(rbd.count, values.count)
        XCTAssertEqual(accum, result)
        result = rbd.map({Double($0.key)*$0.value}).reduce(0.0, {$0 + $1})
        XCTAssertTrue(result > 0.0)
    }

    func testAddRemove() throws {
        for idx in 1...16 {
            let values = Array(1..<128*idx)
            let check = values.shuffled()
            let rbd = RBDictionary<Int, Int>()
            for value in check {
                rbd[value] = value
            }
            // Checks the iterator
            for elements in zip(values, rbd) {
                XCTAssertEqual(elements.0, elements.1.key)
                XCTAssertEqual(elements.0, elements.1.value)
            }
            // Checks the index
            XCTAssertTrue(rbd.map({$0.key == $0.value}).reduce(true, {$0 && $1}))
            let remove = values.shuffled()
            for value in remove {
                let result = rbd.remove(value)
                XCTAssertNotNil(result)
                XCTAssertEqual(result!.key, value)
                XCTAssertEqual(result!.value, value)
            }
            rbd.removeAll()
        }
    }
}
