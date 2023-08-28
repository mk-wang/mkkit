
import Foundation
import OpenCombine

// MARK: - CombineInfo

public final class CombineInfo {
    public var cancellableSet = Set<AnyCancellable>()
}

public extension NSObject {
    var combineInfo: CombineInfo {
        if let info = getAssociatedObject(&AssociatedKeys.kCombineInfo) as? CombineInfo {
            return info
        }

        let info = CombineInfo()
        setAssociatedObject(&AssociatedKeys.kCombineInfo, info)
        return info
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kCombineInfo = 0
}
