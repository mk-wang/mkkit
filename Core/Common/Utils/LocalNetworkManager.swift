//
//  LocalNetworkManager.swift
//
//  Created by MK on 2024/3/12.
//  https://www.jianshu.com/p/0daf226a1536

import Foundation
import Network
#if canImport(OpenCombine)
    import OpenCombine
#elseif canImport(Combine)
    import Combine
#endif

// MARK: - LocalNetworkManager

open class LocalNetworkManager: NSObject {
    public enum AuthState {
        case unkown
        case checking
        case denied
        case authed

        public var isDetected: Bool {
            self == .denied || self == .authed
        }
    }

    private let stateSubject: CurrentValueSubject<AuthState, Never> = .init(LocalNetworkManager.needAuth ? .unkown : .authed)
    public lazy var statePublisher = stateSubject.eraseToAnyPublisher()

    public private(set) var state: AuthState {
        get {
            stateSubject.value
        }
        set {
            if stateSubject.value != newValue {
                stateSubject.value = newValue

                Logger.shared.debug("localNetwork state \(newValue)")
            }
        }
    }

    private var netService: NetService?
    private var _browser: AnyObject?

    public var isDenied: Bool {
        stateSubject.value == .denied
    }

    public func requestAuthorization() {
        guard Self.needAuth, #available(iOS 14, *) else {
            state = .authed
            return
        }
        doAuthorization()
    }

    public static var needAuth: Bool {
        #if targetEnvironment(simulator)
            return false
        #endif

        if #available(iOS 14, *) {
            return true
        } else {
            return false
        }
    }
}

@available(iOS 14.0, *)
private extension LocalNetworkManager {
    var browser: NWBrowser? {
        get {
            _browser as? NWBrowser
        }
        set {
            _browser = newValue
        }
    }

    func doAuthorization() {
        guard state != .checking else {
            return
        }
        Logger.shared.debug("localNetwork doAuthorization")

        state = .checking

        // Create parameters, and allow browsing over peer-to-peer link.
        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        // Browse for a custom service type.
        let browser = NWBrowser(for: .bonjour(type: "_bonjour._tcp", domain: nil), using: parameters)
        browser.stateUpdateHandler = { [weak self] newState in
            guard let self else {
                return
            }

            switch newState {
            case let .failed(error):
                Logger.shared.debug("localNetwork fail \(error)")
            case .cancelled,
                 .ready:
                break
            case let .waiting(error):
                Logger.shared.debug("localNetwork denied \(error)")
                stop()
                state = .denied
            default:
                break
            }
        }

        let netService = NetService(domain: "local.", type: "_inston-play._tcp.", name: "LocalNetworkPrivacy", port: 1100)
        netService.delegate = self

        browser.start(queue: .main)
        netService.publish()
        // netService.schedule(in: .main, forMode: .common)

        self.browser = browser
        self.netService = netService
    }

    func stop() {
        browser?.cancel()
        browser = nil
        netService?.stop()
        netService = nil
    }
}

// MARK: NetServiceDelegate

@available(iOS 14.0, *) extension LocalNetworkManager: NetServiceDelegate {
    public func netServiceDidPublish(_: NetService) {
        stop()
        state = .authed
    }
}
