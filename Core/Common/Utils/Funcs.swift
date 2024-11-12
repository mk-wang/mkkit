//
//  Funcs.swift
//
//
//  Created by MK on 2022/3/18.
//

import UIKit

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
public func valueForEnvironment<T>(simulatorValue: T, deviceValue: T) -> T {
    #if targetEnvironment(simulator)
        return simulatorValue
    #else
        return deviceValue
    #endif
}

@inline(__always)
public func valueForBuild<T>(debugValue: T, releaseValue: T) -> T {
    #if DEBUG_BUILD
        return debugValue
    #else
        return releaseValue
    #endif
}
