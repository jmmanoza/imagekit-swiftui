//
//  NetworkManager.swift
//  ImageKit
//
//  Created by Jm's Macbook Pro on 8/28/25.
//

//import Foundation
//import Combine
//
//@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
//class NetworkManager {
//    private let session: URLSession
//    private var activeTasks: [URL: URLSessionDataTask] = [:]
//    
//    init() {
//        let config = URLSessionConfiguration.default
//        config.requestCachePolicy = .returnCacheDataElseLoad
//        config.timeoutIntervalForRequest = 30
//        config.timeoutIntervalForResource = 60
//        config.httpMaximumConnectionsPerHost = 6
//        config.waitsForConnectivity = true
//        
//        self.session = URLSession(configuration: config)
//    }
//    
//    func downloadImage(url: URL, timeout: TimeInterval, completion: @escaping (Result<Data, Error>) -> Void) {
//        // Cancel existing task for this URL
//        activeTasks[url]?.cancel()
//        
//        var request = URLRequest(url: url, timeoutInterval: timeout)
//        request.setValue("ImageKit/1.0", forHTTPHeaderField: "User-Agent")
//        request.setValue("image/*", forHTTPHeaderField: "Accept")
//        
//        let task = session.dataTask(with: request) { [weak self] data, response, error in
//            defer { self?.activeTasks.removeValue(forKey: url) }
//            
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse,
//                  200...299 ~= httpResponse.statusCode else {
//                completion(.failure(ImageKitError.invalidResponse))
//                return
//            }
//            
//            guard let data = data, !data.isEmpty else {
//                completion(.failure(ImageKitError.noData))
//                return
//            }
//            
//            completion(.success(data))
//        }
//        
//        activeTasks[url] = task
//        task.resume()
//    }
//    
//    func cancelDownload(for url: URL) {
//        activeTasks[url]?.cancel()
//        activeTasks.removeValue(forKey: url)
//    }
//    
//    func cancelAll() {
//        activeTasks.values.forEach { $0.cancel() }
//        activeTasks.removeAll()
//    }
//}

import Foundation
import Combine

@available(iOS 14.0, macOS 11.0, watchOS 7.0, tvOS 14.0, *)
final class NetworkManager {
    private let session: URLSession
    private var activeTasks: [URL: URLSessionDataTask] = [:]
    
    init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.httpMaximumConnectionsPerHost = 6
        config.waitsForConnectivity = true
        
        self.session = URLSession(configuration: config)
    }
    
    func downloadImage(
        url: URL,
        timeout: TimeInterval,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        // Cancel existing task for this URL
        activeTasks[url]?.cancel()
        
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.setValue("ImageKit/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("image/*", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            // handle response first
            if let error = error {
                completion(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode,
                      let data = data, !data.isEmpty {
                completion(.success(data))
            } else if (response as? HTTPURLResponse) == nil {
                completion(.failure(ImageKitError.invalidResponse))
            } else {
                completion(.failure(ImageKitError.noData))
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.activeTasks.removeValue(forKey: url)
            }
        }
        
        activeTasks[url] = task
        task.resume()
    }
    
    func cancelDownload(for url: URL) {
        activeTasks[url]?.cancel()
        activeTasks.removeValue(forKey: url)
    }
    
    func cancelAll() {
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
    }
}
