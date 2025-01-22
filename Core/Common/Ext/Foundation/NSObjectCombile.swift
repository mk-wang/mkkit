
import Foundation

// MARK: - CombineInfo

final class CombineInfo {
    fileprivate var cancellableSet = Set<AnyCancellable>()
}

extension NSObject {
    fileprivate var combineInfo: CombineInfo {
        getOrMakeAssociatedObject(&AssociatedKeys.kCombineInfo,
                                  type: CombineInfo.self,
                                  builder: { .init() })
    }

    public func clearCancellableSet() {
        combineInfo.cancellableSet.removeAll()
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kCombineInfo = 0
}

public extension AnyCancellable {
    func store(in object: NSObject) {
        store(in: &object.combineInfo.cancellableSet)
    }
}
