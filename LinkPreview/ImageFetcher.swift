//
//  ImageFetcher.swift
//  LinkPreview
//
//  Created by Manu Singh on 07/04/19.
//  Copyright © 2019 Manu Singh. All rights reserved.
//

import Foundation
import UIKit

/// for fetching Data from server, example to download image

func getData(fromUrl url : URL, completion : @escaping (Data)->Void)-> URLSessionDataTask {
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod  =  "GET"
    
    let task =  URLSession.shared.dataTask(with: urlRequest, completionHandler: {
        
        data, response, error in
        
        guard data == nil else {
            completion(data!)
            return
        }
    })
    
    task.resume()
    return task
}

class ImageDownloadTask : NSObject {
    
    var downloadTask :  URLSessionDataTask?
    static var imageCache =  NSCache<AnyObject, AnyObject>()
    weak var imageView : UIImageView?
    
    func getImageforUrl(imageUrl : URL){
        
        if let cachedImage =  ImageDownloadTask.imageCache.object(forKey: imageUrl as AnyObject) as? UIImage {
            DispatchQueue.main.async {
                self.imageView?.image = cachedImage
            }
            return
        }
        
        downloadTask = getData(fromUrl: imageUrl, completion: { [weak self]
            data in
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    self?.imageView?.image = image
                    ImageDownloadTask.imageCache.setObject(image, forKey: imageUrl as AnyObject)
                    
                }
            }
            
        })
    }
    
}

extension UIImageView {
    private static var taskList = [String:ImageDownloadTask]()
    
    var task: ImageDownloadTask? {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return UIImageView.taskList[tmpAddress] ?? nil
        }
        set {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UIImageView.taskList[tmpAddress] = newValue
        }
    }
    
    func setImage(withUrl url : String,placeholder : UIImage?) {
        image = placeholder//#imageLiteral(resourceName: "profile picture")
        task?.imageView = nil
        guard let imageUrl = URL(string: url) else {
            return
        }
        let imageDownloader = ImageDownloadTask()
        imageDownloader.imageView = self
        imageDownloader.getImageforUrl(imageUrl: imageUrl)
        task = imageDownloader
    }
}
