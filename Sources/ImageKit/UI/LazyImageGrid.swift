//
//  LazyImageGrid.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

import SwiftUI

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public struct LazyImageGrid<Content: View>: View {
    let urls: [URL]
    let columns: [GridItem]
    let spacing: CGFloat
    let content: (URL, Int) -> Content
    
    public init(
        urls: [URL],
        columns: [GridItem],
        spacing: CGFloat = 8,
        @ViewBuilder content: @escaping (URL, Int) -> Content
    ) {
        self.urls = urls
        self.columns = columns
        self.spacing = spacing
        self.content = content
    }
    
    public var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(Array(urls.enumerated()), id: \.offset) { index, url in
                content(url, index)
                    .onAppear {
                        // Prefetch nearby images
                        prefetchNearbyImages(currentIndex: index)
                    }
            }
        }
    }
    
    private func prefetchNearbyImages(currentIndex: Int) {
        let prefetchRange = 5
        let startIndex = max(0, currentIndex - prefetchRange)
        let endIndex = min(urls.count - 1, currentIndex + prefetchRange)
        
        let urlsToPrefetch = Array(urls[startIndex...endIndex])
        ImageKitManager.shared.prefetchImages(urls: urlsToPrefetch, priority: .low)
    }
}
