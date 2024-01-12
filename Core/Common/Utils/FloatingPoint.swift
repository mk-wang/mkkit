//
//  MKFloatingPoint.swift
//
//
//  Created by MK on 2022/3/17.
//

import CoreGraphics

// MARK: - MKFloatingPoint

public protocol MKFloatingPoint {
    var float: Float {
        get
    }
    var double: Double {
        get
    }
}

public extension MKFloatingPoint {
    var cgfValue: CGFloat {
        CGFloat(double)
    }

    var cgSize: CGSize {
        .square(cgfValue)
    }

    var cgfCeil: CGFloat {
        Darwin.ceil(cgfValue)
    }

    var cgfFloor: CGFloat {
        Darwin.floor(cgfValue)
    }

    var radians: CGFloat {
        cgfValue * .pi / 180
    }

    var degrees: CGFloat {
        cgfValue * 180 / .pi
    }
}

// MARK: - CGFloat + MKFloatingPoint

extension CGFloat: MKFloatingPoint {
    public var float: Float {
        Float(self)
    }

    public var double: Double {
        Double(self)
    }
}

// MARK: - Float32 + MKFloatingPoint

extension Float32: MKFloatingPoint {
    public var float: Float {
        self
    }

    public var double: Double {
        Double(self)
    }
}

// MARK: - Float64 + MKFloatingPoint

extension Float64: MKFloatingPoint {
    public var float: Float {
        Float(self)
    }

    public var double: Double {
        self
    }
}

// MARK: - Int32 + MKFloatingPoint

extension Int32: MKFloatingPoint {
    public var float: Float {
        Float(self)
    }

    public var double: Double {
        Double(self)
    }
}

// MARK: - Int64 + MKFloatingPoint

extension Int64: MKFloatingPoint {
    public var float: Float {
        Float(self)
    }

    public var double: Double {
        Double(self)
    }
}

// MARK: - UInt + MKFloatingPoint

extension UInt: MKFloatingPoint {
    public var float: Float {
        Float(self)
    }

    public var double: Double {
        Double(self)
    }
}

// MARK: - UInt32 + MKFloatingPoint

extension UInt32: MKFloatingPoint {
    public var float: Float {
        Float(self)
    }

    public var double: Double {
        Double(self)
    }
}

// MARK: - UInt64 + MKFloatingPoint

extension UInt64: MKFloatingPoint {
    public var float: Float {
        Float(self)
    }

    public var double: Double {
        Double(self)
    }
}

public extension CGPoint {
    init(_ w: MKFloatingPoint, _ y: MKFloatingPoint) {
        self.init(x: w.cgfValue, y: y.cgfValue)
    }
}

public extension CGSize {
    init(_ w: MKFloatingPoint, _ y: MKFloatingPoint) {
        self.init(width: w.cgfValue, height: y.cgfValue)
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
