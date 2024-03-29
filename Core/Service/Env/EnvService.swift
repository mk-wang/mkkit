//
//  EnvService.swift
//  MKKit
//
//  Created by MK on 2023/7/25.
//

import Foundation
import OpenCombine
import OpenCombineFoundation
import UIKit

// MARK: - EnvService

public class EnvService {
    private var cancellableSet = Set<AnyCancellable>()

    private let is12HourTZSubject = CurrentValueSubject<Bool, Never>(Locale.current.is12Hour)
    public lazy var is12HourTZPubliser = is12HourTZSubject.removeDuplicates().eraseToAnyPublisher()

    public lazy var timeService = TimeService()
    public init() {}

    public var is12HourTimeZone: Bool {
        is12HourTZSubject.value
    }
}

private extension EnvService {
    func onLocalChange() {
        is12HourTZSubject.value = Locale.current.is12Hour
    }
}

// MARK: AppSerivce

extension EnvService: AppSerivce {
    public func initBeforeWindow() {
        NotificationCenter.default.ocombine
            .publisher(for: NSLocale.currentLocaleDidChangeNotification)
            .sink { [weak self] _ in
                self?.onLocalChange()
            }.store(in: &cancellableSet)
    }

    public func initAfterWindow(window _: UIWindow) {}
    public func onExit() {}
}
