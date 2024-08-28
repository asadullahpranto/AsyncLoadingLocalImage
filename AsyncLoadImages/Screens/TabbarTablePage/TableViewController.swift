//
//  TableViewController.swift
//  AsyncLoadImages
//
//  Created by PosterMaker on 8/28/24.
//

import UIKit

class TableViewController: UIViewController {
    
    typealias DataSource = UITableViewDiffableDataSource<Section, ImageItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ImageItem>
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var dataSource = makeDataSource()
    private var imageObjects = [ImageItem]()
    private var numbers = [1, 2, 4, 5, 6, 11, 21, 44, 55, 66, 1111, 2222, 4444, 5555, 6666, 10, 20, 40, 50, 60, 100, 200, 400, 500, 600]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if imageObjects.isEmpty {
            for index in 1...100 {
                if let url = Bundle.main.url(forResource: "UIImage_\(index)", withExtension: "png") {
                    self.imageObjects.append(ImageItem(image: ImageCachingHelper.publicCache.placeHolderImage!, url: url))
                }
            }
        }

        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        applySnapshot()
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView) { (tableView: UITableView, indexPath: IndexPath, item: ImageItem) ->
            UITableViewCell? in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.image = item.image
//            content.text = "\(item)"
            
            ImageCachingHelper.publicCache.load(url: item.url as NSURL, item: item) { (fetchedItem, image) in
                if let img = image, img != fetchedItem.image {
                    var updatedSnapshot = self.dataSource.snapshot()
                    if let datasourceIndex = updatedSnapshot.indexOfItem(fetchedItem) {
                        let item = self.imageObjects[datasourceIndex]
                        item.image = img
                        updatedSnapshot.reloadItems([item])
                        self.dataSource.apply(updatedSnapshot, animatingDifferences: true)
                    }
                }
            }
            
            cell.contentConfiguration = content
            return cell
        }
        dataSource.defaultRowAnimation = .fade
        
        return dataSource
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot() // reusing typealias
        snapshot.appendSections([.main])
        snapshot.appendItems(imageObjects)

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension TableViewController: UITableViewDelegate {
    
}
