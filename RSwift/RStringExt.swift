import Foundation
import MKKit
import RswiftResources

// MARK: - TrKey

public protocol TrKey {
    var key: StaticString { get }
}

public extension TrKey {
    var tr: String {
        key.tr
    }

    func tr(for lang: Lang) -> String {
        lang.bundle?.translate(for: key) ?? key.description
    }
}

// MARK: - RswiftResources.StringResource + TrKey

extension RswiftResources.StringResource: TrKey {}

// MARK: - RswiftResources.StringResource1 + TrKey

extension RswiftResources.StringResource1: TrKey {
    public func tr(_ arg1: Arg1) -> String {
        String(format: tr, arg1)
    }

    public func tr(for lang: Lang, _ arg1: Arg1) -> String {
        String(format: tr(for: lang), arg1)
    }
}

// MARK: - RswiftResources.StringResource2 + TrKey

extension RswiftResources.StringResource2: TrKey {
    public func tr(_ arg1: Arg1, _ arg2: Arg2) -> String {
        String(format: tr, arg1, arg2)
    }

    public func tr(for lang: Lang, _ arg1: Arg1, _ arg2: Arg2) -> String {
        String(format: tr(for: lang), arg1, arg2)
    }
}

// MARK: - RswiftResources.StringResource3 + TrKey

extension RswiftResources.StringResource3: TrKey {
    public func tr(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) -> String {
        String(format: tr, arg1, arg2, arg3)
    }

    public func tr(for lang: Lang, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) -> String {
        String(format: tr(for: lang), arg1, arg2, arg3)
    }
}

// MARK: - RswiftResources.StringResource4 + TrKey

extension RswiftResources.StringResource4: TrKey {
    public func tr(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4) -> String {
        String(format: tr, arg1, arg2, arg3, arg4)
    }

    public func tr(for lang: Lang, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4) -> String {
        String(format: tr(for: lang), arg1, arg2, arg3, arg4)
    }
}

// MARK: - RswiftResources.StringResource5 + TrKey

extension RswiftResources.StringResource5: TrKey {
    public func tr(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5) -> String {
        String(format: tr, arg1, arg2, arg3, arg4, arg5)
    }

    public func tr(for lang: Lang, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5) -> String {
        String(format: tr(for: lang), arg1, arg2, arg3, arg4, arg5)
    }
}

// MARK: - RswiftResources.StringResource6 + TrKey

extension RswiftResources.StringResource6: TrKey {
    public func tr(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6) -> String {
        String(format: tr, arg1, arg2, arg3, arg4, arg5, arg6)
    }

    public func tr(for lang: Lang, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6) -> String {
        String(format: tr(for: lang), arg1, arg2, arg3, arg4, arg5, arg6)
    }
}

// MARK: - RswiftResources.StringResource7 + TrKey

extension RswiftResources.StringResource7: TrKey {
    public func tr(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7) -> String {
        String(format: tr, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    }

    public func tr(for _: Lang, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7) -> String {
        String(format: tr, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    }
}

// MARK: - RswiftResources.StringResource8 + TrKey

extension RswiftResources.StringResource8: TrKey {
    public func tr(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8) -> String {
        String(format: tr, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    }

    public func tr(for lang: Lang, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8) -> String {
        String(format: tr(for: lang), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    }
}

// MARK: - RswiftResources.StringResource9 + TrKey

extension RswiftResources.StringResource9: TrKey {
    public func tr(_ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8, _ arg9: Arg9) -> String {
        String(format: tr, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    }

    public func tr(for lang: Lang, _ arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3, _ arg4: Arg4, _ arg5: Arg5, _ arg6: Arg6, _ arg7: Arg7, _ arg8: Arg8, _ arg9: Arg9) -> String {
        String(format: tr(for: lang), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    }
}
