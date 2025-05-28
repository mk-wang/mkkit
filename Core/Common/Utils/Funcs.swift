//
//  Funcs.swift
//
//
//  Created by MK on 2022/3/18.
//

public typealias ValueBuilder<R> = () -> R
public typealias ValueBuilder1<R, T> = (T) -> R
public typealias ValueBuilder2<R, T1, T2> = (T1, T2) -> R
public typealias ValueBuilder3<R, T1, T2, T3> = (T1, T2, T3) -> R
public typealias ValueBuilder4<R, T1, T2, T3, T4> = (T1, T2, T3, T4) -> R
public typealias ValueBuilder5<R, T1, T2, T3, T4, T5> = (T1, T2, T3, T4, T5) -> R
public typealias ValueBuilder6<R, T1, T2, T3, T4, T5, T6> = (T1, T2, T3, T4, T5, T6) -> R

public typealias VoidFunction = ValueBuilder<Void>
public typealias VoidFunction1<T> = ValueBuilder1<Void, T>
public typealias VoidFunction2<T1, T2> = ValueBuilder2<Void, T1, T2>
public typealias VoidFunction3<T1, T2, T3> = ValueBuilder3<Void, T1, T2, T3>
public typealias VoidFunction4<T1, T2, T3, T4> = ValueBuilder4<Void, T1, T2, T3, T4>
public typealias VoidFunction5<T1, T2, T3, T4, T5> = ValueBuilder5<Void, T1, T2, T3, T4, T5>
public typealias VoidFunction6<T1, T2, T3, T4, T5, T6> = ValueBuilder6<Void, T1, T2, T3, T4, T5, T6>

@inline(__always)
public func isNotEmpty(_ object: (some Collection)?) -> Bool {
    !isEmpty(object)
}

@inline(__always)
public func isEmpty(_ object: (some Collection)?) -> Bool {
    object?.isEmpty ?? true
}

@inline(__always)
public func len(_ object: (some Collection)?) -> Int {
    object?.count ?? 0
}

@inline(__always)
public func valueFor<T>(simulator: @autoclosure ValueBuilder<T>,
                        device: @autoclosure ValueBuilder<T>) -> T
{
    #if targetEnvironment(simulator)
        return simulator()
    #else
        return device()
    #endif
}

@inline(__always)
public func valueFor<T>(predicat: ValueBuilder<T?>,
                        otherwise: @autoclosure ValueBuilder<T>) -> T
{
    predicat() ?? otherwise()
}

@inline(__always)
public func valueFor<T>(debugBuild value: @autoclosure ValueBuilder<T>,
                        otherwise: @autoclosure ValueBuilder<T>) -> T
{
    #if DEBUG_BUILD
        return value()
    #else
        return otherwise()
    #endif
}

@inline(__always)
public func valueFor<T>(debug value: @autoclosure ValueBuilder<T>,
                        otherwise: @autoclosure ValueBuilder<T>) -> T
{
    #if DEBUG
        return value()
    #else
        return otherwise()
    #endif
}

/// Traverses a tree or graph structure starting from the root node.
/// - Parameters:
///   - root: The root node to start the traversal from.
///   - bfs: A boolean indicating whether to use breadth-first search (true) or depth-first search (false).
///   - visitor: A closure that takes a node and returns its child nodes. return nil to end the traversal.
public func visit<T>(root: T, bfs: Bool, visitor: (T) -> [T]?) {
    var list: [T] = [root]

    while !list.isEmpty {
        // BFS: Remove the first element, DFS: Remove the last element
        let current = bfs ? list.removeFirst() : list.removeLast()

        guard let nextItems = visitor(current) else {
            break
        }

        if bfs {
            list.append(contentsOf: nextItems)
        } else {
            // Reverse for DFS order
            list.append(contentsOf: nextItems.reversed())
        }
    }
}
