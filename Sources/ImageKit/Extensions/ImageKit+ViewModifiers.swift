//
//  ImageKit+ViewModifiers.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

import SwiftUI

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
extension View {
    public func imageKit(
        url: URL?,
        processors: [ImageProcessor] = [],
        placeholder: @escaping () -> some View = { ProgressView() },
        errorView: @escaping () -> some View = { Image(systemName: "exclamationmark.triangle").foregroundColor(.red) },
        transition: AnyTransition = .opacity,
        animation: Animation? = .easeInOut(duration: 0.3)
    ) -> some View {
        overlay(
            ImageKit(
                url: url,
                placeholder: placeholder,
                errorView: errorView,
                transition: transition,
                animation: animation,
                processors: processors
            )
        )
    }
    
    public func prefetchImages(_ urls: [URL], priority: ImageLoadPriority = .low) -> some View {
        onAppear {
            ImageKitManager.shared.prefetchImages(urls: urls, priority: priority)
        }
    }
}
