//
//  GCCalendarView.swift
//  GCCalendar
//
//  Created by Gray Campbell on 1/28/16.
//

import UIKit

// MARK: - InnerCalendarConfiguration

/// The display mode when displaying a calendar.

class InnerCalendarConfiguration: GCCalendarConfiguration {
    fileprivate var selectedDateCallback: (() -> Date?)?
    fileprivate var dayViewSelectedCallback: ((GCCalendarDayView) -> Void)?

    var selectedDate: Date? {
        selectedDateCallback?()
    }

    func isSelectedDay(date: Date) -> Bool {
        guard let selectedDate else {
            return false
        }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }

    func selectDayView(_ dayView: GCCalendarDayView) {
        dayViewSelectedCallback?(dayView)
    }
}

// MARK: - GCCalendarView

/// The GCCalendarView class defines a view containing an interactive calendar.

public class GCCalendarView: UIView {
    // MARK: Properties

    let innerConfiguration: InnerCalendarConfiguration

    public var configuration: GCCalendarConfiguration {
        innerConfiguration
    }

    public fileprivate(set) var selectedDate: Date

    fileprivate var selectedDayView: GCCalendarDayView? = nil

    fileprivate var userSelectedDate: Date?

    fileprivate var headerView: UIStackView?

    fileprivate var weekViews: [GCCalendarWeekView] = []
    fileprivate var monthViews: [GCCalendarMonthView] = []

    fileprivate var panGestureStartLocation: CGFloat?

    fileprivate var currentCenter: CGPoint = .zero

    /// The object that acts as the delegate of the calendar view.

    public weak var delegate: GCCalendarViewDelegate?

    /// The display mode for the calendar view.

    var displayMode: GCCalendarConfiguration.GCCalendarDisplayMode {
        configuration.displayMode
    }

    // MARK: Initializers

    public required init?(coder aDecoder: NSCoder) {
        innerConfiguration = .init(calendar: .current)
        selectedDate = innerConfiguration.calendar.startOfDay(for: .init())

        super.init(coder: aDecoder)

        commonInit()
    }

    /// Initializes and returns a newly allocated calendar view object with the specified frame rectangle.
    ///
    /// - Parameter frame: The frame rectangle for the calendar view, measured in points. The origin of the frame is relative to the superview in which you plan to add it. This method uses the frame rectangle to set the center and bounds properties accordingly.
    /// - Returns: An initialized calendar view object.

    public init(frame: CGRect,
                selectedDate: Date? = nil,
                displayMode: GCCalendarConfiguration.GCCalendarDisplayMode = .month,
                calendar: Calendar = .current)
    {
        innerConfiguration = .init(calendar: calendar, displayMode: displayMode)

        self.selectedDate = calendar.startOfDay(for: selectedDate ?? .init())

        super.init(frame: frame)

        commonInit()
    }

    /// Initializes and returns a newly allocated calendar view object.
    ///
    /// Use this initializer if you are planning on using layout constraints. If you are using frame rectangles to layout your views, use `init(frame:)` instead.
    ///
    /// - Returns: An initialized calendar view object.

    public convenience init() {
        self.init(frame: CGRect.zero)
    }

    func commonInit() {
        clipsToBounds = true

        innerConfiguration.selectedDateCallback = { [weak self] in
            self?.selectedDate
        }

        innerConfiguration.dayViewSelectedCallback = { [weak self] dayView in
            guard let self, let date = dayView.date else {
                return
            }

            let prevView = selectedDayView
            if prevView != dayView {
                prevView?.unselected()

                let prevDate = selectedDate
                selectedDate = date
                selectedDayView = dayView
                delegate?.calendarView(self, didSelectDate: date, previousDate: prevDate)
            }
        }
    }
}

// MARK: - Layout

public extension GCCalendarView {
    override func layoutSubviews() {
        super.layoutSubviews()

        if subviews.isEmpty {
            refresh()
        } else {
            resetLayout()
        }
    }

    private func resetLayout() {
        previousView.center.x = -bounds.size.width * 0.5
        currentView.center.x = bounds.size.width * 0.5
        nextView.center.x = bounds.size.width * 1.5
    }
}

// MARK: - Refresh

extension GCCalendarView {
    public func refresh() {
        removeHeaderView()
        addHeaderView()

        removeWeekViews()
        removeMonthViews()

        switch displayMode {
        case .week:
            addWeekViews()
        case .month:
            addMonthViews()
        }

        layoutIfNeeded()

        resetLayout()
        showDateView()
    }

    private func showDateView() {
        guard let delegate, let dateView = currentView as? GCCalendarDateView else {
            return
        }

        delegate.calendarView(self, showDateView: dateView)
    }
}

// MARK: - Header View

private extension GCCalendarView {
    func addHeaderView() {
        guard let config = configuration.headerConfig else {
            return
        }

        let itemSpacing = configuration.itemSpacing

        let headerView = UIStackView()

        headerView.axis = .horizontal
        headerView.distribution = .fillEqually
        headerView.spacing = itemSpacing

        for index in 0 ..< configuration.numberOfWeekdays {
            let weekdayLabel = UILabel()
            let weekday = configuration.weekday(of: index)
            config.viewConfig(self, weekdayLabel, weekday)

            headerView.addArrangedSubview(weekdayLabel)
        }

        headerView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(headerView)

        let xPad = configuration.xPad
        headerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerView.leftAnchor.constraint(equalTo: leftAnchor, constant: xPad).isActive = true
        headerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -xPad).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: config.height).isActive = true

        self.headerView = headerView
    }

    func removeHeaderView() {
        headerView?.removeFromSuperview()
        headerView = nil
    }
}

// MARK: - Week & Month Views

extension GCCalendarView {
    private var previousViewDisabled: Bool {
        guard !configuration.pastDatesEnabled else {
            return false
        }
        if previousView.isKind(of: GCCalendarMonthView.self) {
            return currentMonthView.contains(date: Date())
        } else {
            return currentWeekView.contains(date: Date())
        }
    }

    // MARK: Views

    public var previousView: UIView {
        switch displayMode {
        case .week:
            previousWeekView
        case .month:
            previousMonthView
        }
    }

    public var currentView: UIView {
        switch displayMode {
        case .week:
            currentWeekView
        case .month:
            currentMonthView
        }
    }

    public var nextView: UIView {
        switch displayMode {
        case .week:
            nextWeekView
        case .month:
            nextMonthView
        }
    }

    // MARK: Toggle Views

    open func canToNextMonth(_ view: UIView) -> Bool {
        guard let max = configuration.maxDate?(),
              let dateView = view as? GCCalendarDateView
        else {
            return true
        }

        if let date = dateView.nextBegin {
            return date < max
        }

        return true
    }

    open func canToPrevMonth(_ view: UIView) -> Bool {
        guard let min = configuration.minDate?(),
              let dateView = view as? GCCalendarDateView
        else {
            return true
        }

        if let date = dateView.prevBegin {
            return date > min
        }

        return true
    }

    @objc open func toggleCurrentView(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            panGestureStartLocation = pan.location(in: self).x
            currentCenter = currentView.center
        case .changed:
            defer {
                panGestureStartLocation = pan.location(in: self).x
            }
            guard let panGestureStartLocation else {
                return
            }

            var changeInX = pan.location(in: self).x - panGestureStartLocation

            guard !previousViewDisabled || currentView.center.x + changeInX <= bounds.size.width * 0.5 else {
                return
            }

            let target = currentView.center.x + changeInX
            // next
            if target < currentCenter.x, !canToNextMonth(currentView) {
                changeInX = currentCenter.x - currentView.center.x
            } else if target > currentCenter.x, !canToPrevMonth(currentView) {
                changeInX = currentCenter.x - currentView.center.x
            }

            previousView.center.x += changeInX
            currentView.center.x += changeInX
            nextView.center.x += changeInX
        case .ended:
            let half = bounds.size.width * 0.5
            let distance = currentView.center.x - half
            let minDistance = half * 0.5
            if distance < -minDistance {
                UIView.animate(withDuration: 0.25, animations: showNextView, completion: nextViewDidShow)
            } else if distance > minDistance {
                UIView.animate(withDuration: 0.25, animations: showPreviousView, completion: previousViewDidShow)
            } else {
                UIView.animate(withDuration: 0.15, animations: { self.resetLayout() })
            }
        default:
            break
        }
    }

    private func showPreviousView() {
        previousView.center.x = bounds.size.width * 0.5
        currentView.center.x = bounds.size.width * 1.5
    }

    private func previousViewDidShow(_ finished: Bool) {
        guard finished else {
            return
        }

        switch displayMode {
        case .week:
            previousWeekViewDidShow(finished)
        case .month:
            previousMonthViewDidShow(finished)
        }
    }

    private func showNextView() {
        currentView.center.x = -bounds.size.width * 0.5
        nextView.center.x = bounds.size.width * 0.5
    }

    private func nextViewDidShow(_ finished: Bool) {
        guard finished else {
            return
        }

        switch displayMode {
        case .week:
            nextWeekViewDidShow(finished)
        case .month:
            nextMonthViewDidShow(finished)
        }
    }
}

// MARK: - Today

private extension GCCalendarView {
    func findDateInWeekViews(date: Date) {
        if previousWeekView.contains(date: date) {
            UIView.animate(withDuration: 0.15, animations: showPreviousView, completion: previousWeekViewDidShow)
        } else if currentWeekView.contains(date: date) {
            currentWeekView.select(date: date)
            userSelectedDate = nil
        } else if nextWeekView.contains(date: date) {
            UIView.animate(withDuration: 0.15, animations: showNextView, completion: nextWeekViewDidShow)
        } else {
            if date < selectedDate {
                show(date: date, animations: showPreviousView, weekViewReuse: reuseNextWeekView) { finished in

                    if finished {
                        self.previousWeekViewDidShow(finished)

                        let newDates = self.nextWeekDates(currentWeekDates: self.currentWeekView.dates)

                        self.nextWeekView.update(dates: newDates)
                    }
                }
            } else if date > selectedDate {
                show(date: date, animations: showNextView, weekViewReuse: reusePreviousWeekView) { finished in

                    if finished {
                        self.nextWeekViewDidShow(finished)

                        let newDates = self.previousWeekDates(currentWeekDates: self.currentWeekView.dates)
                        self.previousWeekView.update(dates: newDates)
                    }
                }
            }
        }
    }

    func show(date: Date, animations: @escaping () -> Void, weekViewReuse: @escaping (([Date?]) -> Void), completion: @escaping ((Bool) -> Void)) {
        UIView.animate(withDuration: 0.08, animations: animations) { finished in

            if finished {
                let newDates = self.currentWeekDates(fromDate: date)

                weekViewReuse(newDates)

                self.resetLayout()

                UIView.animate(withDuration: 0.08, animations: animations) { finished in completion(finished) }
            }
        }
    }

    func findDateInMonthViews(date: Date) {
        if previousMonthView.contains(date: date) {
            UIView.animate(withDuration: 0.15, animations: showPreviousView, completion: previousMonthViewDidShow)
        } else if currentMonthView.contains(date: date) {
            currentMonthView.select(date: date)
            userSelectedDate = nil
        } else if nextMonthView.contains(date: date) {
            UIView.animate(withDuration: 0.15, animations: showNextView, completion: nextMonthViewDidShow)
        } else {
            if date < selectedDate {
                show(date: date, animations: showPreviousView, monthViewReuse: reuseNextMonthView) { finished in

                    if finished {
                        self.previousMonthViewDidShow(finished)

                        let newStartDate = self.nextMonthStartDate(currentMonthStartDate: self.currentMonthView.startDate)

                        self.nextMonthView.startDate = newStartDate
                    }
                }
            } else if date > selectedDate {
                show(date: date, animations: showNextView, monthViewReuse: reusePreviousMonthView) { finished in

                    if finished {
                        self.nextMonthViewDidShow(finished)

                        let newStartDate = self.previousMonthStartDate(currentMonthStartDate: self.currentMonthView.startDate)

                        self.previousMonthView.startDate = newStartDate
                    }
                }
            }
        }
    }

    func show(date: Date, animations: @escaping () -> Void, monthViewReuse: @escaping ((Date) -> Void), completion: @escaping ((Bool) -> Void)) {
        UIView.animate(withDuration: 0.08, animations: animations) { finished in

            if finished {
                let newStartDate = self.currentMonthStartDate(fromDate: date)

                monthViewReuse(newStartDate)

                self.resetLayout()

                UIView.animate(withDuration: 0.08, animations: animations) { finished in completion(finished) }
            }
        }
    }
}

// MARK: - Week Views

private extension GCCalendarView {
    func addWeekViews() {
        let currentWeekDates = currentWeekDates(fromDate: selectedDate)
        let previousWeekDates = previousWeekDates(currentWeekDates: currentWeekDates)
        let nextWeekDates = nextWeekDates(currentWeekDates: currentWeekDates)

        let weekHeight = configuration.weekConfig.height
        let enablePanGesture = configuration.enablePanGesture

        for dates in [previousWeekDates, currentWeekDates, nextWeekDates] {
            let weekView = configuration.weekConfig.viewBuilder?(configuration) ?? GCCalendarWeekView(frame: .zero, configuration: configuration)

            weekView.update(dates: dates)

            weekView.translatesAutoresizingMaskIntoConstraints = false

            if enablePanGesture {
                let gesture = weekView.addPanGestureRecognizer(target: self, action: #selector(toggleCurrentView(_:)))
                gesture.delegate = self
            }

            addSubview(weekView)
            weekViews.append(weekView)

            if let headerView, let config = configuration.headerConfig {
                weekView.topAnchor.constraint(equalTo: headerView.bottomAnchor,
                                              constant: config.bottomMargin).isActive = true

            } else {
                weekView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            }

            weekView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            weekView.heightAnchor.constraint(equalToConstant: weekHeight).isActive = true
        }
    }

    func removeWeekViews() {
        weekViews.forEach { $0.removeFromSuperview() }
        weekViews.removeAll()
    }

    // MARK: Views

    var previousWeekView: GCCalendarWeekView {
        weekViews[0]
    }

    var currentWeekView: GCCalendarWeekView {
        weekViews[1]
    }

    var nextWeekView: GCCalendarWeekView {
        weekViews[2]
    }

    // MARK: Dates

    func previousWeekDates(currentWeekDates: [Date?]) -> [Date?] {
        let startDate = configuration.calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekDates[0]!)

        return configuration.weekDates(startDate: startDate!)
    }

    func currentWeekDates(fromDate date: Date) -> [Date?] {
        var components = configuration.calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)

        components.weekday = 1

        let startDate = configuration.calendar.date(from: components)

        return configuration.weekDates(startDate: startDate!)
    }

    func nextWeekDates(currentWeekDates: [Date?]) -> [Date?] {
        let startDate = configuration.calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekDates[0]!)

        return configuration.weekDates(startDate: startDate!)
    }

    // MARK: Show Week View

    func previousWeekViewDidShow(_: Bool) {
        let newDates = previousWeekDates(currentWeekDates: previousWeekView.dates)

        reuseNextWeekView(newDates: newDates)
        weekViewDidShow()
    }

    func reuseNextWeekView(newDates: [Date?]) {
        nextWeekView.update(dates: newDates)
        weekViews.insert(nextWeekView, at: 0)
        weekViews.removeLast()
    }

    func nextWeekViewDidShow(_: Bool) {
        let newDates = nextWeekDates(currentWeekDates: nextWeekView.dates)

        reusePreviousWeekView(newDates: newDates)
        weekViewDidShow()
    }

    func reusePreviousWeekView(newDates: [Date?]) {
        previousWeekView.update(dates: newDates)

        weekViews.append(previousWeekView)
        weekViews.removeFirst()
    }

    func weekViewDidShow() {
        resetLayout()
        showDateView()

        guard let userSelectedDate else {
            let hasCurrent = currentWeekView.contains(date: Date())
            currentWeekView.select(date: nil, hasCurrent: hasCurrent)
            return
        }

        currentWeekView.select(date: userSelectedDate)
        self.userSelectedDate = nil
    }
}

// MARK: - Month Views

private extension GCCalendarView {
    func addMonthViews() {
        let currentMonthStartDate = currentMonthStartDate(fromDate: selectedDate)
        let previousMonthStartDate = previousMonthStartDate(currentMonthStartDate: currentMonthStartDate)
        let nextMonthStartDate = nextMonthStartDate(currentMonthStartDate: currentMonthStartDate)

        let enablePanGesture = configuration.enablePanGesture

        for startDate in [previousMonthStartDate, currentMonthStartDate, nextMonthStartDate] {
            let monthView = GCCalendarMonthView(frame: .zero, configuration: configuration)

            monthView.startDate = startDate
            monthView.translatesAutoresizingMaskIntoConstraints = false

            if enablePanGesture {
                let gesture = monthView.addPanGestureRecognizer(target: self, action: #selector(toggleCurrentView(_:)))
                gesture.delegate = self
            }

            addSubview(monthView)
            monthViews.append(monthView)

            if let headerView, let config = configuration.headerConfig {
                monthView.topAnchor.constraint(equalTo: headerView.bottomAnchor,
                                               constant: config.bottomMargin).isActive = true

            } else {
                monthView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            }

            monthView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            monthView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        }
    }

    func removeMonthViews() {
        monthViews.forEach { $0.removeFromSuperview() }
        monthViews.removeAll()
    }

    // MARK: Views

    var previousMonthView: GCCalendarMonthView {
        monthViews[0]
    }

    var currentMonthView: GCCalendarMonthView {
        monthViews[1]
    }

    var nextMonthView: GCCalendarMonthView {
        monthViews[2]
    }

    // MARK: Start Dates

    func previousMonthStartDate(currentMonthStartDate: Date) -> Date {
        configuration.calendar.date(byAdding: .month, value: -1, to: currentMonthStartDate)!
    }

    func currentMonthStartDate(fromDate date: Date) -> Date {
        var components = configuration.calendar.dateComponents([.day, .month, .year], from: date)

        components.day = 1

        return configuration.calendar.date(from: components)!
    }

    func nextMonthStartDate(currentMonthStartDate: Date) -> Date {
        configuration.calendar.date(byAdding: .month, value: 1, to: currentMonthStartDate)!
    }

    // MARK: Show Month View

    func previousMonthViewDidShow(_ finished: Bool) {
        if finished {
            let newStartDate = previousMonthStartDate(currentMonthStartDate: previousMonthView.startDate)

            reuseNextMonthView(newStartDate: newStartDate)
            monthViewDidShow()
        }
    }

    func reuseNextMonthView(newStartDate: Date) {
        nextMonthView.startDate = newStartDate
        monthViews.insert(nextMonthView, at: 0)
        monthViews.removeLast()
    }

    func nextMonthViewDidShow(_ finished: Bool) {
        if finished {
            let newStartDate = nextMonthStartDate(currentMonthStartDate: nextMonthView.startDate)

            reusePreviousMonthView(newStartDate: newStartDate)
            monthViewDidShow()
        }
    }

    func reusePreviousMonthView(newStartDate: Date) {
        previousMonthView.startDate = newStartDate
        monthViews.append(previousMonthView)
        monthViews.removeFirst()
    }

    func monthViewDidShow() {
        resetLayout()
        showDateView()

        if let userSelectedDate {
            currentMonthView.select(date: userSelectedDate)
            self.userSelectedDate = nil
        } else if currentMonthView.contains(date: Date()) {
            currentMonthView.select(date: Date())
        } else {
            currentMonthView.select(date: nil)
        }
    }
}

// MARK: - Public Functions

public extension GCCalendarView {
    /// Tells the calendar view to select the current date, updating any visible week views or month views if necessary.

    func today() {
        select(date: Date())
    }

    /// Tells the calendar view to select the specified date, updating any visible week views or month views if necessary.

    func select(date: Date) {
        guard !configuration.calendar.isDate(date, inSameDayAs: selectedDate) else {
            return
        }

        userSelectedDate = date

        switch displayMode {
        case .week:
            findDateInWeekViews(date: date)
        case .month:
            findDateInMonthViews(date: date)
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension GCCalendarView: UIGestureRecognizerDelegate {
    override public func gestureRecognizerShouldBegin(_ recognizer: UIGestureRecognizer) -> Bool {
        guard let view = recognizer.view,
              let recognizer = recognizer as? UIPanGestureRecognizer,
              let dateView = view as? GCCalendarDateView
        else {
            return false
        }

        let next = recognizer.velocity(in: view).x < 0

        if next, let maxDate = configuration.maxDate?(), let date = dateView.nextBegin {
            return date < maxDate
        } else if !next, let minDate = configuration.minDate?(), let date = dateView.prevBegin {
            return date > minDate
        }

        return true
    }
}
