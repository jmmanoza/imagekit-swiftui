//
//  ImageUtils.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

import UIKit
import UniformTypeIdentifiers

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public enum ImageFormat {
    case jpeg(quality: CGFloat)
    case png
    case heic(quality: CGFloat)
    case webp
    
    public var mimeType: String {
        switch self {
        case .jpeg: return "image/jpeg"
        case .png: return "image/png"
        case .heic: return "image/heic"
        case .webp: return "image/webp"
        }
    }
    
    public var fileExtension: String {
        switch self {
        case .jpeg: return "jpg"
        case .png: return "png"
        case .heic: return "heic"
        case .webp: return "webp"
        }
    }
}

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public class ImageUtils {
    public static func detectFormat(from data: Data) -> ImageFormat? {
        guard data.count >= 12 else { return nil }
        
        let bytes = data.prefix(12).map { $0 }
        
        // JPEG
        if bytes[0] == 0xFF && bytes[1] == 0xD8 {
            return .jpeg(quality: 0.8)
        }
        
        // PNG
        if bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 {
            return .png
        }
        
        // HEIC
        if bytes[4] == 0x66 && bytes[5] == 0x74 && bytes[6] == 0x79 && bytes[7] == 0x70 {
            return .heic(quality: 0.8)
        }
        
        // WebP
        if bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
           bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50 {
            return .webp
        }
        
        return nil
    }
    
    public static func compress(image: UIImage, to format: ImageFormat) -> Data? {
        switch format {
        case .jpeg(let quality):
            return image.jpegData(compressionQuality: quality)
        case .png:
            return image.pngData()
        case .heic(let quality):
            if #available(iOS 17.0, *) {
                return image.heifData(compressionQuality: quality)
            } else {
                return image.jpegData(compressionQuality: quality)
            }
        case .webp:
            return image.jpegData(compressionQuality: 0.8)
        }
    }
    
    public static func calculateMemoryFootprint(for size: CGSize) -> Int {
        return Int(size.width * size.height * 4)
    }
    
    @MainActor
    public static func optimalImageSize(for displaySize: CGSize,
                                        scale: CGFloat = UIScreen.main.scale) -> CGSize {
        CGSize(
            width: displaySize.width * scale,
            height: displaySize.height * scale
        )
    }
}

import UIKit
import ImageIO
import UniformTypeIdentifiers

extension UIImage {
    func heifData(compressionQuality: CGFloat = 1.0) -> Data? {
        let mutableData = NSMutableData()
  
        guard let cgImage = self.cgImage,
              let destination = CGImageDestinationCreateWithData(
                    mutableData,
                    UTType.heic.identifier as CFString,
                    1,
                    nil
              ) else {
            return nil
        }
        
        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
        CGImageDestinationFinalize(destination)
        
        return mutableData as Data
    }
}
