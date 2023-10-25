//
//  Funcs.swift
//
//
//  Created by MK on 2022/3/18.
//

import UIKit

public typealias ValueBuilder<R> = () -> R
public typealias ValueBuilder1<T, R> = (T) -> R
public typealias ValueBuilder2<T1, T2, R> = (T1, T2) -> R
public typealias ValueBuilder3<T1, T2, T3, R> = (T1, T2, T3) -> R
public typealias ValueBuilder4<T1, T2, T3, T4, R> = (T1, T2, T3, T4) -> R
public typealias ValueBuilder5<T1, T2, T3, T4, T5, R> = (T1, T2, T3, T4, T5) -> R
public typealias ValueBuilder6<T1, T2, T3, T4, T5, T6, R> = (T1, T2, T3, T4, T5, T6) -> R

public typealias VoidFunction = ValueBuilder<Void>
public typealias VoidFunction1<T> = ValueBuilder1<T, Void>
public typealias VoidFunction2<T1, T2> = ValueBuilder2<T1, T2, Void>
public typealias VoidFunction3<T1, T2, T3> = ValueBuilder3<T1, T2, T3, Void>
public typealias VoidFunction4<T1, T2, T3, T4> = ValueBuilder4<T1, T2, T3, T4, Void>
public typealias VoidFunction5<T1, T2, T3, T4, T5> = ValueBuilder5<T1, T2, T3, T4, T5, Void>
public typealias VoidFunction6<T1, T2, T3, T4, T5, T6> = ValueBuilder6<T1, T2, T3, T4, T5, T6, Void>

public func isNotEmpty(_ object: (some Collection)?) -> Bool {
    !isEmpty(object)
}

public func isEmpty(_ object: (some Collection)?) -> Bool {
    object?.isEmpty ?? true
}

public func len(_ object: (some Collection)?) -> Int {
    object?.count ?? 0
}
