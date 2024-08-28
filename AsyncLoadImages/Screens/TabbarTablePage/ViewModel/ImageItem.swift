//
//  ImageItem.swift
//  AsyncLoadImages
//
//  Created by PosterMaker on 8/28/24.
//

import UIKit

enum Section {
    case main
}

class ImageItem: Hashable {
    var image: UIImage!
    let url: URL!
    let identifier = UUID()
    
    init(image: UIImage, url: URL) {
        self.image = image
        self.url = url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: ImageItem, rhs: ImageItem) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
