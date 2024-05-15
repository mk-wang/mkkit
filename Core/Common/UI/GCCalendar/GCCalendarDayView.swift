//
//  GCCalendarDayView.swift
//  GCCalendar
//
//  Created by Gray Campbell on 1/29/16.
//

import UIKit

// MARK: - GCCalendarDateType

public enum GCCalendarDateType {
    case none
    case current
    case past
    case future
}

// MARK: - GCCalendarDayView

open class GCCalendarDayView: UIView {
    // MARK: Properties

    public let configuration: GCCalendarConfiguration

    public fileprivate(set) var dateType: GCCalendarDateType = .none {
        didSet {
            updateDay()
        }
    }

    public private(set) lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(selected))
        return gesture
    }()

    lazy var dateFormatter: DateFormatter = {
        let fmt = DateFormatter()

        fmt.calendar = calendar
        fmt.dateFormat = DateFormatter.dateFormat(fromTemplate: "d", options: 0, locale: calendar.locale)

        return fmt
    }()

    public private(set) var month: Int?
    public private(set) var date: Date?
    public private(set) var weekday: Int = 1
    public private(set) var weekIndex: Int = 0
    public private(set) var isAdjacentMonth: Bool = false
    public private(set) var isSelected: Bool = false

    // MARK: Initializers

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var envService: EnvService? {
        MKAppDelegate.shared?.findService()
    }

    public init(frame: CGRect, configuration: GCCalendarConfiguration) {
        self.configuration = configuration
        super.init(frame: frame)
        addTapGestureRecognizer()

        envService?.timeService.dayPublisher.dropFirst().sink { [weak self] _ in
            self?.updateDateType()
        }.store(in: &combineInfo.cancellableSet)
    }
}

// MARK: - Button

extension GCCalendarDayView {
    func update(weekIndex: Int, date: Date?, month: Int? = nil) {
        self.weekIndex = weekIndex
        weekday = configuration.weekday(of: weekIndex)
        self.month = month
        self.date = date

        updateDateType()
    }

    public func updateDateType() {
        defer {
            configuration.dayConfig.viewConfig?(self)
        }

        guard let date else {
            dateType = .none
            return
        }
        isAdjacentMonth = month == nil || calendar.component(.month, from: date) != month!

        if calendar.isDateInToday(date) {
            dateType = .current
        } else if date < Date() {
            dateType = .past
        } else {
            dateType = .future
        }
    }
}

private extension GCCalendarDayView {
    var innerConfiguration: InnerCalendarConfiguration? {
        configuration as? InnerCalendarConfiguration
    }
}

public extension GCCalendarDayView {
    var isToday: Bool {
        dateType == .current
    }

    var title: String? {
        guard dateType != .none, let date else {
            return nil
        }

        return dateFormatter.string(from: date)
    }

    var calendar: Calendar {
        configuration.calendar
    }

    func contentView<T: UIView>(addIfNotfound: (GCCalendarDayView) -> T) -> T {
        let list = subviews
        var contentView = list.first as? T
        if contentView == nil {
            if !list.isEmpty {
                list.forEach { $0.removeFromSuperview() }
            }
            contentView = addIfNotfound(self)
        }
        return contentView!
    }

    @objc open func updateDay() {
        isUserInteractionEnabled = dateType != .none
        if let date, let innerConfiguration, innerConfiguration.isSelectedDay(date: date) {
            selected()
        } else {
            unselected()
        }
    }

    @discardableResult
    @objc open func selected() -> Bool {
        guard dateType != .past || configuration.pastDatesEnabled else {
            return false
        }

        guard configuration.canSelectFuture || dateType != .future else {
            return false
        }

        isSelected = true
        innerConfiguration?.selectDayView(self)
        return true
    }

    @objc open func unselected() {
        isSelected = false
    }

    @objc open func addTapGestureRecognizer() {
        addGestureRecognizer(tapGestureRecognizer)
    }
}

// MARK: GCCalendarDayView.SimpleDayView

extension GCCalendarDayView {
    class SimpleDayView: GCCalendarDayView {
        lazy var lbl: UILabel = {
            let lbl = UILabel()
            lbl.font = .systemFont(ofSize: 18)
            lbl.textAlignment = .center
            return lbl
        }()

        override init(frame: CGRect, configuration: GCCalendarConfiguration) {
            super.init(frame: frame, configuration: configuration)
            addSubview(lbl)

            lbl.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                lbl.centerXAnchor.constraint(equalTo: centerXAnchor),
                lbl.centerYAnchor.constraint(equalTo: centerYAnchor),
                lbl.widthAnchor.constraint(equalToConstant: 36),
                lbl.heightAnchor.constraint(equalToConstant: 36),
            ])
        }

        override func updateDay() {
            super.updateDay()
            lbl.text = title
        }

        override func selected() -> Bool {
            guard super.selected() else {
                return false
            }

            updateUI(selected: true)

            return true
        }

        override func unselected() {
            updateUI(selected: false)
        }

        func updateUI(selected: Bool) {
            guard !selected else {
                lbl.textColor = .red
                return
            }

            guard !isAdjacentMonth else {
                lbl.textColor = .gray
                return
            }

            switch dateType {
            case .none:
                lbl.textColor = .clear
            case .current:
                lbl.textColor = .green
            case .past:
                lbl.textColor = .black
            case .future:
                lbl.textColor = .black
            }
        }
    }
}
