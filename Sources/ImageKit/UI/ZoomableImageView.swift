import SwiftUI

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage
    let minZoomScale: CGFloat
    let maxZoomScale: CGFloat
    
    public init(image: UIImage, minZoomScale: CGFloat = 1.0, maxZoomScale: CGFloat = 6.0) {
        self.image = image
        self.minZoomScale = minZoomScale
        self.maxZoomScale = maxZoomScale
    }
    
    public func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let imageView = UIImageView(image: image)
        
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = minZoomScale
        scrollView.maximumZoomScale = maxZoomScale
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bouncesZoom = true
        
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        
        return scrollView
    }
    
    public func updateUIView(_ scrollView: UIScrollView, context: Context) {
        if let imageView = scrollView.subviews.first as? UIImageView {
            imageView.image = image
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, UIScrollViewDelegate {
        let parent: ZoomableImageView
        
        init(_ parent: ZoomableImageView) {
            self.parent = parent
        }
        
        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }
    }
}
