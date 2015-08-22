//
//  GoogleImagePhotoBrowser.swift
//  GoogleImagePhotoBrowser
//
//  Created by Bharath Urs on 8/12/15.
//  Copyright (c) 2015 Urs. All rights reserved.
//

import UIKit

class GoogleImagePhotoBrowser: UICollectionViewController {

    let GoogleImageReuseIdentifier = "PhotoCell"
    var photos = [Photos]()
    var currentPage = 0
    var searchKey = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        // Initial string.
        self.searchKey = "Google"
        self.loadImagesWithKey(self.searchKey)
    }

    func setupView() {
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (view.bounds.size.width - 3) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        
        collectionView!.collectionViewLayout = layout
        collectionView!.registerClass(GoogleImagePhotoCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: GoogleImageReuseIdentifier)
    }
    
    func loadImagesWithKey(key: String) {
        let GoogleImageService = GoogleImagePhotoService()
        self.photos.removeAll(keepCapacity: false)
        self.collectionView?.reloadData()
        let query = "+".join(key.componentsSeparatedByString(" "))
        self.currentPage = 0
        
        GoogleImageService.fetchImagesWithKey(query, page: self.currentPage, completionHandler: { (photos) -> Void in
            self.photos.extend(photos)
            self.collectionView?.reloadData()
        })
    }
    
    func reloadImagesWithKey(key: String) {
        let GoogleImageService = GoogleImagePhotoService()
        let query = "+".join(key.componentsSeparatedByString(" "))
        
        GoogleImageService.fetchImagesWithKey(query, page: currentPage, completionHandler: { (photos) -> Void in
            self.photos.extend(photos)
            self.collectionView?.performBatchUpdates({ () -> Void in
                let rows = self.collectionView?.numberOfItemsInSection(0)
                var arrayWithIndexPaths = NSMutableArray()
                var i = 0
                for (i = rows!; i < rows! + photos.count; i++) {
                    arrayWithIndexPaths.addObject(NSIndexPath(forRow: i, inSection: 0))
                }
                self.collectionView?.insertItemsAtIndexPaths(arrayWithIndexPaths as [AnyObject])                
            }, completion: nil)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension GoogleImagePhotoBrowser: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.searchKey = textField.text
        self.loadImagesWithKey(self.searchKey)
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}

extension GoogleImagePhotoBrowser: UICollectionViewDataSource {
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GoogleImageReuseIdentifier, forIndexPath: indexPath) as! GoogleImagePhotoCollectionViewCell
        
        let url = self.photos[indexPath.row].thumbnail
        cell.imageView.image = nil
        cell.imageView.setImageWithURL(NSURL(string: url))
        
        if(indexPath.row == self.photos.count - 1) {
            self.currentPage+=8;
            self.reloadImagesWithKey(self.searchKey)
        }
        
        return cell
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.photos.count > 0 ? 1 : 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
}

class GoogleImagePhotoCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = bounds
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
    }
}
