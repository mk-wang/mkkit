//
//  GCCalendarWeekView.swift
//  GCCalendar
//
//  Created by Gray Campbell on 1/29/16.
//

import UIKit

// MARK: - GCCalendarWeekView

open class GCCalendarWeekView: UIView {
    // MARK: Properties

    public let configuration: GCCalendarConfiguration!
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer!

    fileprivate lazy var stackView: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = configuration.itemSpacing
        return view
    }()

    public var dayViews: [GCCalendarDayView] {
        stackView.arrangedSubviews as! [GCCalendarDayView]
    }

    private(set) var dates: [Date?] = []

    private(set) var month: Int?

    open func update(dates: [Date?], month: Int? = nil) {
        self.month = month
        self.dates = dates

        if dayViews.isEmpty {
            for _ in 0 ..< dates.count {
                let dayView = configuration.dayConfig.viewBuilder?(configuration)
                    ?? GCCalendarDayView(frame: .zero, configuration: configuration)
                stackView.addArrangedSubview(dayView)
            }
        }

        updateDayViews()
    }

    open func contains(date: Date) -> Bool {
        dates.contains(where: { [weak self] dayDate in
            guard let self, let dayDate else {
                return false
            }
            return configuration.calendar.isDate(dayDate, equalTo: date, toGranularity: .weekOfYear)
        })
    }

    // MARK: Initializers

    public init(frame: CGRect, configuration: GCCalendarConfiguration) {
        self.configuration = configuration
        super.init(frame: frame)

        addSubview(stackView)

        let xPad = configuration.xPad
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: xPad),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -xPad),
        ])

        stackView.isUserInteractionEnabled = !configuration.weekConfig.selectByWeek
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        stackView.layoutIfNeeded()
        updateDayViews()
    }
}

// MARK: - Day Views

public extension GCCalendarWeekView {
    @discardableResult
    @objc open func updateDayViews() -> Bool {
        guard !bounds.isEmpty, !dayViews.isEmpty else {
            return false
        }

        for (index, date) in dates.enumerated() {
            let dayView = dayViews[index]
            dayView.update(weekIndex: index, date: date, month: month)
        }
        return true
    }
}

// MARK: - Pan Gesture Recognizer

extension GCCalendarWeekView {
    @discardableResult
    func addPanGestureRecognizer(target: Any?, action: Selector?) -> UIPanGestureRecognizer {
        panGestureRecognizer = UIPanGestureRecognizer(target: target, action: action)
        addGestureRecognizer(panGestureRecognizer)
        return panGestureRecognizer
    }
}

// MARK: - Selected Date

extension GCCalendarWeekView {
    func selectDay(date: Date? = nil, hasCurrent: Bool) -> GCCalendarDayView? {
        let calendar = configuration.calendar

        if let newDate = date {
            for dayView in dayViews {
                guard let dayViewDate = dayView.date else { continue }

                if calendar.isDate(dayViewDate, inSameDayAs: newDate) {
                    return dayView
                }
            }
            return nil
        }

        guard let selectedDate = (configuration as? InnerCalendarConfiguration)?.selectedDate,
              let selectedDateWeekday = calendar.dateComponents([.weekday], from: selectedDate).weekday
        else {
            return nil
        }

        let checkCurrent = hasCurrent && !configuration.canSelectFuture
        let now = Date()
        for dayView in dayViews {
            guard let dayViewDate = dayView.date else { continue }

            if checkCurrent, calendar.isDate(dayViewDate, inSameDayAs: now) {
                return dayView
            }

            let dayViewDateComponents = calendar.dateComponents([.weekday], from: dayViewDate)

            guard let dayViewDateWeekday = dayViewDateComponents.weekday else { continue }

            if dayViewDateWeekday == selectedDateWeekday {
                return dayView
            }
        }

        return nil
    }

    func select(date: Date? = nil, hasCurrent: Bool = false) {
        guard let dayView = selectDay(date: date, hasCurrent: hasCurrent) else {
            return
        }
        dayView.selected()
    }
}
