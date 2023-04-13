//
//  PHAssetCollectionExt.swift
//  AdbClient
//
//  Created by MK on 2023/4/13.
//

import Photos

public extension PHAssetCollection {
    var isRecentlyAdded: Bool {
        guard assetCollectionType == .smartAlbum else {
            return false
        }
        return assetCollectionSubtype == .smartAlbumRecentlyAdded
    }

    var isRecentlyDeleted: Bool {
        guard assetCollectionType == .smartAlbum else {
            return false
        }
        return assetCollectionSubtype.rawValue == 1_000_000_201
    }
}
