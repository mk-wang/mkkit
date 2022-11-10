//
//  AppStage.swift
//
//  Created by MK on 2021/8/30.
//

import Foundation
import UIKit

// MARK: - AppSerivce

public protocol AppSerivce {
    func initBeforeWindow()
    func initAfterWindow(window: UIWindow)
    func onExit()
}
