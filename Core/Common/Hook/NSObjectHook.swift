//
//  NSObject.swift
//
//
//  Created by MK on 2021/5/30.
//

import Foundation
/*
 import UIKit
 extension UIViewController {
     class func hookVC() {
         UIViewController.yxSwizzle(original: #selector(viewWillAppear(_:)),
                                    holder: VCHookHelper.holder)
     }
 }

 // MARK: - VCHookHelper

 enum VCHookHelper {
     typealias ClosureType = @convention(c) (UIViewController, Selector, Bool) -> Void

     static var myImp: ClosureType = {
         vc, sel, animated in
         print("before ")
         let c = VCHookHelper.holder.storedFunc!
         c(vc, sel, animated)
         print("after ")
     }

     static var holder = YXHookHolder(replace: myImp)
 }

 */

public extension NSObject {
    @discardableResult class func yxSwizzle(original: Selector, holder: YXHookHolder<some Any>) -> Bool {
        holder.storeIMP = swizzleMethod(clz: Self.self,
                                        original: original,
                                        replacement: holder.replaceImp)
        return holder.storeIMP != nil
    }
}

// MARK: - YXHookHolder

open class YXHookHolder<F> {
    private var replace: F
    fileprivate var storeIMP: IMP?

    public init(replace: F) {
        self.replace = replace
    }

    public var replaceImp: IMP {
        unsafeBitCast(replace, to: IMP.self)
    }

    public var storedFunc: F? {
        unsafeBitCast(storeIMP, to: F.self)
    }
}

private func swizzleMethod(clz: AnyClass, original: Selector, replacement: IMP) -> IMP? {
    var imp: IMP?
    if let method = class_getInstanceMethod(clz, original) {
        let type = method_getTypeEncoding(method)
        imp = class_replaceMethod(clz, original, replacement, type)
        if imp == nil {
            imp = method_getImplementation(method)
        }
    }
    return imp
}
