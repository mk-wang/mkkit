//
//  CGImageExt.swift
//  MKKit
//
//  Created by MK on 2023/12/14.
//
import CoreGraphics
import Foundation
import VideoToolbox

public extension CGImage {
    /**

     from https://github.com/hollance/CoreMLHelpers

     Creates a new CGImage from a CVPixelBuffer.

     - Note: Not all CVPixelBuffer pixel formats support conversion into a
     CGImage-compatible pixel format.
     */
    static func create(pixelBuffer: CVPixelBuffer) -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        return cgImage
    }
}
