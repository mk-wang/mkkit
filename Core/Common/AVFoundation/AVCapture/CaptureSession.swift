//
//  CaptureSession.swift
//  MKKit
//
//  Created by MK on 2023/12/13.
//  https://developer.apple.com/documentation/avfoundation/capture_setup/avcambarcode_detecting_barcodes_and_faces

import AVFoundation
import Foundation

// MARK: - CaptureSession

open class CaptureSession {
    public let session = AVCaptureSession()
    public private(set) var useFrontCamera: Bool = true

    private let sessionQueue = DispatchQueue(label: "mkkit.capture.session.queue") // Communicate with the session and other session objects on this queue.

    private lazy var videoDiscovery: AVCaptureDevice.DiscoverySession = discoveryBuilder()
    let discoveryBuilder: ValueBuilder<AVCaptureDevice.DiscoverySession>

    let preset: AVCaptureSession.Preset

    public private(set) var videoInput: AVCaptureDeviceInput?

    private var kvObservations = [NSKeyValueObservation]()

    private let interruptSubject = CurrentValueSubjectType<Interrupt, Never>(.none)
    public private(set) lazy var interruptPublisher = interruptSubject.eraseToAnyPublisher()
    public private(set) var interrupt: Interrupt {
        get {
            interruptSubject.value
        }
        set {
            if interruptSubject.value != newValue {
                interruptSubject.value = newValue
            }
        }
    }

    private let runningSubject = CurrentValueSubjectType<Bool, Never>(false)
    public private(set) lazy var runningPublisher = runningSubject.eraseToAnyPublisher()
    public private(set) var isRunning: Bool {
        get {
            runningSubject.value
        }

        set {
            if runningSubject.value != newValue {
                Logger.shared.debug("Capture session is running: \(newValue)")
                runningSubject.value = newValue
            }
        }
    }

    public init(useFrontCamera: Bool,
                preset: AVCaptureSession.Preset = .high,
                discoveryBuilder: ValueBuilder<AVCaptureDevice.DiscoverySession>? = nil)
    {
        self.useFrontCamera = useFrontCamera
        self.preset = preset
        self.discoveryBuilder = discoveryBuilder ?? {
            .init(deviceTypes: [.builtInWideAngleCamera],
                  mediaType: .video,
                  position: .unspecified)
        }
    }

    public func setupSession(configuration: @escaping VoidFunction1<CaptureSession>, callback: VoidFunction? = nil) {
        runInSessionQueue { [weak self] in
            guard let self else {
                callback?()
                return
            }

            session.beginConfiguration()
            configuration(self)
            session.commitConfiguration()
            callback?()
        }
    }

    public func videoDevcieFor(front: Bool) -> AVCaptureDevice? {
        let position: AVCaptureDevice.Position = front ? .front : .back
        return videoDiscovery.devices.first(where: { $0.position == position })
    }

    public func runInSessionQueue(delay: TimeInterval = 0, function: @escaping VoidFunction) {
        DispatchQueue.async(queue: sessionQueue, after: delay, block: function)
    }
}

public extension CaptureSession {
    @discardableResult
    func addVideoDevice(_ device: AVCaptureDevice) throws -> Bool {
        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else {
            return false
        }

        session.addInput(input)

        videoInput = input
        return true
    }

    @discardableResult
    func addOutput(_ output: AVCaptureOutput) -> Bool {
        guard session.canAddOutput(output) else {
            return false
        }

        session.addOutput(output)
        return true
    }

    @discardableResult
    func switchCamera(front: Bool,
                      configuration: VoidFunction1<Bool>? = nil,
                      callback: VoidFunction? = nil) -> Bool
    {
        guard useFrontCamera != front else {
            callback?()
            return true
        }

        guard let device = videoDevcieFor(front: front),
              let newInput = try? AVCaptureDeviceInput(device: device)
        else {
            callback?()
            return false
        }

        runInSessionQueue { [weak self] in
            guard let self else {
                callback?()
                return
            }

            session.beginConfiguration()

            if let videoInput {
                session.removeInput(videoInput)
            }

            let previousSessionPreset = session.sessionPreset
            session.sessionPreset = preset

            if session.canAddInput(newInput) {
                session.addInput(newInput)
                videoInput = newInput
            } else if let videoInput {
                session.addInput(videoInput)
            }

            // Restore the previous session preset if we can.
            if session.canSetSessionPreset(previousSessionPreset) {
                session.sessionPreset = previousSessionPreset
            }

            configuration?(front)
            session.commitConfiguration()

            DispatchQueue.main.async { [weak self] in
                self?.useFrontCamera = front
            }
            callback?()
        }
        return true
    }
}

public extension CaptureSession {
    static func checkPermission(mediaType: AVMediaType = .video,
                                requestIfNotDetermined: Bool = true,
                                onRequestAccess: VoidFunction? = nil,
                                callback: @escaping VoidFunction2<Bool, Bool>) // notDetermined, authed
    {
        let handler: VoidFunction2<Bool, Bool> = { notDetermined, authed in
            DispatchQueue.mainAsync {
                callback(notDetermined, authed)
            }
        }

        let status = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch status {
        case .notDetermined:
            if requestIfNotDetermined {
                AVCaptureDevice.requestAccess(for: mediaType) { authed in
                    handler(true, authed)
                }
                onRequestAccess?()
            } else {
                handler(true, false)
            }
        case .denied,
             .restricted:
            handler(false, false)
        case .authorized:
            handler(false, true)
        default:
            break
        }
    }
}

public extension CaptureSession {
    func start() {
        runInSessionQueue { [weak self] in
            guard let self else {
                return
            }

            // Only setup observers and start the session running if setup succeeded.
            addObservers()
            session.startRunning()
        }
    }

    func stop() {
        runInSessionQueue { [weak self] in
            guard let self else {
                return
            }
            session.stopRunning()
            removeObservers(resetRunning: true)
        }
    }

    private func addObservers() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }

            isRunning = session.isRunning

            let observation = session.observe(\.isRunning, options: .new) { _, change in
                guard let isSessionRunning = change.newValue else {
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    self?.isRunning = isSessionRunning
                }
            }

            kvObservations.append(observation)

            let notificationCenter = NotificationCenter.default

            notificationCenter.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: session)
            notificationCenter.addObserver(self, selector: #selector(sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: session)
            notificationCenter.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: session)
        }
    }

    private func removeObservers(resetRunning: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }

            NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionInterruptionEnded, object: session)
            NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionWasInterrupted, object: session)
            NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionRuntimeError, object: session)

            for observation in kvObservations {
                observation.invalidate()
            }

            kvObservations.removeAll()
            if resetRunning {
                isRunning = false
            }
        }
    }

    @objc
    func sessionRuntimeError(notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            guard let self, let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else {
                return
            }

            Logger.shared.debug("Capture session runtime error: \(error)")

            if error.code == .mediaServicesWereReset {
                if isRunning {
                    runInSessionQueue {
                        self.session.startRunning()
                    }
                }
            }
        }
    }

    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            guard let self, let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
                  let reasonIntegerValue = userInfoValue.integerValue,
                  let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue)
            else {
                return
            }
            interrupt = .reason(reason)
        }
    }

    @objc
    func sessionInterruptionEnded(notification _: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            interrupt = .end
        }
    }
}

// MARK: CaptureSession.Interrupt

public extension CaptureSession {
    enum Interrupt: Equatable {
        case none
        case reason(AVCaptureSession.InterruptionReason)
        case end

        var isInterrupted: Bool {
            switch self {
            case .none:
                false
            case let .reason(interruptionReason):
                true
            case .end:
                false
            }
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none):
                true
            case (.end, .end):
                true
            default:
                false
            }
        }
    }
}
