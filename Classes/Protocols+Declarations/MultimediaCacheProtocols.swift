//
//  MultimediaCacheProtocols.swift
//  Pods
//
//  Created by Chrishon Wyllie on 12/25/19.
//

import UIKit.UIImage

internal protocol CelestialCacheProtocol: class {
    
    // Video
    
    // Returns the image associated with a given url string
    func video(for urlString: String) -> Data?
    // Inserts the image of the specified url string in the cache
    func store(video: Data?, with urlString: String)
    // Removes the image of the specified url string in the cache
    func removeVideo(at urlString: String)
    // Removes all images from the cache
    func clearAllVideos()
    
    
    
    
    // Image
    
    // Returns the image associated with a given url string
    func image(for urlString: String) -> UIImage?
    // Inserts the image of the specified url string in the cache
    func store(image: UIImage?, with urlString: String)
    // Removes the image of the specified url string in the cache
    func removeImage(at urlString: String)
    // Removes all images from the cache
    func clearAllImages()
    
    
    
    func reset()
}

internal struct CacheControlConfiguration {
    let countLimit: Int
    let memoryLimit: Int
    
    static let defaultCountLimit: Int = 100 // 100 images
    static let defaultMemoryLimit: Int = Int.OneMegabyte * 100 // 100 MB
    
    static let defaultConfig = CacheControlConfiguration(countLimit: CacheControlConfiguration.defaultCountLimit, memoryLimit: CacheControlConfiguration.defaultMemoryLimit)
}

internal protocol CacheManagerProtocol: class {
    
    var encodedItemsCache: NSCache<AnyObject, AnyObject> { get }
    var decodedItemsCache: NSCache<AnyObject, AnyObject> { get }
    var lock: NSLock { get }
    var config: CacheControlConfiguration { get }
    
}

/// Generic protocol that both VideoCache and ImageCache must implement.
internal protocol CacheProtocol: class {
    
    associatedtype T
    
    // Returns the image/video associated with a given url string
    func item(for urlString: String) -> T?
    
    // Inserts the image/video of the specified url string in the cache
    func store(_ item: T?, with urlString: String)
    
    // Removes the image/video of the specified url string in the cache
    func removeItem(at urlString: String)
    
    // Removes all images/videos from the cache
    func clearAllItems()
    
    // Set the total number of items that can be saved.
    // Note this is not an explicit limit. See Apple documentation
    func setCacheItemLimit(_ value: Int)
    
    // Set the total cost in MB that can be saved.
    // Note this is not an explicit limit. See Apple documentation
    func setCacheCostLimit(numMegabytes: Int)
    
    // Accesses the value associated with the given key for reading and writing
    subscript(_ urlString: String) -> T? { get set}
}
