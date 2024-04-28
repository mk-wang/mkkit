//
//  URLResponseExt.swift
//  MKKit
//
//  Created by MK on 2024/4/28.
//

import Foundation
import UIKit

public extension URLResponse {
    var httpStatusCode: Int? {
        (self as? HTTPURLResponse)?.statusCode
    }
}
