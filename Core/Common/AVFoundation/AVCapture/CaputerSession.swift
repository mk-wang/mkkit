//
//  CaputerSession.swift
//  MKKit
//
//  Created by MK on 2023/12/13.
//  https://developer.apple.com/documentation/avfoundation/capture_setup/avcambarcode_detecting_barcodes_and_faces

import AVFoundation
import Foundation
import OpenCombine

// MARK: - CaputerSession

open class CaputerSession {
    public let session = AVCaptureSession()
    public private(set) var useFrontCamera: Bool = true

    private let sessionQueue = DispatchQueue(label: "mkkit.session.queue") // Communicate with the session and other session objects on this queue.

    private lazy var videoDiscovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                       mediaType: .video,
                                                                       position: .unspecified)

    public private(set) var videoInput: AVCaptureDeviceInput?

    private var keyValueObservations = [NSKeyValueObservation]()

    private let interruptSubject = CurrentValueSubject<Interrupt, Never>(.none)
    public private(set) lazy var interruptPublisher = interruptSubject.eraseToAnyPublisher()
    public private(set) var interrupt: Interrupt {
        get {
            interruptSubject.value
        }
        set {
            DispatchQueue.main.async { [weak self] in
                if let self, self.interruptSubject.value != newValue {
                    self.interruptSubject.value = newValue
                }
            }
        }
    }

    private let runningSubject = CurrentValueSubject<Bool, Never>(false)
    public private(set) lazy var runningPublisher = runningSubject.eraseToAnyPublisher()
    public private(set) var isRuning: Bool {
        get {
            runningSubject.value
        }
        set {
            DispatchQueue.main.async { [weak self] in
                if let self, self.runningSubject.value != newValue {
                    self.runningSubject.value = newValue
                }
            }
        }
    }

    private var metadataOutput: AVCaptureMetadataOutput?
    private lazy var metadataObjectsQueue = DispatchQueue(label: "mk.video.meta.queue")
    private var previewView: VideoPreviewView?

    let preset: AVCaptureSession.Preset

    public init(useFrontCamera: Bool, preset: AVCaptureSession.Preset = .high) {
        self.useFrontCamera = useFrontCamera
        self.preset = preset
    }

    public func setupSession(configuration: @escaping (CaputerSession) -> Void) {
        runInSessionQueue { [weak self] in
            guard let self else {
                return
            }

            self.session.beginConfiguration()
            configuration(self)
            self.session.commitConfiguration()
        }
    }

    public func videoDevcieFor(front: Bool) -> AVCaptureDevice? {
        let position: AVCaptureDevice.Position = front ? .front : .back
        return videoDiscovery.devices.first(where: { $0.position == position })
    }

    public func runInSessionQueue(_ function: @escaping VoidFunction) {
        sessionQueue.async {
            function()
        }
    }
}

public extension CaputerSession {
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
    func switchCamera(front: Bool) -> Bool {
        guard useFrontCamera != front else {
            return true
        }

        guard let device = videoDevcieFor(front: front),
              let newInput = try? AVCaptureDeviceInput(device: device)
        else {
            return false
        }

        runInSessionQueue { [weak self] in
            guard let self else {
                return
            }

            session.beginConfiguration()

            if let videoInput {
                session.removeInput(videoInput)
            }

            let previousSessionPreset = session.sessionPreset
            session.sessionPreset = self.preset

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

            session.commitConfiguration()

            DispatchQueue.main.async { [weak self] in
                self?.useFrontCamera = front
            }
        }
        return true
    }
}

public extension CaputerSession {
    func start() {
        runInSessionQueue { [weak self] in
            guard let self else {
                return
            }

            // Only setup observers and start the session running if setup succeeded.
            self.addObservers()
            self.session.startRunning()
            let isRunning = self.session.isRunning
            self.isRuning = isRunning
        }
    }

    func stop() {
        runInSessionQueue { [weak self] in
            guard let self else {
                return
            }

            self.session.stopRunning()
            self.isRuning = self.session.isRunning
            self.removeObservers()
        }
    }

    private func addObservers() {
        var keyValueObservation: NSKeyValueObservation

        weak var weakSelf = self
        keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            weakSelf?.isRuning = isSessionRunning
        }
        keyValueObservations.append(keyValueObservation)

        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: session)
        notificationCenter.addObserver(self, selector: #selector(sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: session)
        notificationCenter.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: session)
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionInterruptionEnded, object: session)
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionRuntimeError, object: session)

        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }

    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else {
            return
        }

        Logger.shared.debug("Capture session runtime error: \(error)")

        if error.code == .mediaServicesWereReset {
            runInSessionQueue {
                if self.isRuning {
                    self.session.startRunning()
                    self.isRuning = self.session.isRunning
                }
            }
        }
    }

    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
           let reasonIntegerValue = userInfoValue.integerValue,
           let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue)
        {
            interrupt = .reason(reason)
        }
    }

    @objc
    func sessionInterruptionEnded(notification _: NSNotification) {
        interrupt = .end
    }
}

// MARK: CaputerSession.Interrupt

public extension CaputerSession {
    enum Interrupt {
        case none
        case reason(AVCaptureSession.InterruptionReason)
        case end

        var isInterrupted: Bool {
            self == .none || self == .end
        }
    }
}

// MARK: - CaputerSession.Interrupt + Comparable

extension CaputerSession.Interrupt: Comparable {
    public static func < (lhs: CaputerSession.Interrupt, rhs: CaputerSession.Interrupt) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case let (.reason(l), .reason(r)):
            return l == r
        case (.end, .end):
            return true
        default:
            return false
        }
    }
}
