//
//  NSDecimalNumberExt.swift
//  MKKit
//
//  Created by MK on 2023/7/22.
//

import Foundation

// MARK: - MKDecimalNumber

public protocol MKDecimalNumber {
    var decimalNumber: NSDecimalNumber {
        get
    }
}

// MARK: - NSNumber + MKDecimalNumber

extension NSNumber: MKDecimalNumber {
    public var decimalNumber: NSDecimalNumber {
        NSDecimalNumber(decimal: decimalValue)
    }
}

// MARK: - String + MKDecimalNumber

extension String: MKDecimalNumber {
    public var decimalNumber: NSDecimalNumber {
        NSDecimalNumber(string: self)
    }
}

// MARK: - Double + MKDecimalNumber

extension Double: MKDecimalNumber {
    public var decimalNumber: NSDecimalNumber {
        NSDecimalNumber(value: self)
    }
}

// MARK: - Bool + MKDecimalNumber

extension Bool: MKDecimalNumber {
    public var decimalNumber: NSDecimalNumber {
        NSDecimalNumber(value: self)
    }
}

// MARK: - Int + MKDecimalNumber

extension Int: MKDecimalNumber {
    public var decimalNumber: NSDecimalNumber {
        NSDecimalNumber(value: self)
    }
}

// MARK: - Int8 + MKDecimalNumber

extension Int8: MKDecimalNumber {
    public var decimalNumber: NSDecimalNumber {
        NSDecimalNumber(value: self)
    }
}

// MARK: - Int16 + MKDecimalNumber

extension Int16: MKDecimalNumber {
    public var decimalNumber: NSDecimalNumber {
        NSDecimalNumber(value: self)
    }
}

// MARK: - Int32 + MKDecimalNumber

extension Int32: MKDecimalNumber {
    public var decimalNumber: NSDecimalNumber {
        NSDecimalNumber(value: self)
    }
}

// MARK: - Int64 + MKDecimalNumber

extension Int64: MKDecimalNumber {
    public var decimalNumber: NSDecimalNumber {
        NSDecimalNumber(value: self)
    }
}

// MARK: - UInt + MKDecimalNumber

extension UInt: MKDecimalNumber {
    public var decimalNumber: NSDecimalNumber {
        NSDecimalNumber(value: self)
    }
}

// MARK: - UInt8 + MKDecimalNumber

extension UInt8: MKDecimalNumber {
    public var decimalNumber: NSDecimalNumber {
        NSDecimalNumber(value: self)
    }
}

// MARK: - UInt16 + MKDecimalNumber

extension UInt16: MKDecimalNumber {
    public var decimalNumber: NSDecimalNumber {
        NSDecimalNumber(value: self)
    }
}

// MARK: - UInt32 + MKDecimalNumber

extension UInt32: MKDecimalNumber {
    public var decimalNumber: NSDecimalNumber {
        NSDecimalNumber(value: self)
    }
}

// MARK: - UInt64 + MKDecimalNumber

extension UInt64: MKDecimalNumber {
    public var decimalNumber: NSDecimalNumber {
        NSDecimalNumber(value: self)
    }
}

public extension NSDecimalNumber {
    var isNaN: Bool {
        self == NSDecimalNumber.notANumber
    }

    var abs: NSDecimalNumber {
        guard !isNaN else {
            return .notANumber
        }
        return self >= .zero ? self : -self
    }
}

// MARK: - NSDecimalNumber + Comparable

extension NSDecimalNumber: Comparable {}

public func + (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    lhs.adding(rhs)
}

public func - (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    lhs.subtracting(rhs)
}

public func * (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    lhs.multiplying(by: rhs)
}

public func / (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> NSDecimalNumber {
    lhs.dividing(by: rhs)
}

public func == (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    lhs.compare(rhs) == .orderedSame
}

public func < (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
    lhs.compare(rhs) == .orderedAscending
}

precedencegroup ExponentiativePrecedence {
    associativity: left
    higherThan: MultiplicationPrecedence
}

infix operator **: ExponentiativePrecedence
public func ** (value: NSDecimalNumber, exponent: Int) -> NSDecimalNumber {
    value.raising(toPower: exponent)
}

public func min(_ lhs: NSDecimalNumber, _ rhs: NSDecimalNumber) -> NSDecimalNumber {
    lhs < rhs ? lhs : rhs
}

public func max(_ lhs: NSDecimalNumber, _ rhs: NSDecimalNumber) -> NSDecimalNumber {
    lhs > rhs ? lhs : rhs
}

public func += (lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
    lhs = lhs + rhs
}

public func -= (lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
    lhs = lhs - rhs
}

public func *= (lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
    lhs = lhs * rhs
}

public func /= (lhs: inout NSDecimalNumber, rhs: NSDecimalNumber) {
    lhs = lhs / rhs
}

public prefix func - (lhs: NSDecimalNumber) -> NSDecimalNumber {
    lhs * NSDecimalNumber(string: "-1")
}

public prefix func + (lhs: NSDecimalNumber) -> NSDecimalNumber {
    lhs
}

// MARK: - LocationCoord

extension NSDecimalNumber {
    static let angleFactor = Double.pi.decimalNumber / 180.decimalNumber
    static let radianFactor = 180.decimalNumber / Double.pi.decimalNumber

    public var radian: NSDecimalNumber {
        self * Self.radianFactor
    }

    public var angle: NSDecimalNumber {
        self * Self.angleFactor
    }
}

private let VaraibleDecimalNumberHandler: (_ roundingMode: NSDecimalNumber.RoundingMode,
                                           _ scale: Int16) -> NSDecimalNumberBehaviors
    = { roundingMode, scale -> NSDecimalNumberHandler in
        NSDecimalNumberHandler(roundingMode: roundingMode,
                               scale: scale,
                               raiseOnExactness: false,
                               raiseOnOverflow: true,
                               raiseOnUnderflow: true,
                               raiseOnDivideByZero: true)
    }

public extension NSDecimalNumber.RoundingMode {
    func round(value: NSDecimalNumber, scale: Int16) -> NSDecimalNumber {
        value.rounding(accordingToBehavior: VaraibleDecimalNumberHandler(self, scale))
    }
}
