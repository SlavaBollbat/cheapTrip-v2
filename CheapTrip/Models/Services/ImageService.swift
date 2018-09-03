//
//  ImageService.swift
//  CheapTrip
//
//  Created by Слава on 01.09.2018.
//  Copyright © 2018 Слава. All rights reserved.
//

import Foundation
import UIKit

class ImageService {
    
    
    static func downloadImage(withURL url: URL, completion: @escaping (_ image: UIImage?)->()) {
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            var downloadedImage: UIImage?
            
            if let data = data {
                downloadedImage = UIImage(data: data )
            }
            
            DispatchQueue.main.async {
                completion(downloadedImage)
            }
        }
        
        dataTask.resume()
    }
}







