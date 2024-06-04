//
//  VideoPreviewView.swift
//  MKKit
//
//  Created by MK on 2023/12/12.
//  https://developer.apple.com/documentation/avfoundation/capture_setup/avcambarcode_detecting_barcodes_and_faces

import AVFoundation
import Foundation
import OpenCombine
import UIKit

// MARK: - VideoPreviewView

open class VideoPreviewView: UIView {
    override open class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    public var canShowRegionOfInterest: Bool = false

    private(set) lazy var regionOfInterestSubject: CurrentValueSubject<CGRect, Never> = .init(self.bounds)
    public private(set) lazy var regionOfInterestPublihser = regionOfInterestSubject.removeDuplicatesDropAndDebounce(0, debounce: 0.1).eraseToAnyPublisher()

    public lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = layer as! AVCaptureVideoPreviewLayer

    private lazy var drawLayer = CALayer()

    public var minimumRegionOfInterestSize: CGFloat = 50

    private lazy var regionOfInterestOutline: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(rect: regionOfInterest).cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.yellow.cgColor
        return layer
    }()

    override open func layoutSubviews() {
        super.layoutSubviews()

        if drawLayer.superlayer == nil {
            layer.addSublayer(drawLayer)
        }

        guard canShowRegionOfInterest else {
            return
        }

        if regionOfInterestOutline.superlayer == nil {
            addToDrawLayer(regionOfInterestOutline)
        }

        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        path.append(UIBezierPath(rect: regionOfInterest))
        path.usesEvenOddFillRule = true

        regionOfInterestOutline.path = CGPath(rect: regionOfInterest, transform: nil)
    }

    public var previewROIRect: CGRect {
        videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: videoPreviewLayer.bounds)
    }
}

public extension VideoPreviewView {
    func showDrawLayer(_ show: Bool) {
        UIView.runDisableActions { [weak self] in
            guard let self else {
                return
            }
            drawLayer.isHidden = !show
        }
    }

    func addToDrawLayer(_ layer: CALayer) {
        UIView.runDisableActions { [weak self] in
            self?.drawLayer.addSublayer(layer)
        }
    }

    private(set) var regionOfInterest: CGRect {
        get {
            regionOfInterestSubject.value
        }

        set {
            if newValue != regionOfInterestSubject.value {
                regionOfInterestSubject.value = newValue
                if canShowRegionOfInterest {
                    setNeedsLayout()
                }
            }
        }
    }

    var session: AVCaptureSession? {
        get {
            videoPreviewLayer.session
        }

        set {
            videoPreviewLayer.session = newValue
        }
    }

    func regionOfInterestWithProposedRegion(_ proposedRegionOfInterest: CGRect) -> CGRect {
        // We standardize to ensure we have positive widths and heights with an origin at the top left.
        let videoPreviewRect = videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: .fullROI).standardized

        /*
         Intersect the video preview view with the view's frame to only get
         the visible portions of the video preview view.
         */
        let visibleVideoPreviewRect = videoPreviewRect.intersection(bounds)

        let oldRegionOfInterest = regionOfInterest
        var newRegionOfInterest = proposedRegionOfInterest.standardized

        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0

        if !visibleVideoPreviewRect.contains(newRegionOfInterest.origin) {
            xOffset = max(visibleVideoPreviewRect.minX - newRegionOfInterest.minX, CGFloat(0))
            yOffset = max(visibleVideoPreviewRect.minY - newRegionOfInterest.minY, CGFloat(0))
        }

        if !visibleVideoPreviewRect.contains(CGPoint(x: visibleVideoPreviewRect.maxX, y: visibleVideoPreviewRect.maxY)) {
            xOffset = min(visibleVideoPreviewRect.maxX - newRegionOfInterest.maxX, xOffset)
            yOffset = min(visibleVideoPreviewRect.maxY - newRegionOfInterest.maxY, yOffset)
        }

        newRegionOfInterest = newRegionOfInterest.offsetBy(dx: xOffset, dy: yOffset)

        // Clamp the size when the region of interest is being resized.
        newRegionOfInterest = visibleVideoPreviewRect.intersection(newRegionOfInterest)

        // Fix a minimum width of the region of interest.
        if proposedRegionOfInterest.size.width < minimumRegionOfInterestSize {
            newRegionOfInterest.origin = oldRegionOfInterest.origin
            newRegionOfInterest.size.width = minimumRegionOfInterestSize
        }

        // Fix a minimum height of the region of interest.
        if proposedRegionOfInterest.size.height < minimumRegionOfInterestSize {
            newRegionOfInterest.origin = oldRegionOfInterest.origin
            newRegionOfInterest.size.height = minimumRegionOfInterestSize
        }
        return newRegionOfInterest
    }

    /**
     Updates the region of interest with a proposed region of interest ensuring
     the new region of interest is within the bounds of the video preview. When
     a new region of interest is set, the region of interest is redrawn.
     */
    @objc func setRegionOfInterestWithProposedRegion(_ rect: CGRect) {
        regionOfInterest = regionOfInterestWithProposedRegion(rect)
    }
}

public extension VideoPreviewView {
    func convertDevice(point: CGPoint, rect: CGRect) -> CGPoint {
        let drowablePoint = CGPoint(x: point.x * rect.size.width + rect.origin.x,
                                    y: point.y * rect.size.height + rect.origin.y)

        return videoPreviewLayer.layerPointConverted(fromCaptureDevicePoint: drowablePoint)
    }

    func convertDevice(rect: CGRect) -> CGRect {
        videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: rect)
    }
}
