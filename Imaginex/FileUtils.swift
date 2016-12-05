//
//  FileUtils.swift
//  Imaginex
//
//  Created by Mac Mini on 10/12/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

struct Path {
    static var Documents : URL {
        let filer = FileManager.default
        let docs  = filer.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs
    }
}

class FileUtils {
    
    static func getAppName() -> String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
    
    static func getAppFolder(asString: Bool) -> String {
        return getAppFolder().path
    }
    
    static func getAppFolder() -> URL {
        let filer = FileManager.default
        let docs  = filer.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url   = docs.appendingPathComponent(getAppName(), isDirectory: true)
        return url
    }

    static func getMediaFolder() -> URL {
        let filer = FileManager.default
        let docs  = filer.urls(for: .documentDirectory, in: .userDomainMask).first!
        let full  = docs.appendingPathComponent(getAppName(), isDirectory: true)
        let url   = full.appendingPathComponent("media", isDirectory: true)
        return url
    }

    static func getImagesFolder(gallery: String) -> URL {
        let filer = FileManager.default
        let docs  = filer.urls(for: .documentDirectory, in: .userDomainMask).first!
        let full  = docs.appendingPathComponent(getAppName(), isDirectory: true)
        let media = full.appendingPathComponent("media", isDirectory: true)
        let url   = media.appendingPathComponent(gallery.lowercased(), isDirectory: true)
        return url
    }
    
    static func getImagePath(gallery name: String, forFile file: String) -> String {
        let folder = getImagesFolder(gallery: name.lowercased())
        let path = folder.appendingPathComponent(file).path
        return path
    }

    static func getPathRelativeToDocs(_ path :String) -> String {
        // TODO: get Documents folder from OS
        if path.contains("/Documents") {
            let pos = path.range(of: "/Documents", options: [.backwards])?.lowerBound
            let rel = path.substring(from: pos!)
            return rel
        }
        return path
    }

    static func getImageNameFromUrl(_ url: String) -> String {
        return (url as NSString).lastPathComponent
    }
    
    static func getThumbsFolder(gallery: String) -> URL {
        let filer = FileManager.default
        let docs  = filer.urls(for: .documentDirectory, in: .userDomainMask).first!
        let full  = docs.appendingPathComponent(getAppName(), isDirectory: true)
        let media = full.appendingPathComponent("media", isDirectory: true)
        let pics  = media.appendingPathComponent(gallery.lowercased(), isDirectory: true)
        let url   = pics.appendingPathComponent(".thumbs", isDirectory: true)
        return url
    }
    
    static func getThumbnailPath(gallery name: String, forFile file: String) -> String {
        let folder = getThumbsFolder(gallery: name.lowercased())
        let path = folder.appendingPathComponent(file).path
        return path
    }
    
    static func getSettingsFileName() -> String {
        let folder = getAppFolder()
        let file   = folder.appendingPathComponent("settings.txt")
        return file.path
    }
    
    static func verifyAppFolder() -> Bool {
        let path = getAppFolder().path
        //print("App folder: \(path)")
        return verifyFolder(path)
    }
    
    static func verifyMediaFolder() -> Bool {
        let path = getMediaFolder().path
        //print("Media folder: \(path)")
        return verifyFolder(path)
    }

    static func verifyImagesFolder(gallery name: String) -> Bool {
        let path = getImagesFolder(gallery: name.lowercased()).path
        //print("Images folder for \(name): \(path)")
        return verifyFolder(path)
    }

    static func verifyThumbsFolder(gallery name: String) -> Bool {
        let path  = getThumbsFolder(gallery: name.lowercased()).path
        //print("Thumbs folder for \(name): \(path)")
        return verifyFolder(path)
    }
    
    static func verifyFolder(_ path: String) -> Bool {
        do {
            var isDir :ObjCBool = false
            let filer = FileManager.default
            
            if filer.fileExists(atPath: path, isDirectory: &isDir) {
                if isDir.boolValue {
                    //print("Folder exists in \(path)")
                    return true
                } else {
                    print("Exists as file. Creating as folder")
                }
            } else {
                print("Folder does not exist. Creating new folder in \(path)")
            }
            
            // Create new folder
            try filer.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
            
        } catch let error as NSError {
            print("Error verifying folder: \(path)")
            print(error)
            return false
        }
        
        return true
    }

    
    static func fileExists(_ name: String) -> Bool {
        if FileManager.default.fileExists(atPath: name) {
            return true
        }
        return false
    }
/*
    static func fileExistsInDocs(_ name: String) -> Bool {
        let docs = getAppFolder()
        let full = docs.appendingPathComponent(name)
        //print("Checking in app folder \(full.path)")
        if FileManager.default.fileExists(atPath: full.path) {
            return true
        }
        return false
    }
    
    static func fileExistsInMedia(_ name: String) -> Bool {
        let docs = getMediaFolder()
        let full = docs.appendingPathComponent(name)
        //print("Checking in media folder \(full.path)")
        if FileManager.default.fileExists(atPath: full.path) {
            return true
        }
        return false
    }
*/
    /*
    static func listFilesInMedia(_ name: String, max: Int) -> [String] {
        var list = [String]()
        let folder = getThumbsFolder(gallery: name).path
        do {
            list = try FileManager.default.contentsOfDirectory(atPath: folder)
        } catch {
            print("Error listing thumbnails")
        }
        return list
    }
    */
   
    static func listFilesInMedia(gallery name: String, max: Int) -> [String]? {
        _ = verifyThumbsFolder(gallery: name)
        let folder = getThumbsFolder(gallery: name)
        let props  = [URLResourceKey.localizedNameKey, URLResourceKey.creationDateKey]

        if let fileArray = try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: props, options: .skipsHiddenFiles) {
            let results = fileArray.map { url -> (String, Date) in
                do {
                    var created = try url.resourceValues(forKeys: [URLResourceKey.creationDateKey])
                    return (url.lastPathComponent, created.creationDate!)
                } catch {
                    print(error)
                }
                return ("Error", Date())
            }

            let ordered = results.sorted(by: { $0.1 > $1.1 }) // sort descending creation dates
            let names = ordered.map { $0.0 } // extract file names
            
            return names
        } else {
            return nil
        }
    }
    
    static func getFileInfo(_ name: String) -> [FileAttributeKey: Any]? {
        do {
            let info = try FileManager.default.attributesOfItem(atPath: name)
            return info
        } catch {
            print(error)
        }
        
        return nil
    }
    
    static func deleteFile(_ path: String) {
        do {
            if fileExists(path) {
                try FileManager.default.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
    
    static func renameFile(_ path: String, to newName: String) {
        do {
            if fileExists(path) {
                try FileManager.default.moveItem(atPath: path, toPath: newName)
            }
        } catch {
            print(error)
        }
    }
    
    // Load file from Documents/App folder
    static func load(_ name: String) -> String {
        var content :String = ""

        do {
            if fileExists(name) {
                try content = String(contentsOfFile: name, encoding: String.Encoding.utf8)
            } else {
                print("File not found: \(name)")
            }
        } catch let error as NSError {
            print("Error reading file in \(name)")
            print(error)
        }

        return content
    }

    
    static func loadAsJson(_ name: String) -> [String:AnyObject]? {
        let content :String = self.load(name)
        //print("|"+content+"|")
        if let data = content.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
                return json
            } catch let error as NSError {
                print("Error parsing json from \(name)")
                print(error)
            }
        }
        return nil
    }
    
    // Save file to Documents/App folder
    static func save(name: String, content: String) {
        do {
            try content.write(toFile: name, atomically: false, encoding: String.Encoding.utf8)
            print("FILE UTILS: FIle saved")
        } catch let error as NSError {
            print("Error writing file to \(name)")
            print(error)
        }
    }
    
    static func saveAsJson(name: String, data: [String:AnyObject]) {
        let invalidJson = "\"error\":\"Invalid JSON\""
        do {
            let json = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            let text = String(data: json, encoding: String.Encoding.utf8) ?? invalidJson
            self.save(name: name, content: text)
        } catch let error as NSError {
            print("Error saving json for \(name)")
            print(error)
        }
    }
    
    // Download to memory
    /*
    static func download(fromUrl: String, callback: @escaping (_ data:Data?, _ response:URLResponse?, _ error:Error?) -> Void) throws {
        let uri = URL(string:fromUrl)
        let task = URLSession.shared.dataTask(with: uri!){ data, response, error in
            guard data != nil && error == nil else {
                print("(UTIL)Error downloading \(fromUrl)")
                print("(UTIL)Message: \(error)")
                return
            }
            
            do {
                print("(UTIL)Downloaded.")
                callback(data, response, error)
            }
        }
        task.resume()
    }
    */
    
    // Download to file
    static func download(fromUrl: String, toFile: String, callback: @escaping (_ location :URL?, _ response :URLResponse?, _ error :Error?) -> Void) throws {
        let uri = URL(string:fromUrl)
        let task = URLSession.shared.downloadTask(with: uri!){ location, response, error in
            guard location != nil && error == nil else {
                print("(UTIL)Error downloading \(fromUrl)")
                print("(UTIL)Message: \(error)")
                print("-- End error")
                //callback(location, response, error)
                return
                //return
            }
            
            let fileManager = FileManager.default
            //let source = location?.absoluteString
            let source = location?.path
            //let target = URL(string: toFile)
            let target = toFile
            do {
                try fileManager.moveItem(atPath: source!, toPath: target)
                //(at: location!, to: url!)
                //print("(UTIL)Downloaded.")
                callback(location, response, error)
            } catch let error as NSError {
                print("Error moving file:")
                print("  Source: \(source)")
                print("  Target: \(target)")
                print(error)
                print("-- End error")
            }
        }
        task.resume()
    }

}

