//
//  ResizeProcessor.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

import UIKit

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public struct ResizeProcessor: ImageProcessor {
    public let targetSize: CGSize
    public let contentMode: UIView.ContentMode
    
    public var identifier: String {
        return "resize_\(Int(targetSize.width))x\(Int(targetSize.height))_\(contentMode.rawValue)"
    }
    
    public init(targetSize: CGSize, contentMode: UIView.ContentMode = .scaleAspectFill) {
        self.targetSize = targetSize
        self.contentMode = contentMode
    }
    
    public func process(_ image: UIImage) throws -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { context in
            var drawRect: CGRect
            
            switch contentMode {
            case .scaleAspectFit:
                let scale = min(targetSize.width / image.size.width, targetSize.height / image.size.height)
                let scaledSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                drawRect = CGRect(
                    x: (targetSize.width - scaledSize.width) / 2,
                    y: (targetSize.height - scaledSize.height) / 2,
                    width: scaledSize.width,
                    height: scaledSize.height
                )
            case .scaleAspectFill:
                let scale = max(targetSize.width / image.size.width, targetSize.height / image.size.height)
                let scaledSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                drawRect = CGRect(
                    x: (targetSize.width - scaledSize.width) / 2,
                    y: (targetSize.height - scaledSize.height) / 2,
                    width: scaledSize.width,
                    height: scaledSize.height
                )
            default:
                drawRect = CGRect(origin: .zero, size: targetSize)
            }
            
            image.draw(in: drawRect)
        }
    }
}
