//
//  ViewController.swift
//  Imaginex
//
//  Created by Mac Mini on 10/12/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, didFinishDownload {

    var windowGallery : NSWindow = NSWindow()
    var settings      = Settings()
    var galleries     = [Gallery]()
    var gallery       = Gallery()
    var selected      = GalleryItem()
    var zoomValue     = 1.0
    var autoDownload  = true
    
    @IBOutlet weak var mainWindow  : NSWindow!
    @IBOutlet weak var viewDesktop : NSView!
    @IBOutlet weak var mainArea    : NSScrollView!
    @IBOutlet weak var mainImage   : NSImageView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var statusBar   : NSView!
    @IBOutlet weak var statusText  : NSTextField!
    @IBOutlet weak var spinner     : NSProgressIndicator!
    
    
    //-- Menu actions
    
    @IBAction func onAutoDownload(_ sender: NSMenuItem) {
        imageAutoDownload()
    }
    
    @IBAction func addGallery(_ sender: NSMenuItem) {
        addGallery()
    }
    
    @IBAction func deleteGallery(_ sender: NSMenuItem) {
        removeGallery()
    }
    
    @IBAction func refreshGallery(_ sender: NSMenuItem) {
        refreshGallery()
    }
    
    @IBAction func onSelectGallery(_ sender: NSMenuItem) {
        selectGallery(byName: sender.title.lowercased())
    }
    
    @IBAction func onFirstItem(_ sender: NSMenuItem) {
        goFirstThumbnail()
    }

    @IBAction func onLastItem(_ sender: NSMenuItem) {
        goLastThumbnail()
    }

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        //TODO: enable/disable items
        //if menuItem.title == "Refresh" { return false }
        return true
    }
    
    
    //-- Toolbar actions
    
    @IBAction func onRefresh(_ sender: NSButton) {
        refreshGallery()
    }
    
    @IBAction func onZoomOut(_ sender: NSButton) {
        zoomOut()
    }
    
    @IBAction func onZoomToFit(_ sender: NSButton) {
        zoomToFit()
    }
    
    @IBAction func onZoomIn(_ sender: NSButton) {
        zoomIn()
    }
    
    @IBAction func onOpenFinder(_ sender: NSButton) {
        openFinder(file: selected.imagePath)
    }

    @IBAction func onSetWallpaper(_ sender: NSButton) {
        setAsWallpaper(file: selected.imagePath)
    }

    @IBAction func onDeleteImage(_ sender: NSButton) {
        deleteImage(file: selected.imagePath)
    }

    
    //-- View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear() {
        // Dark
        if let window = self.view.window {
            window.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    
    func initialize() {
        viewDesktop.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        showStatus("Ready")
        
        // Async after all UI has been shown
        DispatchQueue.main.async {
            self.settings.load()
            self.loadGalleries()
            self.selectFirstGallery()
        }
    }
    
    
    //-- Status bar
    
    enum StatusType {
        case info, data, warn, error
    }
    
    func showStatus(_ text: String) {
        showStatus(text: text, type: .info) // Default
    }
    
    func showStatus(text: String, type:StatusType) {
        //print(text)
        statusText.stringValue = text
        setStatusColor(for: type)
    }
    
    func setStatusColor(for type: StatusType){
        let CrayonLead = NSColor(hex:0x252525)
        switch type {
          case .info : // white on black
            statusText.textColor = NSColor.darkGray
            statusBar.backgroundColor = CrayonLead
            break
          case .data : // green on black
            statusText.textColor = NSColor.green
            statusBar.backgroundColor = CrayonLead
            break
          case .warn : // yellow on black
            statusText.textColor = NSColor.yellow
            statusBar.backgroundColor = CrayonLead
            break
          case .error: // white on red
            //statusText.textColor = NSColor.white
            //statusBar.backgroundColor = NSColor.red
            statusText.textColor = NSColor.red
            statusBar.backgroundColor = CrayonLead
            break
        }
    }
   
    
    // Add galleries to menu
    
    func loadGalleries(){
        galleries = settings.galleries  // Alias
        let names: [String] = galleries.map{ $0.name }
        buildGalleriesMenu(names)
    }

    func buildGalleriesMenu(_ list:[String]) {
        let mainMenu = NSApplication.shared().mainMenu
        let menuGalleries = mainMenu?.item(withTitle: "Galleries") //.item(at: 2)

        var pos = 0
        for name in list {
            let menuItem = NSMenuItem()
            menuItem.title = name
            menuItem.isEnabled = true
            menuItem.action = #selector(ViewController.onSelectGallery(_:))
            menuGalleries?.submenu?.insertItem(menuItem, at: pos)
            pos += 1
        }
    }
    
    func addToMenu(name :String) {
        let mainMenu = NSApplication.shared().mainMenu
        let menuGalleries = mainMenu?.item(withTitle: "Galleries")

        // find point of insertion
        var pos = 0
        for item in (menuGalleries?.submenu?.items)! {
            if item.isSeparatorItem {
                break
            }
            print(item.title)
            pos += 1
        }

        let menuItem = NSMenuItem()
        menuItem.title = name
        menuItem.isEnabled = true
        menuItem.action = #selector(ViewController.onSelectGallery(_:))
        menuGalleries?.submenu?.insertItem(menuItem, at: pos)
    }
    
    func removeFromMenu(name :String) {
        let mainMenu = NSApplication.shared().mainMenu
        let menuGalleries = mainMenu?.item(withTitle: "Galleries")

        for item in (menuGalleries?.submenu?.items)! {
            if item.isSeparatorItem {
                print("-- separator")
                break
            }
            print(item.title)
            if item.title == name {
                print("Removing menu item: \(item.title)")
                menuGalleries?.submenu?.removeItem(item)
            }
        }
    }
    
    func imageAutoDownload() {
        autoDownload  = !autoDownload
        let mainMenu  = NSApplication.shared().mainMenu
        let menuItem  = mainMenu?.item(withTitle: "Images") //.item(at: 2)
        let option    = menuItem?.submenu?.item(withTitle: "AutoDownload")
        option?.state = (autoDownload ? 1 : 0)
        option?.isEnabled = autoDownload
    }
    
    func addGallery() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: "viewGalleryController") as! GalleryController
        windowGallery = NSWindow(contentViewController: controller)
        let app = NSApplication.shared()
        // Modal direct
        app.runModal(for: windowGallery)

        // On return
        print(".\(controller.response)")
        if controller.response == .saved {
            let name = controller.gallery.name // response form modal
            print("Added gallery: \(name)")
            settings.load() // reload with new gallery
            galleries = settings.galleries  // reassign to global var
            gallery = findGallery(byName: name)
            guard !gallery.name.isEmpty else {
                print("Gallery recently added not found")
                return
            }
            addToMenu(name: name)
            showThumbnails()
        } else {
            print("User cancelled")
            // Do nothing
            //let _ = settings.toDictionary()
        }
        print("Modal session ended")
    }
    
    func removeGallery() {
        let dialog = DialogYesNo(title: "Remove gallery", info: "Are you sure you want to remove it from the list?\nYour images in 'Media' folder won't be lost")
        if dialog.choice() {
            removeFromMenu(name: gallery.name)
            settings.removeGallery(name: gallery.name)
            selectFirstGallery()
            showStatus(text: "Gallery removed from list", type: .warn)
        }
    }
    
    func fetchImages(gallery name: String) {
        if settings.galleries.count < 1 {
            self.showStatus(text: "No galleries available", type: .error)
            return
        }
        
        gallery = findGallery(byName: name)
        guard !gallery.name.isEmpty else {
            self.showStatus(text: "Gallery [\(name)] not found", type: .error)
            return
        }
        
        // Fetch gallery thumbs from html
        showStatus("Downloading images from [\(name)]...")
        
        let url = URL(string: gallery.url)
        
        // Get html from gallery
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                if (error as! URLError?) != nil {
                    DispatchQueue.main.async(execute: {
                        self.showStatus(text: "Internet error. Check Connection", type: .error)
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        self.showStatus(text: "Error fetching images. Try again later", type: .error)
                    })
                }
                print(error)
                print("-- End Error")
                return
            }
            
            if let data = data, let html = String(data: data, encoding: String.Encoding.utf8) {
                //print(html)
                // FileUtils.save(name: path, content: html)
                // Download thumbs
                let regex   = "<img alt=\"\" src=\"(.*?)\" />"
                let matches = html.matchAll(regex)
                let thumbs  = matches.map{ "http:"+$0 }
                //print(thumbs)

                if thumbs.count > 0 {
                    self.downloadThumbs(gallery: name, thumbs: thumbs)
                }
            } else {
                print("No data")
                return
            }
        }
        task.resume()
    }
    
    // Get them from Imgur if not exist locally
    
    func downloadThumbs(gallery name: String, thumbs: [String]) {
        print("Downloads:")
        if thumbs.count < 1 {
            showStatus(text: "No images to download", type: .error)
            return
        }

        // docs/Imaginex/media
        if !FileUtils.verifyMediaFolder() {
            showStatus(text: "Media folder not found", type: .error)
            return
        }
        
        // docs/Imaginex/media/{gallery}
        if !FileUtils.verifyImagesFolder(gallery: gallery.name) {
            showStatus(text: "Images folder for gallery [\(name)] not found", type: .error)
            return
        }
        
        // docs/Imaginex/media/{gallery}/.thumbs
        if !FileUtils.verifyThumbsFolder(gallery: gallery.name) {
            showStatus(text: "Thumbs folder for gallery [\(name)] not found", type: .error)
            return
        }

        // Chained serial async download one image at a time
        // Start with thumbs since they are smaller and will show all first
        
        // Async process, add callback on finish
        let thumbFetcher = ThumbFetcher(gallery: name, thumbs: thumbs, inReverse: true)
        thumbFetcher.delegate = self // protocol to show thumb after downloaded
        thumbFetcher.loop()
    }

    // Get them from Imgur if not exist locally
    
    func downloadImage(_ url :String, gallery name: String) {
        if url.isEmpty {
            showStatus(text: "No URL to download", type: .error)
            return
        }
        
        if name.isEmpty {
            showStatus(text: "No gallery specified", type: .error)
            return
        }
        
        if !FileUtils.verifyMediaFolder() {
            showStatus(text: "Media folder not found", type: .error)
            return
        }
        
        if !FileUtils.verifyImagesFolder(gallery: name) {
            showStatus(text: "Media folder for gallery [\(name)] not found", type: .error)
            return
        }
        
        let image  = FileUtils.getImageNameFromUrl(url)
        let folder = FileUtils.getImagesFolder(gallery: name)
        let path   = folder.appendingPathComponent(image).path
        
        // Async process, add callback on finish
        do {
            try FileUtils.download(fromUrl: url, toFile: path){ url, response, error in
                self.showImage(path: path)
            }
        } catch let error as NSError {
            showStatus(text: "Error downloading image from url: \(url)", type: .error)
            print(error)
        }
    }

    func selectFirstGallery() {
        selectGallery(0)
    }
    
    func selectGallery(_ index :Int) {
        if index >= galleries.count { return }
        gallery = galleries[index]
        self.view.window?.title = gallery.name
        showThumbnails()
    }
    
    func selectGallery(byName name: String) {
        var index = 0
        for item in galleries {
            if item.name.lowercased() == name.lowercased() {
                selectGallery(index)
                return
            }
            index += 1
        }
        showStatus(text: "Gallery [\(name)] not available", type: .error)
    }
    
    func findGallery(byName name: String) -> Gallery {
        for item in galleries {
            if item.name.lowercased() == name.lowercased() {
                return item
            }
        }
        showStatus(text: "Gallery [\(name)] not found", type: .error)
        return Gallery()
    }
    
    func refreshGallery() {
        let name = gallery.name.lowercased()
        fetchImages(gallery: name)
        // downloadThumbs
        // showThumbs
        // showFirstImage
    }
    
    // Get last 100 thumbs from media/gallery/thumbs folder
    func showThumbnails() {
        let name = gallery.name
        print("Show thumbnails")

        gallery.items = [GalleryItem]()
        
        // Get thumbs from folder[name]
        guard let thumbs = FileUtils.listFilesInMedia(gallery: name, max: 100) else {
            showStatus("Empty gallery. Refresh to get images from server")
            return
        }
        
        for item in thumbs {
            // item is the file name without path, just the name.jpg
            if item.hasPrefix(".") { continue }  // system file
            if item.hasPrefix("_") { continue }  // deleted
            let file  = NSString(string: item)
            let ext   = file.pathExtension
            let thumb = file.deletingPathExtension
            let image = String(thumb.characters.dropLast())  // remove the 'b' for thumbs
            let imageName = image+"."+ext
            //print(item,imageName)
            let some = GalleryItem()
            //some.title       = item.title
            //some.link        = item.link
            //some.desc        = item.desc
            some.imageUrl    = "http://i.imgur.com/"+imageName
            //some.imageType   = item.imageType
            //some.imageHeight = item.imageHeight
            //some.imageWidth  = item.imageWidth
            //some.imageSize   = item.imageSize
            some.imageName   = imageName
            some.imagePath   = FileUtils.getImagePath(gallery: gallery.name, forFile: imageName)
            some.thumbUrl    = "http://i.imgur.com/"+item
            some.thumbName   = item
            some.thumbPath   = FileUtils.getThumbnailPath(gallery: gallery.name, forFile: item)
            gallery.items.append(some)
        }
        
        if gallery.items.count < 1 {
            showStatus("Empty gallery. No thumbnails to show")
            return
        }
        
        showStatus("Refreshing gallery, wait a moment...")

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()

        goFirstThumbnail()
    }
    
    
    func getLocalThumbs(_ name: String, max: Int) -> [String] {
        var numItems = max
        if max < 1 { numItems = 100 }
        let list = FileUtils.listFilesInMedia(gallery: name, max: numItems)!
        return list
    }
    
    // Invoke delegate select/deselect
    func deselectThumbnail() {
        let current = collectionView.selectionIndexPaths.first!
        collectionView.delegate?.collectionView!(collectionView, didDeselectItemsAt: [current])
    }

    // Invoke delegate select/deselect
    func selectThumbnail(_ index :Int) {
        let newpos = IndexPath(item: index, section: 0)
        collectionView.delegate?.collectionView!(collectionView, didSelectItemsAt: [newpos])
    }
    
    func goFirstThumbnail(){
        collectionView.deselectAll(nil)
        let index = IndexPath(item: 0, section: 0)
        collectionView.selectItems(at: [index], scrollPosition: NSCollectionViewScrollPosition.left)
        selectThumbnail(0)
    }
    
    func goLastThumbnail(){
        collectionView.deselectAll(nil)
        let last = collectionView.numberOfItems(inSection: 0) - 1
        let index = IndexPath(item: last, section: 0)
        collectionView.selectItems(at: [index], scrollPosition: NSCollectionViewScrollPosition.right)
        selectThumbnail(last)
    }
    
    
    func showFirstImage() {
        showImage(index: 0)
    }
    
    // Protocol didFinishDownload
    func showDownloadedImage(_ path: String) {
        showImage(path: path)
    }

    // Protocol didFinishDownload
    func showDownloadedThumb(_ path: String) {
        // add thumbnail to head of collection
        let item = GalleryItem()
        item.thumbName = FileUtils.getImageNameFromUrl(path)
        item.thumbPath = path
        gallery.items.insert(item, at: 0)
        print("First thumb")
        collectionView.reloadData()
        //goFirstThumbnail() // No. It will download the image and thats not wanted
    }

    // Protocol didFinishDownload
    func refreshCurrentGallery() {
        print("Refreshing gallery...")
        DispatchQueue.main.async(execute: {
            self.showThumbnails()
        })
    }
    
    func showImage(index :Int) {
        if index >= gallery.items.count { return }
        selected = gallery.items[index]
        let folder = FileUtils.getImagesFolder(gallery: gallery.name)
        let imageName = gallery.items[index].imageName
        let imagePath = folder.appendingPathComponent(imageName)
        let imageFile = imagePath.path
        let fileExtension = imagePath.pathExtension

        if imageName.hasPrefix("_") { /* deleted */
            showDeletedImage()
            showStatus(text: "Image: \(imagePath) has been deleted", type: .info)
            return
        }
        
        DispatchQueue.main.async(execute: {
            self.spinner.stopAnimation(self.view)
            self.spinner.isHidden = true
        })

        if FileUtils.fileExists(imageFile) {
            let image = NSImage(byReferencingFile: imageFile)!
            
            if fileExtension == "gif" {
                print("GIF file")
                mainImage.canDrawSubviewsIntoLayer = true
                mainImage.animates = true
            }
            mainImage.image = image
            
            // Image Info
            let fileInfo  = FileUtils.getFileInfo(imageFile)!
            let sizeval   = fileInfo[FileAttributeKey.size] as! Double
            let sizekb :Double = sizeval / 1024.00
            let sizeInKB  = String(format: "%.0f KB", sizekb)
            let width     = String(format: "%.0f", image.size.width)
            let height    = String(format: "%.0f", image.size.height)
            let imageInfo = " [\(width)x\(height)] \(sizeInKB)"
            let imagePath = FileUtils.getPathRelativeToDocs(imageFile) + imageInfo
            showStatus(text: "Image: \(imagePath)", type: .info)
            
        } else {
            // UI cue to downloading, spinning caret
            /*
            let path  = Bundle.main.path(forResource: "spinner", ofType: "gif")
            let gif   = URL(fileURLWithPath: path!)
            let image = NSImage(byReferencing: gif)
            mainImage.canDrawSubviewsIntoLayer = true
            mainImage.animates = true
            mainImage.image = image
            */
            // download image
            let url = gallery.items[index].imageUrl
            DispatchQueue.main.async(execute: {
                self.showStatus("Downloading image: \(url)")
                self.spinner.isHidden = false
                self.spinner.startAnimation(self.view)
            })
            
            downloadImage(url, gallery: gallery.name)
        }
    }

    func showImage(path: String) {
        showStatus(text: "Image: \(FileUtils.getPathRelativeToDocs(path))", type: .info)
        DispatchQueue.main.async(execute: {
            self.spinner.stopAnimation(self.view)
            self.spinner.isHidden = true
        })
        
        if FileUtils.fileExists(path) {
            let fileExtension = (path as NSString).pathExtension
            if fileExtension == "gif" {
                print("GIF file")
                mainImage.canDrawSubviewsIntoLayer = true
                mainImage.animates = true
            }
            let image = NSImage(byReferencingFile: path)
            mainImage.image = image
        } else {
            showStatus(text: "Image not found: \(FileUtils.getPathRelativeToDocs(path))", type: .error)
        }
    }
    
    func zoomOut() {
        guard zoomValue>1 else { return }
        zoomValue -= 0.5
        let center = NSPoint(x: mainArea.bounds.width/2, y: mainArea.bounds.height/2)
        mainArea.setMagnification(CGFloat(zoomValue), centeredAt: center)
    }

    func zoomIn() {
        guard zoomValue<4 else { return }
        zoomValue += 0.5
        let center = NSPoint(x: mainArea.bounds.width/2, y: mainArea.bounds.height/2)
        mainArea.setMagnification(CGFloat(zoomValue), centeredAt: center)
    }
    
    func zoomToFit() {
        zoomValue = 1.0
        let center = NSPoint(x: mainArea.bounds.width/2, y: mainArea.bounds.height/2)
        mainArea.setMagnification(CGFloat(zoomValue), centeredAt: center)
        // TODO: zoomToFit not working
        // let rect = NSRect(x: 0, y: 0, width: 0, height: 0)
        // mainArea.magnify(toFit: rect)
    }
    
    func openFinder(file :String) {
        let url = URL(fileURLWithPath: file)
        let selected = [url]
        showStatus("Opening in Finder: \(FileUtils.getPathRelativeToDocs(file))")
        NSWorkspace.shared().activateFileViewerSelecting(selected)
    }
    
    func setAsWallpaper(file :String) {
        let space  = NSWorkspace.shared()
        let screen = NSScreen.main()
        let url = URL(fileURLWithPath: file)
        showStatus("Setting as wallpaper: \(FileUtils.getPathRelativeToDocs(file))")
        do {
            try space.setDesktopImageURL(url, for: screen!)
        } catch {
            print(error)
            showStatus(text: "Error setting image as wallpaper", type: .warn)
        }
    }

    func deleteImage(file :String) {
        guard let selected = collectionView.selectionIndexes.first else { return }
        let thumbFile = gallery.items[selected].thumbPath
        let newName   = "_" + gallery.items[selected].thumbName
        let newFile   = FileUtils.getThumbnailPath(gallery: gallery.name, forFile: newName)
        gallery.items[selected].thumbName = "_"+gallery.items[selected].thumbName
        gallery.items[selected].imageName = "_"+gallery.items[selected].imageName
        FileUtils.deleteFile(file)
        FileUtils.renameFile(thumbFile, to: newFile)
        showDeletedImage()
        showStatus("Image has been deleted")
    }
    
    func showDeletedImage() {
        mainImage.image = NSImage(named: "deleted")
    }

}


//---- EXTENSIONS

// NSVIEW
extension NSView {
    var backgroundColor :NSColor? {
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
}


// THUMBNAILS COLLECTION

extension ViewController : NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "ViewThumbnail", for: indexPath)

        guard let thumb = item as? ViewThumbnail else { return item }
        
        // IndexPath is a tuple (section, item) use the item number as index, section is zero for our list
        let folder = FileUtils.getThumbsFolder(gallery: gallery.name)
        let imageFile = folder.appendingPathComponent(gallery.items[indexPath.item].thumbName).path
        let image = NSImage(byReferencingFile: imageFile)

        thumb.imageFile = image

        var hilite = false
        let selectedIndex = collectionView.selectionIndexPaths.first
        if selectedIndex == indexPath { hilite = true }
        thumb.setHighlight(hilite)
        
        return item
    }
}

extension ViewController : NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {

        guard let indexPath = indexPaths.first else {
            return
        }

        if autoDownload {
            showImage(index: indexPath.item)
        }
        
        guard let item = collectionView.item(at: indexPath) else {
            return
        }
        
        let thumb = (item as! ViewThumbnail)
        thumb.setHighlight(true)

    }
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        guard let item = collectionView.item(at: indexPath) else { return }
        let thumb = (item as! ViewThumbnail)
        thumb.setHighlight(false)
    }
}
