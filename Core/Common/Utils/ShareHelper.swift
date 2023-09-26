//
//  ShareHelper.swift
//  YXPDF
//
//  Created by MK on 2022/6/5.
//

import Foundation
import UIKit

// MARK: - ShareItem

//// MARK: - ShareItem
//
open class ShareItem: NSObject, UIActivityItemSource {
    public let text: String
    public let subject: String?

    public init(text: String, subject: String?) {
        self.text = text
        self.subject = subject
        super.init()
    }

    public func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        text
    }

    public func activityViewController(_: UIActivityViewController,
                                       itemForActivityType _: UIActivity.ActivityType?) -> Any?
    {
        text
    }

    public func activityViewController(_: UIActivityViewController,
                                       subjectForActivityType _: UIActivity.ActivityType?) -> String
    {
        subject ?? ""
    }
}

// MARK: - ShareHelper

public enum ShareHelper {
    public static func share(in vc: UIViewController,
                             text: String,
                             images: [UIImage]? = nil,
                             subject: String? = nil)
    {
        var items: [Any] = [ShareItem(text: text, subject: subject)]
        if let images, images.isNotEmpty {
            items.append(contentsOf: images)
        }

        let activityController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        vc.present(activityController, animated: true)
    }

    public static func share(in vc: UIViewController,
                             files: [URL],
                             onDismissed: ((Bool) -> Void)? = nil)
    {
        let activityController = UIActivityViewController(
            activityItems: files,
            applicationActivities: nil
        )

        if let cb = onDismissed {
            activityController.completionWithItemsHandler = { _, completed, _, _ in
                cb(completed)
            }
        }
        vc.present(activityController, animated: true)
    }
}
