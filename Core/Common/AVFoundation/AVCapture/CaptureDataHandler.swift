//
//  CaptureDataHandler.swift
//
//  Created by MK on 2025/2/21.
//

import AVFoundation
import MKKit

// MARK: - CaptureDataHandler

open class CaptureDataHandler: NSObject {
    public var onMetadataOutput: VoidFunction3<AVCaptureMetadataOutput, [AVMetadataObject], AVCaptureConnection>?
    public var onVideoOutput: VoidFunction3<AVCaptureOutput, CMSampleBuffer, AVCaptureConnection>?

    private let dataOutputQueue = DispatchQueue(label: "com.simplehealth.camera.data.output")

    private let imageSubject: CurrentValueSubjectType<ImageInfo?, Never> = .init(nil)
    public private(set) lazy var imageInfoPublisher = imageSubject.debounceOnMain(for: 0.01).share().eraseToAnyPublisher()

    open var metaTypesBuilder: ValueBuilder1<[AVMetadataObject.ObjectType], AVCaptureMetadataOutput> =
        { $0.availableMetadataObjectTypes }

    // 只能再 dataOutputQueue 调用
    open var imageInfo: ImageInfo? {
        get {
            imageSubject.value
        }
        set {
            imageSubject.value = newValue
        }
    }

    // 只能再 dataOutputQueue 调用
    open var imageBuffer: CVImageBuffer?

    open weak var metaOutput: AVCaptureMetadataOutput? {
        didSet {
            metaOutput?.setMetadataObjectsDelegate(self, queue: dataOutputQueue)
        }
    }

    open weak var videoOutput: AVCaptureVideoDataOutput? {
        didSet {
            videoOutput?.setSampleBufferDelegate(self, queue: dataOutputQueue)
        }
    }

    public func runInDataOutputQueue(_ block: @escaping VoidFunction) {
        dataOutputQueue.async {
            block()
        }
    }

    open func cleanData(_ block: VoidFunction? = nil) {
        runInDataOutputQueue { [weak self] in
            self?.imageInfo = nil
            self?.imageBuffer = nil
            block?()
        }
    }
}

// MARK: AVCaptureMetadataOutputObjectsDelegate

extension CaptureDataHandler: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ metaOutput: AVCaptureMetadataOutput,
                               didOutput metaObjects: [AVMetadataObject],
                               from connect: AVCaptureConnection)
    {
        onMetadataOutput?(metaOutput, metaObjects, connect)
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension CaptureDataHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ captureOutput: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connect: AVCaptureConnection)
    {
        if let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            imageBuffer = buffer
        }

        onVideoOutput?(captureOutput, sampleBuffer, connect)
    }
}

// MARK: CaptureDataHandler.ImageInfo

public extension CaptureDataHandler {
    struct ImageInfo {
        public let buffer: CVImageBuffer

        public init(buffer: CVImageBuffer) {
            self.buffer = buffer
        }

        public var imageSize: CGSize {
            .init(width: CVPixelBufferGetWidth(buffer),
                  height: CVPixelBufferGetHeight(buffer))
        }

        public func getImage(crop: CGRect? = nil) -> UIImage {
            guard let cgImage = CGImage.create(pixelBuffer: buffer) else {
                return .init()
            }
            var image = UIImage(cgImage: cgImage)
            if let crop {
                image = image.cropped(to: crop)
            }
            return image
        }

        public func getImage(roiRect: CGRect) -> UIImage {
            var cropRect = roiRect.scale(imageSize)
            cropRect = .init(center: cropRect.center,
                             size: .square(cropRect.size.width.cgfFloor))
            return getImage(crop: cropRect)
        }
    }
}
