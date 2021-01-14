//
//  BidirectionalList.swift
//  
//
//  Created by José María Gómez Cama on 26/09/2020.
//

import Foundation

public class BidirectionalList<T> {
    public typealias Element = T
    public typealias Index = ListIndex<Element>
    @usableFromInline internal typealias Value = ListIndex<Element>.Value
    
    @usableFromInline internal var begin: Value? = nil
    @usableFromInline internal var end: Value? = nil
    @usableFromInline internal var _last: Index
    @usableFromInline internal var _count = 0

    @inlinable
    public var count: Int {
        return _count
    }

    @usableFromInline
    internal func removeEntry(_ e: Value) {
        _count -= 1
        if (count == 0) {
            begin = nil
            end = nil
        } else {
            if (e === begin) {
                begin = e.next
                e.next!.previous = nil
            } else if (e === end) {
                end = e.previous
                e.previous!.next = nil
            } else {
                e.next!.previous = e.previous
                e.previous!.next = e.next
            }
        }
        e.previous = nil
        e.next = nil
        self._last.value.previous = self.end
    }
    
    @usableFromInline
    internal func insertEntry(_ e: Value,
                             at after: Value) {
        e.next = after
        e.previous = after.previous
        if (after.previous == nil) {
            begin = e
        } else {
            after.previous!.next = e
        }
        after.previous = e
        _count += 1
        self._last.value.previous = self.end
    }
    
    @usableFromInline
    internal func substituteEntry(_ e: Value,
                                 at entry: Value) {
        e.next = entry.next
        e.previous = entry.previous
        if (entry.previous == nil) {
            begin = e
        } else {
            e.previous!.next = e
        }
        if (entry.next == nil) {
            end = e
        } else {
            e.next!.previous = e
        }
        entry.previous = nil
        entry.next = nil
        self._last.value.previous = self.end
    }
    
    @usableFromInline
    internal func addLastEntry(_ e: Value) {
        if (count == 0) {
            begin = e
            end = e
        } else {
            e.previous = end
            end!.next = e
            end = e
        }
        _count += 1
        self._last.value.previous = self.end
    }

    @inlinable
    required public init() {
        self._last = Index(Value(nil, next: nil, previous: self.end))
    }

    @inlinable
    required public init<S: Sequence>(_ contents: S) where S.Element == Element {
        self._last = Index(Value(nil, next: nil, previous: self.end))
        append(contentsOf: contents)
    }

    @inlinable
    required public init(from decoder: Decoder) throws where Element: Decodable {
        self._last = Index(Value(nil, next: nil, previous: self.begin))
        var values = try decoder.unkeyedContainer()
        append(contentsOf: try values.decode([Element].self))
    }

    @inlinable
    required public init(arrayLiteral contents: Element...) {
        self._last = Index(Value(nil, next: nil, previous: self.end))
        append(contentsOf: contents)
    }
    
    @inlinable
    public func remove(_ isIncluded: (Element) throws -> Bool) rethrows {
        var entry = begin
        repeat {
            let tmp = entry!.next
            if try isIncluded(entry!.data!) {
                removeEntry(entry!)
            }
            entry = tmp
        } while (entry != nil)
    }
    
    @inlinable
    internal func checkBoundsExclusive(_ idx: Index) {
        if idx === _last {
            fatalError("Index out of Bounds")
        }
    }
}

extension BidirectionalList: List {
    @inlinable
    public subscript(idx: Index) -> Element {
        get {
            return idx.value.data!
        }
        set(newValue) {
            let value = Value(newValue)
            substituteEntry(value, at: idx.value)
            idx.value = value
        }
    }

    @inlinable
    public var startIndex:Index {
        return self.begin != nil ? Index(self.begin!): self._last
    }

    @inlinable
    public var endIndex: Index {
        return self._last
    }

    @inlinable
    public func index(after i: Index) -> Index {
        return i.next ?? _last
    }

    @inlinable
    public func index(before i: Index) -> Index {
        return i.previous!
    }

    @inlinable
    public func append(_ o: Element) -> Index {
        let value = Value(o, last: self._last.value)
        addLastEntry(value)
        return Index(value)
    }

    @inlinable
    public func append<S: Sequence>(contentsOf newElements: S) where Element == S.Element {
        for o in newElements {
            addLastEntry(Value(o, last: self._last.value))
        }
    }

    @inlinable
    public func insert(_ element: Element,
                       at idx: Index) -> Index{
        let e = Value(element, last: self._last.value);
        if idx === self._last {
            addLastEntry(e)
        } else {
            insertEntry(e, at: idx.value)
        }
        return Index(e)
    }

    @inlinable
    public func remove(at idx: Index) -> Element {
        checkBoundsExclusive(idx)
        let element = idx.value.data!
        removeEntry(idx.value)
        return element
    }

    @inlinable
    public func removeAll() {
        var value = begin
        // Disconect elements
        while value != nil {
            value!.previous = nil
            value = value!.next
        }
        begin = nil
        end = nil
        _last.value.previous = begin
        _count = 0
    }
}

extension BidirectionalList where Element: Equatable{
}

extension BidirectionalList {
}

extension BidirectionalList: Equatable where Element: Equatable {
    @inlinable
    public static func == (lhs: BidirectionalList<Element>,
                           rhs: BidirectionalList<Element>) -> Bool {
        if lhs === rhs {
            return true
        }
        if lhs.count != rhs.count {
            return false
        }
        for (l, r) in zip(lhs, rhs) {
            if l != r {
                return false
            }
        }
        return true
    }
}

extension BidirectionalList: Decodable where Element: Decodable {
}

extension BidirectionalList: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws where Element: Encodable {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: self)
    }
}

extension BidirectionalList: ExpressibleByArrayLiteral {
}

extension BidirectionalList {
    @inlinable
    public func sort(
        by areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows {
        if begin != nil {
            let result = try ListValue.listSort(begin!,
                                                circular: false,
                                                double: true,
                                                by: areInIncreasingOrder)
            self.begin = result.0
            self.end = result.1
            self._last.value.previous = self.end
        }
    }

    @inlinable
    public func sort() where Element: Comparable {
        sort(by: {$0 < $1})
    }
}
