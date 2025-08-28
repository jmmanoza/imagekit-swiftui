# ImageKit-SwiftUI

A simple and powerful SwiftUI library for integrating ImageKit.io, allowing you to easily load, transform, and optimize images directly within your SwiftUI views.

---

### Installation

ImageKit-SwiftUI can be added to your project using Swift Package Manager.

1.  In Xcode, navigate to `File` > `Add Packages...`.
2.  Enter the repository URL: `https://github.com/jmmanoza/imagekit-swiftui`
3.  Click `Add Package`.

---

### Usage

The core of this library is the `ImageKit` view, which works just like SwiftUI's built-in `AsyncImage` but with built-in support for ImageKit.io's URL-based transformations.

First, import the library:

```swift
import SwiftUI
import ImageKit_SwiftUI

struct ContentView: View {
    
    // Replace "your_imagekit_id" and "your_image_path" with your actual values.
    private let urlEndpoint = "[https://ik.imagekit.io/your_imagekit_id/](https://ik.imagekit.io/your_imagekit_id/)"
    private let imagePath = "default-image.jpg"
    
    var body: some View {
        VStack(spacing: 40) {
            
            // Basic Usage: Display an image without transformations.
            Text("Original Image")
                .font(.headline)
            ImageKit(urlEndpoint: urlEndpoint, path: imagePath)
                .scaledToFit()
                .frame(width: 200, height: 200)

            // Transformed Usage: Apply transformations like resizing and cropping.
            Text("Transformed Image (Resized & Blurred)")
                .font(.headline)
            
            // Chaining transformations for a different effect
            ImageKit(
                urlEndpoint: urlEndpoint,
                path: "tr:w-250,h-150,bl-5/default-image.jpg"
            )
            .scaledToFit()
            
            // For a cleaner, more idiomatic SwiftUI approach, you can also build
            // your URL with a separate function or use a more advanced URL builder.
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```

This example demonstrates how to display a simple image and then apply transformations by including them directly in the URL path, as is common with ImageKit.io.

---

### Contributing

We welcome contributions! Please feel free to open a pull request or submit an issue on the GitHub repository.
