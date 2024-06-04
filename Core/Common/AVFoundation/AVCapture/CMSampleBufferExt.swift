//
//  CMSampleBufferExt.swift
//  MKKit
//
//  Created by MK on 2024/6/2.
//

import CoreMedia
import Foundation

public extension CMSampleBuffer {
    var brightness: Double? {
        let raw = CMCopyDictionaryOfAttachments(allocator: nil,
                                                target: self,
                                                attachmentMode: .init(kCMAttachmentMode_ShouldPropagate))
        let metadata = CFDictionaryCreateMutableCopy(nil, 0, raw) as NSDictionary
        let exifData = metadata[kCGImagePropertyExifDictionary as String] as? NSDictionary
        let value = exifData?[kCGImagePropertyExifBrightnessValue as String]
        return value as? Double
    }
}
