# imagekit-swiftui

A lightweight, SwiftUI-friendly image loading and caching utility for Swift projects.

> **imagekit-swiftui** provides a small, easy-to-use Swift Package that lets you load images from remote URLs and display them in SwiftUI views with built-in caching, placeholders, resizing, and error handling.

---

## Features

* Simple SwiftUI-first API
* Asynchronous image loading from URL
* In-memory disk caching (configurable)
* Placeholder & failure views
* Resizing and content-mode support
* Works seamlessly with Swift Package Manager

---

## Requirements

* iOS 14.0+ / macOS 11.0+ / tvOS 14.0+ / watchOS 7.0+
* Swift 5.3+

---

## Installation

### Swift Package Manager (recommended)

1. In Xcode choose **File > Add Packages...**
2. Enter the repository URL:

```
https://github.com/jmmanoza/imagekit-swiftui.git
```

3. Choose the version or branch you want and add the package to your project.

### CocoaPods (optional)

This package ships as an SPM package. If you need CocoaPods integration, consider adding a lightweight wrapper pod that pulls in the compiled module, or move the core sources into a CocoaPods podspec. Example Podfile entry (if you create a podspec named `ImageKit`):

```ruby
pod 'ImageKit', :git => 'https://github.com/jmmanoza/imagekit-swiftui.git'
```

> Note: The repository currently contains a `Package.swift` for Swift Package Manager; SPM is the recommended integration method.

---

## Quick Start

Import the module where you want to use it:

```swift
import SwiftUI
import ImageKit
```

> The examples below show a small, idiomatic SwiftUI API. If the public API in `imagekit-swiftui` differs slightly, adapt the usage accordingly.

### Basic remote image

```swift
struct AvatarView: View {
    let url = URL(string: "https://example.com/avatar.jpg")!

    var body: some View {
        ImageKitView(url: url)
            .aspectRatio(contentMode: .fill)
            .frame(width: 80, height: 80)
            .clipShape(Circle())
    }
}
```

### Placeholder and failure handling

```swift
struct PhotoView: View {
    let url: URL

    var body: some View {
        ImageKitView(url: url,
                     placeholder: { ProgressView() },
                     failure: { _ in Image(systemName: "photo.fill") })
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
```

### Resizing / target size

If you want the loader to request a target size (to optimize network or decoding), pass `targetSize` or use the provided modifier:

```swift
ImageKitView(url: url)
    .targetSize(CGSize(width: 400, height: 300))
    .frame(width: 200, height: 150)
```

### Caching

`imagekit-swiftui` provides a basic cache. Cache configuration (memory/disk) can be adjusted via a `ImageCache.shared` or similar configuration API. Example:

```swift
ImageCache.shared.maxMemoryCost = 50 * 1024 * 1024 // 50 MB
```

(Adapt to the real API available in the `Sources` if the names are different.)

---

## API Notes

* The project focuses on a small, SwiftUI-first surface — a single view type (e.g. `ImageKitView` or `RemoteImage`) and a lightweight `ImageLoader` under the hood.
* If you need advanced features (priority, progressive decoding, custom URL request), extend the loader or open an issue/PR.

---

## Examples

Add an `Examples/` folder to the repo with small SwiftUI sample apps that showcase:

* Basic image loading
* Grid of images (lazy loading)
* Prefetching and cancellation

---

## Contributing

Contributions, issues and feature requests are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b my-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin my-feature`
5. Open a Pull Request

Please include tests where relevant and keep API changes backward-compatible if possible.

---

## License

This project is open source and available under the MIT License. See the `LICENSE` file for more information.

---

## Contact

Created by Joseph Mikko Manoza — feel free to open issues or reach out via GitHub.

---

*If you'd like, I can adjust the README to reflect the exact public API (function or type names) — I based this README on common SwiftUI image-loader patterns. If you want me to match the repo's exact API, I can extract the public type names and examples directly from the `Sources` and update the README.*
