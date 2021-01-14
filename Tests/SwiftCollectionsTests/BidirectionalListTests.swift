import XCTest
@testable import SwiftCollections

final class BidirectionalListTests: XCTestCase {
    func testIndex() {
        let values = [0, 1, 2, 3, 4]
        let bl = BidirectionalList<Int>(values)
        let startIdx = bl.startIndex
        XCTAssertEqual(bl.first, values[0])
        let oneIdx = bl.index(after: startIdx)
        XCTAssertEqual(bl[oneIdx], values[1])
        XCTAssertEqual(bl.first, 0)
        let endIdx = bl.endIndex
        let lastValue = bl.last
        let valuesLast = values.last
        XCTAssertEqual(lastValue, valuesLast)
        let lastIdx = bl.index(before: endIdx)
        XCTAssertEqual(bl[lastIdx], bl.last)
        XCTAssertEqual(bl.last, 4)
        XCTAssertEqual(bl.endIndex, bl.index(after: lastIdx))
    }

    func testInsert() {
        let bl = BidirectionalList<Int>()
        _ = bl.append(1)
        XCTAssertEqual(bl.count, 1)
        XCTAssertEqual(bl.first, 1)
        _ = bl.insert(4, at: bl.startIndex)
        XCTAssertEqual(bl.count, 2)
        XCTAssertEqual(bl.first, 4)
        let idx = bl.index(before: bl.endIndex)
        _ = bl.insert(8, at: idx)
        XCTAssertEqual(bl.count, 3)
        XCTAssertEqual(bl[bl.index(before: bl.index(before: bl.endIndex))], 8)
    }

    func testGeneral() {
        let values = [0, 1, 2, 3, 4]
        let bl0 = BidirectionalList<Int>(values)
        let bl1 = BidirectionalList<Int>()
        XCTAssertEqual(bl1.count, 0)
        bl1.append(contentsOf: values)
        XCTAssertEqual(bl1.count, 5)
        for (lhs, rhs) in zip(bl0, values) {
            XCTAssertEqual(lhs, rhs);
        }
        for (lhs, rhs) in zip(bl1, values) {
            XCTAssertEqual(lhs, rhs);
        }

        let bl2 = bl1.filter { $0 != 2 }
        bl1.remove { $0 == 2 }
        let n = bl2.count
        XCTAssertEqual(bl1.count, n)
        for (lhs, rhs) in zip(bl1, bl2) {
            XCTAssertEqual(lhs, rhs)
        }

        let bl3 = bl2.filter { $0 != 0 }
        bl1.remove { $0 == 0 }
        XCTAssertEqual(bl3.count, bl1.count)
        for (lhs, rhs) in zip(bl3, bl1) {
            XCTAssertEqual(lhs, rhs)
        }

        let bl4 = bl1
        XCTAssertEqual(bl4.count, bl1.count);
        for (lhs, rhs) in zip(bl4, bl3) {
            XCTAssertEqual(lhs, rhs)
        }

        let noIterator = bl4.firstIndex { $0 == 0 }
        XCTAssertEqual(noIterator, nil)

        let bl5 = bl4
        let position = bl5.firstIndex { $0 == 3 }!
        _ = bl5.insert(3, at: position)
        _ = bl5.insert(54, at: position)
        let values4 = [1, 3, 54, 3, 4]
        XCTAssertEqual(bl5.count, 5);
        for (lhs, rhs) in zip(bl5, values4) {
            XCTAssertEqual(lhs, rhs)
        }

        let values5 = values4.filter { $0 != 3 }
        bl5.remove { $0 == 3 }
        XCTAssertEqual(bl5.count, 3);
        for (lhs, rhs) in zip(bl5, values5) {
            XCTAssertEqual(lhs, rhs)
        }

        bl5.remove { $0 != 1 }
        XCTAssertEqual(bl5.count, 1)
        XCTAssertEqual(bl5[bl5.startIndex], 1)
        XCTAssertEqual(bl5.first, 1)

        _ = bl5.insert(27, at: bl5.startIndex)
        XCTAssertEqual(bl5.count, 2);
        XCTAssertEqual(bl5.first, 27)
        XCTAssertEqual(bl5.last, 1)

        _ = bl5.remove(at: bl5.startIndex)
        XCTAssertEqual(bl5.count, 1);
        XCTAssertEqual(bl5.first, 1);
        _ = bl5.remove(at: bl5.startIndex)
        XCTAssertEqual(bl5.count, 0);

        let bl6 = bl0
        XCTAssertEqual(bl6, bl0)
        let bl7 = BidirectionalList(bl0)
        XCTAssertEqual(bl7, bl0)
        XCTAssertNotEqual(bl7, bl5)
    }

    func testSort() {
        struct Datum {
            var value: Int
            var idx: BidirectionalList<Datum>.Index? = nil
        }

        var values = [1, 54, 3, 3, 4]
        let data = values.map{Datum(value: $0, idx: nil)}
        let bl = BidirectionalList(data)
        let fit = bl.startIndex
        let sit = bl.index(after: fit)
        var idx = fit
        while idx != bl.endIndex {
            bl[idx].idx = idx
            idx = bl.index(after: idx)
        }
        XCTAssertEqual(values[1], bl[sit].value)
        let first = bl.first
        XCTAssertEqual(first!.value, bl[fit].value)
        var lit = bl.endIndex
        let last = bl.last
        lit = bl.index(before: lit)
        XCTAssertEqual(last!.value, bl[lit].value)
        lit = bl.index(before:lit)
        lit = bl.index(before:lit)
        lit = bl.index(before:lit)
        lit = bl.index(before:lit)
        XCTAssertEqual(bl.first!.value, bl[lit].value)
        idx = bl.startIndex
        var count = 0
        while idx != bl.endIndex {
            XCTAssertEqual(bl[idx].value, values[count])
            idx = bl.index(after: idx)
            count += 1
        }
        XCTAssertEqual(bl.count, count)
        idx = bl.endIndex
        count = bl.count
        while idx != bl.startIndex {
            idx = bl.index(before: idx)
            count -= 1
            XCTAssertEqual(bl[idx].value, values[count])
        }
        XCTAssertEqual(count, 0)
        bl.sort{$0.value < $1.value}
        values.sort{$0 < $1}
        XCTAssertEqual(bl.first!.value, 1)
        XCTAssertEqual(bl.last!.value, 54)
        XCTAssertEqual(first!.value, bl[fit].value)
        XCTAssertEqual(first!.value, bl[first!.idx!].value)
        XCTAssertEqual(last!.value, bl[last!.idx!].value)
        bl.removeAll{$0.value == 3}
        values = values.filter{$0 != 3}
        XCTAssertEqual(bl.count, 3)
        idx = bl.startIndex
        count = 0
        while idx != bl.endIndex {
            XCTAssertEqual(bl[idx].value, values[count])
            idx = bl.index(after: idx)
            count += 1
        }
        XCTAssertEqual(bl.count, count)
        idx = bl.endIndex
        count = bl.count
        while idx != bl.startIndex {
            idx = bl.index(before: idx)
            count -= 1
            XCTAssertEqual(bl[idx].value, values[count])
        }
        XCTAssertEqual(count, 0)
    }

    func testOthers() {
        let bl0 = BidirectionalList<Int>(arrayLiteral: 0, 1, 2, 3, 4)
        let values = bl0.filter { $0 >= 0 }
        XCTAssertEqual(bl0.count, values.count)
        for (lhs, rhs) in zip(bl0, values) {
            XCTAssertEqual(lhs, rhs);
        }

        var cw = bl0.makeIterator()
        let bl1 = bl0.reversed()
        var ccw = bl1.makeIterator()
        XCTAssertEqual(ccw.next(), 4)
        XCTAssertEqual(cw.next(), 0)
    }

    func testCopy(){
        let values = [1, 2, 3, 4, 5]
        let bl1 = BidirectionalList(values)
        var count = 0
        for value in zip(bl1, values) {
            XCTAssertEqual(value.0, value.1)
            count += 1
        }
        XCTAssertEqual(bl1.count, count)
        XCTAssertEqual(count, values.count)
        let bl2 = bl1
        count = 0
        for value in zip(bl1, bl2) {
            XCTAssertEqual(value.0, value.1)
            count += 1
        }
        XCTAssertEqual(values.count, count)
        XCTAssertEqual(count, bl2.count)
        let bl3 = BidirectionalList(bl1)
        count = 0
        for value in zip(bl1, bl3) {
            XCTAssertEqual(value.0, value.1)
            count += 1
        }
        XCTAssertEqual(values.count, count)
        XCTAssertEqual(count, bl3.count)
        bl2.remove{$0 == 2}
        count = 0
        for value in bl2 {
            XCTAssertNotEqual(value, 2)
            count += 1
        }
        XCTAssertEqual(bl2.count, count)
        XCTAssertEqual(bl2.count, values.count - 1)
        count = 0
        for value in bl1 {
            XCTAssertNotEqual(value, 2)
            count += 1
        }
        XCTAssertEqual(bl1.count, count)
        XCTAssertEqual(count, values.count - 1)
        XCTAssertEqual(bl1[bl1.index(after: bl1.startIndex)], 3)
        count = 0
        for value in zip(values, bl3) {
            XCTAssertEqual(value.0, value.1)
            count += 1
        }
        XCTAssertEqual(bl3.count, count)
        XCTAssertEqual(count, values.count)
        XCTAssertEqual(bl3[bl3.index(after: bl3.startIndex)], 2)
    }

    static var allTests = [
        ("testGeneral", testGeneral),
        ("testOthers", testOthers),
    ]
}
