//
//  RBDictionary.swift
//
//
//  Created by José María Gómez Cama on 09/11/2020.
//
//  Red Black Tree algorithm based on the code from:
//  https://algs4.cs.princeton.edu/33balanced/RedBlackBST.java.html
//

import Foundation

public class RBDictionary<Key, Value> {
    public typealias Element = (key: Key, value: Value)
    public typealias AreInIncreasingOrder = (Key, Key) throws -> Bool

    @usableFromInline
    enum Color {
        case red
        case black
    }

    @usableFromInline
    internal class Node {
        /** parent in rbtree,*/
        @usableFromInline internal var parent: Node? = nil
        /** left node (smaller items) */
        @usableFromInline internal var left: Node? = nil
        /** right node (larger items) */
        @usableFromInline internal var right: Node? = nil
        /** pointer to sorting key */
        @usableFromInline internal fileprivate(set) var key: Key?
        /** pointer to value */
        @usableFromInline internal fileprivate(set) var value: Value?
        /** colour of this node */
        @usableFromInline internal var color: Color
        /** subtree count */
        @usableFromInline internal var count = 0

        @usableFromInline
        internal init() {
            key = nil
            color = .black
            left = self
            right = self
        }

        fileprivate init(_ key: Key, _ value: Value) {
            self.key = key
            self.value = value
            color = .black
            left = self
            right = self
        }
    }

    /** The root of the red-black tree */
    @usableFromInline internal var root: Node

    /** The number of the nodes in the tree */
    @usableFromInline internal var _count = 0

    @inlinable
    public var count: Int {
        return _count
    }

    /**
     * Key compare function. <0,0,>0 like strcmp.
     * Return 0 on two NULL ptrs.
     */
    @usableFromInline internal var cmp: AreInIncreasingOrder

    @usableFromInline internal let sentinel: Node

    @inlinable
    public init() where Key: Comparable {
        sentinel = Node()
        root = sentinel
        cmp = {$0 < $1}
    }

    @inlinable
    public init(where cmp: @escaping AreInIncreasingOrder) {
        sentinel = Node()
        root = sentinel
        self.cmp = cmp
    }

    @inlinable
    public init(_ tree: RBDictionary) {
        sentinel = Node()
        root = sentinel
        cmp = tree.cmp
        try! insert(tree)
    }

    @inlinable
    public init<S: Sequence>(_ contents: S) where S.Element == Element, Key: Comparable {
        sentinel = Node()
        root = sentinel
        cmp = {$0 < $1}
        try! insert(contents)
    }

    @inlinable
    public init<S: Sequence>(_ contents: S,
                             where cmp: @escaping AreInIncreasingOrder) throws where S.Element == Element {
        sentinel = Node()
        root = sentinel
        self.cmp = cmp
        try insert(contents)
    }

    @inlinable
    public init<S: Sequence>(uniqueKeysWithValues contents: S) where S.Element == (Key, Value), Key: Comparable {
        sentinel = Node()
        root = sentinel
        cmp = {$0 < $1}
        try! insert(contents.map({($0.0, $0.1)}))
    }

    @inlinable
    public init<S: Sequence>(uniqueKeysWithValues contents: S,
                             where cmp: @escaping AreInIncreasingOrder) throws where S.Element == (Key, Value) {
        sentinel = Node()
        root = sentinel
        self.cmp = cmp
        try insert(contents.map({($0.0, $0.1)}))
    }

    @usableFromInline
    internal struct HashableKey: Hashable {
        @usableFromInline internal let id = UUID()
        @usableFromInline internal let key: Key

        @usableFromInline
        internal static func == (lhs: HashableKey, rhs: HashableKey) -> Bool {
            return lhs.id == rhs.id
        }

        public func hash(into hasher: inout Hasher) {
            id.hash(into: &hasher)
        }
    }

    @inlinable
    required public init(from decoder: Decoder) throws where Key: Decodable, Key: Comparable, Value: Decodable {
        sentinel = Node()
        root = sentinel
        cmp = {$0 < $1}
        let dict = try Dictionary<HashableKey, Value>(from: decoder)
        try insert(dict.map({($0.key, $1)}))
    }

    @inlinable
    public init(from decoder: Decoder,
                where cmp: @escaping AreInIncreasingOrder) throws where Key: Decodable, Value: Decodable {
        sentinel = Node()
        root = sentinel
        self.cmp = cmp
        let dict = try Dictionary<HashableKey, Value>(from: decoder)
        try insert(dict.map({($0.key, $1)}))
    }

    @inlinable
    required public init(dictionaryLiteral contents: (Key, Value)...) where Key: Comparable {
        sentinel = Node()
        root = sentinel
        cmp = {$0 < $1}
        do {
            try insert(contents)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }

    @inlinable
    public init(dictionaryLiteral contents: (Key, Value)...,
                where cmp: @escaping AreInIncreasingOrder) {
        sentinel = Node()
        root = sentinel
        self.cmp = cmp
        do {
            try insert(contents)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }

    @usableFromInline
    internal func rotateLeft(_ node: Node) -> Node{
        let x = node.right!
        node.right = x.left
        if x.left !== sentinel {
            x.left!.parent = node
        }
        x.parent = node.parent
        x.left = node
        x.left!.parent = x
        x.color = x.left!.color
        x.left!.color = .red
        x.count = node.count
        node.count = node.left!.count + node.right!.count + 1
        // assert(sentinel.count == 0)
        return x;
    }

    @usableFromInline
    internal func rotateRight(_ node: Node) -> Node{
        let x = node.left!
        node.left = x.right
        if x.right !== sentinel {
            x.right!.parent = node
        }
        x.parent = node.parent
        x.right = node
        x.right!.parent = x
        x.color = x.right!.color
        x.right!.color = .red
        x.count = node.count
        node.count = node.left!.count + node.right!.count + 1
        // assert(sentinel.count == 0)
        return x
    }

    @usableFromInline
    internal func flipColors(_ node: Node) {
        node.color = node.color == .red ? .black : .red
        node.left!.color = node.left!.color == .red ? .black : .red
        node.right!.color = node.right!.color == .red ? .black : .red
    }

    @usableFromInline
    internal func findLessEqual(_ key: Key) throws -> (found: Bool,
                                                      node: Node?) {
        /* We start at root... */
        var node = root

        /* While there are children... */
        var result: Node? = nil
        while node !== sentinel {
            result = node

            if try cmp(key, node.key!) {
                node = node.left!
            } else if try cmp(node.key!, key) {
                node = node.right!
            } else {
                return (true, node)
            }
        }
        return (false, result)
    }

    @inlinable
    public func insert(_ element: Element) -> (inserted: Bool,
                                               memberAfterInsert: Element){
        let result = try! insert(root.parent, root, element)
        root = result.root
        root.color = .black
        root.parent = nil
        _count = root.count
        return (result.inserted, (result.memberAfterInsert.key!,
                                  result.memberAfterInsert.value!))
    }

    @usableFromInline
    internal func insert(_ parent: Node?,
                        _ node: Node,
                        _ element: Element) throws -> (inserted: Bool,
                                                       root: Node,
                                                       memberAfterInsert: Node){
        var inserted = false
        var h = node
        var value = node
        if (node === sentinel) {
            let data = Node(element.key, element.value)
            data.parent = parent
            data.left = sentinel
            data.right = sentinel
            data.color = .red
            data.count = 1
            inserted = true
            h = data
            value = data
        } else {
            if try cmp(element.key, node.key!) {
                let result = try insert(node, node.left!,  element)
                inserted = result.inserted
                node.left  = result.root
                value = result.memberAfterInsert
            } else if try cmp(node.key!, element.key) {
                let result = try insert(node, node.right!, element)
                inserted = result.inserted
                node.right  = result.root
                value = result.memberAfterInsert
            } else {
                node.value = element.value
                value = node
            }
            // fix-up any right-leaning links
            if h.right!.color == .red && h.left!.color == .black {
                h = rotateLeft(h)
            }
            if h.left!.color == .red  &&  h.left!.left!.color == .red {
                h = rotateRight(h)
            }
            if h.left!.color == .red  &&  h.right!.color == .red {
                flipColors(h)
            }
            h.count = h.left!.count + h.right!.count + 1
        }
        return (inserted, h, value)
    }

    @inlinable
    public func insert<S: Sequence>(_ contents: S) throws where S.Element == Element {
        for value in contents {
            _ = insert(value)
        }
    }

    @inlinable
    public func insert(contentsOf contents: Element...) throws {
        try insert(contents)
    }

    @inlinable
    public func contains(_ key: Key) -> Bool {
        let result = try? findLessEqual(key)
        return result == nil ? false : result!.found
    }

    @usableFromInline
    internal func moveRedLeft(_ node: Node) -> Node {
        var h = node
        flipColors(h)
        if h.right!.left!.color == .red {
            h.right = rotateRight(h.right!)
            h = rotateLeft(h)
            flipColors(h)
        }
        return h
    }

    @usableFromInline
    internal func moveRedRight(_ node: Node) -> Node {
        var h = node
        flipColors(h)
        if h.left!.left!.color == .red {
            h = rotateRight(h)
            flipColors(h)
        }
        return h
    }

    @usableFromInline
    internal func min(_ node: Node) -> Node {
        var x = node
        while x.left !== sentinel {
            x = x.left!
        }
        return x
    }

    @usableFromInline
    internal func max(_ node: Node) -> Node {
        var x = node
        while x.right !== sentinel {
            x = x.right!
        }
        return x
    }

    @usableFromInline
    internal func deleteMin(_ node: Node) -> Node {
        var h = node
        if (h.left === sentinel) {
            return sentinel
        }
        if h.left!.color == .black && h.left!.left!.color == .black {
            h = moveRedLeft(h);
        }
        h.left = deleteMin(h.left!)
        return balance(h)
    }

    @usableFromInline
    internal func deleteMax(_ node: Node) -> Node {
        var h = node
        if h.left!.color == .red {
            h = rotateRight(h)
        }
        if (h.right === sentinel) {
            return sentinel
        }
        if h.right!.color == .black && h.right!.left!.color == .black {
            h = moveRedRight(h)
        }
        h.right = deleteMax(h.right!)

        return balance(h)
    }

    @usableFromInline
    internal func balance(_ node: Node) -> Node {
        var h = node

        if h.right!.color == .red {
            h = rotateLeft(h);
        }
        if h.left!.color == .red && h.left!.left!.color == .red {
            h = rotateRight(h);
        }
        if h.left!.color == .red && h.right!.color == .red {
            flipColors(h);
        }

        h.count = h.left!.count + h.right!.count + 1;
        return h;
    }

    @inlinable
    public func remove(_ key: Key) -> Element? {
        if !contains(key) {
            return nil
        }
        if root.left!.color == .black && root.right!.color == .black {
            root.color = .red
        }
        let result = try? remove(root, key)
        if result == nil {
            return nil
        }
        root = result!.node
        _count = root.count
        root.parent = nil
        if root === sentinel {
            root.color = .black
        }
        return result!.element
    }

    @usableFromInline
    internal func remove(_ node: Node,
                _ key: Key) throws -> (element: Element,
                                       node: Node) {
        var h = node
        var result: Element = (h.key!, h.value!)
        if try cmp(key, h.key!) {
            if h.left!.color == .black && h.left!.left!.color == .black {
                h = moveRedLeft(h)
            }
            let removed = try remove(h.left!, key)
            result = removed.element
            h.left = removed.node
            if h.left! !== sentinel {
                h.left!.parent = h
            }
        } else {
            if h.left!.color == .red {
                h = rotateRight(h)
            }
            if try !cmp(h.key!, key) && h.right === sentinel {
                result = (h.key!, h.value!)
                h = sentinel
            } else {
                if h.right!.color == .black && h.right!.left!.color == .black {
                    h = moveRedRight(h)
                }
                if try !cmp(h.key!, key) {
                    let x = min(h.right!)
                    h.key = x.key!
                    h.value = x.value!
                    x.parent = nil
                    h.right = deleteMin(h.right!)
                    if h.right! !== sentinel {
                        h.right!.parent = h
                    }
                } else {
                    let removed = try remove(h.right!, key)
                    result = removed.element
                    h.right = removed.node
                    if h.right!.parent !== sentinel {
                        h.right!.parent = h
                    }
                }
            }
        }
        if h !== sentinel {
            h = balance(h)
        }
        return (result, h)
    }

    @usableFromInline
    internal func removeParent(_ node: Node) {
        if node.left !== sentinel {
            removeParent(node.left!)
            node.left!.parent = nil
        }
        if node.right !== sentinel {
            removeParent(node.right!)
            node.right!.parent = nil
        }
    }

    @inlinable
    public func removeAll() {
        if root !== sentinel {
            removeParent(root)
        }
        root = sentinel
        _count = 0
    }

    @usableFromInline
    internal func next (_ n: Node) -> Node? {
        var node: Node? = n
        if node!.right !== sentinel {
            /* One right, then keep on going left... */
            node = node!.right
            while node!.left !== sentinel {
                node = node!.left
            }
        } else {
            var parent = node!.parent
            while parent != nil && node === parent!.right {
                node = parent
                parent = parent!.parent
            }
            node = parent
        }
        if node === sentinel {
            node = nil
        }
        return node
    }

    @usableFromInline
    internal func previous(_ n: Node) -> Node? {
        var node: Node? = n
        if node!.left !== sentinel {
            /* One left, then keep on going right... */
            node = node!.left
            while node!.right !== sentinel {
                node = node!.right
            }
        } else {
            var parent = node!.parent
            while parent != nil && node === parent!.left {
                node = parent
                parent = parent!.parent;
            }
            node = parent
        }
        if node === sentinel {
            node = nil
        }
        return node
    }

    @usableFromInline
    internal func firstNode() -> Node? {
        if root === sentinel {
            return nil
        }

        var node = root

        while node.left !== sentinel {
            node = node.left!
        }
        return node
    }

    @usableFromInline
    internal func lastNode() -> Node? {
        if root === sentinel {
            return nil
        }

        var node = root

        while node.right !== sentinel {
            node = node.right!
        }
        return node
    }

    @inlinable
    public func select(_ rank: Int) -> Key {
        if rank < 0 || rank >= count {
            fatalError("argument to select() is invalid: \(rank)")
        }
        return select(root, rank)!
    }

    // Return key in BST rooted at x of given rank.
    // Precondition: rank is in legal range.
    @usableFromInline
    internal func select(_ x: Node, _ rank: Int) -> Key? {
        if (x === sentinel) {
            return nil
        }
        let leftSize = x.left!.count
        if leftSize > rank {
            return select(x.left!,  rank)
        } else if leftSize < rank {
            return select(x.right!, rank - leftSize - 1);
        } else {
            return x.key!
        }
    }

    /**
     * Return the number of keys in the symbol table strictly less than {@code key}.
     * @param key the key
     * @return the number of keys in the symbol table strictly less than {@code key}
     * @throws IllegalArgumentException if {@code key} is {@code null}
     */
    @inlinable
    public func rank(_ key: Key) throws -> Int {
        return try rank(key, root);
    }

    // number of keys less than key in the subtree rooted at x
    @usableFromInline
    internal func rank(_ key: Key, _ x: Node) throws -> Int {
        if x === sentinel {
            return 0
        }
        if try cmp(key, x.key!) {
            return try rank(key, x.left!)
        } else if try cmp(x.key!, key) {
            return try 1 + x.left!.count + rank(key, x.right!)
        } else {
            return x.left!.count
        }
    }

    @inlinable
    public var isEmpty: Bool {
        return root === sentinel
    }

    /***************************************************************************
     *  Check integrity of red-black tree data structure.
     ***************************************************************************/
    internal func check() -> Bool {
        // assert(try! isBST(), "Not in symmetric order")
        // assert(isSizeConsistent(), "Subtree counts not consistent")
        // assert(try! isRankConsistent(), "Ranks not consistent")
        // assert(is23(), "Not a 2-3 tree")
        // assert(isBalanced(), "Not balanced")
        // assert(isParentConsistent(), "Not parent consistent")
        return try! isBST() && isSizeConsistent() && isRankConsistent()
            && is23() && isBalanced() && isParentConsistent()
    }

    // does this binary tree satisfy symmetric order?
    // Note: this test also ensures that data structure is a binary tree since order is strict
    internal func isBST() throws -> Bool {
        return try isBST(root, nil, nil)
    }

    // is the tree rooted at x a BST with all keys strictly between min and max
    // (if min or max is null, treat as empty constraint)
    // Credit: Bob Dondero's elegant solution
    private func isBST(_ x: Node,
                       _ min: Key?,
                       _ max: Key?) throws -> Bool {
        if x === sentinel {
            return true
        }
        if try min != nil && !cmp(min!, x.key!) {
            return false
        }
        if try max != nil && !cmp(x.key!, max!) {
            return false
        }
        return try isBST(x.left!, min, x.key)
            && isBST(x.right!, x.key, max)
    }

    // are the size fields correct?
    private func isSizeConsistent() -> Bool {
        return isSizeConsistent(root)
    }

    private func isSizeConsistent(_ x: Node) -> Bool{
        if x === sentinel {
            return true
        }
        if x.count != x.left!.count + x.right!.count + 1 {
            return false
        }
        return isSizeConsistent(x.left!) && isSizeConsistent(x.right!)
    }

    // is parent consistent?
    private func isParentConsistent() -> Bool {
        return isParentConsistent(root)
    }

    internal func isParentConsistent(_ node: Node) -> Bool {
        var result = true
        if node.left !== sentinel {
            if node.left!.parent !== node || !isParentConsistent(node.left!) {
                result = false
            }
        }
        if node.right !== sentinel {
            if node.right!.parent !== node || !isParentConsistent(node.right!) {
                result = false
            }
        }
        return result
    }


    // check that ranks are consistent
    private func isRankConsistent() throws -> Bool {
        for i in (0..<count) {
            if try i != rank(select(i)) {
                return false
            }
        }
        for element in self {
            if try cmp(element.key, select(rank(element.key)))
                || cmp(select(rank(element.key)), element.key) {
                return false
            }
        }
        return true;
    }

    // Does the tree have no red right links, and at most one (left)
    // red links in a row on any path?
    private func is23() -> Bool {
        return is23(root)
    }

    private func is23(_ x: Node) -> Bool {
        if x === sentinel {
            return true
        }
        if x.right!.color == .red {
            return false
        }
        if x !== root && x.color == .red && x.left!.color == .red {
            return false;
        }
        return is23(x.left!) && is23(x.right!)
    }

    // do all paths from root to leaf have same number of black edges?
    private func isBalanced() -> Bool {
        var black = 0     // number of black links on path from root to min
        var x = root
        while x !== sentinel {
            if x.color == .black {
                black += 1
            }
            x = x.left!
        }
        return isBalanced(root, black);
    }

    // does every path from the root to a leaf have the given number of black links?
    private func isBalanced(_ x: Node, _ black: Int) -> Bool {
        var value = black
        if x === sentinel {
            return value == 0
        }
        if x.color == .black {
            value -= 1
        }
        return isBalanced(x.left!, value) && isBalanced(x.right!, value)
    }

    /// A view of a dictionary's keys.
    @frozen
    public struct Keys: Collection,
                        Equatable,
                        CustomStringConvertible,
                        CustomDebugStringConvertible {
        public typealias Element = Key
        public typealias SubSequence = Slice<RBDictionary.Keys>
        @usableFromInline internal let dictionary: RBDictionary

        @inlinable
        internal init(_dictionary: RBDictionary) {
            self.dictionary = _dictionary
        }

        // Collection Conformance
        // ----------------------
        @inlinable
        public var startIndex: Index {
            return dictionary.startIndex
        }

        @inlinable
        public var endIndex: Index {
            return dictionary.endIndex
        }

        @inlinable
        public func index(after i: Index) -> Index {
            return dictionary.index(after: i)
        }

        @inlinable
        public func formIndex(after i: inout Index) {
            return dictionary.formIndex(after: &i)
        }

        @inlinable
        public subscript(position: Index) -> Element {
            return position.node!.key!
        }

        @inlinable
        public func contains(_ key: Key) -> Bool {
            return dictionary.contains(key)
        }

        // Customization
        // -------------
        /// The number of keys in the dictionary.
        ///
        /// - Complexity: O(1).
        @inlinable
        public var count: Int {
            return dictionary.count
        }

        @inlinable
        public var isEmpty: Bool {
            return count == 0
        }

        @inlinable
        public static func == (lhs: Keys, rhs: Keys) -> Bool {
            // Equal if the two dictionaries share storage.
            if lhs.dictionary === rhs.dictionary {
                return true
            }
            // Not equal if the dictionaries are different sizes.
            if lhs.count != rhs.count {
                return false
            }

            // Perform unordered comparison of keys.
            for key in lhs {
                if !rhs.contains(key) {
                    return false
                }
            }

            return true
        }

        public var description: String {
            return Utils._makeCollectionDescription(self)
        }

        public var debugDescription: String {
            return Utils._makeCollectionDescription(self, withTypeName: "Dictionary.Keys")
        }
    }

    /// A view of a dictionary's values.
    @frozen
    public struct Values
    : MutableCollection, CustomStringConvertible, CustomDebugStringConvertible {
        public typealias Element = Value

        @usableFromInline internal let dictionary: RBDictionary

        @inlinable
        internal init(_dictionary: RBDictionary) {
            self.dictionary = _dictionary
        }

        // Collection Conformance
        // ----------------------
        @inlinable
        public var startIndex: Index {
            return dictionary.startIndex
        }

        @inlinable
        public var endIndex: Index {
            return dictionary.endIndex
        }

        @inlinable
        public func index(after i: Index) -> Index {
            return dictionary.index(after: i)
        }

        @inlinable
        public func formIndex(after i: inout Index) {
            dictionary.formIndex(after: &i)
        }

        @inlinable
        public subscript(position: Index) -> Element {
            // FIXME(accessors): Provide a _read
            get {
                return position.node!.value!
            }
            set(newValue) {
                position.node!.value = newValue
            }
        }

        @inlinable
        public var count: Int {
            return dictionary.count
        }

        @inlinable
        public var isEmpty: Bool {
            return count == 0
        }

        public var description: String {
            return Utils._makeCollectionDescription(self)
        }

        public var debugDescription: String {
            return Utils._makeCollectionDescription(self, withTypeName: "Dictionary.Values")
        }

        @inlinable
        public mutating func swapAt(_ i: Index, _ j: Index)  {
            swap(&i.node!.value, &j.node!.value)
        }
    }

    @inlinable
    public var keys: Keys {
        get {
            return Keys(_dictionary: self)
        }
    }

    @inlinable
    public var values: Values {
        get {
            return Values(_dictionary: self)
        }
    }
}

extension RBDictionary.Keys {
    @frozen
    public struct Iterator: IteratorProtocol {
        @usableFromInline
        internal var _base: RBDictionary<Key, Value>.Iterator

        @inlinable
        internal init(_ base: RBDictionary<Key, Value>.Iterator) {
            self._base = base
        }

        @inlinable
        public mutating func next() -> Key? {
            let following = _base.next()
            return following != nil ? following!.key : nil
        }
    }

    @inlinable
    public func makeIterator() -> Iterator {
        return Iterator(self.dictionary.makeIterator())
    }
}

extension RBDictionary.Values {
    @frozen
    public struct Iterator: IteratorProtocol {
        @usableFromInline
        internal var _base: RBDictionary<Key, Value>.Iterator

        @inlinable
        internal init(_ base: RBDictionary<Key, Value>.Iterator) {
            self._base = base
        }

        @inlinable
        public mutating func next() -> Value? {
            let following = _base.next()
            return following != nil ? following!.value : nil
        }
    }

    @inlinable
    public func makeIterator() -> Iterator {
        return Iterator(self.dictionary.makeIterator())
    }
}

extension RBDictionary: BidirectionalCollection {
    public struct Index {
        @usableFromInline internal var tree: RBDictionary
        @usableFromInline internal let node: RBDictionary.Node?

        @inlinable
        init(_ tree: RBDictionary, _ node: RBDictionary.Node) {
            self.tree = tree
            self.node = node
        }
    }

    @inlinable
    public subscript(idx: Index) -> Element {
        get {
            return Element(idx.node!.key!, idx.node!.value!)
        }
    }

    @inlinable
    public func get(idx: Int) -> Element {
        if idx < 0 || idx >= count {
            fatalError("Index out of bounds: \(idx)")
        }
        var node = root
        var offset = 0
        while true {
            let left = node.left!.count
            offset += left
            let cmp = idx - offset
            if cmp == 0 {
                return (node.key!, node.value!)
            } else if cmp < 0 {
                node = node.left!
                offset -= left
            } else {
                node = node.right!
                offset += 1
            }
        }
    }

    @inlinable
    public subscript(key: Key) -> Value? {
        get {
            let result = try! findLessEqual(key)
            return result.found ? result.node!.value! : nil
        }
        set(newValue) {
            _ = insert((key, newValue!))
        }
    }

    @inlinable
    public var startIndex:Index {
        return Index(self, firstNode()!)
    }

    @inlinable
    public var endIndex: Index {
        return Index(self, sentinel)
    }

    @inlinable
    public func index(after i: Index) -> Index {
        return Index(i.tree, next(i.node!) ?? i.tree.sentinel)
    }

    @inlinable
    public func index(before i: Index) -> Index {
        if i.node === i.tree.sentinel {
            return Index(i.tree, lastNode()!)
        }
        return Index(i.tree, previous(i.node!)!)
    }

    @inlinable
    public func index(forKey key: Key) -> Index? {
        let result = try? findLessEqual(key)
        if result != nil && result!.found {
            return Index(self, result!.node!)
        }
        return nil
    }
}

extension RBDictionary.Index: Comparable {
    @inlinable
    public static func == (lhs: RBDictionary.Index,
                           rhs: RBDictionary.Index) -> Bool {
        if lhs.node!.key == nil && rhs.node!.key == nil {
            return true
        }
        if lhs.node!.key != nil || rhs.node!.key != nil {
            return false
        }
        return try! !lhs.tree.cmp(lhs.node!.key!, rhs.node!.key!)
            && !rhs.tree.cmp(rhs.node!.key!, lhs.node!.key!)
    }

    @inlinable
    public static func < (lhs: RBDictionary.Index,
                          rhs: RBDictionary.Index) -> Bool {
        if lhs.node!.key == nil && rhs.node!.key != nil {
            return false
        }
        if lhs.node!.key != nil && rhs.node!.key == nil {
            return true
        }
        return try! lhs.tree.cmp(lhs.node!.key!, rhs.node!.key!)
    }
}

extension RBDictionary: Decodable where Key: Decodable, Key:Comparable, Value: Decodable {
}

extension RBDictionary: Sequence {
    public struct Iterator: IteratorProtocol {
        public typealias Element = (key: Key, value: Value)

        @usableFromInline internal var tree: RBDictionary<Key, Value>
        @usableFromInline internal var _next: RBDictionary<Key, Value>.Node?

        @inlinable
        internal init(_ tree: RBDictionary<Key, Value>) {
            self.tree = tree
            _next = tree.firstNode()
        }

        @inlinable
        public mutating func next() -> Element? {
            var lastResult: Element?
            if _next === tree.sentinel || _next == nil {
                lastResult = nil
                _next = nil
            } else {
                lastResult = Element(_next!.key!, _next!.value!)
                _next = tree.next(_next!)
            }
            // assert(_next !== tree.sentinel)
            return lastResult
        }
    }

    @inlinable
    public func makeIterator() -> Iterator {
        return Iterator(self)
    }

    @inlinable
    public  var underestimatedCount: Int {
        return count
    }

    @inlinable
    public var first: Element? {
        if root === sentinel {
            return nil
        }
        let result = firstNode()
        return result != nil ? (result!.key!, result!.value!) : nil
    }

    @inlinable
    public var last: Element? {
        if root === sentinel {
            return nil
        }
        let result = lastNode()
        return result != nil ? (result!.key!, result!.value!) : nil
    }

    @inlinable
    public func min() -> Element? {
        let result = firstNode()
        return result != nil ? (result!.key!, result!.value!) : nil
    }

    @inlinable
    public func max() -> Element? {
        let result = lastNode()
        return result != nil ? (result!.key!, result!.value!) : nil
    }
}

extension RBDictionary: Encodable where Key: Encodable,
                                        Value: Encodable {
    public func encode(to encoder: Encoder) throws where Key: Hashable {
        let dict = Dictionary<Key, Value>(uniqueKeysWithValues: self.map({($0.0, $0.1)}))
        try dict.encode(to: encoder)
    }

    public func encode(to encoder: Encoder) throws {
        let dict = Dictionary<HashableKey, Value>(uniqueKeysWithValues: self.map({(HashableKey(key: $0.0), $0.1)}))
        try dict.encode(to: encoder)
    }
}

extension RBDictionary.HashableKey: Decodable where Key: Decodable {
    @usableFromInline
    internal init(from decoder: Decoder) throws {
        key = try Key(from: decoder)
    }
}

extension RBDictionary.HashableKey: Encodable where Key: Encodable {
    @usableFromInline
    internal func encode(to encoder: Encoder) throws {
        try key.encode(to: encoder)
    }
}

extension RBDictionary: Equatable where Value: Equatable {
    @inlinable
    public static func == (lhs: RBDictionary, rhs: RBDictionary) -> Bool {
        // Equal if the two dictionaries share storage.
        if lhs === rhs {
            return true
        }
        // Not equal if the dictionaries are different sizes.
        if lhs.count != rhs.count {
            return false
        }

        // Perform unordered comparison of keys.
        for (lItem, rItem) in zip(lhs, rhs) {
            if try! lhs.cmp(lItem.key, rItem.key) || rhs.cmp(rItem.key, lItem.key) ||
                lItem.value != rItem.value {
                return false
            }
        }

        return true
    }
}

extension RBDictionary: ExpressibleByDictionaryLiteral where Key: Comparable {
}

extension RBDictionary: CustomStringConvertible {
    public var description: String {
        return Utils._makeKeyValuePairDescription(self)
    }
}

extension RBDictionary: CustomDebugStringConvertible {
    public var debugDescription: String {
        return Utils._makeKeyValuePairDescription(self, withTypeName: "RBDictionary")
    }
}

extension RBDictionary: CustomReflectable {
    public var customMirror: Mirror {
        let style = Mirror.DisplayStyle.dictionary
        return Mirror(self, unlabeledChildren: self, displayStyle: style)
    }
}
