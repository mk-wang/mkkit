//
//  GCCalendarMonthView.swift
//  GCCalendar
//
//  Created by Gray Campbell on 1/28/16.
//

import UIKit

// MARK: - GCCalendarMonthView

final class GCCalendarMonthView: UIView {
    // MARK: Properties

    let configuration: GCCalendarConfiguration!
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer!

    fileprivate var weekViews: [GCCalendarWeekView] {
        stackView.arrangedSubviews as! [GCCalendarWeekView]
    }

    fileprivate lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = configuration.weekSpacing
        return stackView
    }()

    var startDate: Date! {
        didSet {
            guard let startDate else {
                startMonth = -1
                return
            }

            startMonth = configuration.calendar.component(.month, from: startDate)
            let viewCount = stackView.arrangedSubviews.count
            let allDates = makeAllDates()
            let datesCount = allDates.count
            let max = max(datesCount, viewCount)

            for index in 0 ..< max {
                var weekView = stackView.arrangedSubviews.at(index) as? GCCalendarWeekView
                if weekView == nil {
                    weekView = configuration.weekConfig.viewBuilder?(configuration)
                        ?? GCCalendarWeekView(frame: .zero, configuration: configuration)
                    stackView.addArrangedSubview(weekView!)
                }

                let dates: [Date?] = allDates.at(index) ?? emptyDates
                weekView?.update(dates: dates, month: startMonth)
            }
        }
    }

    fileprivate var startMonth: Int?

    func contains(date: Date) -> Bool {
        configuration.calendar.isDate(startDate, equalTo: date, toGranularity: .month)
    }

    // MARK: Initializers

    init(frame: CGRect, configuration: GCCalendarConfiguration) {
        self.configuration = configuration
        super.init(frame: frame)

        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//        if stackView.superview == nil {
//        }
//    }
}

private extension GCCalendarMonthView {
    func makeAllDates() -> [[Date?]] {
        guard let startDate else {
            return []
        }

        var list: [[Date?]] = []

        let calendar = configuration.calendar

        let weekday = calendar.ordinality(of: .weekday, in: .weekOfMonth, for: startDate)! - 1
        var date = weekday == 0 ? startDate : calendar.date(byAdding: .day, value: -weekday, to: startDate)!
        var month = calendar.component(.month, from: date)
        repeat {
            var dates: [Date?] = []
            for _ in 0 ..< configuration.numberOfWeekdays {
                dates.append(date)

                date = calendar.date(byAdding: .day, value: 1, to: date)!
                month = calendar.component(.month, from: date)
            }
            list.append(dates)
        } while month == startMonth

        for _ in 0 ..< configuration.maxWeekOfMonth - list.count {
            list.append(emptyDates)
        }

        return list
    }

    func makeAllDates(fillCount: Int = 0) -> [[Date?]] {
        guard fillCount > 0 else {
            return makeAllDates()
        }

        guard let startDate else {
            return []
        }

        var list: [[Date?]] = []

        let calendar = configuration.calendar

        let weekday = calendar.ordinality(of: .weekday, in: .weekOfMonth, for: startDate)! - 1
        var date = weekday == 0 ? startDate : calendar.date(byAdding: .day, value: -weekday, to: startDate)!

        for index in 0 ..< fillCount {
            var dates: [Date?] = []
            for _ in 0 ..< configuration.numberOfWeekdays {
                dates.append(date)

                date = calendar.date(byAdding: .day, value: 1, to: date)!
            }
            list.append(dates)
        }

        return list
    }

    var emptyDates: [Date?] {
        .init(repeating: nil, count: configuration.numberOfWeekdays)
    }
}

// MARK: - Pan Gesture Recognizer

extension GCCalendarMonthView {
    @discardableResult
    func addPanGestureRecognizer(target: Any?, action: Selector?) -> UIPanGestureRecognizer {
        panGestureRecognizer = UIPanGestureRecognizer(target: target, action: action)
        addGestureRecognizer(panGestureRecognizer)
        return panGestureRecognizer
    }
}

// MARK: - Selected Date

extension GCCalendarMonthView {
    func select(date: Date? = nil) {
        let newDate: Date = date ?? startDate
        var weekOfMonth = configuration.calendar.ordinality(of: .weekOfMonth, in: .month, for: newDate)!

        if configuration.calendar.ordinality(of: .weekOfMonth, in: .month, for: startDate)! != 0 {
            weekOfMonth -= 1
        }

        weekViews[weekOfMonth].select(date: newDate)
    }
}
