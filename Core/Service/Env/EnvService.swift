//
//  EnvService.swift
//  MKKit
//
//  Created by MK on 2023/7/25.
//

import Foundation

#if canImport(OpenCombine)
    import OpenCombine
#elseif canImport(Combine)
    import Combine
#endif

import UIKit

// MARK: - EnvService

public class EnvService {
    private var cancellableSet = Set<AnyCancellable>()

    private let is12HourTZSubject: CurrentValueSubject<Bool, Never>
    public lazy var is12HourTZPubliser = is12HourTZSubject.removeDuplicates().eraseToAnyPublisher()

    public private(set) var amPmStrings: [String]? // am / pm

    public lazy var timeService = TimeService()
    public init() {
        let locale = Locale.current
        let is12Hour = locale.is12Hour
        is12HourTZSubject = .init(is12Hour)
        amPmStrings = is12Hour ? locale.amPmStrings : nil
    }

    public var is12HourTimeZone: Bool {
        is12HourTZSubject.value
    }
}

private extension EnvService {
    func onLocalChange() {
        let locale = Locale.current
        let is12Hour = locale.is12Hour
        amPmStrings = is12Hour ? locale.amPmStrings : nil
        is12HourTZSubject.value = is12Hour
    }
}

// MARK: AppSerivce

extension EnvService: AppSerivce {
    public func initBeforeWindow() {
        notificationCenter
            .publisher(for: NSLocale.currentLocaleDidChangeNotification)
            .sink { [weak self] _ in
                self?.onLocalChange()
            }.store(in: &cancellableSet)
    }
}
