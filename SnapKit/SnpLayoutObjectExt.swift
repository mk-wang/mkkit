//
//  SnpLayoutObjectExt.swift
//  MKKit
//
//  Created by MK on 2023/7/24.
//

import Foundation
import SnapKit
import UIKit

public extension SnpLayoutObject {
    // ratio = width / height
    func addSnpAspectRatio(_ ratio: CGFloat, config: SnapKitConfigure? = nil) {
        addSnpConfig { [unowned(unsafe) self] in
            $1.width.equalTo(snpDSL.height).multipliedBy(ratio)
            config?($0, $1)
        }
    }
}

public extension UIImageView {
    func snpFitImage() {
        guard let size = image?.size else {
            return
        }
        addSnpAspectRatio(size.width / size.height)
    }
}
