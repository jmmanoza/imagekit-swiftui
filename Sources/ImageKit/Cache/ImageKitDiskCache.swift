//
//  ImageKitDiskCache.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

import UIKit
import CryptoKit

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public class ImageKitDiskCache {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let ioQueue = DispatchQueue(label: "imagekit.disk.io", qos: .utility)
    private let maxCacheSize: Int = 200 * 1024 * 1024 
    
    public init() {
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cacheDir.appendingPathComponent("ImageKit")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        setupCacheCleanup()
    }
    
    public func image(for key: String, completion: @escaping (UIImage?) -> Void) {
        ioQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let url = self.fileURL(for: key)
            guard let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // Update access time
            try? self.fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: url.path)
            
            DispatchQueue.main.async { completion(image) }
        }
    }
    
    public func setImage(_ image: UIImage, for key: String, originalData: Data? = nil) {
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            
            let url = self.fileURL(for: key)
            let data = originalData ?? image.pngData()
            
            try? data?.write(to: url)
            self.cleanupIfNeeded()
        }
    }
    
    private func fileURL(for key: String) -> URL {
        let hashedKey = SHA256.hash(data: key.data(using: .utf8)!)
        let fileName = hashedKey.compactMap { String(format: "%02x", $0) }.joined()
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    private func setupCacheCleanup() {
        // Clean up cache on app launch
        ioQueue.async { [weak self] in
            self?.cleanupIfNeeded()
        }
    }
    
    private func cleanupIfNeeded() {
        do {
            let files = try fileManager.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]
            )
            
            let totalSize = files.reduce(0) { total, url in
                let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                return total + size
            }
            
            if totalSize > maxCacheSize {
                // Sort by modification date (oldest first)
                let sortedFiles = files.sorted { url1, url2 in
                    let date1 = (try? url1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                    let date2 = (try? url2.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
                    return date1 < date2
                }
                
                var currentSize = totalSize
                for file in sortedFiles {
                    if currentSize <= maxCacheSize * 3/4 { break }
                    
                    let fileSize = (try? file.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                    try? fileManager.removeItem(at: file)
                    currentSize -= fileSize
                }
            }
        } catch {
            // Handle cleanup errors silently
        }
    }
    
    public func removeAll() {
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            try? self.fileManager.removeItem(at: self.cacheDirectory)
            try? self.fileManager.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
        }
    }
}
