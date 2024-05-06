
import Foundation
import OpenCombine

// MARK: - CombineInfo

public final class CombineInfo {
    public var cancellableSet = Set<AnyCancellable>()
}

public extension NSObject {
    var combineInfo: CombineInfo {
        getOrMakeAssociatedObject(&AssociatedKeys.kCombineInfo,
                                  type: CombineInfo.self,
                                  builder: { .init() })
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kCombineInfo = 0
}
