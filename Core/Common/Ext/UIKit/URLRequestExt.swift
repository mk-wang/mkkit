//
//  URLRequestExt.swift
//  MKKit
//
//  Created by MK on 2023/1/16.
//

import UIKit

public extension URLRequest {
    var authorizationHeader: String? {
        value(forHTTPHeaderField: "Authorization") as? String
    }

    mutating func addBasicAuth(userName: String, password: String) {
        let loginStr = "\(userName):\(password)"
        if let base64Str = loginStr.utf8Base64Str {
            setValue("Basic \(base64Str)", forHTTPHeaderField: "Authorization")
        }
    }
}

public extension NSMutableURLRequest {
    func addBasicAuth(userName: String, password: String) {
        let loginStr = "\(userName):\(password)"
        if let base64Str = loginStr.utf8Base64Str {
            setValue("Basic \(base64Str)", forHTTPHeaderField: "Authorization")
        }
    }
}
