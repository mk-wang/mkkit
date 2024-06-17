//
//  TowLabelBox.swift
//
//  Created by MK on 2023/9/13.
//

import MKKit
import UIKit

open class TowLabelBox: MKBaseView {
    public struct Config {
        let topStyle: TextViewStyle
        let bottomStyle: TextViewStyle
        let yPad: CGFloat

        public init(topStyle: TextViewStyle, bottomStyle: TextViewStyle, yPad: CGFloat = 0) {
            self.topStyle = topStyle
            self.bottomStyle = bottomStyle
            self.yPad = yPad
        }
    }

    public let topLbl: UILabel
    public let bottomLbl: UILabel
    public let config: Config

    public let layoutBlock: ((TowLabelBox, UILabel, UILabel) -> Void)?

    public init(frame: CGRect, config: Config, layoutBlock: ((TowLabelBox, UILabel, UILabel) -> Void)? = nil) {
        self.config = config
        self.layoutBlock = layoutBlock
        topLbl = .init(text: "", style: config.topStyle)
        bottomLbl = .init(text: "", style: config.bottomStyle)
        super.init(frame: frame)
    }

    override open func readyToLayout() {
        if let layoutBlock {
            layoutBlock(self, topLbl, bottomLbl)
        } else {
            addSnpStackSubviews(.vertical,
                                builders: [
                                    .view(topLbl, crossEdgesInset: 0),
                                    .space(config.yPad),
                                    .view(bottomLbl, crossEdgesInset: 0),
                                ])
        }
    }

    open func reset() {
        topLbl.text = nil
        bottomLbl.text = nil
    }
}
