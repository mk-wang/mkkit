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

    private let is12HourTZSubject: CurrentValueSubject<Bool, Never>
    public lazy var is12HourTZPubliser = is12HourTZSubject.removeDuplicates().eraseToAnyPublisher()

    public private(set) var amPmString: String? // am / pm

    public lazy var timeService = TimeService()
    public init() {
        let locale = Locale.current
        let is12Hour = locale.is12Hour
        is12HourTZSubject = .init(is12Hour)
        self.amPmString = is12Hour ? locale.amPmString : nil
    }

    public var is12HourTimeZone: Bool {
        is12HourTZSubject.value
    }
}

private extension EnvService {
    func onLocalChange() {
        let locale = Locale.current
        let is12Hour = locale.is12Hour
        self.amPmString = is12Hour ? locale.amPmString : nil
        is12HourTZSubject.value = is12Hour
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
}
