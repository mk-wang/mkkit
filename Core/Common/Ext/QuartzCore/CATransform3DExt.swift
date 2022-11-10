//
//  XX.swift
//  YogaWorkout
//
//  Created by MK on 2021/5/26.
//

import QuartzCore

extension CATransform3D {
    var rotate: CGFloat {
        atan2(m12, m11)
    }
}
