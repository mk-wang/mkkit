//
//  AVFoundationExt.swift
//  MKKit
//
//  Created by MK on 2023/12/13.
//

import AVFoundation
import Foundation
import UIKit

public extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait:
            .portrait
        case .portraitUpsideDown:
            .portraitUpsideDown
        case .landscapeLeft:
            .landscapeLeft
        case .landscapeRight:
            .landscapeRight
        default:
            nil
        }
    }
}

public extension UIDeviceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait:
            .portrait
        case .portraitUpsideDown:
            .portraitUpsideDown
        case .landscapeLeft:
            .landscapeLeft
        case .landscapeRight:
            .landscapeRight
        default:
            nil
        }
    }

    var exifOrientation: CGImagePropertyOrientation {
        switch self {
        case .portraitUpsideDown:
            .rightMirrored
        case .landscapeLeft:
            .downMirrored
        case .landscapeRight:
            .upMirrored
        default:
            .leftMirrored
        }
    }
}

public extension CGRect {
    static var fullROI: Self {
        CGRectMake(0, 0, 1, 1)
    }
}

public extension AVCaptureDevice.Format {
    var resolution: CGSize {
        let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
        return .init(width: CGFloat(dimensions.width), height: CGFloat(dimensions.height))
    }

    var centerRect: CGRect {
        let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
        var size: CGSize = .init(width: 1, height: 1)

        if dimensions.height > dimensions.width {
            size.height = Double(dimensions.width) / Double(dimensions.height)
        } else {
            size.width = Double(dimensions.height) / Double(dimensions.width)
        }
        return .init(origin: .init((1 - size.width) / 2, (1 - size.height) / 2), size: size)
    }
}

public extension AVCaptureDevice {
    static func captureVideoDevice(front: Bool) -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: front ? .front : .back)
    }
}

public extension AVCaptureDevice {
    func withConfigurationLocked(_ block: (AVCaptureDevice) -> Void) -> Bool {
        do {
            try lockForConfiguration()
            defer {
                unlockForConfiguration()
            }
            block(self)
            return true
        } catch {
            Logger.shared.info("Could not lock for configuration: \(error)")
            return false
        }
    }

    var highestResolution420Format: (AVCaptureDevice.Format, CGSize)? {
        highestResolutionFormat(for: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
    }

    func highestResolutionFormat(for type: OSType) -> (AVCaptureDevice.Format, CGSize)? {
        var highestResolutionFormat: AVCaptureDevice.Format?
        var highestResolutionDimensions = CMVideoDimensions(width: 0, height: 0)

        for format in formats {
            let deviceFormat = format as AVCaptureDevice.Format

            let deviceFormatDescription = deviceFormat.formatDescription

            if CMFormatDescriptionGetMediaSubType(deviceFormatDescription) == type {
                let candidateDimensions = CMVideoFormatDescriptionGetDimensions(deviceFormatDescription)
                if (highestResolutionFormat == nil) || (candidateDimensions.width > highestResolutionDimensions.width) {
                    highestResolutionFormat = deviceFormat
                    highestResolutionDimensions = candidateDimensions
                }
            }
        }
        guard let highestResolutionFormat else {
            return nil
        }

        let resolution = CGSize(width: CGFloat(highestResolutionDimensions.width),
                                height: CGFloat(highestResolutionDimensions.height))

        return (highestResolutionFormat, resolution)
    }

    @available(iOS 15.0, *)
    @discardableResult
    func setRecommendedQRZoomFactor(minimumSize: CGFloat, rectOfInterestWidth: CGFloat) -> Bool {
        /*
         Optimize the user experience for scanning QR codes down to sizes of 20mm x 20mm.
         When scanning a QR code of that size, the user may need to get closer than the camera's minimum focus distance to fill the rect of interest.
         To have the QR code both fill the rect and still be in focus, we may need to apply some zoom.
         */
        let deviceMinimumFocusDistance = Float(minimumFocusDistance)
        guard deviceMinimumFocusDistance != -1 else {
            return false
        }

        let fieldOfView = activeFormat.videoFieldOfView
        let minimumSubjectDistanceForCode = minimumSubjectDistanceForCode(fieldOfView: fieldOfView,
                                                                          minimumSize: Float(minimumSize),
                                                                          previewFillPercentage: Float(rectOfInterestWidth))
        if minimumSubjectDistanceForCode < deviceMinimumFocusDistance {
            let zoomFactor: CGFloat = .init(deviceMinimumFocusDistance / minimumSubjectDistanceForCode)
            return withConfigurationLocked {
                $0.videoZoomFactor = zoomFactor
            }
        }
        return true
    }

    private func minimumSubjectDistanceForCode(fieldOfView: Float, minimumSize: Float, previewFillPercentage: Float) -> Float {
        /*
         Given the camera horizontal field of view, we can compute the distance (mm) to make a code
         of minimumCodeSize (mm) fill the previewFillPercentage.
         */
        let radians = fieldOfView * Float.pi / 360
        let filledCodeSize = minimumSize / previewFillPercentage
        return filledCodeSize / tan(radians)
    }
}

public extension AVCaptureOutput {
    @discardableResult
    func setupVideoConnection(isVideoMirrored: Bool? = nil,
                              videoOrientation: AVCaptureVideoOrientation? = nil) -> AVCaptureConnection?
    {
        guard let connection = connection(with: .video) else {
            return nil
        }

        connection.isEnabled = true

        if let isVideoMirrored {
            connection.isVideoMirrored = isVideoMirrored
        }

        if let videoOrientation {
            connection.videoOrientation = videoOrientation
        }
        return connection
    }
}

public extension AVPlayer {
    func genSnapshot() throws -> CGImage? {
        guard let asset = currentItem?.asset else {
            return nil
        }

        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.requestedTimeToleranceAfter = .zero
        imageGenerator.requestedTimeToleranceBefore = .zero

        return try imageGenerator.copyCGImage(at: currentTime(), actualTime: nil)
    }

    func snapshot(spaceBuilder: ValueBuilder<CGColorSpace>? = nil) throws -> UIImage? {
        guard var image = try? genSnapshot() else {
            return nil
        }
        if let space = spaceBuilder?() {
            image = image.copy(colorSpace: space) ?? image
        }
        return .init(cgImage: image)
    }
}

public extension AVAssetImageGenerator {
    static func snapshot(asset: AVAsset,
                         time: CMTime,
                         completion: @escaping VoidFunction2<CGImage?, Error?>)
    {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.requestedTimeToleranceAfter = .zero
        imageGenerator.requestedTimeToleranceBefore = .zero
        if #available(iOS 16.0, *) {
            imageGenerator.generateCGImageAsynchronously(for: time) { image, _, error in
                completion(image, error)
            }
        } else {
            DispatchQueue.global(qos: .background).async {
                do {
                    let image = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                    completion(image, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
}

public extension AVMetadataObject.ObjectType {
    private static let typesOfBarCode: [AVMetadataObject.ObjectType] = {
        var list: [AVMetadataObject.ObjectType] = [
            .code39,
            .code39Mod43,
            .code93,
            .code128,
            .ean8,
            .ean13,
            .interleaved2of5,
            .itf14,
            .upce,
        ]

        if #available(iOS 15.4, *) {
            list.append(contentsOf: [
                .codabar,
                .gs1DataBar,
                .gs1DataBarExpanded,
                .gs1DataBarLimited,
            ])
        }
        return list
    }()

    private static let typesOf2D: [AVMetadataObject.ObjectType] = {
        var list: [AVMetadataObject.ObjectType] = [
            .aztec,
            .dataMatrix,
            .pdf417,
            .qr,
        ]

        if #available(iOS 15.4, *) {
            list.append(contentsOf: [
                .microPDF417,
                .microQR,
            ])
        }
        return list
    }()

    var isBarcode: Bool {
        Self.typesOfBarCode.contains(self)
    }

    var is2D: Bool {
        Self.typesOf2D.contains(self)
    }

    var isFace: Bool {
        self == .face
    }

    var isBody: Bool {
        rawValue.lowercased().contains("body")
    }
}
