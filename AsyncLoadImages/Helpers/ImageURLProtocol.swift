//
//  ImageURLProtocol.swift
//  AsyncLoadImages
//
//  Created by PosterMaker on 8/28/24.
//

import Foundation

class ImageURLProtocol: URLProtocol {
    
    var cancelledOrComplete: Bool = false
    var block: DispatchWorkItem!
    
    private static let queue = DispatchQueue(label: "com.test.imageLoaderURLProtocol")
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return false
    }
    
    override func startLoading() {
        guard let requestURL = request.url, let urlClient = client else {
            return
        }
        
        block = DispatchWorkItem {[weak self] in
            guard let self else { return }
            
            if self.cancelledOrComplete == false {
                let fileURL = URL(fileURLWithPath: requestURL.path)
                
                do {
                    let data = try Data(contentsOf: fileURL)
                    urlClient.urlProtocol(self, didLoad: data)
                    urlClient.urlProtocolDidFinishLoading(self)
                    
                } catch {
                    urlClient.urlProtocol(self, didFailWithError: error)
                }
            }
            
            self.cancelledOrComplete = true
        }
        
        ImageURLProtocol.queue.asyncAfter(deadline: .now() + 0.5, execute: block)
    }
    
    override func stopLoading() {
        ImageURLProtocol.queue.async {
            if !self.cancelledOrComplete, let cancelBlock = self.block {
                cancelBlock.cancel()
                self.cancelledOrComplete = true
            }
        }
    }
    
    static func urlSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [ImageURLProtocol.classForCoder()]
        
        return URLSession(configuration: config)
    }
}
