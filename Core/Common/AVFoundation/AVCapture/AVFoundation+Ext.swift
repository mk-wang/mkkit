//
//  AVFoundation+Ext.swift
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
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return nil
        }
    }
}

public extension UIDeviceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return nil
        }
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
    var highestResolution420Format: AVCaptureDevice.Format? {
        highestResolutionFormat(for: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
    }

    func highestResolutionFormat(for type: OSType) -> AVCaptureDevice.Format? {
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
        return highestResolutionFormat
    }

    func setRecommendedZoomFactor(minimumSize: CGFloat, rectOfInterestWidth: CGFloat) {
        /*
         Optimize the user experience for scanning QR codes down to sizes of 20mm x 20mm.
         When scanning a QR code of that size, the user may need to get closer than the camera's minimum focus distance to fill the rect of interest.
         To have the QR code both fill the rect and still be in focus, we may need to apply some zoom.
         */
        if #available(iOS 15.0, *) {
            let deviceMinimumFocusDistance = Float(self.minimumFocusDistance)
            guard deviceMinimumFocusDistance != -1 else {
                return
            }

            let fieldOfView = activeFormat.videoFieldOfView
            let minimumSubjectDistanceForCode = minimumSubjectDistanceForCode(fieldOfView: fieldOfView,
                                                                              minimumSize: Float(minimumSize),
                                                                              previewFillPercentage: Float(rectOfInterestWidth))
            if minimumSubjectDistanceForCode < deviceMinimumFocusDistance {
                let zoomFactor = deviceMinimumFocusDistance / minimumSubjectDistanceForCode
                do {
                    try lockForConfiguration()
                    videoZoomFactor = CGFloat(zoomFactor)
                    unlockForConfiguration()
                } catch {
                    Logger.shared.info("Could not lock for configuration: \(error)")
                }
            }
        } else {}
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
    func setupVideoConnection(front: Bool, videoOrientation: AVCaptureVideoOrientation) -> AVCaptureConnection? {
        guard let connection = connection(with: .video) else {
            return nil
        }

        if front {
            connection.isVideoMirrored = true
        }

        connection.videoOrientation = videoOrientation
        return connection
    }
}
