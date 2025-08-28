//
//  ImageKitMemoryCache.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

import UIKit

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public class ImageKitMemoryCache {
    private let cache = NSCache<NSString, UIImage>()
    private let lock = NSLock()
    
    public init() {
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 150
        cache.name = "ImageKit.MemoryCache"
    }
    
    public func image(for key: String) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        return cache.object(forKey: key as NSString)
    }
    
    public func setImage(_ image: UIImage, for key: String) {
        lock.lock()
        defer { lock.unlock() }
        
        let cost = Int(image.size.width * image.size.height * 4) 
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    public func removeImage(for key: String) {
        lock.lock()
        defer { lock.unlock() }
        cache.removeObject(forKey: key as NSString)
    }
    
    public func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAllObjects()
    }
}
