//
//  ImageKitConfiguration.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

import Foundation

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public class ImageKitConfiguration {
    @MainActor public static let shared = ImageKitConfiguration()
    
    public var maxMemoryCacheSize: Int = 150 * 1024 * 1024
    public var maxDiskCacheSize: Int = 200 * 1024 * 1024 
    public var maxConcurrentOperations: Int = 6
    public var defaultTimeoutInterval: TimeInterval = 30
    public var enableDiskCache: Bool = true
    public var enableMemoryCache: Bool = true
    public var enableProgressiveLoading: Bool = true
    public var enableImageOptimization: Bool = true
    
    private init() {}
    
    public func configure(
        maxMemoryCacheSize: Int? = nil,
        maxDiskCacheSize: Int? = nil,
        maxConcurrentOperations: Int? = nil,
        defaultTimeoutInterval: TimeInterval? = nil,
        enableDiskCache: Bool? = nil,
        enableMemoryCache: Bool? = nil,
        enableProgressiveLoading: Bool? = nil,
        enableImageOptimization: Bool? = nil
    ) {
        if let maxMemoryCacheSize = maxMemoryCacheSize {
            self.maxMemoryCacheSize = maxMemoryCacheSize
        }
        if let maxDiskCacheSize = maxDiskCacheSize {
            self.maxDiskCacheSize = maxDiskCacheSize
        }
        if let maxConcurrentOperations = maxConcurrentOperations {
            self.maxConcurrentOperations = maxConcurrentOperations
        }
        if let defaultTimeoutInterval = defaultTimeoutInterval {
            self.defaultTimeoutInterval = defaultTimeoutInterval
        }
        if let enableDiskCache = enableDiskCache {
            self.enableDiskCache = enableDiskCache
        }
        if let enableMemoryCache = enableMemoryCache {
            self.enableMemoryCache = enableMemoryCache
        }
        if let enableProgressiveLoading = enableProgressiveLoading {
            self.enableProgressiveLoading = enableProgressiveLoading
        }
        if let enableImageOptimization = enableImageOptimization {
            self.enableImageOptimization = enableImageOptimization
        }
    }
}
