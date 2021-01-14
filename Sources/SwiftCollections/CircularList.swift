//
//  CircularList.swift
//  
//
//  Created by José María Gómez Cama on 26/09/2020.
//

import Foundation

public enum CircularListError: Error {
    case iteratorsFromDifferentCircularLists
    case iteratorsWithDifferentOffsets
}

public class CircularList<T> {
    public typealias Element = T
    public typealias Index = ListIndex<Element>
    @usableFromInline internal typealias Value = ListIndex<Element>.Value

    @usableFromInline internal var root: Value? = nil
    @usableFromInline internal var _count = 0
    @usableFromInline internal var _last: Index

    @inlinable
    public var count: Int {
        return _count
    }

    @usableFromInline
    internal func removeEntry(_ e: Value) {
        _count -= 1
        if (count == 0) {
            root = nil
        } else {
            e.next!.previous = e.previous
            e.previous!.next = e.next
            if (e === root) {
                root = e.next
            }
            e.previous = nil
            e.next = nil
        }
        self._last.value.previous = self.root?.previous
    }

    @usableFromInline
    internal func insertEntry(_ e: Value,
                             at after: Value) {
        e.next = after
        e.previous = after.previous
        after.previous!.next = e
        after.previous = e
        if (after === root) {
            root = e
        }
        _count += 1
        self._last.value.previous = self.root?.previous
    }

    @usableFromInline
    internal func substituteEntry(_ e: Value,
                                 at entry: Value) {
        e.next = entry.next
        e.previous = entry.previous
        e.next!.previous = e
        e.previous!.next = e
        if (entry === root) {
            root = e
        }
        entry.previous = nil
        entry.next = nil
        self._last.value.previous = self.root?.previous
    }

    @usableFromInline
    internal func addLastEntry(_ e: Value) {
        if (count == 0) {
            root = e
            root!.next = e
            root!.previous = e
        } else {
            e.previous = root!.previous
            e.next = root
            root!.previous!.next = e
            root!.previous = e
        }
        _count += 1
        self._last.value.previous = self.root?.previous
    }

    @inlinable
    required public init() {
        self._last = Index(Value(nil, next: nil, previous: self.root?.previous, circular: true))
    }

    @inlinable
    required public init<S: Sequence>(_ contents: S) where S.Element == Element {
        self._last = Index(Value(nil, next: nil, previous: self.root?.previous, circular: true))
        append(contentsOf: contents)
    }

    @inlinable
    required public init(arrayLiteral contents: Element...) {
        self._last = Index(Value(nil, next: nil, previous: self.root?.previous, circular: true))
        append(contentsOf: contents)
    }

    @inlinable
    required public init(from decoder: Decoder) throws where Element: Decodable {
        self._last = Index(Value(nil, next: nil, previous: self.root?.previous, circular: true))
        var values = try decoder.unkeyedContainer()
        append(contentsOf: try values.decode([Element].self))
    }

    @inlinable
    public func remove(_ isIncluded: (T) throws -> Bool) rethrows {
        var entry = root
        repeat {
            let tmp = entry!.next
            if try isIncluded(entry!.data!) {
                removeEntry(entry!)
            }
            entry = tmp
        } while (entry !== root)
    }

    @inlinable
    internal func checkBoundsExclusive(_ idx: Index)
    {
        if idx === _last {
            fatalError("Index out of Bounds")
        }
    }

}

extension CircularList: List {
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
        return self.root != nil ? Index(self.root!): self._last
    }

    @inlinable
    public var endIndex: Index {
        return self._last
    }

    @inlinable
    public func loop(after i: Index) -> Index {
        return i.next!
    }

    public func loop(before i: Index) -> Index {
        return i.previous!
    }

    @inlinable
    public func index(after i: Index) -> Index {
        if i.next!.value === root {
            return _last
        } else {
            return i.next!
        }
    }

    @inlinable
    public func index(before i: Index) -> Index {
        return i.previous!
    }

    @inlinable
    public func append(_ o: Element) -> Index {
        let value = Value(o, circular: true)
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
    public func insert(_ value: Element,
                at idx: Index) -> Index{
        let e = Value(value, circular: true);
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
        if root != nil {
            var value = root
            repeat {
                value!.previous = nil
                value = value!.next
            } while value !== root
            root!.next = nil
            root = nil
        }
        _last.value.previous = root
        _count = 0
    }
}

extension CircularList: Equatable where Element: Equatable {
    @inlinable
    public static func == (lhs: CircularList<Element>,
                    rhs: CircularList<Element>) -> Bool {
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

extension CircularList: Decodable where Element: Decodable {
}

extension CircularList: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws where Element: Encodable {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: self)
    }
}

extension CircularList: ExpressibleByArrayLiteral {
}

extension CircularList {
    public func sort(
        by areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows {
        if root != nil {
            let result = try ListValue.listSort(root!,
                                                circular: true,
                                                double: true,
                                                by: areInIncreasingOrder)
            self.root = result.0
            self._last.value.previous = self.root!.previous
        }
    }
}
