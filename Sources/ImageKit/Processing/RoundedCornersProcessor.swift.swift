//
//  RoundedCornersProcessor.swift.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

import UIKit

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public struct RoundedCornersProcessor: ImageProcessor {
    public let cornerRadius: CGFloat
    public let corners: UIRectCorner
    
    public var identifier: String {
        return "rounded_\(cornerRadius)_\(corners.rawValue)"
    }
    
    public init(cornerRadius: CGFloat, corners: UIRectCorner = .allCorners) {
        self.cornerRadius = cornerRadius
        self.corners = corners
    }
    
    public func process(_ image: UIImage) throws -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: image.size)
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
            )
            
            path.addClip()
            image.draw(in: rect)
        }
    }
}
