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
    let path: String
    let imageSize: CGSize
    let tintColorBuilder: ((Bool) -> UIColor?)?

    private var cancellbale: AnyCancellable?

    public init(path: String,
                imageSize: CGSize,
                langFlip: Bool = false,
                listenTheme: Bool = false,
                tintColorBuilder: ((Bool) -> UIColor?)? = nil)
    {
        self.path = path
        self.imageSize = imageSize
        self.tintColorBuilder = tintColorBuilder
        super.init(frame: CGRect(size: imageSize))

        if listenTheme, tintColorBuilder != nil {
            cancellbale = subjectThemeChange()
        }

        var image = svgImage(path: path, size: imageSize)
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
    }

    convenience init(url: URL,
                     iconSize size: CGFloat,
                     listenTheme: Bool = false,
                     tintColorBuilder: ((Bool) -> UIColor?)? = nil)
    {
        self.init(path: url.path,
                  imageSize: CGSize(width: size, height: size),
                  listenTheme: listenTheme,
                  tintColorBuilder: tintColorBuilder)
    }

    convenience init(path: String,
                     iconSize size: CGFloat,
                     listenTheme: Bool = false,
                     tintColorBuilder: ((Bool) -> UIColor?)? = nil)
    {
        self.init(path: path,
                  imageSize: CGSize(width: size, height: size),
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

public func svgImage(path: String, size: CGSize) -> UIImage? {
    let url = URL(fileURLWithPath: path)
    guard let svgImage = SwiftDraw.SVG(fileURL: url) else {
        return nil
    }
    return svgImage.rasterize(with: size)
}
