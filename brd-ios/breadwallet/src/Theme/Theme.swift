//
//  Theme.swift
//  breadwallet
//
//  Created by Ray Vander Veen on 2019-05-27
//  Copyright © 2019 Breadwinner AG. All rights reserved.
//

// TODO: Refactor when rebranding.

import UIKit
import SwiftUI

/**
 *  Standardizes colors and fonts.
 */
protocol BRDTheme {
    // MARK: - Fonts
    
    static var h0Title: UIFont { get }
    static var h1Title: UIFont { get }
    static var h2Title: UIFont { get }
    static var h3Title: UIFont { get }

    static var body1: UIFont { get }
    static var body1Accent: UIFont { get }
    static var body2: UIFont { get }
    
    static var primaryButton: UIFont { get }
    
    // MARK: - Colors
    static var primaryBackground: UIColor { get }
    static var secondaryBackground: UIColor { get }
    static var tertiaryBackground: UIColor { get }
    
    static var primaryText: UIColor { get }
    static var secondaryText: UIColor { get }
    static var tertiaryText: UIColor { get }
    
    static var accent: UIColor { get }
    static var accentHighlighted: UIColor { get }
    static var error: UIColor { get }
    static var success: UIColor { get }
}

//
// Default theme implementation.
//

class Theme: BRDTheme {
    enum FontSize: CGFloat {
        /// Size: 36.0
        case h0Title = 36.0
        
        /// Size: 28.0
        case h1Title = 28.0
        
        /// Size: 24.0
        case h2Title = 24.0
        
        /// Size: 18.0
        case h3Title = 18.0
        
        /// Size: 16.0
        case body1 = 16.0
        
        /// Size: 14.0
        case body2 = 14.0
        
        /// Size: 12.0
        case caption = 12.0
    }
    
    enum FontName {
        case book
        case medium
        case bold
    }
    
    enum ColorHex: String {
        case primaryBackground = "#FFFFFF"
        case secondaryBackground = "#211F3F"
        case tertiaryBackground = "#312F4C"
        case blueBackground = "#2C78FF"
        case onboardingBackground = "#141233"
        
        case text = "#000000"
        
        case accent = "#5B6DEE"
        case accentHighlighted = "#5667E0"
        case success = "#5BE081"
        case error = "#EA6654"
    }

    enum TextAlpha: CGFloat {
        case primary = 1.0
        case secondary = 0.75
        case tertiary = 0.6
    }
    
    // Fonts
    
    static var h0Title: UIFont {
        return font(.h0Title, .headline)
    }
    
    static var h1Title: UIFont {
        return font(.h1Title, .title1)
    }
    
    static var h2Title: UIFont {
        return font(.h2Title, .title2)
    }
    
    static var h3Title: UIFont {
        return font(.h3Title, .title3)
    }
    
    static var boldTitle: UIFont {
        return UIFont.customBold(size: FontSize.body1.rawValue)
    }
    
    static var body1: UIFont {
        return font(.body1, .body )
    }
    
    static var body1Accent: UIFont {
        return font(.bold, .body1, .body)
    }
    
    static var h3Accent: UIFont {
        return font(.bold, .h3Title, .body)
    }
    
    static var body2: UIFont {
        return font(.body2, .body)
    }
    
    static var body3: UIFont {
        return font(.medium, .body2, .body)
    }
    
    static var caption: UIFont {
        return font(.caption, .caption1)
    }
    
    static var primaryButton: UIFont {
        return font(.body1, .body)
    }
    
    // MARK: - Colors
    
    static var primaryBackground: UIColor {
        return color(.primaryBackground)
    }
    
    static var blueBackground: UIColor {
        return color(.blueBackground)
    }
    
    static var onboardingBackground: UIColor {
        return color(.onboardingBackground)
    }
    
    static var transparentBlue: UIColor {
        return color(.blueBackground).withAlphaComponent(0.4)
    }
    
    static var secondaryBackground: UIColor {
        return color(.secondaryBackground)
    }
    
    static var tertiaryBackground: UIColor {
        return color(.tertiaryBackground)
    }
    
    static var primaryText: UIColor {
        return color(.text)
    }
    
    static var primaryButtonText: UIColor {
        return color(.primaryBackground)
    }
    
    static var secondaryText: UIColor {
        return primaryText.withAlphaComponent(TextAlpha.secondary.rawValue)
    }
    
    static var tertiaryText: UIColor {
        return primaryText.withAlphaComponent(TextAlpha.tertiary.rawValue)
    }
    
    static var accent: UIColor {
        return color(.accent)
    }
    
    static var accentHighlighted: UIColor {
        return color(.accentHighlighted)
    }
    
    static var error: UIColor {
        return color(.error)
    }
    
    static var success: UIColor {
        return color(.success)
    }
    
    // Returns a font with the given size with the default typeface
    private static func font(_ size: FontSize, _ fallbackStyle: UIFont.TextStyle) -> UIFont {
        return font(.book, size, fallbackStyle)
    }

    // Returns a font with the given typeface and size
    private static func font(_ name: FontName, _ size: FontSize, _ fallbackStyle: UIFont.TextStyle) -> UIFont {
        // TODO: This is not proper way of handling fonts. Refactor when rebranding.
        return UIFont.preferredFont(forTextStyle: fallbackStyle)
    }
    
    // Returns a color with the given enum
    private static func color(_ hex: ColorHex) -> UIColor {
        return UIColor(hex: hex.rawValue)
    }
}

struct ThemePreview: View {
    func colorRectangle(color: Color, label: String) -> some View {
        return ZStack {
            Rectangle()
                .fill(color)
            Text(label)
                .font(Font(Theme.h3Title))
                .foregroundColor(Color(Theme.primaryText))
        }
    }
    
    var body: some View {
        VStack {
            Text("h0Title")
                .font(Font(Theme.h0Title))
            Text("h1Title")
                .font(Font(Theme.h1Title))
            Text("h2Title")
                .font(Font(Theme.h2Title))
            Text("h3Title")
                .font(Font(Theme.h3Title))
            Text("body1")
                .font(Font(Theme.body1))
            Text("body2")
                .font(Font(Theme.body2))
            Text("body3")
                .font(Font(Theme.body3))
            Group {
                HStack {
                    self.colorRectangle(color: Color(LightColors.Background.one), label: "primaryBackground")
                    self.colorRectangle(color: Color(LightColors.Background.two), label: "secondaryBackground")
                    self.colorRectangle(color: Color(LightColors.Background.three), label: "tertiaryBackground")
                }
                HStack {
                    self.colorRectangle(color: Color(Theme.accent), label: "accent")
                    self.colorRectangle(color: Color(Theme.accentHighlighted), label: "accentHighlighted")
                }
                HStack {
                    self.colorRectangle(color: Color(Theme.error), label: "error")
                    self.colorRectangle(color: Color(Theme.success), label: "success")
                }
                HStack {
                    self.colorRectangle(color: Color(Theme.primaryText), label: "primaryText")
                    self.colorRectangle(color: Color(LightColors.Text.two), label: "secondaryText")
                    self.colorRectangle(color: Color(Theme.tertiaryText), label: "tertiaryText")
                }.background(Color(LightColors.Background.one))
            }
        }
    }
}

struct Theme_Previews: PreviewProvider {
    static var previews: some View {
        ThemePreview()
    }
}
