//
//  File.swift
//  
//
//  Created by José María Gómez Cama on 26/09/2020.
//

import Foundation

public final class Utils {
    @usableFromInline
    internal static func _makeCollectionDescription<S>(
        _ values: S,
        withTypeName type: String? = nil
    ) -> String where S: Sequence{
        var result = ""
        if let type = type {
            result += "\(type)(["
        } else {
            result += "["
        }

        var first = true
        for item in values {
            if first {
                first = false
            } else {
                result += ", "
            }
            debugPrint(item, terminator: "", to: &result)
        }
        result += type != nil ? "])" : "]"
        return result
    }

    @usableFromInline
    internal static func _makeKeyValuePairDescription<D, K, V>(
        _ values: D,
        withTypeName type: String? = nil
    ) -> String where D:Collection, D.Element == (key: K, value: V) {
        if values.isEmpty {
            if type != nil {
                return "\(type!)()"
            } else {
                return "[:]"
            }
        }

        var result = type == nil ? "[" : "\(type!)(["
        var first = true
        for (k, v) in values {
            if first {
                first = false
            } else {
                result += ", "
            }
            debugPrint(k, terminator: "", to: &result)
            result += ": "
            debugPrint(v, terminator: "", to: &result)
        }
        result += type == nil ? "]" : "])"
        return result
    }
}
