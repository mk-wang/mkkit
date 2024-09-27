//
//  ArrayExt.swift
//
//
//  Created by MK on 2021/6/16.
//

import Foundation

public extension Array {
    init<S>(_ s: S, prefix value: Int) where Element == S.Element, S: Sequence {
        self.init(s.prefix(value))
    }

    init<S>(_ s: S, suffix value: Int) where Element == S.Element, S: Sequence {
        self.init(s.suffix(value))
    }
}

public extension Array {
    func at(_ index: Int) -> Element? {
        guard index >= 0, index < count else {
            return nil
        }
        return self[index]
    }

    func indexOf(next: Bool, from index: Int) -> Int {
        var target = index
        if next {
            target += 1
        } else {
            target -= 1
        }

        if target >= count {
            target = 0
        } else if target < 0 {
            target = count - 1
        }
        return target
    }

    func expand(header: Bool = false,
                tail: Bool = false,
                by sepBuilder: () -> Element) -> [Element]
    {
        var list = [Element]()
        for (index, element) in enumerated() {
            if header || index != 0 {
                list.append(sepBuilder())
            }
            list.append(element)
        }
        if tail {
            list.append(sepBuilder())
        }
        return list
    }

    mutating func removeFirst(where predicate: (Self.Element) throws -> Bool) {
        guard let index = try? firstIndex(where: predicate) else {
            return
        }
        remove(at: index)
    }

    func randomPick() -> Element? {
        guard isNotEmpty else {
            return nil
        }

        let index = Int.random(in: 0 ..< count)
        return at(index)
    }
}

public extension Array where Element: Equatable {
    func element(next: Bool, by source: Element) -> Element? {
        guard let index = firstIndex(of: source) else {
            return nil
        }
        let targetIndex = indexOf(next: next, from: index)
        return at(targetIndex)
    }
}

// https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks
public extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
