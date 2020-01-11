//
//  Extensions.swift
//  Pods
//
//  Created by Chrishon Wyllie on 12/25/19.
//

import UIKit
import MobileCoreServices

// MARK: - UIImage

internal extension UIImage {

    func decodedImage() -> UIImage {
        guard let cgImage = cgImage else { return self }
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: nil,
                                width: Int(size.width), height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: cgImage.bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let decodedImage = context?.makeImage() else { return self }
        return UIImage(cgImage: decodedImage)
    }
    
    /// A rough estimation of how much memory this UIImage uses in bytes
    var diskSize: Int {
        guard let cgImage = cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
    
    func resize(width: CGFloat) -> UIImage? {
        let height = (width / self.size.width) * self.size.height
        return self.resize(size: CGSize(width: width, height: height))
    }

    func resize(height: CGFloat) -> UIImage? {
        let width = (height / self.size.height) * self.size.width
        return self.resize(size: CGSize(width: width, height: height))
    }

    func resize(size: CGSize) -> UIImage? {
        let widthRatio  = size.width / self.size.width
        let heightRatio = size.height / self.size.height
        var updateSize = size
        
        if (widthRatio > heightRatio) {
            updateSize = CGSize(width: self.size.width * heightRatio, height: self.size.height * heightRatio)
        } else if heightRatio > widthRatio {
            updateSize = CGSize(width: self.size.width * widthRatio,  height: self.size.height * widthRatio)
        }
        
        UIGraphicsBeginImageContextWithOptions(updateSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: updateSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}













// MARK: - Int

public extension Int {
    
    /// Number of bytes in one megabyte. Used to set the cost limit of the decoded items NSCache.
    static let OneMegabyte = 1024 * 1024
    
    /// Number of bytes in one gigabyte. Used to set the cost limit of the decoded items NSCache.
    static let OneGigabyte = OneMegabyte * 1000
    
    var megabytes: Int {
        return self * Int.OneMegabyte
    }
    
    var gigabytes: Int {
        return self * Int.OneGigabyte
    }
    
    var sizeInMB: Float {
        return Float(self) / Float(Int.OneMegabyte)
    }
}





// MARK: - Data

internal extension Data {
    
    /// Quick reference for calculating the number of megabytes that a video uses.
    var sizeInMB: Float {
        return Float(self.count) / Float(Int.OneMegabyte)
    }
    
}






// MARK: - URL

internal extension URL {
    
    func withScheme(_ scheme: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        return components?.url
    }
    
    /// Gets the proper mime type of a URL based on its file extension.
    /// Useful for storing and recreating videos from NSData with the proper mime type.
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream" // default value
    }
    
    /// Returns a boolean value for if the file at the specified URL is an image
    var containsImage: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeImage)
    }
    
    /// Returns a boolean value for if the file at the specified URL is an audio file
    var containsAudio: Bool {
        let mimeType = self.mimeType()
        guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeAudio)
    }
    
    /// Returns a boolean value for if the file at the specified URL is a video
    var containsVideo: Bool {
        let mimeType = self.mimeType()
        guard  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
            return false
        }
        return UTTypeConformsTo(uti, kUTTypeMovie)
    }

}
