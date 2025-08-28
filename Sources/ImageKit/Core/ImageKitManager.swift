//
//  ImageKitManager.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

import UIKit
import Combine
import os.log

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public class ImageKitManager {
    @MainActor public static let shared = ImageKitManager()
    
    private let memoryCache = ImageKitMemoryCache()
    private let diskCache = ImageKitDiskCache()
    private let networkManager = NetworkManager()
    private let processingQueue = DispatchQueue(label: "imagekit.processing", qos: .userInitiated)
    private let logger = Logger(subsystem: "ImageKit", category: "Manager")
    
    private var activeTasks: [String: ImageTask] = [:]
    private let taskQueue = DispatchQueue(label: "imagekit.tasks", attributes: .concurrent)
    
    private init() {
        setupMemoryWarningObserver()
    }
    
    @discardableResult
    public func loadImage(request: ImageRequest, completion: @escaping (Result<ImageResponse, ImageKitError>) -> Void) -> ImageTask {
        let cacheKey = request.cacheKey
        
        // Check if task already exists
        if let existingTask = activeTasks[cacheKey] {
            existingTask.addCompletion(completion)
            return existingTask
        }
        
        let task = ImageTask(request: request)
        task.addCompletion(completion)
        activeTasks[cacheKey] = task
        
        // Check memory cache first
        if let cachedImage = memoryCache.image(for: cacheKey) {
            let response = ImageResponse(image: cachedImage, source: .memoryCache)
            task.complete(with: .success(response))
            activeTasks.removeValue(forKey: cacheKey)
            return task
        }
        
        // Check disk cache if policy allows
        if request.cachePolicy != .reloadIgnoringCache {
            diskCache.image(for: cacheKey) { [weak self] diskImage in
                if let image = diskImage {
                    let response = ImageResponse(image: image, source: .diskCache)
                    task.complete(with: .success(response))
                    self?.memoryCache.setImage(image, for: cacheKey)
                    self?.activeTasks.removeValue(forKey: cacheKey)
                } else {
                    self?.downloadImage(task: task)
                }
            }
        } else {
            downloadImage(task: task)
        }
        
        return task
    }
    
    private func downloadImage(task: ImageTask) {
        let request = task.request
        let cacheKey = request.cacheKey
        
        networkManager.downloadImage(url: request.url, timeout: request.timeoutInterval) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.processingQueue.async {
                    self.processImageData(data, task: task)
                }
            case .failure(let error):
                task.complete(with: .failure(ImageKitError.networkError(error)))
                self.activeTasks.removeValue(forKey: cacheKey)
            }
        }
    }
    
    private func processImageData(_ data: Data, task: ImageTask) {
        let request = task.request
        let cacheKey = request.cacheKey
        
        guard var image = UIImage(data: data) else {
            task.complete(with: .failure(ImageKitError.invalidImageData))
            activeTasks.removeValue(forKey: cacheKey)
            return
        }
        
        // Apply image processors
        for processor in request.processors {
            do {
                image = try processor.process(image)
            } catch {
                task.complete(with: .failure(ImageKitError.processingFailed(error)))
                activeTasks.removeValue(forKey: cacheKey)
                return
            }
        }
        
        // Cache the processed image
        memoryCache.setImage(image, for: cacheKey)
        diskCache.setImage(image, for: cacheKey, originalData: data)
        
        let response = ImageResponse(image: image, source: .network)
        task.complete(with: .success(response))
        activeTasks.removeValue(forKey: cacheKey)
    }
    
    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.memoryCache.removeAll()
        }
    }
    
    public func prefetchImages(urls: [URL], priority: ImageLoadPriority = .low) {
        for url in urls {
            let request = ImageRequest(url: url, priority: priority)
            loadImage(request: request) { _ in
                // Prefetch completion - no action needed
            }
        }
    }
    
    public func cancelAll() {
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
    }
}
