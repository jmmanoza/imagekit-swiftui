import XCTest
@testable import ImageKit

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
final class ImageKitTests: XCTestCase {
    
    func testMemoryCache() {
        let cache = ImageKitMemoryCache()
        let testImage = UIImage(systemName: "star")!
        let key = "test_key"
        
        cache.setImage(testImage, for: key)
        let retrievedImage = cache.image(for: key)
        
        XCTAssertNotNil(retrievedImage)
        XCTAssertEqual(testImage.size, retrievedImage?.size)
    }
    
    func testImageRequest() {
        let url = URL(string: "https://example.com/image.jpg")!
        let processor = ResizeProcessor(targetSize: CGSize(width: 100, height: 100))
        
        let request = ImageRequest(
            url: url,
            processors: [processor],
            priority: .high,
            cachePolicy: .returnCacheDataElseLoad
        )
        
        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.processors.count, 1)
        XCTAssertEqual(request.priority, .high)
        XCTAssertTrue(request.cacheKey.contains("resize_100x100"))
    }
    
    func testResizeProcessor() throws {
        let originalImage = UIImage(systemName: "star")!
        let targetSize = CGSize(width: 50, height: 50)
        let processor = ResizeProcessor(targetSize: targetSize)
        
        let processedImage = try processor.process(originalImage)
        
        XCTAssertEqual(processedImage.size, targetSize)
        XCTAssertTrue(processor.identifier.contains("resize_50x50"))
    }
    
    func testRoundedCornersProcessor() throws {
        let originalImage = UIImage(systemName: "square")!
        let processor = RoundedCornersProcessor(cornerRadius: 10)
        
        let processedImage = try processor.process(originalImage)
        
        XCTAssertNotNil(processedImage)
        XCTAssertEqual(processedImage.size, originalImage.size)
    }
    
    func testImageFormatDetection() {
        // Test JPEG detection
        let jpegHeader = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01])
        let jpegFormat = ImageUtils.detectFormat(from: jpegHeader)
        
        if case .jpeg = jpegFormat {
            XCTAssertTrue(true)
        } else {
            XCTFail("Should detect JPEG format")
        }
        
        // Test PNG detection
        let pngHeader = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D])
        let pngFormat = ImageUtils.detectFormat(from: pngHeader)
        
        if case .png = pngFormat {
            XCTAssertTrue(true)
        } else {
            XCTFail("Should detect PNG format")
        }
    }
    
//    func testImageKitConfiguration() {
//        let config = ImageKitConfiguration.shared
//        
//        let originalMemorySize = config.maxMemoryCacheSize
//        config.configure(maxMemoryCacheSize: 100 * 1024 * 1024)
//        
//        XCTAssertEqual(config.maxMemoryCacheSize, 100 * 1024 * 1024)
//        XCTAssertNotEqual(config.maxMemoryCacheSize, originalMemorySize)
//    }
    
    func testImageTask() {
        let url = URL(string: "https://example.com/test.jpg")!
        let request = ImageRequest(url: url)
        let task = ImageTask(request: request)
        
        XCTAssertEqual(task.request.url, url)
        XCTAssertFalse(task.cancelled)
        
        task.cancel()
        XCTAssertTrue(task.cancelled)
    }
    
    func testImageKitError() {
        let invalidURLError = ImageKitError.invalidURL
        let networkError = ImageKitError.networkError(URLError(.badURL))
        
        XCTAssertEqual(invalidURLError.localizedDescription, "Invalid URL provided")
        XCTAssertTrue(networkError.localizedDescription.contains("Network error"))
        
        // Test equality
        XCTAssertEqual(ImageKitError.invalidURL, ImageKitError.invalidURL)
        XCTAssertNotEqual(ImageKitError.invalidURL, ImageKitError.invalidImageData)
    }
    
    func testPerformanceMemoryCache() {
        let cache = ImageKitMemoryCache()
        let testImages = (0..<100).map { _ in UIImage(systemName: "star")! }
        
        measure {
            for (index, image) in testImages.enumerated() {
                cache.setImage(image, for: "key_\(index)")
            }
            
            for index in 0..<100 {
                _ = cache.image(for: "key_\(index)")
            }
        }
    }
}
