//
//  Model.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

import UIKit
import Combine

// MARK: - ImageState
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public enum ImageState: Equatable {
    case loading
    case success(UIImage)
    case failure(ImageKitError)
    case empty
    
    public static func == (lhs: ImageState, rhs: ImageState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.empty, .empty):
            return true
        case (.success(let lhsImage), .success(let rhsImage)):
            return lhsImage === rhsImage
        case (.failure(let lhsError), .failure(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

// MARK: - ImageRequest
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public struct ImageRequest {
    public let url: URL
    public let processors: [ImageProcessor]
    public let priority: ImageLoadPriority
    public let cachePolicy: CachePolicy
    public let timeoutInterval: TimeInterval
    
    public init(
        url: URL,
        processors: [ImageProcessor] = [],
        priority: ImageLoadPriority = .normal,
        cachePolicy: CachePolicy = .returnCacheDataElseLoad,
        timeoutInterval: TimeInterval = 30
    ) {
        self.url = url
        self.processors = processors
        self.priority = priority
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
    }
    
    public var cacheKey: String {
        let processorsKey = processors.map { $0.identifier }.joined(separator: "_")
        return "\(url.absoluteString)_\(processorsKey)"
    }
}

// MARK: - ImageResponse
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public struct ImageResponse {
    public let image: UIImage
    public let source: ImageSource
    
    public init(image: UIImage, source: ImageSource) {
        self.image = image
        self.source = source
    }
}

// MARK: - ImageSource
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public enum ImageSource {
    case memoryCache
    case diskCache
    case network
}

// MARK: - ImageLoadPriority
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public enum ImageLoadPriority {
    case veryHigh
    case high
    case normal
    case low
    case veryLow
}

// MARK: - CachePolicy
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public enum CachePolicy {
    case returnCacheDataElseLoad
    case reloadIgnoringCache
    case cacheOnly
}

// MARK: - ImageTask
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public class ImageTask {
    public let request: ImageRequest
    private var completions: [(Result<ImageResponse, ImageKitError>) -> Void] = []
    private var isCancelled = false
    
    @Published public var progress: Double = 0.0
    public var progressPublisher: AnyPublisher<Double, Never> {
        $progress.eraseToAnyPublisher()
    }
    
    init(request: ImageRequest) {
        self.request = request
    }
    
    func addCompletion(_ completion: @escaping (Result<ImageResponse, ImageKitError>) -> Void) {
        completions.append(completion)
    }
    
    func complete(with result: Result<ImageResponse, ImageKitError>) {
        guard !isCancelled else { return }
        
        completions.forEach { $0(result) }
        completions.removeAll()
    }
    
    public func cancel() {
        isCancelled = true
        completions.removeAll()
    }
    
    public var cancelled: Bool {
        return isCancelled
    }
}

// MARK: - ImageKitError
@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public enum ImageKitError: Error, Equatable {
    case invalidURL
    case invalidImageData
    case networkError(Error)
    case processingFailed(Error)
    case invalidResponse
    case noData
    case cancelled
    
    public static func == (lhs: ImageKitError, rhs: ImageKitError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidImageData, .invalidImageData),
             (.invalidResponse, .invalidResponse),
             (.noData, .noData),
             (.cancelled, .cancelled):
            return true
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.processingFailed(let lhsError), .processingFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
    
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL provided"
        case .invalidImageData:
            return "Invalid image data received"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .processingFailed(let error):
            return "Image processing failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .noData:
            return "No data received"
        case .cancelled:
            return "Request was cancelled"
        }
    }
}
