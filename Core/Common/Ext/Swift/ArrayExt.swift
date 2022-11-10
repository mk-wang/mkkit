//
//  ArrayExt.swift
//  YogaWorkout
//
//  Created by MK on 2021/6/16.
//

import Foundation

public extension Array {
    func at(_ index: Int) -> Element? {
        guard index >= 0, index < count else {
            return nil
        }
        return self[index]
    }
}
