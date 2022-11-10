//
//  SelfLoader.swift
//
//
//  Created by MK on 2022/3/16.
//

import Foundation

//
// 利用 objc 运行时做自启动
// 如果定义了
// extension SelfLoader {
//     @objc class func _load_RegisterXXX() {
//
//     }
// }
//
// 那么在 app 启动的时候调用 SelfLoader.loadAll(), 就会执行 SelfLoader._load_Foo()
//
public class SelfLoader: NSObject {
    static let loadKey = "_load_"

    public class func loadAll() {
        var count: UInt32 = 0

        guard let clz = object_getClass(self),
              let methodList = class_copyMethodList(clz, &count)
        else {
            return
        }

        for idx in 0 ..< Int(count) {
            let method = methodList[idx]
            let sel = method_getName(method)
            let name = String(_sel: sel)
            if name.starts(with: loadKey) {
                perform(sel)
            }
        }

        free(methodList)
    }
}
