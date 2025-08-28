//
//  ImageKitLoader.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

//import SwiftUI
//import Combine
//import os.log
//
//@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
//public class ImageKitLoader: ObservableObject {
//    @Published public var state: ImageState = .loading
//    @Published public var progress: Double = 0.0
//    
//    private var cancellables = Set<AnyCancellable>()
//    private let imageManager = ImageKitManager.shared
//    private var currentTask: ImageTask?
//    
//    public init() {}
//    
//    public func loadImage(request: ImageRequest, retryCount: Int = 3) {
//        // Cancel any existing task
//        currentTask?.cancel()
//        
//        state = .loading
//        progress = 0.0
//        
//        currentTask = imageManager.loadImage(request: request) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    self?.state = .success(response.image)
//                    self?.progress = 1.0
//                case .failure(let error):
//                    if retryCount > 0 {
//                        let delay = pow(2.0, Double(4 - retryCount)) * 0.5
//                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                            self?.loadImage(request: request, retryCount: retryCount - 1)
//                        }
//                    } else {
//                        self?.state = .failure(error)
//                    }
//                }
//            }
//        }
//        
//        currentTask?.progressPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] progress in
//                self?.progress = progress
//            }
//            .store(in: &cancellables)
//    }
//    
//    deinit {
//        currentTask?.cancel()
//    }
//}


import Foundation
import Combine

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
@MainActor
public class ImageKitLoader: ObservableObject {
    @Published public var state: ImageState = .loading
    @Published public var progress: Double = 0.0
    
    private var cancellables = Set<AnyCancellable>()
    private let imageManager = ImageKitManager.shared
    nonisolated(unsafe) private var currentTask: ImageTask?
    
    public init() {}
    
    public func loadImage(request: ImageRequest, retryCount: Int = 3) {
        // Cancel any existing task
        currentTask?.cancel()
        
        state = .loading
        progress = 0.0
        
        currentTask = imageManager.loadImage(request: request) { [weak self] result in
            // `self` is now MainActor-isolated automatically
            switch result {
            case .success(let response):
                self?.state = .success(response.image)
                self?.progress = 1.0
            case .failure(let error):
                if retryCount > 0 {
                    let delay = pow(2.0, Double(4 - retryCount)) * 0.5
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        self?.loadImage(request: request, retryCount: retryCount - 1)
                    }
                } else {
                    self?.state = .failure(error)
                }
            }
        }
        
        currentTask?.progressPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.progress = progress
            }
            .store(in: &cancellables)
    }
    
    deinit {
        let task = currentTask
        Task { @MainActor in
            task?.cancel()
        }
    }
}
