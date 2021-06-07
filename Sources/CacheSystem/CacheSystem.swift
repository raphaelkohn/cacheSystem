import Foundation

public class CacheSystem {
    
    public static var shared: CacheSystem = CacheSystem()
    private var capacity: UInt64 = 2 * 1024 * 1024 * 1024
    private var cachedImages: [String: ImageFileCache] = [:]
    
    public func setCapacity(_ capacity: UInt64) {
        
        self.capacity = capacity
    }
    
    public func getImage(forId id: String) -> ImageFileCache? {
        
        return self.cachedImages[id]
    }
    
    public func createCache(_ image: ImageFileCache) {
        
        self.cachedImages[image.id] = image
    }
    
    public func saveImageToDisk(image: Data, id: String) {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileURL = documentsDirectory.appendingPathComponent("cachedImages").appendingPathComponent(id)
        //guard let data = image.jpegData(compressionQuality: 1) else { return }
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
            
            try image.write(to: fileURL)
            self.cachedImages[id]?.cached   = true
            self.cachedImages[id]?.fileSize = fileSize
            self.cachedImages[id]?.filePath = fileURL.path
            
        } catch let error {
            print("error saving file: ", error)
        }
    }
    
    private func checkCapacity(for fileSize: UInt64) -> Bool {
        
        let used = self.cachedImages.values.map { return $0.fileSize }.reduce(0) { sum, size in
            
            return sum + size
        }
        
        return (used + fileSize) < capacity
    }
    
    private func freeSpace(until fileSize: UInt64) {
        
        var spaceToFree = 0
        var numberOfFilesToErase = 0
        for cache in self.cachedImages {
            
            spaceToFree += Int(cache.value.fileSize)
            numberOfFilesToErase += 1
            
            if spaceToFree > fileSize {
                
                break
            }
        }
        
        for i in (0...numberOfFilesToErase) {
            
            let keyToErase = Array(self.cachedImages.keys)[i]
            self.cachedImages[keyToErase]?.removeCache()
        }
    }
}
