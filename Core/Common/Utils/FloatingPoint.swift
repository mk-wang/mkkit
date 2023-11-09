//
//  FloatingPoint.swift
//
//
//  Created by MK on 2022/3/17.
//

import CoreGraphics

// MARK: - FloatingPoint

public protocol FloatingPoint {
    var float: Float {
        get
    }
    var double: Double {
        get
    }
}

public extension FloatingPoint {
    var cgFloat: CGFloat {
        CGFloat(float)
    }

    var cgSize: CGSize {
        .square(cgFloat)
    }

    var cgCeil: CGFloat {
        Darwin.ceil(cgFloat)
    }

    var cgFloor: CGFloat {
        Darwin.floor(cgFloat)
    }
}

// MARK: - CGFloat + FloatingPoint

extension CGFloat: FloatingPoint {
    public var float: Float {
        Float(self)
    }

    public var double: Double {
        Double(self)
    }
}

// MARK: - Float32 + FloatingPoint

extension Float32: FloatingPoint {
    public var float: Float {
        self
    }

    public var double: Double {
        Double(self)
    }
}

// MARK: - Float64 + FloatingPoint

extension Float64: FloatingPoint {
    public var float: Float {
        Float(self)
    }

    public var double: Double {
        self
    }
}

// MARK: - Int32 + FloatingPoint

extension Int32: FloatingPoint {
    public var float: Float {
        Float(self)
    }

    public var double: Double {
        Double(self)
    }
}

// MARK: - Int64 + FloatingPoint

extension Int64: FloatingPoint {
    public var float: Float {
        Float(self)
    }

    public var double: Double {
        Double(self)
    }
}

// MARK: - UInt + FloatingPoint

extension UInt: FloatingPoint {
    public var float: Float {
        Float(self)
    }

    public var double: Double {
        Double(self)
    }
}

// MARK: - UInt32 + FloatingPoint

extension UInt32: FloatingPoint {
    public var float: Float {
        Float(self)
    }

    public var double: Double {
        Double(self)
    }
}

// MARK: - UInt64 + FloatingPoint

extension UInt64: FloatingPoint {
    public var float: Float {
        Float(self)
    }

    public var double: Double {
        Double(self)
    }
}

public extension CGPoint {
    init(_ w: FloatingPoint, _ y: FloatingPoint) {
        self.init(x: w.cgFloat, y: y.cgFloat)
    }
}

public extension CGSize {
    init(_ w: FloatingPoint, _ y: FloatingPoint) {
        self.init(width: w.cgFloat, height: y.cgFloat)
    }
}

public extension Int {
    var digitCount: Int {
        numberOfDigits(in: self)
    }

    var usefulDigitCount: Int {
        var count = 0
        for digitOrder in 0 ..< digitCount {
            /// get each order digit from self
            let digit = self % Int(truncating: pow(10, digitOrder + 1) as NSDecimalNumber)
                / Int(truncating: pow(10, digitOrder) as NSDecimalNumber)
            if isUseful(digit) { count += 1 }
        }
        return count
    }

    private func numberOfDigits(in number: Int) -> Int {
        if number < 10 && number >= 0 || number > -10 && number < 0 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number / 10)
        }
    }

    private func isUseful(_ digit: Int) -> Bool {
        (digit != 0) && (self % digit == 0)
    }
}

public extension Int {
    func formatNumber(separator: String? = nil) -> String {
        let formater = NumberFormatter()
        if let separator {
            formater.groupingSeparator = separator
        }
        formater.numberStyle = .decimal
        return formater.string(from: NSNumber(value: self))!
    }
}
