//
//  ImageProcessor.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

import UIKit

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
public protocol ImageProcessor {
    var identifier: String { get }
    func process(_ image: UIImage) throws -> UIImage
}
