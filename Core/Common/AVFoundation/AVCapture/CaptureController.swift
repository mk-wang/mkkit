//
//  CaptureController.swift
//  FaceYoga
//
//  Created by MK on 2025/2/22.
//

import AVFoundation
import MKKit

// MARK: - CaptureController

open class CaptureController {
    public let frontCameraSubject: CurrentValueSubjectType<Bool, Never>
    public let present: AVCaptureSession.Preset

    public private(set) lazy var session = CaptureSession(useFrontCamera: frontCameraSubject.value,
                                                          preset: present)
    public private(set) var sessionStarted = false

    public private(set) var metaOutput: AVCaptureMetadataOutput?
    public private(set) var videoOutput: AVCaptureVideoDataOutput?

    private var frontCameraObs: AnyCancellableType?

    private var sessionRunningObs: AnyCancellableType?
    private var regionOfInterestObs: AnyCancellableType?

    open weak var cameraView: VideoPreviewView? {
        didSet {
            cameraView?.session = session.session
        }
    }

    public init(present: AVCaptureSession.Preset,
                frontCameraSubject: CurrentValueSubjectType<Bool, Never>)
    {
        self.present = present
        self.frontCameraSubject = frontCameraSubject
    }

    open func setupSession(configuration: @escaping ValueBuilder1<Bool, CaptureController>,
                           callback: VoidFunction1<Bool>? = nil)
    {
        Logger.shared.debug("setupSession0")
        cameraView?.session = session.session
        let front = frontCameraSubject.value

        session.setupSession { [weak self] _ in
            guard let self, addDevice(front: front) else {
                Logger.shared.error("setupSession: addDevice failed")
                callback?(false)
                return
            }

            guard configuration(self) else {
                Logger.shared.error("setupSession: configuration failed")
                callback?(false)
                return
            }

            callback?(true)
            Logger.shared.debug("setupSession2")
        }
    }
}

extension CaptureController {
    @objc
    open func addDevice(front: Bool) -> Bool {
        guard let device = session.videoDevcieFor(front: front) else {
            Logger.shared.error("cannot find videoDevcieFor for front \(front)")
            return false
        }
        do {
            guard try session.addVideoDevice(device) else {
                Logger.shared.error("cannot addVideoDevice for front \(front)")
                return false
            }
            return true
        } catch {
            Logger.shared.error("setupSession front \(front): \(error)")
            return false
        }
    }
}

extension CaptureController {
    @discardableResult
    @objc
    open func startSession() -> Bool {
        guard !sessionStarted else {
            return false
        }
        sessionStarted = true

        Logger.shared.debug("FaceCameraContoller startSession")

        session.start()
        addSessionObs()
        cameraView?.showDrawLayer(true)
        return true
    }

    @objc
    open func stopSession() {
        guard sessionStarted else {
            return
        }

        sessionStarted = false
        Logger.shared.debug("FaceCameraContoller stopSession")
        removeSessionObserver()
        session.stop()
        cameraView?.showDrawLayer(false)
    }

    @objc
    open func addSessionObs() {
        sessionRunningObs = session.runningPublisher
            .sink(receiveValue: { [weak self] running in
                Logger.shared.debug("FaceCameraContoller running \(running)")
                guard let self else {
                    return
                }

                guard running else {
                    regionOfInterestObs = nil
                    return
                }

                guard let cameraView else {
                    return
                }

                cameraView.configCamera()

                regionOfInterestObs = cameraView
                    .regionOfInterestPublisher
                    .sink { [weak self] rect in
                        guard let self else {
                            return
                        }

                        let metaRect = cameraView.metadataRectOfInterest
                        session.runInSessionQueue { [weak self] in
                            self?.metaOutput?.rectOfInterest = metaRect
                        }
                        Logger.shared.debug("updatImageInterest \(rect) \(metaRect)")
                    }
            })
    }

    @objc
    open func removeSessionObserver() {
        regionOfInterestObs = nil
        sessionRunningObs = nil
    }
}

extension CaptureController {
    @discardableResult
    @objc
    open func addMetadataDevice(typesBuilder: ValueBuilder1<[AVMetadataObject.ObjectType], AVCaptureMetadataOutput>) -> AVCaptureMetadataOutput? {
        let output = AVCaptureMetadataOutput()

        let front = session.useFrontCamera
        guard session.addOutput(output) else {
            Logger.shared.error("cannot add metaOutput for front \(front)")
            return nil
        }

        let types = typesBuilder(output)
        let list = output.availableMetadataObjectTypes
        guard types.isNotEmpty, types.allSatisfy({ list.contains($0) }) else {
            Logger.shared.error("metaOutput has no \(types) for front \(front)")
            return nil
        }
        output.metadataObjectTypes = types
        metaOutput = output
        return output
    }

    @discardableResult
    @objc
    open func addVideoDataOutput() -> AVCaptureVideoDataOutput? {
        let front = session.useFrontCamera

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true

        guard session.addOutput(output) else {
            Logger.shared.error("cannot add videoDataOutput for front \(front)")
            return nil
        }

        videoOutput = output
        return output
    }
}

extension CaptureController {
    @objc
    open func handleSwitchCamera(configuration: VoidFunction1<Bool>? = nil,
                                 callback: VoidFunction? = nil)
    {
        frontCameraObs = frontCameraSubject
            .removeDuplicatesDropAndDebounce(debounce: 0.001)
            .sink { [weak self] front in
                guard let self else {
                    return
                }
                session.switchCamera(front: front,
                                     configuration: { front in
                                         configuration?(front)
                                     },
                                     callback: callback)
            }
    }
}
