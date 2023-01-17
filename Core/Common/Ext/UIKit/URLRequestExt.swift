//
//  URLRequestExt.swift
//  MKKit
//
//  Created by MK on 2023/1/16.
//

import UIKit

extension URLRequest {
    mutating func addBasicAuth(userName: String, password: String) {
        let loginStr = "\(userName):\(password)"
        if let base64Str = loginStr.utf8Base64Str {
            setValue("Basic \(base64Str)", forHTTPHeaderField: "Authorization")
        }
    }
}
