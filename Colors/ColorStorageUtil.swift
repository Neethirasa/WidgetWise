//
//  ColorStorageUtil.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-15.
//

// ColorStorageUtil.swift
import UIKit

struct ColorStorageUtil {
    static let sharedUserDefaults = UserDefaults(suiteName: "group.Nivethikan-Neethirasa.InspireSync")

    static func saveColor(_ color: UIColor, forKey key: String) {
        do {
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
            sharedUserDefaults?.set(colorData, forKey: key)
        } catch {
            print("Failed to save color: \(error)")
        }
    }
    
    static func loadColor(forKey key: String) -> UIColor? {
        if let colorData = sharedUserDefaults?.data(forKey: key),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            return color
        }
        return nil
    }
}

