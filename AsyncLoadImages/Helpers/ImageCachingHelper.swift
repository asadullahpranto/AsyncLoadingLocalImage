//
//  ImageCachingHelper.swift
//  AsyncLoadImages
//
//  Created by PosterMaker on 8/28/24.
//

import UIKit

public class ImageCachingHelper {
    
    public static let publicCache = ImageCachingHelper()
    
    var placeHolderImage = UIImage(systemName: "rectangle")
    private let cachedImages = NSCache<NSURL, UIImage>()
    private var loadingResponses = [NSURL: [(ImageItem, UIImage?) -> Void]]()
    
    public final func image(for url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    
    final func load(url: NSURL, item: ImageItem, completion: @escaping (ImageItem, UIImage?) -> Void) {
        
        if let cachedImage = image(for: url) {
            DispatchQueue.main.async {
                completion(item, cachedImage)
            }
            return
        }
        
        // In case there are more than one requestor for the image, we append their completion block.
        if loadingResponses[url] != nil {
            loadingResponses[url]?.append(completion)
            return
        } else {
            loadingResponses[url] = [completion]
        }
        
        ImageURLProtocol.urlSession().dataTask(with: url as URL) { (data, response, error) in
            // Check for the error, then data and try to create the image.
            guard let responseData = data,
                  let image = UIImage(data: responseData),
                  let blocks = self.loadingResponses[url], error == nil else {
                DispatchQueue.main.async {
                    completion(item, nil)
                }
                return
            }
            
            // Cache the image.
            self.cachedImages.setObject(image, forKey: url, cost: responseData.count)
            // Iterate over each requestor for the image and pass it back.
            for block in blocks {
                DispatchQueue.main.async {
                    block(item, image)
                }
                return
            }
        }.resume()
    }
}
