//
//  Settings.swift
//  Imaginex
//
//  Created by Mac Mini on 10/12/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

class Settings {
    var version :String = "1.0"
    var galleries :[Gallery] = [Gallery]()

    func firstTime() {
        let _ = FileUtils.verifyAppFolder() // If not exists, create it
        print("Settings file not found")
        // if not settings.txt in app folder, create it
        if let path = Bundle.main.path(forResource: "settings", ofType: "txt") {
            do {
                let text = try String(contentsOfFile: path)
                // Save in app folder
                let docs = FileUtils.getAppFolder()
                let file = docs.appendingPathComponent("settings.txt")
                FileUtils.save(name: file.path, content: text)
                print("Settings file created")
            } catch {
                print("Error accessing settings file")
            }
        }
    }
    
    func load(){
        let file = FileUtils.getSettingsFileName()
        if !FileUtils.fileExists(file) {
            firstTime() // create a basic settings file
        }
        
        // Read file settings.txt as json
        var json = FileUtils.loadAsJson(file)
        
        // assign values from file
        if let v = json?["version"] as? String { self.version = v }
        if let list = json?["galleries"] as? NSArray {
            for item in list {
                if let data = item as? [String:AnyObject] {
                    let gallery = Gallery()
                    guard
                        let name   = data["name"]  as? String,
                        let url    = data["url"]   as? String,
                        let image  = data["image"] as? String
                        else {
                            print("No data \(type(of:data))")
                            break
                    }
                    gallery.name  = name
                    gallery.url   = url
                    gallery.image = image
                    self.galleries.append(gallery)
                } else {
                    print("No item \(type(of:item))")
                }
            }
        } else {
            print("No galleries")
        }
        
        print("Version \(self.version)")
        //for item in self.galleries {
        //    print(item.name, item.updated)
        //}
        print("-")
    }
    
    func save() {
        let path = FileUtils.getSettingsFileName()
        let json = self.toJson()
        print("Saving settings in \(path)")
        print(json)
        FileUtils.save(name: path, content: json)
    }
    
    func toDictionary() -> [String:Any] {
        var data = [String:Any]()
        data["version"] = self.version
        var items = [[String:Any]]()  // Array of dicks

        for item in self.galleries {
            var gallery = [String:Any]()
            gallery["name"]  = item.name
            gallery["url"]   = item.url
            gallery["image"] = item.image
            items.append(gallery)
        }
        data["galleries"] = items

        return data
    }
    
    func toJson() -> String {
        let data = self.toDictionary()
        return data.toJson() // uses Dictionary extension from DataUtils
    }
    
    func findGalleryIndex(name: String) -> Int {
        var index = 0
        for item in galleries {
            if item.name.lowercased() == name.lowercased() {
                print("Gallery found at #\(index)")
                return index
            }
            index += 1
        }
        return -1
    }
    
    func addGallery(_ gallery :Gallery) -> Bool {
        // name and url are required
        let index = findGalleryIndex(name: gallery.name)
        
        if index >= 0 {
            print("Gallery already exists")
            AlertOK("Gallery already exists").show()
            return false
        }
        
        self.galleries.append(gallery)
        self.save()
        
        // create media/thumbs folder
        let _ = FileUtils.verifyImagesFolder(gallery: gallery.name)
        let _ = FileUtils.verifyThumbsFolder(gallery: gallery.name)
        return true
    }
    
    func removeGallery(name :String) {
        let index = findGalleryIndex(name: name)
        if index >= 0 {
            self.removeGallery(at: index)
        }
    }
    
    func removeGallery(at index :Int) {
        self.galleries.remove(at: index)
        self.save()
    }
}
