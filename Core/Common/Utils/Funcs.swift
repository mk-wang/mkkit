//
//  Funcs.swift
//
//
//  Created by MK on 2022/3/18.
//

import UIKit

public typealias ValueBuilder<T> = () -> T
public typealias VoidFunction = ValueBuilder<Void>
public typealias ViewControllerBuilder = ValueBuilder<UIViewController>

public func isNotEmpty(_ object: (some Collection)?) -> Bool {
    !isEmpty(object)
}

public func isEmpty(_ object: (some Collection)?) -> Bool {
    object?.isEmpty ?? true
}

public func len(_ object: (some Collection)?) -> Int {
    object?.count ?? 0
}
