import XCTest
@testable import SwiftCollections

final class ListTests: XCTestCase {
    func testIndex() {
        let last = ListIndex(ListValue<Int>(nil))
        let idx0 = ListIndex(ListValue<Int>(0, last: last.value))
        let idx1 = ListIndex(ListValue<Int>(1, last: last.value))
        let idx2 = ListIndex(ListValue<Int>(2, last: last.value))
        let idx3 = ListIndex(ListValue<Int>(3, last: last.value))
        idx1.value.previous = idx0.value
        idx2.value.previous = idx1.value
        idx3.value.previous = idx2.value
        last.value.previous = idx3.value
        idx0.value.next = idx1.value
        idx1.value.next = idx2.value
        idx2.value.next = idx3.value

        XCTAssertTrue(idx0 < idx1)
        XCTAssertTrue(idx1 < idx2)
        XCTAssertTrue(idx2 < last)
        XCTAssertTrue(idx1 > idx0)
        XCTAssertTrue(idx2 > idx1)
        XCTAssertTrue(last > idx2)
        XCTAssertFalse(idx0 > idx1)
        XCTAssertFalse(idx1 > idx2)
        XCTAssertFalse(idx2 > last)
        XCTAssertFalse(idx1 < idx0)
        XCTAssertFalse(idx2 < idx1)
        XCTAssertFalse(last < idx2)
        XCTAssertFalse(idx0 == idx1)
        XCTAssertFalse(idx0 == idx2)
        XCTAssertFalse(idx0 == last)
        XCTAssertFalse(idx1 == idx2)
        XCTAssertFalse(idx1 == last)
        XCTAssertFalse(idx2 == last)
        XCTAssertFalse(idx1 == idx0)
        XCTAssertFalse(idx2 == idx0)
        XCTAssertFalse(last == idx0)
        XCTAssertFalse(idx2 == idx1)
        XCTAssertFalse(last == idx1)
        XCTAssertFalse(last == idx2)
        XCTAssertTrue(idx0 == idx0)
        XCTAssertTrue(idx1 == idx1)
        XCTAssertTrue(idx2 == idx2)
        XCTAssertTrue(last == last)
        XCTAssertFalse(idx0 < idx0)
        XCTAssertFalse(idx1 < idx1)
        XCTAssertFalse(idx2 < idx2)
        XCTAssertFalse(last < last)
    }

    func checkSort<S: Sequence>(_ data: S,
                                is_circular: Bool,
                                is_double: Bool) where S.Element: Comparable {
        var k: [ListValue<S.Element>] = []

        for value in data {
            let e = ListValue<S.Element>(value)
            k.append(e)
        }
        for value in k.enumerated() {
            let j = value.offset
            value.element.next = (j+1 < k.count ? k[j+1] :
                                    is_circular ? k[0] : nil)
            value.element.previous = (!is_double ? nil :
                                        j > 0 ? k[j-1] :
                                        is_circular ? k.last : nil)
        }
        let result = ListValue.listSort(k[0],
                                        circular: is_circular,
                                        double: is_double,
                                        by: <)
        if is_circular {
            XCTAssertTrue(result.1.next === result.0)
            if is_double {
                XCTAssertTrue(result.0.previous === result.1)
            }
        } else {
            XCTAssertTrue(result.1.next == nil)
            XCTAssertTrue(result.0.previous == nil)
        }
        let head = result.0
        var e: ListValue<S.Element>? = head
        var count = 0
        if is_circular {
            repeat {
                if e!.next !== head {
                    XCTAssertTrue(e!.data! <= e!.next!.data!)
                } else {
                    XCTAssertTrue(e!.next!.data! < e!.data!)
                }
                if is_double {
                    XCTAssertEqual(e!.data!, e!.next!.previous!.data!)
                }
                e = e!.next
                count += 1
            } while e !== head
        } else {
            while e != nil {
                if e!.next != nil {
                    XCTAssertTrue(e!.data! <= e!.next!.data!)
                    if is_double {
                        XCTAssertEqual(e!.data!, e!.next!.previous!.data!)
                    }
                }
                e = e!.next
                count += 1
            }
        }
        XCTAssertEqual(k.count, count)
    }

    func testListSort() {
        let cases = ["abcdefghijklm",
                     "gcielbmhdjfak",
                     "mlkjihgfedcba"]
        for is_circular in [false, true] {
            for is_double in [false, true] {
                for value in cases {
                    checkSort(value, is_circular: is_circular, is_double: is_double)
                }
            }
        }
    }

    func testIntegerListSort() {
        let cases = [[1, 2, 3, 4, 5],
                     [1, 54, 3, 3, 4]]
        for is_circular in [false, true] {
            for is_double in [false, true] {
                for value in cases {
                    checkSort(value, is_circular: is_circular, is_double: is_double)
                }
            }
        }
    }

    static var allTests = [
        ("testIndex", testIndex),
        ("testListSort", testListSort),
        ("testIntegerListSort", testIntegerListSort),
    ]
}
