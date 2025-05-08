//
//  SVGImage.swift
//
//
//  Created by MK on 2022/3/26.
//

import SwiftDraw
import UIKit

// MARK: - SVGImageView

public class SVGImageView: UIImageView {
    let imageSize: CGSize
    let tintColorBuilder: ((Bool) -> UIColor?)?

    private var themeObs: AnyCancellableType?

    public init(url: URL,
                imageSize: CGSize,
                langFlip: Bool = false,
                listenTheme: Bool = false,
                aspectFit: Bool = false,
                tintColorBuilder: ((Bool) -> UIColor?)? = nil)
    {
        self.imageSize = imageSize
        self.tintColorBuilder = tintColorBuilder

        super.init(frame: CGRect(size: imageSize))

        contentMode = aspectFit ? .scaleAspectFit : .scaleToFill

        if listenTheme, tintColorBuilder != nil {
            themeObs = AppTheme.darkPublisher.sink(receiveValue: { [weak self] _ in
                self?.tintColor = self?.makeTintColor()
            })
        }

        var image = svgImage(url: url, size: imageSize, renderingMode: aspectFit ? .fit : .fill)

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

extension SVGImageView {
    private func makeTintColor() -> UIColor? {
        if let builder = tintColorBuilder, let color = builder(AppTheme.isDark) {
            return color
        }
        return nil
    }
}

// MARK: - SvgImageRenderingMode

public enum SvgImageRenderingMode {
    case fill
    case fit
    case width
    case height
}

public func svgImage(path: String, size: CGSize? = nil, scale: CGFloat = 0, renderingMode: SvgImageRenderingMode = .fill, insets: UIEdgeInsets = .zero) -> UIImage? {
    svgImage(url: URL(fileURLWithPath: path), size: size, scale: scale, renderingMode: renderingMode, insets: insets)
}

public func svgImage(url: URL, size: CGSize? = nil, scale: CGFloat = 0, renderingMode: SvgImageRenderingMode = .fill, insets: UIEdgeInsets = .zero) -> UIImage? {
    guard let svg = SwiftDraw.SVG(fileURL: url) else {
        return nil
    }
    return svgImage(svg: svg, size: size, scale: scale, renderingMode: renderingMode, insets: insets)
}

public func svgImage(data: Data, size: CGSize? = nil, scale: CGFloat = 0, renderingMode: SvgImageRenderingMode = .fill, insets: UIEdgeInsets = .zero) -> UIImage? {
    guard let svg = SwiftDraw.SVG(data: data) else {
        return nil
    }
    return svgImage(svg: svg, size: size, scale: scale, renderingMode: renderingMode, insets: insets)
}

private func svgImage(svg: SwiftDraw.SVG, size: CGSize? = nil, scale: CGFloat, renderingMode: SvgImageRenderingMode, insets: UIEdgeInsets) -> UIImage? {
    guard var size else {
        return .init(svg)
    }

    // fix size
    size.width = ceil(size.width)
    size.height = ceil(size.height)

    guard renderingMode != .fill else {
        #if canImport(MKKit13)
            return svg.rasterize(size: size, scale: scale)
        #else
            return svg.rasterize(with: size, scale: scale)
        #endif
    }

    let svgSize = svg.size
    var imageSize = size

    switch renderingMode {
    case .fit:
        imageSize = svgSize.scale(fit: size)
    case .width:
        imageSize = svgSize.scale(width: size.width)
    case .height:
        imageSize = svgSize.scale(height: size.height)
    default:
        break
    }

    #if canImport(MKKit13)
        return svg.rasterize(size: imageSize, scale: scale)
    #else
        return svg.rasterize(with: imageSize, scale: scale, insets: insets)
    #endif
}
