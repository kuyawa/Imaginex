//
//  SerialFetcher.swift
//  Imaginex
//
//  Created by Mac Mini on 10/14/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

protocol didFinishDownload {
    func showDownloadedImage(_ path: String)
    func showDownloadedThumb(_ path: String)
    func refreshCurrentGallery()
}

class ThumbFetcher {
    var name: String
    var thumbs: [String]
    var currentIndex: Int = 0
    var isReversed: Bool = false
    var delegate: didFinishDownload?
    
    init(gallery name: String, thumbs: [String]){
        self.name   = name
        self.thumbs = thumbs
    }

    init(gallery name: String, thumbs: [String], inReverse: Bool){
        self.name   = name
        self.thumbs = thumbs
        if inReverse {
            isReversed = true
            currentIndex = thumbs.count-1 // Start from last
        }
    }

    func next() -> String? {
        if isReversed {
            if currentIndex >= 0 && currentIndex < thumbs.count {
                let item = thumbs[currentIndex]
                currentIndex -= 1
                return item
            }
            return nil
        } else {
            if currentIndex < thumbs.count {
                let item = thumbs[currentIndex]
                currentIndex += 1
                return item
            }
        }
        return nil
    }
    
    func loop() {
        guard let item = self.next() else {
            print("--Finished loop for thumbs")
            // Call UI delegate here
            self.delegate?.refreshCurrentGallery()
            return
        }
        
        let media = FileUtils.getThumbsFolder(gallery: name)
        
        let thumbUrl  = item
        let thumbName = FileUtils.getImageNameFromUrl(thumbUrl)
        let thumbFull = media.appendingPathComponent(thumbName)
        let thumbPath = thumbFull.path

        if FileUtils.fileExists(thumbPath) {
            print("- Thumbnail \(thumbName) exists, not downloaded")
            self.loop() // Next thumb
            return
        }
        
        // Check for deleted
        let thumbNameX = "_"+thumbName
        let thumbFullX = media.appendingPathComponent(thumbNameX)
        let thumbPathX = thumbFullX.path
        
        if FileUtils.fileExists(thumbPathX) {
            print("- Image \(thumbName) has been deleted, not downloaded")
            self.loop()
            return
        }
        
        print("Downloading thumb: \(thumbUrl)")
        //print("To \(thumbPath)\n")
        
        do {
            // This is a serial async task, once finished will call next
            try FileUtils.download(fromUrl: thumbUrl, toFile: thumbPath) { location, response, error in
                guard error == nil else {
                    print("Error downloading thumbnail \(thumbUrl)")
                    self.loop() // Next thumb
                    return
                }
                print("Download finished for thumbnail \(thumbUrl)")
                // TODO: Add thumbnail to collection as first item
                // Use some kind of event dispatcher?
                // Or pass collectionView to this constructor?
                self.delegate?.showDownloadedThumb(thumbPath)
                self.loop() // Next thumb
            }
        } catch {
            print("Unkown error")
            self.loop() // Next thumb
        }
    }
    
}
