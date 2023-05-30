//
//  AnyExt.swift
//  MKKit
//
//  Created by MK on 2023/5/30.
//

import Foundation

public func debugType(_ instance: Any) -> String {
    String(describing: type(of: instance))
}

public func debugAddress(_ instance: AnyObject) -> String {
    "\(Unmanaged.passUnretained(instance).toOpaque())"
}
