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

    func addSnpSize(_ size: CGSize) {
        addSnpConfig {
            $1.size.equalTo(size)
        }
    }

    func addSnpEdgesToSuper(_ inset: UIEdgeInsets = .zero) {
        addSnpConfig {
            $1.edges.equalToSuperview().inset(inset)
        }
    }

    func addSnpMKEdgesToSuper(_ inset: MKEdgeInsets) {
        addSnpConfig {
            if let inset = inset.start {
                $1.leading.equalToSuperview().inset(inset)
            }
            if let inset = inset.end {
                $1.trailing.equalToSuperview().inset(inset)
            }
            if let inset = inset.top {
                $1.top.equalToSuperview().inset(inset)
            }
            if let inset = inset.bottom {
                $1.bottom.equalToSuperview().inset(inset)
            }
        }
    }

    func addSnpHorizontalEdgesToSuper(_ inset: CGFloat = 0) {
        addSnpConfig {
            $1.horizontalEdges.equalToSuperview().inset(inset)
        }
    }

    func addSnpVerticalEdgesToSuper(_ inset: CGFloat = 0) {
        addSnpConfig {
            $1.verticalEdges.equalToSuperview().inset(inset)
        }
    }

    func addSnpCenterToSuper(x: Bool = true, y: Bool = true) {
        addSnpConfig {
            if x {
                $1.centerX.equalToSuperview()
            }
            if y {
                $1.centerY.equalToSuperview()
            }
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
