//
//  ImageKit.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

import SwiftUI
import Combine
import os.log

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public struct ImageKit: View {
    private let url: URL?
    private let placeholder: AnyView?
    private let errorView: AnyView?
    private let transition: AnyTransition
    private let animation: Animation?
    private let processors: [ImageProcessor]
    private let priority: ImageLoadPriority
    private let cachePolicy: CachePolicy
    private let retryCount: Int
    private let timeout: TimeInterval
    
    @StateObject private var loader = ImageKitLoader()
    @State private var imageState: ImageState = .loading
    
    public init<P: View, E: View>(
        url: URL?,
        @ViewBuilder placeholder: @escaping () -> P = { ProgressView().progressViewStyle(CircularProgressViewStyle()) },
        @ViewBuilder errorView: @escaping () -> E = {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
        },
        transition: AnyTransition = .opacity,
        animation: Animation? = .easeInOut(duration: 0.3),
        processors: [ImageProcessor] = [],
        priority: ImageLoadPriority = .normal,
        cachePolicy: CachePolicy = .returnCacheDataElseLoad,
        retryCount: Int = 3,
        timeout: TimeInterval = 30
    ) {
        self.url = url
        self.placeholder = AnyView(placeholder())
        self.errorView = AnyView(errorView())
        self.transition = transition
        self.animation = animation
        self.processors = processors
        self.priority = priority
        self.cachePolicy = cachePolicy
        self.retryCount = retryCount
        self.timeout = timeout
    }
    
    public var body: some View {
        Group {
            switch imageState {
            case .loading:
                placeholder ?? AnyView(ProgressView())
            case .success(let image):
                Image(uiImage: image)
                    .resizable()
                    .transition(transition)
            case .failure:
                errorView ?? AnyView(
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                )
            case .empty:
                Color.clear
            }
        }
        .animation(animation, value: imageState)
        .onAppear {
            loadImage()
        }
        .onChange(of: url) { _ in
            loadImage()
        }
        .onReceive(loader.$state) { state in
            imageState = state
        }
    }
    
    private func loadImage() {
        guard let url = url else {
            imageState = .empty
            return
        }
        
        let request = ImageRequest(
            url: url,
            processors: processors,
            priority: priority,
            cachePolicy: cachePolicy,
            timeoutInterval: timeout
        )
        
        loader.loadImage(request: request, retryCount: retryCount)
    }
}
