//
//  GoogleImagePhotoService.swift
//  GoogleImagePhotoBrowser
//
//  Created by Bharath Urs on 8/12/15.
//  Copyright (c) 2015 Urs. All rights reserved.
//

class Photos {
    var url: String
    var thumbnail: String
    var width: CGFloat
    var height: CGFloat
    init() {
        url = ""
        thumbnail = ""
        width = 0
        height = 0
    }
}


class GoogleImagePhotoService: NSObject {
   let BASE_URL = "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&q="
    
    func fetchImagesWithKey(key: String, page: Int, completionHandler: (([Photos])->Void)) {
        let manager = AFHTTPRequestOperationManager()
        let query = BASE_URL + key + "&start=\(page)"
        manager.GET(query, parameters: nil, success: { (request, response) -> Void in
            var photos = [Photos]()
            
            if let resp = response["responseData"] as? NSDictionary {
                if let results = resp["results"] as? NSArray {
                    for result in results {
                        let photo = Photos()
                        photo.thumbnail = result["tbUrl"] as! String
                        photo.url = result["url"] as! String
                        photo.height = CGFloat((result["tbHeight"] as! NSString).floatValue)
                        photo.width = CGFloat((result["tbWidth"] as! NSString).floatValue)
                        
                        photos.append(photo)
                    }
                }
            }
            
            println(response)
            completionHandler(photos)
            
            }) { (request, error) -> Void in }
    }
}
