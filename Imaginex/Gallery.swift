//
//  Gallery.swift
//  Imaginex
//
//  Created by Mac Mini on 10/18/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

class Gallery {
    var name  : String = ""
    var url   : String = ""
    var image : String = ""
    var items : [GalleryItem] = [GalleryItem]()
}

class GalleryItem {
    var title       :String = ""
    var link        :String = ""
    var desc        :String = ""
    var imageUrl    :String = ""
    var imageType   :String = ""
    var imageHeight :String = ""
    var imageWidth  :String = ""
    var imageSize   :String = ""
    var imageName   :String = ""
    var imagePath   :String = ""
    var thumbUrl    :String = ""
    var thumbName   :String = ""
    var thumbPath   :String = ""
}
