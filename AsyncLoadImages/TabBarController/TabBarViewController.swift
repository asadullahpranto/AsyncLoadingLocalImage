//
//  TabBarViewController.swift
//  AsyncLoadImages
//
//  Created by PosterMaker on 8/28/24.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    let kBarHeight: CGFloat = 84

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewControllers = [initialTabBar, finalTabBar]
        self.tabBar.tintColor = .orange
//        self.tabBar.backgroundColor = .darkGray
        self.tabBar.isTranslucent = false
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        tabBar.frame.size.height = kBarHeight
//        tabBar.frame.origin.y = view.frame.height - kBarHeight
        
        
    }
    

    lazy public var initialTabBar: TableViewController = {
        
        let initialTabBar = TableViewController()
        
        let defaultImage = UIImage(systemName: "rectangle.grid.1x2")
        
        let tabBarItem = UITabBarItem(title: "Table", image: defaultImage, selectedImage: nil)
        
        initialTabBar.tabBarItem = tabBarItem
        
        return initialTabBar
    }()
    
    lazy public var finalTabBar: CollectionViewController = {
        
        let finalTabBar = CollectionViewController()
        
        let defaultImage = UIImage(systemName: "tablecells")
        
        let tabBarItem = UITabBarItem(title: "Collection", image: defaultImage, selectedImage: nil)
        
        finalTabBar.tabBarItem = tabBarItem
        
        return finalTabBar
    }()

}
