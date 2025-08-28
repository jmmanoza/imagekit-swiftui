//
//  BlurProcessor.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

import UIKit
import CoreImage

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public struct BlurProcessor: ImageProcessor {
    public let radius: Float
    
    public var identifier: String {
        return "blur_\(radius)"
    }
    
    public init(radius: Float) {
        self.radius = radius
    }
    
    public func process(_ image: UIImage) throws -> UIImage {
        guard let ciImage = CIImage(image: image) else {
            throw ImageKitError.processingFailed(NSError(domain: "BlurProcessor", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create CIImage"]))
        }
        
        guard let filter = CIFilter(name: "CIGaussianBlur") else {
            throw ImageKitError.processingFailed(NSError(
                domain: "BlurProcessor",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create Gaussian Blur filter"]
            ))
        }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter.outputImage else {
            throw ImageKitError.processingFailed(NSError(domain: "BlurProcessor", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to apply blur filter"]))
        }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            throw ImageKitError.processingFailed(NSError(domain: "BlurProcessor", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create CGImage"]))
        }
        
        return UIImage(cgImage: cgImage)
    }
}
