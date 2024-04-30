//
//  ColorExtensions.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-15.
//

// ColorExtensions.swift
import SwiftUI
import UIKit

extension Color {
    func uiColor() -> UIColor {
        let components = self.components()
        return UIColor(red: components.red, green: components.green, blue: components.blue, alpha: components.alpha)
    }
    
    private func components() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}

extension UIColor {
    func color() -> Color {
        return Color(self)
    }
}

