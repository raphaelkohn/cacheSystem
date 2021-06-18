//
//  File.swift
//  
//
//  Created by Raphael Kohn on 07/06/21.
//

import Foundation

@objc public class ImageFileCache: NSObject, NSCoding {
    
    public var fileSize: UInt64 = 0
    public var filePath: String?
    public let id: String
    public let remoteUrl: String
    public var cached: Bool
    
    @objc public init(id: String, remoteUrl: String) {
        
        self.id        = id
        self.remoteUrl = remoteUrl
        self.cached    = false
    }
    
    @objc public func removeCache() {
        
        guard let filePath = self.filePath else { return }
        
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
                self.cached   = false
                self.fileSize = 0
                self.filePath = nil
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
    }
    
    @objc public func encode(with coder: NSCoder) {
        
        coder.encode(Int64(fileSize), forKey: "fileSize")
        coder.encode(filePath, forKey: "filePath")
        coder.encode(id, forKey: "id")
        coder.encode(remoteUrl, forKey: "remoteUrl")
        coder.encode(cached, forKey: "cached")
    }
    
    @objc public required init?(coder: NSCoder) {
        
        self.fileSize  = UInt64(coder.decodeInt64(forKey: "fileSize"))
        self.filePath  = coder.decodeObject(forKey: "filePath") as? String
        self.id        = coder.decodeObject(forKey: "id") as! String
        self.remoteUrl = coder.decodeObject(forKey: "remoteUrl") as! String
        self.cached    = coder.decodeBool(forKey: "cached")
    }
}
