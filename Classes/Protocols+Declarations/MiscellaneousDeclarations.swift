//
//  MiscellaneousDeclarations.swift
//  Pods
//
//  Created by Chrishon Wyllie on 12/25/19.
//

import Foundation
import UIKit.UIImage
import AVFoundation

@objc public protocol URLCachableView: class {
    
    /// The url of the requested resource
    var sourceURL: URL? { get }
    
    /// Determines whether the requested resource should be cached or not once download completes
    var cachePolicy: MultimediaCachePolicy { get }
    
    /// Determines where a downloaded resource will be stored if `cachePolicy == .allow`
    var cacheLocation: DownloadCompletionCacheLocation { get }
    
    /**
     Initializes a download model to begin a download and link its status with a receiver

    - Parameters:
       - delegate: Used to notify receiver of events related to current download of the requested resource. e.g. An image or video hosted on an external server
       - cachePolicy: Used to notify receiver of download state events such as completion, progress and errors
       - cacheLocation: Determines where a downloaded resource will be stored if `cachePolicy == .allow`
    */
    init(frame: CGRect, cachePolicy: MultimediaCachePolicy, cacheLocation: DownloadCompletionCacheLocation)
}

/// Delegate for notifying receiver of events related to current download of a requested resource
@objc public protocol URLCachableViewDelegate: class {
    
    /**
     Notifies receiver of errors encountered during download and/or caching

    - Parameters:
       - view: The view that will send delegate information to its receiver
       - media: The media that just finished downloading. For `URLImageView` images, this can be type-casted to a `UIImage`. For `URLVideoPlayerView`, this can be type-casted to a URL if necessary
    */
    @objc optional func urlCachableView(_ view: URLCachableView, didFinishDownloading media: Any)
    
    /**
     Notifies receiver of errors encountered during download and/or caching

    - Parameters:
       - view: The view that will send delegate information to its receiver
       - error: Error encountered during download and possible caching
    */
    @objc optional func urlCachableView(_ view: URLCachableView, downloadFailedWith error: Error)
    
    /**
     Notifies receiver of download progress prior to completion

    - Parameters:
       - view: The view that will send delegate information to its receiver
       - progress: Float value from 0.0 to 1.0 denoting current download progress of the requested resource
       - humanReadableProgress: A more easily readable version of the progress parameter
    */
    @objc optional func urlCachableView(_ view: URLCachableView, downloadProgress progress: Float, humanReadableProgress: String)
}








// MARK: - CachableAVPlayerItem

@objc public protocol CachableAVPlayerItemDelegate {
    
    /// This is called when the video file is fully downloaded.
    /// At this point, the data can be cached using the MemoryCachedVideoData struct
    func playerItem(_ playerItem: CachableAVPlayerItem, didFinishDownloading data: Data)
    
    /// This is called when an error occurred while downloading the video
    /// Inspect the `error` argument for a more detailed description.
    func playerItem(_ playerItem: CachableAVPlayerItem, downloadFailedWith error: Error)
    
    
    
    
    // Optional delegate functions
    
    
    /// Called every time a new portion of data is received.
    /// This can be used to update your UI with the appropriate values to let users know the progress of the download
    @objc optional func playerItem(_ playerItem: CachableAVPlayerItem, downloadProgress progress: CGFloat, humanReadableProgress: String)
    
    /// Called after initial prebuffering is finished,
    /// In other words, the video is ready to begin playback.
    @objc optional func playerItemReadyToPlay(_ playerItem: CachableAVPlayerItem)
    
    /// Called when the data being downloaded did not arrive in time to
    /// continue playback.
    /// Perhaps  at this point, a loading animation would be recommented to show to users
    @objc optional func playerItemPlaybackStalled(_ playerItem: CachableAVPlayerItem)
    
    
    /// Called when the video experiences an error when attempting to begin playing
    @objc optional func playerItem(_ playerItem: CachableAVPlayerItem, failedToPlayWith error: Error)
    
}










// MARK: - ObservableAVPlayer

/// Delegate for notifying receiver of status changes for AVPlayerItem
internal protocol ObservableAVPlayerDelegate: class {
    
    /**
     Notifies receiver of `AVPlayerItem.Status`

    - Parameters:
       - player: The AVPlayer that will send delegate information to its receiver
       - status: The new status for the player item. Switch on to determine when ready to play
    */
    func observablePlayer(_ player: ObservableAVPlayer, didLoadChangePlayerItem status: AVPlayerItem.Status)
}

/// Protocol that all Observable AVPlayers must conform to in order to provide relevant info to the receiver
internal protocol ObservablePlayerProtocol {
    /// Notifies receiver of `AVPlayerItem.Status`
    var delegate: ObservableAVPlayerDelegate? { get }
    
    /// Context for adding observer
    var playerItemContext: Int { get }
    
    /**
     Required initializer
 
    - Parameters:
        - playerItem: The `AVPlayerItem` which will be observed
        - delegate: Receiver of AVPlayerItem status updates
    */
    init(playerItem: AVPlayerItem, delegate: ObservableAVPlayerDelegate)
}













// MARK: - MediaResourceLoaderDelegate

internal protocol MediaResourceLoaderDelegate: class {
    
    /// This is called when the media is fully downloaded.
    /// At this point, the data can be cached.
    func resourceLoader(_ loader: MediaResourceLoader, didFinishDownloading media: Any)
    
    /// This is called when an error occurred while downloading the media
    /// Inspect the `error` argument for a more detailed description.
    func resourceLoader(_ loader: MediaResourceLoader, downloadFailedWith error: Error)
    
    /// This is called every time a new portion of data is received.
    /// This can be used to update your UI with the appropriate values to let users know the progress of the download
    func resourceLoader(_ loader: MediaResourceLoader, downloadProgress progress: CGFloat, humanReadableProgress: String)
}












// MARK: - Errors

/// Errors encountered during internal Celestial operations
enum CLSError: Error {
    case urlToDataError(String)
    case invalidSourceURLError(String)
    case nonExistentFileAtURLError(String)
}









/// Determines what state a resource is in
/// Whether it has been cached, exists in a temporary uncached state, .etc
internal enum ResourceExistenceState: Int {
    /// The resource has completed downloading but remains in a temporary
    /// cache in the file system until URLCachableView decides what to do with it
    case uncached = 0
    /// The resource has completed downloading and is cached to either memory or file system
    case cached
    /// The resource is currently being downloaded
    case currentlyDownloading
    /// The download task for the resource has been paused
    case downloadPaused
    /// There are no pending downloads for the resource, nor does it exist anywhere. Must begin new download
    case none
}

/// File type of the resource. Used for proper identification and storage location
internal enum ResourceFileType: Int {
    case video = 0
    case image
    case temporary
    case all
}

/// Struct for identifying if a resource exists in cache, whether in memory or in file system
internal struct CachedResourceIdentifier: Codable, Equatable, Hashable, CustomStringConvertible {
    
    /// The URL pointing to the external resource
    let sourceURL: URL
    /// The file type of the resource
    let resourceType: ResourceFileType
    /// The location that the cached resource exists in: in local memory, in file system, .etc
    let cacheLocation: DownloadCompletionCacheLocation
    
    var description: String {
        let description = "Source URL: \(sourceURL), resourceType: \(resourceType.rawValue), cacheLocation: \(cacheLocation)"
        return description
    }
    
    /// Initializes CachedResourceIdentifier object to be used later to determine if the actual file exists and can be retrieved
    init(sourceURL: URL, resourceType: ResourceFileType, cacheLocation: DownloadCompletionCacheLocation) {
        self.sourceURL = sourceURL
        self.resourceType = resourceType
        self.cacheLocation = cacheLocation
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        sourceURL = try container.decode(URL.self, forKey: .sourceURL)
        let resourceTypeRawValue = try container.decode(Int.self, forKey: .resourceType)
        resourceType = ResourceFileType(rawValue: resourceTypeRawValue)!
        
        let cacheLocationRawValue = try container.decode(Int.self, forKey: .cacheLocation)
        cacheLocation = DownloadCompletionCacheLocation(rawValue: cacheLocationRawValue)!
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(sourceURL, forKey: .sourceURL)
        try container.encode(resourceType.rawValue, forKey: .resourceType)
        try container.encode(cacheLocation.rawValue, forKey: .cacheLocation)
    }
    
    enum CodingKeys: String, CodingKey {
        case sourceURL
        case resourceType
        case cacheLocation
    }
}












public struct TestURLs {
    
    public struct Videos {
        public static var urlStrings: [String] = [
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"
        ]
    }
}
