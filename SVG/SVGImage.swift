//
//  SVGImage.swift
//
//
//  Created by MK on 2022/3/26.
//

import OpenCombine
import SwiftDraw
import UIKit

// MARK: - SVGImageView

public class SVGImageView: UIImageView {
    let imageSize: CGSize
    let tintColorBuilder: ((Bool) -> UIColor?)?

    private var cancellbale: AnyCancellable?

    public init(url: URL,
                imageSize: CGSize,
                langFlip: Bool = false,
                listenTheme: Bool = false,
                tintColorBuilder: ((Bool) -> UIColor?)? = nil)
    {
        self.imageSize = imageSize
        self.tintColorBuilder = tintColorBuilder

        super.init(frame: CGRect(size: imageSize))

        if listenTheme, tintColorBuilder != nil {
            cancellbale = subjectThemeChange()
        }

        var image = svgImage(url: url, size: imageSize)
        let color = makeTintColor()
        if listenTheme || color != nil {
            image = image?.withRenderingMode(.alwaysTemplate)
            tintColor = color
        }

        if langFlip {
            image = image?.langFlip
        }

        self.image = image
        backgroundColor = .clear

        addConstraints([
            .init(item: self,
                  attribute: .width,
                  relatedBy: .equal,
                  toItem: nil,
                  attribute: .notAnAttribute,
                  multiplier: 1,
                  constant: imageSize.width),

            .init(item: self,
                  attribute: .height,
                  relatedBy: .equal,
                  toItem: nil,
                  attribute: .notAnAttribute,
                  multiplier: 1,
                  constant: imageSize.height),
        ])
    }

    public convenience init(path: String,
                            imageSize: CGSize,
                            langFlip: Bool = false,
                            listenTheme: Bool = false,
                            tintColorBuilder: ((Bool) -> UIColor?)? = nil)
    {
        self.init(url: URL(fileURLWithPath: path),
                  imageSize: imageSize,
                  langFlip: langFlip,
                  listenTheme: listenTheme,
                  tintColorBuilder: tintColorBuilder)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: ThemeChangeListener

extension SVGImageView: ThemeChangeListener {
    private func makeTintColor() -> UIColor? {
        if let builder = tintColorBuilder, let color = builder(AppTheme.current.isDark ?? false) {
            return color
        }
        return nil
    }

    public func onThemeChange(isDark _: Bool) {
        tintColor = makeTintColor()
    }
}

public func svgImage(path: String, size: CGSize? = nil) -> UIImage? {
    svgImage(url: URL(fileURLWithPath: path), size: size)
}

public func svgImage(url: URL, size: CGSize? = nil) -> UIImage? {
    guard let svgImage = SwiftDraw.SVG(fileURL: url) else {
        return nil
    }
    if let size {
        return svgImage.rasterize(with: size)
    } else {
        return UIImage(svgImage)
    }
}

public func svgImage(data: Data, size: CGSize? = nil) -> UIImage? {
    guard let svgImage = SwiftDraw.SVG(data: data) else {
        return nil
    }
    if let size {
        return svgImage.rasterize(with: size)
    } else {
        return UIImage(svgImage)
    }
}
