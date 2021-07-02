import Foundation

@objc public class CacheSystem: NSObject {
    
    @objc public static var shared: CacheSystem = CacheSystem()
    private var capacity: UInt64 = 2 * 1024 * 1024 * 1024
    
    @objc public func setCapacity(_ capacity: UInt64) {
        
        self.capacity = capacity
    }
    
    @objc public func getImage(forId id: String) -> ImageFileCache? {
        
        if let data = UserDefaults.cacheSystem.data(forKey: id) {
            let cache = NSKeyedUnarchiver.unarchiveObject(with: data) as? ImageFileCache
            guard let cacheId = cache?.id else { return nil }
            
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let filePath = documentsDirectory.appendingPathComponent("cachedImages").appendingPathComponent(cacheId).path
                
                if FileManager.default.fileExists(atPath: filePath) {
                    
                    do {
                        
                        let imageData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                        cache?.imageData = imageData
                        return cache
                        
                    } catch {
                        
                        return nil
                    }
                }
            }
            
        } else {
            return nil
        }
        
        return nil
    }
    
    @objc public func createCache(_ image: ImageFileCache) {
        
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: image)
        UserDefaults.cacheSystem.set(encodedData, forKey: image.id)
    }
    
    @objc public func saveImageToDisk(image: Data, id: String) {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        
        if !FileManager.default.fileExists(atPath: documentsDirectory.appendingPathComponent("cachedImages").path) {
            
            do {
            try FileManager.default.createDirectory(atPath: documentsDirectory.appendingPathComponent("cachedImages").path, withIntermediateDirectories: false, attributes: nil)
            } catch let createError {
                print("couldn't create directory at path", createError)
            }
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("cachedImages").appendingPathComponent(id)
        let fileSize = UInt64(image.count)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
        
        do {
            
            if !checkCapacity(for: fileSize) {
                
                freeSpace(until: fileSize)
            }
            
            if let data = UserDefaults.cacheSystem.data(forKey: id) {
                
                try image.write(to: fileURL)
                let cache = NSKeyedUnarchiver.unarchiveObject(with: data) as! ImageFileCache
                cache.cached   = true
                cache.fileSize = fileSize
                cache.filePath = fileURL.relativePath
                
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: cache)
                UserDefaults.cacheSystem.set(encodedData, forKey: cache.id)
                
                let currentUsed = UserDefaults.cacheSystem.integer(forKey: "usedCapacity")
                UserDefaults.cacheSystem.set(currentUsed + Int(cache.fileSize), forKey: "usedCapacity")
            }
            
        } catch let error {
            print("error saving file: ", error)
        }
    }
    
    private func checkCapacity(for fileSize: UInt64) -> Bool {
        
        let currentUsed = UserDefaults.cacheSystem.integer(forKey: "usedCapacity")
        
        return (UInt64(currentUsed) + fileSize) < capacity
    }
    
    private func freeSpace(until fileSize: UInt64) {
        
//        var spaceToFree = 0
//        var numberOfFilesToErase = 0
//        for cache in self.cachedImages {
//
//            spaceToFree += Int(cache.value.fileSize)
//            numberOfFilesToErase += 1
//
//            if spaceToFree > fileSize {
//
//                break
//            }
//        }
//
//        for i in (0...numberOfFilesToErase) {
//
//            let keyToErase = Array(self.cachedImages.keys)[i]
//            self.cachedImages[keyToErase]?.removeCache()
//        }
    }
}
