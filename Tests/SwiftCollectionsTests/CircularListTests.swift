import XCTest
@testable import SwiftCollections

final class CircularListTests: XCTestCase {
    func testIndex() {
        let values = [0, 1, 2, 3, 4]
        let cl = CircularList<Int>(values)
        let startIdx = cl.startIndex
        XCTAssertEqual(cl.first, values[0])
        let oneIdx = cl.index(after: startIdx)
        XCTAssertEqual(cl[oneIdx], values[1])
        XCTAssertEqual(cl.first, 0)
        XCTAssertEqual(cl.startIndex, cl.index(before: cl.index(after: startIdx)))
        let endIdx = cl.endIndex
        XCTAssertEqual(cl.last, values.last)
        let lastIdx = cl.index(before: endIdx)
        XCTAssertEqual(cl[lastIdx], cl.last)
        XCTAssertEqual(cl.last, 4)
        XCTAssertEqual(cl.endIndex, cl.index(after: lastIdx))
    }

    func testInsert() {
        let cl = CircularList<Int>()
        _ = cl.append(1)
        XCTAssertEqual(cl.count, 1)
        XCTAssertEqual(cl.first, 1)
        _ = cl.append(4)
        XCTAssertEqual(cl.count, 2)
        XCTAssertEqual(cl.last, 4)
        let idx = cl.index(after: cl.startIndex)
        _ = cl.insert(8, at: idx)
        XCTAssertEqual(cl.count, 3)
        XCTAssertEqual(cl[cl.index(after: cl.startIndex)], 8)
    }

    func testGeneral() {
        let values = [0, 1, 2, 3, 4]
        let cl0 = CircularList<Int>(values)
        let cl1 = CircularList<Int>()
        XCTAssertEqual(cl1.count, 0)
        cl1.append(contentsOf: values)
        XCTAssertEqual(cl1.count, 5)
        for (lhs, rhs) in zip(cl0, values) {
            XCTAssertEqual(lhs, rhs);
        }
        for (lhs, rhs) in zip(cl1, values) {
            XCTAssertEqual(lhs, rhs);
        }

        let cl2 = cl1.filter { $0 != 2 }
        cl1.remove { $0 == 2 }
        let n = cl2.count
        XCTAssertEqual(cl1.count, n)
        for (lhs, rhs) in zip(cl1, cl2) {
            XCTAssertEqual(lhs, rhs)
        }

        let cl3 = cl2.filter { $0 != 0 }
        cl1.remove { $0 == 0 }
        XCTAssertEqual(cl3.count, cl1.count)
        for (lhs, rhs) in zip(cl3, cl1) {
            XCTAssertEqual(lhs, rhs)
        }

        let cl4 = cl1
        XCTAssertEqual(cl4.count, cl1.count);
        for (lhs, rhs) in zip(cl4, cl3) {
            XCTAssertEqual(lhs, rhs)
        }

        let noIterator = cl4.firstIndex { $0 == 0 }
        XCTAssertEqual(noIterator, nil)

        let cl5 = cl4
        let position = cl5.firstIndex { $0 == 3 }
        _ = cl5.insert(3, at: position!)
        _ = cl5.insert(54, at: position!)
        let values4 = [1, 3, 54, 3, 4]
        XCTAssertEqual(cl5.count, 5);
        for (lhs, rhs) in zip(cl5, values4) {
            XCTAssertEqual(lhs, rhs)
        }

        let values5 = values4.filter { $0 != 3 }
        cl5.remove { $0 == 3 }
        XCTAssertEqual(cl5.count, 3);
        for (lhs, rhs) in zip(cl5, values5) {
            XCTAssertEqual(lhs, rhs)
        }

        XCTAssertEqual(cl5[cl5.index(after: cl5.startIndex)], 54)

        cl5.remove { $0 != 1 }
        XCTAssertEqual(cl5.count, 1)
        XCTAssertEqual(cl5.first, 1)

        _ = cl5.insert(27, at: cl5.startIndex)
        XCTAssertEqual(cl5.count, 2);
        XCTAssertEqual(cl5.first, 27)
        XCTAssertEqual(cl5.last, 1)

        _ = cl5.remove(at: cl5.startIndex)
        XCTAssertEqual(cl5.count, 1);
        XCTAssertEqual(cl5.first, 1);
        _ = cl5.remove(at: cl5.startIndex)
        XCTAssertEqual(cl5.count, 0);

        let cl6 = cl0
        XCTAssertEqual(cl6, cl0)
        let cl7 = CircularList(cl0)
        XCTAssertEqual(cl7, cl0)
        XCTAssertNotEqual(cl7, cl5)
    }

    func testSort() {
        struct Datum {
            var value: Int
            var idx: BidirectionalList<Datum>.Index? = nil
        }

        let values = [1, 54, 3, 3, 4]
        let data = values.map{Datum(value: $0, idx: nil)}
        let cl = CircularList(data)
        let fit = cl.startIndex
        let sit = cl.index(after: fit)
        var idx = fit
        while idx != cl.endIndex {
            cl[idx].idx = idx
            idx = cl.index(after: idx)
        }
        XCTAssertEqual(values[1], cl[sit].value)
        let first = cl.first
        XCTAssertEqual(first!.value, cl[fit].value)
        var lit = cl.endIndex
        let last = cl.last
        lit = cl.index(before: lit)
        XCTAssertEqual(last!.value, cl[lit].value)
        lit = cl.index(before:lit)
        lit = cl.index(before:lit)
        lit = cl.index(before:lit)
        lit = cl.index(before:lit)
        XCTAssertEqual(cl.first!.value, cl[lit].value)
        cl.sort{$0.value < $1.value}
        XCTAssertEqual(cl.first!.value, 1)
        XCTAssertEqual(cl.last!.value, 54)
        XCTAssertEqual(first!.value, cl[fit].value)
        XCTAssertEqual(first!.value, cl[first!.idx!].value)
        XCTAssertEqual(last!.value, cl[last!.idx!].value)
    }

    func testOthers() {
        let cl0 = CircularList<Int>(arrayLiteral: 0, 1, 2, 3, 4)
        let values = cl0.filter { $0 >= 0 }
        XCTAssertEqual(cl0.count, values.count)
        for (lhs, rhs) in zip(cl0, values) {
            XCTAssertEqual(lhs, rhs);
        }

        var cw = cl0.makeIterator()
        let cl1 = cl0.reversed()
        var ccw = cl1.makeIterator()
        XCTAssertEqual(ccw.next(), 4)
        XCTAssertEqual(cw.next(), 0)
    }

    static var allTests = [
        ("testGeneral", testGeneral),
        ("testOthers", testOthers),
    ]
}
