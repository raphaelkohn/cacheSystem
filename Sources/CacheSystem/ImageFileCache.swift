//
//  File.swift
//  
//
//  Created by Raphael Kohn on 07/06/21.
//

import Foundation

public struct ImageFileCache {
    
    public var fileSize: UInt64 = 0
    public var filePath: String?
    public let id: String
    public let remoteUrl: String
    public var cached: Bool
    
    public init(id: String, remoteUrl: String) {
        
        self.id        = id
        self.remoteUrl = remoteUrl
        self.cached    = false
    }
    
    public mutating func removeCache() {
        
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
}
