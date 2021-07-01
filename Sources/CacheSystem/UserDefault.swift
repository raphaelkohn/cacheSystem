//
//  File.swift
//  
//
//  Created by Raphael Kohn on 01/07/21.
//

import Foundation

extension UserDefaults {
    
    static var cacheSystem: UserDefaults {
        
        return UserDefaults(suiteName: "com.raphaelkohn.CacheSystem") ?? UserDefaults()
    }
}
