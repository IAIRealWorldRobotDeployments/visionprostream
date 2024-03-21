//
//  ImageData.swift
//  VideoStream
//
//  Created by Nandini Thakur on 3/20/24.
//

import Foundation
import SwiftUI

class ImageData: ObservableObject {
    @Published var image: UIImage?
//    @Published var right: UIImage?
    
    init() {
        // Set an initial image
        self.image = UIImage(named: "LoadingImageLeft") 
//        self.right = UIImage(named: "LoadingImageRight")
    }
}

//struct StereoImage{
//    var left: UIImage?
//    var right: UIImage?
//    
//    init(left: UIImage? = nil, right: UIImage? = nil) {
//        self.left = left
//        self.right = right
//    }
//}
