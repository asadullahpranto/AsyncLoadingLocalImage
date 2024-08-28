//
//  CollectionViewController.swift
//  AsyncLoadImages
//
//  Created by PosterMaker on 8/28/24.
//

import UIKit

class CollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ImageItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ImageItem>
    
    private lazy var dataSource = makeDataSource()
    private var imageObjects = [ImageItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get our image URLs for processing.
        if imageObjects.isEmpty {
            for index in 1...100 {
                if let url = Bundle.main.url(forResource: "UIImage_\(index)", withExtension: "png") {
                    self.imageObjects.append(ImageItem(image: ImageCachingHelper.publicCache.placeHolderImage!, url: url))
                }
            }
        }
        
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        
        applySnapshot()
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: ImageItem) ->
            UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            var content = UIListContentConfiguration.cell()
            content.directionalLayoutMargins = .zero
            content.axesPreservingSuperviewLayoutMargins = []
            content.image = item.image
            
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
        
        return dataSource
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot() // reusing typealias
        snapshot.appendSections([.main])
        snapshot.appendItems(imageObjects)

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    
}
