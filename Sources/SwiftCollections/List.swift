//
//  List.swift
//  
//
//  Created by José María Gómez Cama on 07/11/2020.
//

public protocol List: AnyObject, BidirectionalCollection {
    override associatedtype Element
    associatedtype Index

    var first: Element? { get set }
    var last: Element? { get set }

    var startIndex: Index { get }
    var endIndex: Index { get }

    associatedtype Iterator = ListIterator<Self>
    override func makeIterator() -> Iterator

    subscript(position: Index) -> Element { get set }

    var isEmpty: Bool { get }

    var count: Int { get }

    func index(after i: Index) -> Index

    func index(before i: Index) -> Index

    func append(_ newElement: Element) -> Index

    func append<S: Sequence>(contentsOf newElements: S)
    where S.Element == Element

    func insert(_ newElement: Element, at i: Index) -> Index

    func insert<S: Collection>(contentsOf newElements: __owned S, at i: Index)
    where S.Element == Element

    func remove(at i: Index) -> Element

    func removeFirst() -> Element

    func removeFirst(_ k: Int)

    func removeLast() -> Element

    func removeLast(_ k: Int)

    func removeAll()

    func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows
}

@usableFromInline
internal class ListValue<T> {
    @usableFromInline internal let data: T?
    @usableFromInline internal var next: ListValue<T>?
    @usableFromInline internal var previous: ListValue<T>?
    @usableFromInline internal let last: ListValue<T>?

    @inlinable
    internal init(_ data: T?,
         next: ListValue<T>? = nil,
         previous: ListValue<T>? = nil,
         circular: Bool = false) {
        self.data = data
        self.next = nil
        self.previous = nil
        self.last = nil
    }

    @inlinable
    internal init(_ data: T?,
         last: ListValue<T>,
         next: ListValue<T>? = nil,
         previous: ListValue<T>? = nil,
         circular: Bool = false) {
        self.data = data
        self.next = nil
        self.previous = nil
        self.last = last
    }

    /*
     * Mergesort algorithm based on the code from Simon Tatham
     * https://www.chiark.greenend.org.uk/~sgtatham/algorithms/listsort.html
     */

    @inlinable
    internal static func listSort(_ begin: ListValue<T>,
                                circular: Bool,
                                double: Bool,
                                by areInIncreasingOrder: (T, T) throws -> Bool
    ) rethrows -> (ListValue<T>, ListValue<T>) {
        var list: ListValue<T>? = begin

        var insize = 1

        while true {
            var p: ListValue<T>? = list
            let oldhead = list  // only used for circular linkage
            var tail: ListValue<T>? = nil
            list = nil

            var nmerges = 0  // count number of merges we do in this pass
            while p != nil {
                nmerges += 1  // there exists a merge to be done
                // step `insize' places along from p
                var q = p
                var psize = 0
                for _ in 0..<insize {
                    psize += 1
                    if (circular) {
                        q = q!.next === oldhead ? nil : q!.next
                    } else {
                        q = q!.next
                    }
                    if q == nil {
                        break
                    }
                }

                /* if q hasn't fallen off end, we have two lists to merge */
                var qsize = insize

                /* now we have two lists; merge them */
                while psize > 0 || (qsize > 0 && q != nil) {

                    var e: ListValue<T>

                    /* decide whether next element of merge comes from p or q */
                    if (psize == 0) {
                        /* p is empty; e must come from q. */
                        e = q!
                        q = q!.next
                        qsize -= 1
                        if circular && q === oldhead {
                            q = nil
                        }
                    } else if (qsize == 0 || q == nil) {
                        /* q is empty; e must come from p. */
                        e = p!
                        p = p!.next
                        psize -= 1
                        if circular && p === oldhead {
                            p = nil
                        }
                    } else if try areInIncreasingOrder(p!.data!, q!.data!) {
                        /* First element of p is lower (or same);
                         * e must come from p. */
                        e = p!
                        p = p!.next
                        psize -= 1
                        if circular && p === oldhead {
                            p = nil
                        }
                    } else {
                        /* First element of q is lower; e must come from q. */
                        e = q!
                        q = q!.next
                        qsize -= 1
                        if circular && q === oldhead {
                            q = nil
                        }
                    }

                    /* add the next element to the merged list */
                    if tail != nil {
                        tail!.next = e
                    } else {
                        list = e
                    }
                    if double {
                        /* Maintain reverse pointers in a doubly linked list. */
                        e.previous = tail
                    }
                    tail = e
                }

                /* now p has stepped `insize' places along, and q has too */
                p = q
            }
            if circular {
                tail!.next = list
                if double {
                    list!.previous = tail
                }
            } else {
                tail!.next = nil
            }

            /* If we have done only one merge, we're finished. */
            if nmerges <= 1 {  /* allow for nmerges==0, the empty list case */
                return (list!, tail!)
            }

            /* Otherwise repeat, merging lists twice the size */
            insize <<= 1
        }
    }
}

public class ListIndex<T> {
    @usableFromInline internal typealias Value = ListValue<T>
    @usableFromInline internal var value: Value

    @inlinable
    internal init(_ value: Value) {
        self.value = value
    }

    @inlinable
    internal var next: ListIndex? {
        get {
            return value.next != nil ? ListIndex(value.next!): nil
        }
    }

    @inlinable
    internal var previous: ListIndex? {
        get {
            return value.previous != nil ? ListIndex(value.previous!) : nil
        }
    }
}

extension ListIndex: Equatable {
    @inlinable
    public static func == (lhs: ListIndex<T>, rhs: ListIndex<T>) -> Bool {
        return lhs.value === rhs.value
    }
}

extension ListIndex: Comparable {
    @inlinable
    public static func < (lhs: ListIndex<T>, rhs: ListIndex<T>) -> Bool {
        if lhs.value === rhs.value {
            return false
        }
        var lhsNegative = lhs.value
        var rhsNegative = rhs.value
        var lhsPositive = lhs.value
        var rhsPositive = rhs.value

        while true {
            // start <- lhs
            if lhsNegative.previous == nil {
                return true
            } else {
                lhsNegative = lhsNegative.previous!
                // rhs <- lhs
                if lhsNegative === rhsPositive {
                    return false
                }
            }
            // start <- rhs
            if rhsNegative.previous == nil {
                return false
            } else {
                rhsNegative = rhsNegative.previous!
                // lhs <- rhs
                if rhsNegative === lhsPositive {
                    return true
                }
            }
            // lhs -> end
            if lhsPositive.next == nil {
                return false
            } else {
                lhsPositive = lhsPositive.next!
                // lhs -> rhs
                if lhsPositive === rhsNegative {
                    return true
                }
            }
            // rsh -> end
            if rhsPositive.next == nil {
                return true
            } else {
                rhsPositive = rhsPositive.next!
                // rhs -> lhs
                if rhsNegative === lhsPositive {
                    return false
                }
            }
        }
    }
}

public struct ListIterator<C: List>: IteratorProtocol {
    public typealias Element = C.Element
    @usableFromInline internal typealias Index = C.Index

    @usableFromInline internal let parent: C
    @usableFromInline internal var next_: Index?

    @inlinable
    internal init(_ parent: C) {
        self.parent = parent
        self.next_ = self.parent.startIndex
    }

    @inlinable
    public mutating func next() -> Element? {
        if next_ != self.parent.endIndex {
            let lastReturned = parent[next_!]
            next_ = parent.index(after: next_!)
            return lastReturned
        } else {
            return nil
        }
    }
}

public extension List {
    @inlinable
    var first: Element? {
        get {
            return self[self.startIndex]
        }
        set(newValue) {
            self[self.startIndex] = newValue!
        }
    }

    @inlinable
    var last: Element? {
        get {
            return self[index(before: self.endIndex)]
        }
        set(newValue) {
            self[index(before: self.endIndex)] = newValue!
        }
    }

    @inlinable
    var underestimatedCount: Int {
        return count
    }

    @inlinable
    var isEmpty: Bool {
        return startIndex == endIndex
    }

    @inlinable
    func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
        var idx = startIndex
        while idx != endIndex {
            if try predicate(self[idx]) {
                return idx
            }
            idx = index(after: idx)
        }
        return nil
    }

    @inlinable
    func formIndex(after i: inout Index) {
        i = index(after: i)
    }

    @inlinable
    func append(_ newElement: Element) -> Index {
        return insert(newElement, at: endIndex)
    }

    @inlinable
    func append<S: Sequence>(contentsOf newElements: S)
    where S.Element == Element {
        for element in newElements {
            _ = append(element)
        }
    }

    @inlinable
    func insert<S: Collection>(contentsOf newElements: S, at idx: Index)
    where S.Element == Element {
        for element in newElements {
            _ = insert(element, at: idx)
        }
    }

    @inlinable
    func removeFirst() -> Element {
        return remove(at: startIndex)
    }

    @inlinable
    func removeFirst(_ k: Int) {
        var cnt = k
        while startIndex != endIndex {
            if cnt > 0 {
                _ = remove(at: startIndex)
                cnt -= 1
            } else {
                break
            }
        }
    }

    @inlinable
    func removeLast() -> Element {
        return remove(at: index(before: endIndex))
    }

    @inlinable
    func removeLast(_ k: Int) {
        var idx = endIndex
        if idx == startIndex {
            return
        }
        var cnt = k
        repeat {
            if cnt > 0 {
                idx = index(before: endIndex)
                _ = remove(at: idx)
                cnt -= 1
            } else {
                break
            }
        } while idx != startIndex
    }

    @inlinable
    func removeAll() {
        var idx = startIndex
        while idx != endIndex {
            let nextIdx = index(after: idx)
            _ = remove(at: idx)
            idx = nextIdx
        }
    }

    @inlinable
    func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        var idx = startIndex
        while idx != endIndex {
            let nextIdx = index(after: idx)
            if try shouldBeRemoved(self[idx]) {
                _ = remove(at: idx)
            }
            idx = nextIdx
        }
    }
}

public extension List where Element: Equatable {
    @inlinable
    func firstIndex(of element: Element) -> Index? {
        var idx = startIndex
        while idx != endIndex {
            if self[idx] == element {
                return idx
            }
            idx = index(after: idx)
        }
        return nil
    }
}

public extension List where Iterator == ListIterator<Self> {
    @inlinable
    func makeIterator() -> Iterator {
        return Iterator(self)
    }
}
