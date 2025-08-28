//
//  AnimatedImageView.swift.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

import SwiftUI

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public struct AnimatedImageView: View {
    let url: URL?
    let placeholder: AnyView?
    let errorView: AnyView?
    
    @State private var currentFrame: UIImage?
    @State private var isAnimating = false
    
    public init<P: View, E: View>(
        url: URL?,
        @ViewBuilder placeholder: @escaping () -> P,
        @ViewBuilder errorView: @escaping () -> E
    ) {
        self.url = url
        self.placeholder = AnyView(placeholder())
        self.errorView = AnyView(errorView())
    }
    
    public var body: some View {
        Group {
            if let frame = currentFrame {
                Image(uiImage: frame)
                    .resizable()
            } else {
                placeholder ?? AnyView(ProgressView())
            }
        }
        .onAppear {
            loadAnimatedImage()
        }
    }
    
    private func loadAnimatedImage() {
        guard let url = url else { return }
        
        // Load and animate GIF/WebP images
        // This is a simplified implementation - in practice you'd use a more robust GIF decoder
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    self.currentFrame = image
                }
            }
        }.resume()
    }
}
